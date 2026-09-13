import csv
import io
import datetime
from fastapi import APIRouter, Depends, HTTPException, Response
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.models.audit_log import AuditLog
from app.models.consent import Consent
from app.models.user import User
from app.database import get_db, init_db
from app.seed.seed_data import seed_demo_data

router = APIRouter()

@router.get("/audit")
async def get_audit_logs(actor: str = None, action: str = None, limit: int = 50, db: AsyncSession = Depends(get_db)):
    query = select(AuditLog).order_by(AuditLog.created_at.desc()).limit(limit)
    if action:
        query = query.where(AuditLog.action.ilike(f"%{action}%"))
    if actor:
        query = query.where(AuditLog.actor_id == actor)

    logs = (await db.execute(query)).scalars().all()
    return [
        {
            "id": l.id,
            "actor_type": l.actor_type,
            "actor_id": l.actor_id,
            "action": l.action,
            "target_type": l.target_type,
            "target_id": l.target_id,
            "meta": l.meta_json,
            "ip": l.ip,
            "timestamp": l.created_at.isoformat() if l.created_at else datetime.datetime.utcnow().isoformat()
        } for l in logs
    ]

@router.get("/audit/export")
async def export_audit_csv(db: AsyncSession = Depends(get_db)):
    logs = (await db.execute(select(AuditLog).order_by(AuditLog.created_at.desc()))).scalars().all()
    
    output = io.StringIO()
    writer = csv.writer(output)
    writer.writerow(["ID", "Timestamp", "Actor Type", "Actor ID", "Action", "Target Type", "Target ID", "IP Address", "Metadata"])

    for l in logs:
        ts = l.created_at.isoformat() if l.created_at else ""
        writer.writerow([l.id, ts, l.actor_type, l.actor_id, l.action, l.target_type, l.target_id, l.ip, str(l.meta_json)])

    content = output.getvalue()
    return Response(
        content=content,
        media_type="text/csv",
        headers={"Content-Disposition": "attachment; filename=medikiosk_audit_trail.csv"}
    )

@router.get("/consents")
async def get_consent_ledger(db: AsyncSession = Depends(get_db)):
    consents = (await db.execute(select(Consent).order_by(Consent.granted_at.desc()))).scalars().all()
    now = datetime.datetime.utcnow()

    total = len(consents)
    active = sum(1 for c in consents if not c.revoked_at and (not c.expires_at or c.expires_at > now))
    revoked = sum(1 for c in consents if c.revoked_at)
    expired = sum(1 for c in consents if not c.revoked_at and c.expires_at and c.expires_at <= now)

    return {
        "summary": {
            "total_grants": total,
            "active_grants": active,
            "revoked_grants": revoked,
            "expired_grants": expired,
            "compliance_standard": "ABDM Consent Artifact v1.2 / DPDP Act 2023"
        },
        "records": [
            {
                "id": c.id,
                "user_id": c.user_id,
                "scope": c.scope,
                "purpose": c.purpose,
                "target_type": c.target_type,
                "target_id": c.target_id,
                "granted_at": c.granted_at.isoformat() if c.granted_at else "",
                "expires_at": c.expires_at.isoformat() if c.expires_at else "",
                "revoked_at": c.revoked_at.isoformat() if c.revoked_at else None,
                "audio_flag": c.audio_flag
            } for c in consents[:30]
        ]
    }

@router.post("/demo/reset")
async def reset_demo(db: AsyncSession = Depends(get_db)):
    await seed_demo_data(db)
    return {"status": "success", "message": "Demo fixtures reset and verified."}
