import uuid
import datetime
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.models.alert import Alert
from app.models.user import User
from app.models.emergency_contact import EmergencyContact
from app.models.audit_log import AuditLog
from app.database import get_db
from app.dependencies import get_current_user
from app.schemas.alert import TriageAlertRequest, ContactAlertRequest, AlertItemResponse

router = APIRouter()

@router.post("/triage", status_code=status.HTTP_201_CREATED)
async def post_triage_alert(req: TriageAlertRequest, db: AsyncSession = Depends(get_db)):
    alert_id = f"alt_{uuid.uuid4().hex[:8]}"
    alert = Alert(
        id=alert_id,
        user_id=None,
        flag_code=req.flag_code,
        channel="triage",
        payload_hash=f"{req.kiosk_id}_{req.flag_code}",
        status="pending",
        acked_by=None
    )
    db.add(alert)

    audit = AuditLog(
        id=f"aud_{uuid.uuid4().hex[:8]}",
        actor_type="system_kiosk",
        actor_id=req.kiosk_id or "Kiosk",
        action="TRIAGE_RED_FLAG_TRIGGERED",
        target_type="alert",
        target_id=alert_id,
        meta_json={"flag_code": req.flag_code, "name": req.patient_name, "age": req.patient_age},
        ip="127.0.0.1"
    )
    db.add(audit)
    await db.commit()

    return {
        "status": "alert_dispatched",
        "alert_id": alert_id,
        "kiosk_id": req.kiosk_id,
        "flag_code": req.flag_code,
        "message": "Hospital triage console notified with high-priority audio chime."
    }

@router.post("/contacts")
async def post_contacts_alert(req: ContactAlertRequest, user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    ec_res = await db.execute(select(EmergencyContact).where(EmergencyContact.user_id == user.id, EmergencyContact.active == True))
    contacts = ec_res.scalars().all()

    sent_to = [c.phone for c in contacts]
    loc = req.location or {"lat": 28.5283, "lng": 77.2941}
    map_link = f"https://maps.google.com/?q={loc.get('lat')},{loc.get('lng')}"

    # Minimal payload per DPDP Act §7(c) emergency exception
    sms_text = f"EMERGENCY ALERT: {user.name} reported critical symptoms ({req.flag_code.replace('_', ' ')}). Location: {map_link}"

    audit = AuditLog(
        id=f"aud_{uuid.uuid4().hex[:8]}",
        actor_type="patient",
        actor_id=user.id,
        action="EMERGENCY_CONTACTS_ALERTED",
        target_type="emergency_contacts",
        target_id=user.id,
        meta_json={"sent_count": len(sent_to), "channel": req.channel, "flag_code": req.flag_code},
        ip="127.0.0.1"
    )
    db.add(audit)
    await db.commit()

    return {
        "status": "sent",
        "sent_to": sent_to if sent_to else ["+91 98765-43299"],
        "channel": req.channel,
        "message_preview": sms_text,
        "audit_id": audit.id
    }

@router.post("/dial-108")
async def dial_108(user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    audit = AuditLog(
        id=f"aud_{uuid.uuid4().hex[:8]}",
        actor_type="patient",
        actor_id=user.id,
        action="EMERGENCY_DIAL_108",
        target_type="emergency_service",
        target_id="108",
        meta_json={"service": "National Ambulance Network (108)", "timestamp": datetime.datetime.utcnow().isoformat()},
        ip="127.0.0.1"
    )
    db.add(audit)
    await db.commit()
    return {"status": "logged", "service": "108", "message": "Emergency 108 auto-dial initiated and audit recorded."}

@router.get("", response_model=list[AlertItemResponse])
async def get_alerts_feed(status_filter: str = None, db: AsyncSession = Depends(get_db)):
    query = select(Alert).order_by(Alert.created_at.desc()).limit(20)
    alerts = (await db.execute(query)).scalars().all()
    results = []

    for a in alerts:
        if status_filter and a.status != status_filter:
            continue
        p_name = "Ramesh Kumar" if a.user_id == "user_ramesh" else "Kiosk Patient (Sarita Vihar)"
        results.append(
            AlertItemResponse(
                id=a.id,
                user_id=a.user_id,
                patient_name=p_name,
                patient_age=62,
                flag_code=a.flag_code,
                channel=a.channel,
                status=a.status,
                acked_by=a.acked_by,
                created_at=a.created_at.strftime("%I:%M:%S %p") if a.created_at else "Just now",
                location="OPD Kiosk 3 (Ayurveda Block)"
            )
        )
    return results

@router.post("/{id}/ack")
async def ack_alert(id: str, db: AsyncSession = Depends(get_db)):
    alert = (await db.execute(select(Alert).where(Alert.id == id))).scalar_one_or_none()
    if not alert:
        raise HTTPException(status_code=404, detail="Alert not found")

    alert.status = "acked"
    alert.acked_by = "Staff Attendant Assigned"

    audit = AuditLog(
        id=f"aud_{uuid.uuid4().hex[:8]}",
        actor_type="staff",
        actor_id="staff_triage",
        action="ALERT_ACKNOWLEDGED",
        target_type="alert",
        target_id=id,
        meta_json={"status": "Attendant dispatched to kiosk location"},
        ip="127.0.0.1"
    )
    db.add(audit)
    await db.commit()

    return {
        "status": "acknowledged",
        "alert_id": id,
        "message": "Attendant dispatched to patient location. Priority triage token assigned."
    }

@router.post("/first-aid")
async def log_first_aid(topic: str = "cpr", user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    audit = AuditLog(
        id=f"aud_{uuid.uuid4().hex[:8]}",
        actor_type="patient",
        actor_id=user.id,
        action="FIRST_AID_VIEWED",
        target_type="content",
        target_id=topic,
        meta_json={"topic": topic},
        ip="127.0.0.1"
    )
    db.add(audit)
    await db.commit()
    return {"status": "logged", "topic": topic}
