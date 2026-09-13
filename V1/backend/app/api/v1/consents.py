import uuid
import datetime
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.models.consent import Consent
from app.models.user import User
from app.models.doctor import Doctor
from app.models.audit_log import AuditLog
from app.database import get_db
from app.dependencies import get_current_user
from app.schemas.consent import ConsentGrantRequest, ConsentItemResponse

router = APIRouter()

def get_consent_status(c: Consent) -> str:
    now = datetime.datetime.utcnow()
    if c.revoked_at:
        return "revoked"
    if c.expires_at and c.expires_at < now:
        return "expired"
    return "active"

@router.post("", response_model=ConsentItemResponse, status_code=status.HTTP_201_CREATED)
async def grant_consent(req: ConsentGrantRequest, user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    cons_id = f"cons_{uuid.uuid4().hex[:8]}"
    now = datetime.datetime.utcnow()
    expires_at = now + datetime.timedelta(hours=4)
    if req.expires_at:
        try:
            expires_at = datetime.datetime.fromisoformat(req.expires_at)
        except Exception:
            pass

    consent = Consent(
        id=cons_id,
        user_id=user.id,
        scope=req.scope,
        purpose=req.purpose,
        target_type=req.target_type,
        target_id=req.target_id,
        appointment_id=req.appointment_id,
        granted_at=now,
        expires_at=expires_at,
        revoked_at=None,
        consent_version=1,
        audio_flag=req.audio_flag
    )
    db.add(consent)

    audit = AuditLog(
        id=f"aud_{uuid.uuid4().hex[:8]}",
        actor_type="patient",
        actor_id=user.id,
        action="CONSENT_GRANTED",
        target_type="consent",
        target_id=cons_id,
        meta_json={"scope": req.scope, "target": req.target_id, "purpose": req.purpose},
        ip="127.0.0.1"
    )
    db.add(audit)
    await db.commit()

    return ConsentItemResponse(
        id=consent.id,
        user_id=consent.user_id,
        scope=consent.scope,
        purpose=consent.purpose,
        target_type=consent.target_type,
        target_id=consent.target_id,
        target_name="Dr. Rajesh Sharma" if "doc" in consent.target_id else consent.target_id,
        appointment_id=consent.appointment_id,
        granted_at=consent.granted_at.isoformat(),
        expires_at=consent.expires_at.isoformat(),
        revoked_at=None,
        status="active",
        consent_version=consent.consent_version,
        audio_flag=consent.audio_flag
    )

@router.get("", response_model=list[ConsentItemResponse])
async def list_consents(status_filter: str = None, user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    query = select(Consent).where(Consent.user_id == user.id).order_by(Consent.granted_at.desc())
    consents = (await db.execute(query)).scalars().all()
    results = []

    for c in consents:
        c_status = get_consent_status(c)
        if status_filter and c_status != status_filter:
            continue
        
        target_name = "Dr. Rajesh Sharma" if "doc" in c.target_id else "Healthcare Staff"
        results.append(
            ConsentItemResponse(
                id=c.id,
                user_id=c.user_id,
                scope=c.scope,
                purpose=c.purpose,
                target_type=c.target_type,
                target_id=c.target_id,
                target_name=target_name,
                appointment_id=c.appointment_id,
                granted_at=c.granted_at.isoformat() if c.granted_at else "",
                expires_at=c.expires_at.isoformat() if c.expires_at else "",
                revoked_at=c.revoked_at.isoformat() if c.revoked_at else None,
                status=c_status,
                consent_version=c.consent_version or 1,
                audio_flag=c.audio_flag or False
            )
        )
    return results

@router.get("/active", response_model=list[ConsentItemResponse])
async def active_consents(user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    now = datetime.datetime.utcnow()
    query = select(Consent).where(
        Consent.user_id == user.id,
        Consent.revoked_at.is_(None),
        Consent.expires_at > now
    )
    consents = (await db.execute(query)).scalars().all()
    return [
        ConsentItemResponse(
            id=c.id,
            user_id=c.user_id,
            scope=c.scope,
            purpose=c.purpose,
            target_type=c.target_type,
            target_id=c.target_id,
            target_name="Dr. Rajesh Sharma" if "doc" in c.target_id else "Doctor / Clinic",
            appointment_id=c.appointment_id,
            granted_at=c.granted_at.isoformat(),
            expires_at=c.expires_at.isoformat(),
            revoked_at=None,
            status="active",
            consent_version=c.consent_version or 1,
            audio_flag=c.audio_flag or False
        ) for c in consents
    ]

@router.post("/{id}/revoke")
async def revoke_consent(id: str, user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    consent = (await db.execute(select(Consent).where(Consent.id == id, Consent.user_id == user.id))).scalar_one_or_none()
    if not consent:
        raise HTTPException(status_code=404, detail="Consent grant not found")

    consent.revoked_at = datetime.datetime.utcnow()

    audit = AuditLog(
        id=f"aud_{uuid.uuid4().hex[:8]}",
        actor_type="patient",
        actor_id=user.id,
        action="CONSENT_REVOKED",
        target_type="consent",
        target_id=id,
        meta_json={"revoked_early": True, "reason": "User revoked via Settings"},
        ip="127.0.0.1"
    )
    db.add(audit)
    await db.commit()

    return {
        "status": "revoked",
        "consent_id": id,
        "revoked_at": consent.revoked_at.isoformat(),
        "message": "Consent revoked successfully. Clinical access terminated."
    }

@router.get("/{id}", response_model=ConsentItemResponse)
async def get_consent(id: str, user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    c = (await db.execute(select(Consent).where(Consent.id == id, Consent.user_id == user.id))).scalar_one_or_none()
    if not c:
        raise HTTPException(status_code=404, detail="Consent not found")

    return ConsentItemResponse(
        id=c.id,
        user_id=c.user_id,
        scope=c.scope,
        purpose=c.purpose,
        target_type=c.target_type,
        target_id=c.target_id,
        target_name="Dr. Rajesh Sharma" if "doc" in c.target_id else c.target_id,
        appointment_id=c.appointment_id,
        granted_at=c.granted_at.isoformat() if c.granted_at else "",
        expires_at=c.expires_at.isoformat() if c.expires_at else "",
        revoked_at=c.revoked_at.isoformat() if c.revoked_at else None,
        status=get_consent_status(c),
        consent_version=c.consent_version or 1,
        audio_flag=c.audio_flag or False
    )
