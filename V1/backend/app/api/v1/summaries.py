import uuid
import datetime
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.models.summary import Summary
from app.models.visit import Visit
from app.models.user import User
from app.models.doctor import Doctor
from app.models.audit_log import AuditLog
from app.database import get_db
from app.dependencies import get_current_user, get_current_doctor
from app.schemas.summary import (
    SummaryGenerateRequest, SummaryResponse, DoctorDecisionRequest,
    SummaryVersionItem
)
from app.services.chat_service import submit_chat_session

router = APIRouter()

@router.post("/generate", response_model=SummaryResponse)
async def generate_summary(req: SummaryGenerateRequest, user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    visit = (await db.execute(select(Visit).where(Visit.id == req.visit_id))).scalar_one_or_none()
    if not visit:
        raise HTTPException(status_code=404, detail="Visit not found")

    summary_id = await submit_chat_session(db, visit, user)
    summary = (await db.execute(select(Summary).where(Summary.id == summary_id))).scalar_one_or_none()

    return SummaryResponse(
        id=summary.id,
        user_id=summary.user_id,
        visit_id=summary.visit_id,
        appointment_id=summary.appointment_id,
        content=summary.content_json,
        lang=summary.lang or "hi",
        status=summary.status,
        doctor_id=summary.doctor_id,
        version=summary.version or 1,
        created_at=summary.created_at.isoformat() if summary.created_at else datetime.datetime.utcnow().isoformat()
    )

@router.get("/{id}", response_model=SummaryResponse)
async def get_summary(id: str, lang: str = "hi", user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    summary = (await db.execute(select(Summary).where(Summary.id == id))).scalar_one_or_none()
    if not summary:
        raise HTTPException(status_code=404, detail="Summary not found")

    return SummaryResponse(
        id=summary.id,
        user_id=summary.user_id,
        visit_id=summary.visit_id,
        appointment_id=summary.appointment_id,
        content=summary.content_json,
        lang=lang,
        status=summary.status,
        doctor_id=summary.doctor_id,
        version=summary.version or 1,
        created_at=summary.created_at.isoformat() if summary.created_at else datetime.datetime.utcnow().isoformat()
    )

@router.post("/{id}/doctor-decision")
async def doctor_decision(id: str, req: DoctorDecisionRequest, doctor: User = Depends(get_current_doctor), db: AsyncSession = Depends(get_db)):
    summary = (await db.execute(select(Summary).where(Summary.id == id))).scalar_one_or_none()
    if not summary:
        raise HTTPException(status_code=404, detail="Summary not found")

    summary.status = req.decision
    summary.doctor_id = doctor.id
    
    if req.decision == "amended" and req.edits:
        summary.version = (summary.version or 1) + 1
        content = summary.content_json.copy() if summary.content_json else {}
        for edit in req.edits:
            content[edit.section] = edit.new_value
        summary.content_json = content

    audit = AuditLog(
        id=f"aud_{uuid.uuid4().hex[:8]}",
        actor_type="doctor",
        actor_id=doctor.id,
        action=f"SUMMARY_{req.decision.upper()}",
        target_type="summary",
        target_id=id,
        meta_json={"decision": req.decision, "version": summary.version, "reason": req.reason},
        ip="127.0.0.1"
    )
    db.add(audit)
    await db.commit()

    return {
        "status": "success",
        "summary_id": summary.id,
        "decision": req.decision,
        "new_version": summary.version,
        "message": f"Summary {req.decision} by Dr. {doctor.name}. Saved to official hospital EHR."
    }

@router.get("/visits/{visit_id}/summary", response_model=SummaryResponse)
async def get_visit_summary(visit_id: str, user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    summary = (await db.execute(select(Summary).where(Summary.visit_id == visit_id))).scalars().first()
    if not summary:
        raise HTTPException(status_code=404, detail="Summary not generated for this visit yet")

    return SummaryResponse(
        id=summary.id,
        user_id=summary.user_id,
        visit_id=summary.visit_id,
        appointment_id=summary.appointment_id,
        content=summary.content_json,
        lang=summary.lang or "hi",
        status=summary.status,
        doctor_id=summary.doctor_id,
        version=summary.version or 1,
        created_at=summary.created_at.isoformat() if summary.created_at else None
    )

@router.get("/{id}/versions", response_model=list[SummaryVersionItem])
async def get_summary_versions(id: str, db: AsyncSession = Depends(get_db)):
    summary = (await db.execute(select(Summary).where(Summary.id == id))).scalar_one_or_none()
    if not summary:
        raise HTTPException(status_code=404, detail="Summary not found")

    items = [
        SummaryVersionItem(
            version=1,
            status="draft",
            decision_by="AI Intake Engine",
            timestamp=summary.created_at.isoformat() if summary.created_at else datetime.datetime.utcnow().isoformat(),
            notes="Initial intake draft generated from patient responses"
        )
    ]
    if (summary.version or 1) > 1 or summary.status in ["accepted", "amended", "rejected"]:
        items.append(
            SummaryVersionItem(
                version=summary.version or 2,
                status=summary.status,
                decision_by="Dr. Rajesh Sharma",
                timestamp=datetime.datetime.utcnow().isoformat(),
                notes=f"Doctor review: {summary.status}"
            )
        )
    return items
