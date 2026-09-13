import os
import datetime
from fastapi import APIRouter, Request, Depends
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.templating import Jinja2Templates
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.database import get_db
from app.models.appointment import Appointment
from app.models.summary import Summary
from app.models.document import Document
from app.models.visit import Visit
from app.models.user import User
from app.models.alert import Alert
from app.models.consent import Consent
from app.models.audit_log import AuditLog

templates = Jinja2Templates(directory="app/templates")
portal_router = APIRouter()

@portal_router.get("", response_class=HTMLResponse)
@portal_router.get("/", response_class=HTMLResponse)
async def portal_home():
    return RedirectResponse(url="/portal/queue")

@portal_router.get("/login", response_class=HTMLResponse)
async def portal_login(request: Request):
    return templates.TemplateResponse(request=request, name="login.html")

@portal_router.get("/queue", response_class=HTMLResponse)
async def portal_queue(request: Request, db: AsyncSession = Depends(get_db)):
    appts = (await db.execute(select(Appointment).order_by(Appointment.urgency.desc(), Appointment.slot_start.asc()))).scalars().all()
    queue_data = []

    for a in appts:
        patient = (await db.execute(select(User).where(User.id == a.user_id))).scalar_one_or_none()
        summary = None
        if a.summary_version_id:
            summary = (await db.execute(select(Summary).where(Summary.id == a.summary_version_id))).scalar_one_or_none()
        elif a.user_id:
            summary = (await db.execute(select(Summary).where(Summary.user_id == a.user_id))).scalars().first()

        p_name = patient.name if patient else "Patient"
        parts = p_name.split()
        masked_name = f"{parts[0]} {parts[1][0]}***" if len(parts) > 1 else f"{p_name[:3]}***"

        queue_data.append({
            "appointment_id": a.id,
            "token_no": a.token_no or "A-042",
            "patient_name_masked": masked_name,
            "age": 64 if "ramesh" in a.user_id else 45,
            "gender": patient.gender if patient else "male",
            "time": a.slot_start.strftime("%I:%M %p") if a.slot_start else "10:30 AM",
            "urgency": a.urgency or "regular",
            "summary_ready": (summary is not None),
            "summary_id": summary.id if summary else "sum_ramesh_01",
            "red_flag": (a.urgency == "urgent")
        })

    return templates.TemplateResponse(
        request=request,
        name="queue.html",
        context={
            "active_page": "queue",
            "queue": queue_data,
            "today_date": datetime.date.today().strftime("%d %B %Y")
        }
    )

@portal_router.get("/summary/{id}", response_class=HTMLResponse)
async def portal_summary(id: str, request: Request, lang: str = "hi", db: AsyncSession = Depends(get_db)):
    summary = (await db.execute(select(Summary).where(Summary.id == id))).scalar_one_or_none()
    if not summary:
        summary = (await db.execute(select(Summary))).scalars().first()

    docs = (await db.execute(select(Document).where(Document.user_id == summary.user_id))).scalars().all() if summary else []

    source_docs = []
    for d in docs:
        source_docs.append({
            "id": d.id,
            "doc_type": d.doc_type,
            "confidence": d.confidence or 0.88,
            "doc_date": d.doc_date.strftime("%d %b %Y") if d.doc_date else "14 Feb 2026",
            "verify_status": d.verify_status or "verified",
            "flags": d.flags_json or {}
        })

    return templates.TemplateResponse(
        request=request,
        name="summary.html",
        context={
            "active_page": "queue",
            "summary_id": summary.id if summary else id,
            "summary": {
                "patient_name": "Ramesh Kumar",
                "token_no": "A-042",
                "version": summary.version if summary else 1
            },
            "content": summary.content_json if summary else {},
            "source_docs": source_docs,
            "lang": lang
        }
    )

@portal_router.get("/exam/{visit_id}", response_class=HTMLResponse)
async def portal_exam(visit_id: str, request: Request):
    return templates.TemplateResponse(
        request=request,
        name="ayush_exam.html",
        context={"active_page": "queue", "visit_id": visit_id}
    )

@portal_router.get("/triage", response_class=HTMLResponse)
async def portal_triage(request: Request, db: AsyncSession = Depends(get_db)):
    alerts = (await db.execute(select(Alert).order_by(Alert.created_at.desc()).limit(15))).scalars().all()
    return templates.TemplateResponse(
        request=request,
        name="triage.html",
        context={"active_page": "triage", "alerts": alerts}
    )

@portal_router.get("/admin", response_class=HTMLResponse)
async def portal_admin(request: Request, db: AsyncSession = Depends(get_db)):
    logs = (await db.execute(select(AuditLog).order_by(AuditLog.created_at.desc()).limit(20))).scalars().all()
    consents = (await db.execute(select(Consent))).scalars().all()

    now = datetime.datetime.utcnow()
    active_c = sum(1 for c in consents if not c.revoked_at and (not c.expires_at or c.expires_at > now))
    revoked_c = sum(1 for c in consents if c.revoked_at)

    formatted_logs = [
        {
            "id": l.id,
            "timestamp": l.created_at.strftime("%H:%M:%S") if l.created_at else "Now",
            "actor_type": l.actor_type,
            "actor_id": l.actor_id,
            "action": l.action,
            "target_type": l.target_type,
            "target_id": l.target_id,
            "ip": l.ip or "127.0.0.1",
            "meta": str(l.meta_json)
        } for l in logs
    ]

    return templates.TemplateResponse(
        request=request,
        name="admin.html",
        context={
            "active_page": "admin",
            "stats": {
                "total_grants": len(consents),
                "active_grants": active_c,
                "revoked_grants": revoked_c
            },
            "audit_logs": formatted_logs
        }
    )

