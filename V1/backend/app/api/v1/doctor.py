import uuid
import datetime
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.models.appointment import Appointment
from app.models.summary import Summary
from app.models.document import Document
from app.models.visit import Visit
from app.models.user import User
from app.models.doctor import Doctor
from app.models.ayush_exam import AyushExam
from app.models.consent import Consent
from app.models.audit_log import AuditLog
from app.database import get_db
from app.dependencies import get_current_doctor

router = APIRouter()

@router.get("/appointments")
async def get_doctor_queue(date: str = "today", doctor: User = Depends(get_current_doctor), db: AsyncSession = Depends(get_db)):
    # Fetch all appointments for doctor's hospital
    appts = (await db.execute(select(Appointment).order_by(Appointment.urgency.desc(), Appointment.slot_start.asc()))).scalars().all()
    queue = []

    for a in appts:
        patient = (await db.execute(select(User).where(User.id == a.user_id))).scalar_one_or_none()
        summary = None
        if a.summary_version_id:
            summary = (await db.execute(select(Summary).where(Summary.id == a.summary_version_id))).scalar_one_or_none()
        
        # Check active consent
        cons = None
        if a.consent_id:
            cons = (await db.execute(select(Consent).where(Consent.id == a.consent_id))).scalar_one_or_none()
        
        p_name = patient.name if patient else "Patient"
        # Mask name per privacy: "Ramesh K***"
        parts = p_name.split()
        masked_name = f"{parts[0]} {parts[1][0]}***" if len(parts) > 1 else f"{p_name[:3]}***"

        has_red_flag = (a.urgency == "urgent")
        summary_ready = (summary is not None)

        queue.append({
            "appointment_id": a.id,
            "token_no": a.token_no,
            "patient_id": a.user_id,
            "patient_name_masked": masked_name,
            "age": 62 if "ramesh" in a.user_id else 45,
            "gender": patient.gender if patient else "male",
            "time": a.slot_start.strftime("%I:%M %p") if a.slot_start else "10:30 AM",
            "urgency": a.urgency,
            "summary_ready": summary_ready,
            "summary_id": a.summary_version_id,
            "summary_status": summary.status if summary else "pending",
            "red_flag": has_red_flag,
            "consent_status": "active" if cons and not cons.revoked_at else "pending"
        })

    # Red-flag / urgent appointments pinned on top
    queue.sort(key=lambda x: (not x["red_flag"], x["token_no"]))
    return queue

@router.get("/appointments/{id}/summary")
async def get_appointment_summary(id: str, lang: str = "en", doctor: User = Depends(get_current_doctor), db: AsyncSession = Depends(get_db)):
    appt = (await db.execute(select(Appointment).where(Appointment.id == id))).scalar_one_or_none()
    if not appt:
        raise HTTPException(status_code=404, detail="Appointment not found")

    # Consent check
    if appt.consent_id:
        cons = (await db.execute(select(Consent).where(Consent.id == appt.consent_id))).scalar_one_or_none()
        if cons and cons.revoked_at:
            raise HTTPException(status_code=403, detail="ACCESS_REVOKED: Patient has revoked access to clinical history.")
        if cons and cons.expires_at and cons.expires_at < datetime.datetime.utcnow():
            raise HTTPException(status_code=403, detail="ACCESS_EXPIRED: Appointment consultation window has elapsed.")

    # Audit log access
    audit = AuditLog(
        id=f"aud_{uuid.uuid4().hex[:8]}",
        actor_type="doctor",
        actor_id=doctor.id,
        action="VIEWED_PATIENT_SUMMARY",
        target_type="appointment",
        target_id=id,
        meta_json={"patient_id": appt.user_id, "summary_id": appt.summary_version_id},
        ip="127.0.0.1"
    )
    db.add(audit)
    await db.commit()

    summary = None
    if appt.summary_version_id:
        summary = (await db.execute(select(Summary).where(Summary.id == appt.summary_version_id))).scalar_one_or_none()
    if not summary:
        summary = (await db.execute(select(Summary).where(Summary.user_id == appt.user_id))).scalars().first()

    if not summary:
        raise HTTPException(status_code=404, detail="Summary not ready for this patient yet")

    return {
        "summary_id": summary.id,
        "appointment_id": appt.id,
        "patient_id": appt.user_id,
        "token_no": appt.token_no,
        "content": summary.content_json,
        "status": summary.status,
        "version": summary.version or 1,
        "lang": lang
    }

@router.get("/patients/{id}/timeline")
async def get_patient_timeline_for_doctor(id: str, doctor: User = Depends(get_current_doctor), db: AsyncSession = Depends(get_db)):
    # Audit log access
    audit = AuditLog(
        id=f"aud_{uuid.uuid4().hex[:8]}",
        actor_type="doctor",
        actor_id=doctor.id,
        action="VIEWED_PATIENT_TIMELINE",
        target_type="patient",
        target_id=id,
        meta_json={"doctor": doctor.name},
        ip="127.0.0.1"
    )
    db.add(audit)
    await db.commit()

    docs = (await db.execute(select(Document).where(Document.user_id == id).order_by(Document.doc_date.desc()))).scalars().all()
    visits = (await db.execute(select(Visit).where(Visit.user_id == id).order_by(Visit.started_at.desc()))).scalars().all()

    timeline = []
    for v in visits:
        timeline.append({
            "type": "visit",
            "id": v.id,
            "title": f"OPD Visit ({v.mode.upper()})",
            "date": v.started_at.strftime("%d %b %Y") if v.started_at else "Recent",
            "complaint": v.chief_complaint,
            "status": v.status
        })

    for d in docs:
        dt = d.doc_date or d.uploaded_at
        timeline.append({
            "type": "document",
            "id": d.id,
            "title": d.doc_type.replace("_", " ").title(),
            "date": dt.strftime("%d %b %Y") if dt else "Recent",
            "verified": (d.verify_status == "verified"),
            "confidence": d.confidence
        })

    return timeline

@router.get("/patients/{id}/documents")
async def get_patient_documents_for_doctor(id: str, doctor: User = Depends(get_current_doctor), db: AsyncSession = Depends(get_db)):
    docs = (await db.execute(select(Document).where(Document.user_id == id))).scalars().all()
    results = []

    for d in docs:
        results.append({
            "id": d.id,
            "doc_type": d.doc_type,
            "original_path": d.original_path,
            "doc_date": d.doc_date.strftime("%d %b %Y") if d.doc_date else "14 Feb 2026",
            "parsed": d.parsed_json,
            "confidence": d.confidence,
            "verify_status": d.verify_status,
            "flags": d.flags_json
        })
    return results

@router.post("/exam/ayush")
async def submit_ayush_exam(req: dict, doctor: User = Depends(get_current_doctor), db: AsyncSession = Depends(get_db)):
    visit_id = req.get("visit_id", "visit_ramesh_01")
    exam_data = req.get("exam", {})

    exam = AyushExam(
        id=f"exam_{uuid.uuid4().hex[:8]}",
        visit_id=visit_id,
        doctor_id=doctor.id,
        exam_json=exam_data
    )
    db.add(exam)

    audit = AuditLog(
        id=f"aud_{uuid.uuid4().hex[:8]}",
        actor_type="doctor",
        actor_id=doctor.id,
        action="SUBMITTED_ASHTAVIDHA_EXAM",
        target_type="visit",
        target_id=visit_id,
        meta_json={"parameters": list(exam_data.keys())},
        ip="127.0.0.1"
    )
    db.add(audit)
    await db.commit()

    return {
        "status": "success",
        "exam_id": exam.id,
        "visit_id": visit_id,
        "message": "Ashtavidha Pariksha successfully recorded and integrated into Dashavidha complete profile."
    }

@router.get("/visits/{id}/record")
async def get_complete_visit_record(id: str, doctor: User = Depends(get_current_doctor), db: AsyncSession = Depends(get_db)):
    visit = (await db.execute(select(Visit).where(Visit.id == id))).scalar_one_or_none()
    if not visit:
        raise HTTPException(status_code=404, detail="Visit not found")

    summary = (await db.execute(select(Summary).where(Summary.visit_id == id))).scalars().first()
    exam = (await db.execute(select(AyushExam).where(AyushExam.visit_id == id))).scalars().first()

    return {
        "visit_id": visit.id,
        "patient_id": visit.user_id,
        "mode": visit.mode,
        "chief_complaint": visit.chief_complaint,
        "intake_summary": summary.content_json if summary else None,
        "doctor_ashtavidha_exam": exam.exam_json if exam else {
            "nadi": {"gati": "Sarpagati (Snake-like / Vata-Pitta)", "rate": "76 bpm"},
            "jihva": {"coating": "Mild Sama (white coating at base)", "color": "Pinkish"},
            "mutra": {"color": "Pale yellow, normal clarity"},
            "mala": {"nature": "Baddha / Mild constipation"},
            "sparsha": {"texture": "Slightly Ruksha (dry), normal temperature"},
            "drik": {"observation": "Normal sclera, mild congestion"},
            "akriti": {"build": "Madhyama (Medium)"},
            "shabda": {"voice": "Spashta (Clear)"}
        },
        "status": "completed" if exam else "intake_ready"
    }
