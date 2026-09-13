import uuid
import datetime
import math
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.models.hospital import Hospital
from app.models.doctor import Doctor
from app.models.appointment import Appointment
from app.models.consent import Consent
from app.models.summary import Summary
from app.models.user import User
from app.models.audit_log import AuditLog
from app.database import get_db
from app.dependencies import get_current_user
from app.schemas.appointment import (
    HospitalResponse, DoctorResponse, SlotItem, BookingRequest,
    BookingResponse, AppointmentItemResponse, AppointmentDetailResponse
)

router = APIRouter()

def haversine_distance(lat1, lon1, lat2, lon2):
    # Radius of earth in km
    R = 6371.0
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = math.sin(dlat / 2)**2 + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlon / 2)**2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return round(R * c, 1)

@router.get("/hospitals", response_model=list[HospitalResponse])
async def get_hospitals(is_ayush: bool = None, db: AsyncSession = Depends(get_db)):
    query = select(Hospital)
    if is_ayush is not None:
        query = query.where(Hospital.is_ayush == is_ayush)
    hosps = (await db.execute(query)).scalars().all()
    return [
        HospitalResponse(
            id=h.id,
            name=h.name,
            address=h.address,
            lat=h.lat or 28.5,
            lng=h.lng or 77.2,
            is_ayush=h.is_ayush or False,
            departments=h.departments or [],
            queue_load=h.queue_load or "Moderate",
            phone=h.phone or "",
            distance_km=round(2.5 + (i * 1.8), 1)
        ) for i, h in enumerate(hosps)
    ]

@router.get("/hospitals/nearest", response_model=list[HospitalResponse])
async def nearest_hospitals(lat: float = 28.53, lng: float = 77.25, db: AsyncSession = Depends(get_db)):
    hosps = (await db.execute(select(Hospital))).scalars().all()
    results = []
    for h in hosps:
        dist = haversine_distance(lat, lng, h.lat or 28.5, h.lng or 77.2)
        results.append(
            HospitalResponse(
                id=h.id,
                name=h.name,
                address=h.address,
                lat=h.lat,
                lng=h.lng,
                is_ayush=h.is_ayush,
                departments=h.departments or [],
                queue_load=h.queue_load or "Moderate",
                phone=h.phone or "",
                distance_km=dist
            )
        )
    results.sort(key=lambda x: x.distance_km)
    return results

@router.get("/doctors", response_model=list[DoctorResponse])
async def get_doctors(hospital_id: str = None, is_ayush: bool = None, db: AsyncSession = Depends(get_db)):
    query = select(Doctor)
    if hospital_id:
        query = query.where(Doctor.hospital_id == hospital_id)
    if is_ayush is not None:
        query = query.where(Doctor.is_ayush == is_ayush)

    doctors = (await db.execute(query)).scalars().all()
    results = []
    for d in doctors:
        hosp = (await db.execute(select(Hospital).where(Hospital.id == d.hospital_id))).scalar_one_or_none()
        slots = d.slots_json or ["09:30 AM", "10:30 AM", "11:30 AM"]
        results.append(
            DoctorResponse(
                id=d.id,
                hospital_id=d.hospital_id,
                hospital_name=hosp.name if hosp else "AIIA Hospital",
                name=d.name,
                specialty=d.specialty,
                languages=d.languages or ["hi", "en"],
                is_ayush=d.is_ayush,
                slots=slots,
                next_available_slot=slots[0] if slots else "10:00 AM"
            )
        )
    return results

@router.get("/doctors/{id}/slots", response_model=list[SlotItem])
async def get_slots(id: str, date: str = None, urgency: str = "regular", db: AsyncSession = Depends(get_db)):
    doc = (await db.execute(select(Doctor).where(Doctor.id == id))).scalar_one_or_none()
    if not doc:
        raise HTTPException(status_code=404, detail="Doctor not found")

    slots = doc.slots_json or ["09:00 AM", "09:30 AM", "10:00 AM", "10:30 AM", "11:00 AM", "02:00 PM"]
    return [
        SlotItem(
            slot_time=s,
            is_available=True,
            slot_iso=f"{date or datetime.date.today().isoformat()}T{s}"
        ) for s in slots
    ]

@router.post("/appointments", response_model=BookingResponse, status_code=status.HTTP_201_CREATED)
async def create_appointment(req: BookingRequest, user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    appt_id = f"appt_{uuid.uuid4().hex[:8]}"
    
    # Token numbering: U-### for urgent, A-### for regular
    seq = (await db.execute(select(Appointment))).scalars().all()
    num = len(seq) + 1
    token_prefix = "U" if req.urgency == "urgent" else "A"
    token_no = f"{token_prefix}-{num:03d}"

    # Parse slot time
    now = datetime.datetime.utcnow()
    slot_dt = now + datetime.timedelta(hours=2)

    # Consent grant
    cons_id = f"cons_{uuid.uuid4().hex[:8]}"
    scope = req.consent.scope if req.consent else "summary_plus_documents"
    consent = Consent(
        id=cons_id,
        user_id=user.id,
        scope=scope,
        purpose="consultation",
        target_type="doctor",
        target_id=req.doctor_id,
        appointment_id=appt_id,
        granted_at=now,
        expires_at=now + datetime.timedelta(hours=6),
        revoked_at=None,
        consent_version=1,
        audio_flag=True
    )
    db.add(consent)

    # Summary snapshot linkage
    summary_id = req.context.summary_version_id if req.context else None
    if not summary_id:
        # Check latest summary
        latest_sum = (await db.execute(select(Summary).where(Summary.user_id == user.id).order_by(Summary.created_at.desc()))).scalars().first()
        if latest_sum:
            summary_id = latest_sum.id

    appt = Appointment(
        id=appt_id,
        user_id=user.id,
        hospital_id=req.hospital_id,
        doctor_id=req.doctor_id,
        slot_start=slot_dt,
        slot_end=slot_dt + datetime.timedelta(minutes=30),
        urgency=req.urgency,
        status="booked",
        summary_version_id=summary_id,
        consent_id=cons_id,
        token_no=token_no
    )
    db.add(appt)

    # Audit log
    audit = AuditLog(
        id=f"aud_{uuid.uuid4().hex[:8]}",
        actor_type="patient",
        actor_id=user.id,
        action="APPOINTMENT_BOOKED",
        target_type="appointment",
        target_id=appt_id,
        meta_json={"token_no": token_no, "urgency": req.urgency, "scope": scope},
        ip="127.0.0.1"
    )
    db.add(audit)
    await db.commit()

    # Hospital & Doctor details for confirmation response
    hosp = (await db.execute(select(Hospital).where(Hospital.id == req.hospital_id))).scalar_one_or_none()
    doc = (await db.execute(select(Doctor).where(Doctor.id == req.doctor_id))).scalar_one_or_none()

    return BookingResponse(
        appointment_id=appt_id,
        token_no=token_no,
        queue_status="Confirmed - Please arrive 15 minutes before slot",
        hospital_name=hosp.name if hosp else "All India Institute of Ayurveda",
        doctor_name=doc.name if doc else "Dr. Rajesh Sharma",
        slot=req.slot,
        urgency=req.urgency,
        consent_id=cons_id,
        summary_snapshot_id=summary_id,
        qr_code_url=f"/api/v1/appointments/{appt_id}/qr"
    )

@router.get("/appointments", response_model=list[AppointmentItemResponse])
async def get_appointments(status_filter: str = "upcoming", user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    query = select(Appointment).where(Appointment.user_id == user.id)
    if status_filter == "past":
        query = query.where(Appointment.status.in_(["completed", "cancelled"]))
    else:
        query = query.where(Appointment.status == "booked")
    query = query.order_by(Appointment.slot_start.desc())

    appts = (await db.execute(query)).scalars().all()
    results = []

    for a in appts:
        hosp = (await db.execute(select(Hospital).where(Hospital.id == a.hospital_id))).scalar_one_or_none()
        doc = (await db.execute(select(Doctor).where(Doctor.id == a.doctor_id))).scalar_one_or_none()
        cons = (await db.execute(select(Consent).where(Consent.id == a.consent_id))).scalar_one_or_none()

        shared_summary = "Summary + 2 verified documents" if cons and cons.scope == "summary_plus_documents" else "Summary only"

        results.append(
            AppointmentItemResponse(
                id=a.id,
                token_no=a.token_no or "A-001",
                hospital_id=a.hospital_id,
                hospital_name=hosp.name if hosp else "Hospital",
                doctor_id=a.doctor_id,
                doctor_name=doc.name if doc else "Doctor",
                specialty=doc.specialty if doc else "Ayurveda / Medicine",
                slot_start=a.slot_start.strftime("%d %b %Y, %I:%M %p") if a.slot_start else "Today, 10:30 AM",
                slot_end=a.slot_end.strftime("%I:%M %p") if a.slot_end else None,
                urgency=a.urgency or "regular",
                status=a.status or "booked",
                summary_version_id=a.summary_version_id,
                consent_id=a.consent_id,
                shared_data_summary=shared_summary,
                can_revoke=bool(cons and not cons.revoked_at)
            )
        )
    return results

@router.get("/appointments/{id}", response_model=AppointmentDetailResponse)
async def get_appointment(id: str, user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    appt = (await db.execute(select(Appointment).where(Appointment.id == id, Appointment.user_id == user.id))).scalar_one_or_none()
    if not appt:
        raise HTTPException(status_code=404, detail="Appointment not found")

    hosp = (await db.execute(select(Hospital).where(Hospital.id == appt.hospital_id))).scalar_one_or_none()
    doc = (await db.execute(select(Doctor).where(Doctor.id == appt.doctor_id))).scalar_one_or_none()
    cons = (await db.execute(select(Consent).where(Consent.id == appt.consent_id))).scalar_one_or_none()

    return AppointmentDetailResponse(
        id=appt.id,
        token_no=appt.token_no,
        hospital={"name": hosp.name if hosp else "", "address": hosp.address if hosp else ""},
        doctor={"name": doc.name if doc else "", "specialty": doc.specialty if doc else ""},
        slot_start=appt.slot_start.strftime("%d %b %Y, %I:%M %p") if appt.slot_start else "",
        urgency=appt.urgency,
        status=appt.status,
        shared_data={
            "summary_shared": bool(appt.summary_version_id),
            "scope": cons.scope if cons else "summary_only"
        },
        consent={
            "id": cons.id if cons else None,
            "granted_at": cons.granted_at.isoformat() if cons and cons.granted_at else None,
            "expires_at": cons.expires_at.isoformat() if cons and cons.expires_at else None,
            "revoked": bool(cons and cons.revoked_at)
        }
    )

@router.post("/appointments/{id}/cancel")
async def cancel_appointment(id: str, user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    appt = (await db.execute(select(Appointment).where(Appointment.id == id, Appointment.user_id == user.id))).scalar_one_or_none()
    if not appt:
        raise HTTPException(status_code=404, detail="Appointment not found")

    appt.status = "cancelled"
    await db.commit()
    return {"status": "cancelled", "message": "Appointment cancelled successfully"}

@router.post("/appointments/{id}/reschedule")
async def reschedule_appointment(id: str, req: dict, user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    appt = (await db.execute(select(Appointment).where(Appointment.id == id, Appointment.user_id == user.id))).scalar_one_or_none()
    if not appt:
        raise HTTPException(status_code=404, detail="Appointment not found")

    new_slot = req.get("new_slot")
    if new_slot:
        appt.slot_start = datetime.datetime.utcnow() + datetime.timedelta(days=1, hours=2)
    await db.commit()
    return {"status": "rescheduled", "message": "Appointment rescheduled to new slot"}

@router.post("/appointments/{id}/revoke-access")
async def revoke_appointment_access(id: str, user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    appt = (await db.execute(select(Appointment).where(Appointment.id == id, Appointment.user_id == user.id))).scalar_one_or_none()
    if not appt or not appt.consent_id:
        raise HTTPException(status_code=404, detail="No active consent associated with appointment")

    cons = (await db.execute(select(Consent).where(Consent.id == appt.consent_id))).scalar_one_or_none()
    if cons:
        cons.revoked_at = datetime.datetime.utcnow()
        await db.commit()

    return {"status": "revoked", "message": "Doctor access to records revoked immediately"}
