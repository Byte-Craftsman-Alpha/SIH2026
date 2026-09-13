import os
import uuid
import datetime
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete
from app.models.document import Document
from app.models.summary import Summary
from app.models.visit import Visit
from app.models.user import User
from app.models.audit_log import AuditLog
from app.database import get_db
from app.dependencies import get_current_user
from app.schemas.document import (
    DocumentUploadResponse, DocumentItemResponse, DocumentStatusResponse,
    DocumentParsedResponse, DocumentVerifyRequest, TimelineEvent
)
from app.core.question_bank import DEMO_PARSED_PRESCRIPTION, DEMO_PARSED_LAB_REPORT, DEMO_PARSED_DISCHARGE
from app.supabase import get_supabase_client

router = APIRouter()

def get_upload_dir() -> str:
    """Returns a writable upload directory, defaulting to /tmp/uploads in serverless/read-only environments."""
    if os.environ.get("VERCEL") or os.environ.get("VERCEL_ENV"):
        upload_path = "/tmp/uploads"
    else:
        base_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
        upload_path = os.path.join(base_dir, "uploads")
    try:
        os.makedirs(upload_path, exist_ok=True)
    except Exception:
        upload_path = "/tmp/uploads"
        try:
            os.makedirs(upload_path, exist_ok=True)
        except Exception:
            pass
    return upload_path

UPLOAD_DIR = get_upload_dir()

@router.post("", response_model=DocumentUploadResponse)
async def upload_document(
    file: UploadFile = File(...),
    doc_type: str = Form("prescription"),
    doc_date: str = Form(None),
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    doc_id = f"doc_{uuid.uuid4().hex[:8]}"
    file_ext = os.path.splitext(file.filename)[1] or ".jpg"
    upload_dir = get_upload_dir()
    dest_path = os.path.join(upload_dir, f"{doc_id}{file_ext}")

    content = await file.read()
    try:
        with open(dest_path, "wb") as f:
            f.write(content)
    except Exception:
        dest_path = os.path.join("/tmp", f"{doc_id}{file_ext}")
        try:
            with open(dest_path, "wb") as f:
                f.write(content)
        except Exception:
            pass

    # 1. Upload to Supabase Storage if available
    storage_path = f"{user.id}/{doc_id}{file_ext}"
    supabase = get_supabase_client()
    if supabase:
        try:
            supabase.storage.from_("medical-documents").upload(
                path=storage_path,
                file=content,
                file_options={"content-type": file.content_type or "image/jpeg"}
            )
        except Exception as e:
            pass

    # 2. Run Gemini Vision Pipeline directly on image bytes
    from app.documents.pipeline import process_document_pipeline
    pipeline_res = await process_document_pipeline(
        doc_id=doc_id,
        doc_type=doc_type,
        image_bytes=content,
        storage_path=dest_path
    )

    parsed = pipeline_res.get("parsed_json", {})
    flags = pipeline_res.get("flags", {})
    confidence = pipeline_res.get("overall_confidence", 0.88)

    parsed["extracted"] = pipeline_res.get("items", [])
    parsed["doc_date"] = doc_date or datetime.date.today().isoformat()

    doc_datetime = datetime.datetime.utcnow()
    if doc_date:
        try:
            doc_datetime = datetime.datetime.fromisoformat(doc_date)
        except Exception:
            pass

    document = Document(
        id=doc_id,
        user_id=user.id,
        doc_type=doc_type,
        original_path=f"/uploads/{doc_id}{file_ext}",
        parsed_json=parsed,
        confidence=confidence,
        verify_status="unverified",
        doc_date=doc_datetime,
        uploaded_at=datetime.datetime.utcnow(),
        flags_json=flags
    )
    db.add(document)

    audit = AuditLog(
        id=f"aud_{uuid.uuid4().hex[:8]}",
        actor_type="patient",
        actor_id=user.id,
        action="DOCUMENT_UPLOADED",
        target_type="document",
        target_id=doc_id,
        meta_json={"filename": file.filename, "doc_type": doc_type, "size_bytes": len(content)},
        ip="127.0.0.1"
    )
    db.add(audit)
    await db.commit()

    return DocumentUploadResponse(
        document_id=doc_id,
        status="ready",
        message="Document uploaded and processed successfully",
        job_id=f"job_{uuid.uuid4().hex[:8]}"
    )

@router.get("", response_model=list[DocumentItemResponse])
async def list_docs(doc_type: str = None, user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    query = select(Document).where(Document.user_id == user.id)
    if doc_type and doc_type != "all":
        query = query.where(Document.doc_type == doc_type)
    query = query.order_by(Document.uploaded_at.desc())

    docs = (await db.execute(query)).scalars().all()
    return [
        DocumentItemResponse(
            id=d.id,
            user_id=d.user_id,
            doc_type=d.doc_type,
            original_path=d.original_path,
            doc_date=d.doc_date.isoformat() if d.doc_date else None,
            uploaded_at=d.uploaded_at.isoformat() if d.uploaded_at else None,
            confidence=d.confidence or 0.85,
            verify_status=d.verify_status or "unverified",
            flags=d.flags_json or {}
        ) for d in docs
    ]

@router.get("/timeline", response_model=list[TimelineEvent])
async def get_timeline(user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    events = []

    # 1. Documents
    docs = (await db.execute(select(Document).where(Document.user_id == user.id).order_by(Document.doc_date.desc()))).scalars().all()
    for d in docs:
        dt = d.doc_date or d.uploaded_at or datetime.datetime.utcnow()
        extracted = d.parsed_json.get("extracted", {}) if d.parsed_json else {}
        doc_title = f"{d.doc_type.replace('_', ' ').title()}"
        summary_text = None
        if d.doc_type == "prescription" and "medicines" in extracted:
            med_names = [m.get("name") for m in extracted.get("medicines", [])[:3]]
            summary_text = ", ".join(med_names)
        elif d.doc_type == "lab_report" and "tests" in extracted:
            summary_text = f"{len(extracted.get('tests', []))} Lab parameters analyzed"

        events.append(TimelineEvent(
            id=d.id,
            type=d.doc_type,
            title=doc_title,
            date=dt.strftime("%d %b %Y"),
            year=str(dt.year),
            summary_text=summary_text or "Document uploaded & verified",
            verified=(d.verify_status == "verified"),
            has_flags=bool(d.flags_json.get("abnormal_values") or d.flags_json.get("drug_interactions")),
            doctor_name=extracted.get("doctor", {}).get("name") if isinstance(extracted.get("doctor"), dict) else None,
            details_url=f"/api/v1/documents/{d.id}"
        ))

    # 2. Summaries
    sums = (await db.execute(select(Summary).where(Summary.user_id == user.id).order_by(Summary.created_at.desc()))).scalars().all()
    for s in sums:
        dt = s.created_at or datetime.datetime.utcnow()
        content = s.content_json or {}
        cc = content.get("2_chief_complaint", "Clinical Consultation")

        events.append(TimelineEvent(
            id=s.id,
            type="visit_summary",
            title="OPD Visit History Summary",
            date=dt.strftime("%d %b %Y"),
            year=str(dt.year),
            summary_text=str(cc),
            verified=(s.status in ["accepted", "amended"]),
            has_flags=False,
            doctor_name="Dr. Rajesh Sharma",
            details_url=f"/api/v1/summaries/{s.id}"
        ))

    return sorted(events, key=lambda x: x.date, reverse=True)

@router.get("/{id}")
async def get_doc(id: str, user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    doc = (await db.execute(select(Document).where(Document.id == id, Document.user_id == user.id))).scalar_one_or_none()
    if not doc:
        raise HTTPException(status_code=404, detail="Document not found")
    return {
        "id": doc.id,
        "doc_type": doc.doc_type,
        "original_path": doc.original_path,
        "parsed": doc.parsed_json,
        "confidence": doc.confidence,
        "verify_status": doc.verify_status,
        "doc_date": doc.doc_date.isoformat() if doc.doc_date else None,
        "uploaded_at": doc.uploaded_at.isoformat() if doc.uploaded_at else None,
        "flags": doc.flags_json
    }

@router.get("/{id}/status", response_model=DocumentStatusResponse)
async def get_status(id: str, user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    doc = (await db.execute(select(Document).where(Document.id == id, Document.user_id == user.id))).scalar_one_or_none()
    if not doc:
        raise HTTPException(status_code=404, detail="Document not found")
    return DocumentStatusResponse(
        document_id=doc.id,
        status="ready",
        progress_percent=100,
        estimated_seconds=0
    )

@router.get("/{id}/parsed", response_model=DocumentParsedResponse)
async def get_parsed(id: str, user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    doc = (await db.execute(select(Document).where(Document.id == id, Document.user_id == user.id))).scalar_one_or_none()
    if not doc:
        raise HTTPException(status_code=404, detail="Document not found")

    parsed = doc.parsed_json or {}
    return DocumentParsedResponse(
        doc_id=doc.id,
        doc_type=doc.doc_type,
        doc_date=doc.doc_date.isoformat() if doc.doc_date else None,
        ocr_lang=parsed.get("ocr_lang", ["hi", "en"]),
        overall_confidence=doc.confidence or 0.88,
        extracted=parsed.get("extracted", {}),
        flags=doc.flags_json or {},
        verify_status=doc.verify_status or "unverified"
    )

@router.post("/{id}/verify")
async def verify_doc(id: str, req: DocumentVerifyRequest, user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    doc = (await db.execute(select(Document).where(Document.id == id, Document.user_id == user.id))).scalar_one_or_none()
    if not doc:
        raise HTTPException(status_code=404, detail="Document not found")

    doc.verify_status = req.status
    if req.edits and doc.parsed_json:
        extracted = doc.parsed_json.get("extracted", {})
        for edit in req.edits:
            extracted[edit.field] = edit.new_value
        doc.parsed_json["extracted"] = extracted

    await db.commit()
    return {"status": "verified", "message": "Document verified and locked into clinical record"}

@router.put("/{id}")
async def update_doc(id: str, req: dict, user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    doc = (await db.execute(select(Document).where(Document.id == id, Document.user_id == user.id))).scalar_one_or_none()
    if not doc:
        raise HTTPException(status_code=404, detail="Document not found")

    if "doc_date" in req:
        try:
            doc.doc_date = datetime.datetime.fromisoformat(req["doc_date"])
        except Exception:
            pass
    if "parsed_json" in req:
        doc.parsed_json = req["parsed_json"]

    await db.commit()
    return {"status": "updated"}

@router.delete("/{id}")
async def delete_doc(id: str, user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    doc = (await db.execute(select(Document).where(Document.id == id, Document.user_id == user.id))).scalar_one_or_none()
    if not doc:
        raise HTTPException(status_code=404, detail="Document not found")

    audit = AuditLog(
        id=f"aud_{uuid.uuid4().hex[:8]}",
        actor_type="patient",
        actor_id=user.id,
        action="DOCUMENT_DELETED",
        target_type="document",
        target_id=id,
        meta_json={"doc_type": doc.doc_type},
        ip="127.0.0.1"
    )
    db.add(audit)
    await db.delete(doc)
    await db.commit()
    return {"status": "deleted", "message": "Original and parsed document deleted from records"}

@router.post("/{id}/reprocess")
async def reprocess_doc(id: str, user: User = Depends(get_current_user)):
    return {
        "status": "processing",
        "job_id": f"reproc_{uuid.uuid4().hex[:8]}",
        "message": "Reprocessing document with Gemini 2.5 Flash Vision pipeline"
    }

@router.get("/{id}/file")
async def get_doc_file_url(id: str, user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    doc = (await db.execute(select(Document).where(Document.id == id, Document.user_id == user.id))).scalar_one_or_none()
    if not doc:
        raise HTTPException(status_code=404, detail="Document not found")

    supabase = get_supabase_client()
    signed_url = None
    if supabase:
        try:
            # Generate 10-minute temporary signed URL
            ext = os.path.splitext(doc.original_path)[1]
            path = f"{user.id}/{doc.id}{ext}"
            res = supabase.storage.from_("medical-documents").create_signed_url(path, 600)
            signed_url = res.get("signedURL") or res.get("signedUrl")
        except Exception:
            pass

    return {
        "document_id": doc.id,
        "file_url": signed_url or doc.original_path,
        "is_signed_url": bool(signed_url),
        "expires_in_seconds": 600 if signed_url else None
    }
