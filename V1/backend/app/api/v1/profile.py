import uuid
import datetime
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete
from app.models.user import User
from app.models.profile import PatientProfile
from app.models.emergency_contact import EmergencyContact
from app.models.document import Document
from app.models.visit import Visit
from app.models.summary import Summary
from app.models.consent import Consent
from app.models.audit_log import AuditLog
from app.database import get_db
from app.dependencies import get_current_user
from app.schemas.profile import (
    ProfileUpdateRequest, ProfileResponse, PrakritiResultData,
    EmergencyContactDto, PrakritiAssessmentRequest, PrakritiResponse,
    DeltaCheckRequest, EmergencyContactCreate, ProfileExportResponse
)
from app.core.question_bank import PRAKRITI_QUESTIONS

router = APIRouter()

def get_lifestyle_recommendations(dominant: str) -> list[str]:
    tips = {
        "Vata": [
            "Warm, cooked, nourishing foods with healthy fats (ghee, sesame oil).",
            "Maintain a regular routine for meals and sleep; avoid late nights.",
            "Stay warm, practice gentle yoga, and prioritize daily Abhyanga (warm oil massage)."
        ],
        "Pitta": [
            "Cooling, soothing foods; favor sweet, bitter, and astringent tastes.",
            "Avoid excessive hot spices, fried food, and prolonged direct midday sunlight.",
            "Cultivate calming practices like swimming, walks near water, and moonlight walks."
        ],
        "Kapha": [
            "Light, warm, dry, and spicy foods; minimize heavy sweets and dairy.",
            "Engage in vigorous daily exercise and active physical movement.",
            "Avoid daytime naps and stay mentally stimulated with new activities."
        ],
        "Vata-Pitta": [
            "Nourishing, grounding meals that are not overly hot or spicy.",
            "Moderate exercise routines like brisk walking, cycling, or yoga.",
            "Balance mental drive with adequate hydration and sound sleep."
        ],
        "Pitta-Kapha": [
            "Light, cooling, digestible foods with fresh leafy greens.",
            "Regular aerobic exercise to balance Kapha heaviness and Pitta heat.",
            "Moderate oil consumption and prioritize seasonal cleansing."
        ],
        "Vata-Kapha": [
            "Warm, light, and lightly spiced foods to stimulate Agni without aggravation.",
            "Stay active and well-clothed in chilly weather.",
            "Regular routine with active mornings and relaxing evenings."
        ]
    }
    return tips.get(dominant, [
        "Eat fresh, seasonally appropriate meals at regular intervals.",
        "Drink warm water throughout the day to support digestive fire (Agni).",
        "Maintain balanced sleep and daily physical activity."
    ])

@router.get("", response_model=ProfileResponse)
async def get_profile(user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    prof_res = await db.execute(select(PatientProfile).where(PatientProfile.user_id == user.id))
    profile = prof_res.scalar_one_or_none()

    ec_res = await db.execute(select(EmergencyContact).where(EmergencyContact.user_id == user.id))
    contacts = ec_res.scalars().all()

    age = None
    if user.dob:
        today = datetime.date.today()
        age = today.year - user.dob.year - ((today.month, today.day) < (user.dob.month, user.dob.day))

    prakriti_data = None
    if profile and profile.prakriti_dominant and profile.prakriti_dominant != "Unassessed":
        prakriti_data = PrakritiResultData(
            vata=round(profile.prakriti_vata or 0.0, 2),
            pitta=round(profile.prakriti_pitta or 0.0, 2),
            kapha=round(profile.prakriti_kapha or 0.0, 2),
            dominant=profile.prakriti_dominant,
            sattva=profile.sattva or "Pravara",
            samhanana=profile.samhanana or "Madhyama",
            assessed_at=profile.assessed_at.isoformat() if profile.assessed_at else None,
            lifestyle_tips=get_lifestyle_recommendations(profile.prakriti_dominant)
        )

    phone_masked = f"+91 {user.phone[:2]}****{user.phone[-4:]}" if user.phone and len(user.phone) >= 10 else user.phone
    abha_masked = f"91-XXXX-XXXX-{user.abha_id[-4:]}" if user.abha_id and len(user.abha_id) >= 4 else user.abha_id

    # Compute completeness
    completeness = 50
    if prakriti_data: completeness += 25
    if contacts: completeness += 15
    if user.abha_id: completeness += 10

    return ProfileResponse(
        user_id=user.id,
        name=user.name,
        phone_masked=phone_masked or "",
        email=user.email,
        dob=user.dob.isoformat() if user.dob else None,
        age=age,
        gender=user.gender,
        language=user.language or "hi",
        abha_id_masked=abha_masked,
        profile_completeness=min(100, completeness),
        prakriti=prakriti_data,
        emergency_contacts=[
            EmergencyContactDto(
                id=c.id, contact_type=c.contact_type, name=c.name, phone=c.phone,
                relation=c.relation, consent_flag=c.consent_flag, active=c.active
            ) for c in contacts
        ]
    )

@router.put("")
async def update_profile(req: ProfileUpdateRequest, user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    if req.name: user.name = req.name
    if req.language: user.language = req.language
    if req.gender: user.gender = req.gender
    if req.email: user.email = req.email
    if req.dob:
        try:
            user.dob = datetime.date.fromisoformat(req.dob)
        except Exception:
            pass
    await db.commit()
    return {"status": "success", "message": "Profile updated successfully"}

@router.get("/completeness")
async def get_completeness(user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    prof_res = await db.execute(select(PatientProfile).where(PatientProfile.user_id == user.id))
    profile = prof_res.scalar_one_or_none()

    ec_res = await db.execute(select(EmergencyContact).where(EmergencyContact.user_id == user.id))
    contacts = ec_res.scalars().all()

    missing = []
    completed = ["basic_identity", "contact_phone"]
    score = 50

    if profile and profile.prakriti_dominant and profile.prakriti_dominant != "Unassessed":
        score += 25
        completed.append("prakriti_assessment")
    else:
        missing.append({"field": "prakriti", "label": "Prakriti Assessment (12 min)", "route": "/prakriti"})

    if contacts:
        score += 15
        completed.append("emergency_contacts")
    else:
        missing.append({"field": "emergency_contacts", "label": "Emergency Contacts", "route": "/profile"})

    if user.abha_id:
        score += 10
        completed.append("abha_id")
    else:
        missing.append({"field": "abha_id", "label": "Link ABHA ID", "route": "/profile"})

    return {
        "score": min(100, score),
        "completed": completed,
        "missing": missing
    }

@router.post("/prakriti/assessment", response_model=PrakritiResponse)
async def post_assessment(req: PrakritiAssessmentRequest, user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    vata_count = 0
    pitta_count = 0
    kapha_count = 0

    for ans in req.answers:
        chosen = ans.option or ans.mapped_option or "A"
        if chosen == "A":
            vata_count += 1
        elif chosen == "B":
            pitta_count += 1
        elif chosen == "C":
            kapha_count += 1

    total = max(1, vata_count + pitta_count + kapha_count)
    v_pct = round(vata_count / total, 2)
    p_pct = round(pitta_count / total, 2)
    k_pct = round(kapha_count / total, 2)

    # Determine dominant
    scores = [("Vata", v_pct), ("Pitta", p_pct), ("Kapha", k_pct)]
    scores.sort(key=lambda x: x[1], reverse=True)

    top1, s1 = scores[0]
    top2, s2 = scores[1]

    if s1 - s2 <= 0.15:
        dominant = f"{top1}-{top2}"
    else:
        dominant = top1

    # Update or create profile
    prof_res = await db.execute(select(PatientProfile).where(PatientProfile.user_id == user.id))
    profile = prof_res.scalar_one_or_none()
    now = datetime.datetime.utcnow()

    if not profile:
        profile = PatientProfile(
            user_id=user.id,
            prakriti_vata=v_pct,
            prakriti_pitta=p_pct,
            prakriti_kapha=k_pct,
            prakriti_dominant=dominant,
            sattva="Pravara",
            samhanana="Madhyama",
            assessment_version=1,
            assessed_at=now,
            last_delta_check_at=now
        )
        db.add(profile)
    else:
        profile.prakriti_vata = v_pct
        profile.prakriti_pitta = p_pct
        profile.prakriti_kapha = k_pct
        profile.prakriti_dominant = dominant
        profile.assessed_at = now
        profile.last_delta_check_at = now

    await db.commit()

    tips = get_lifestyle_recommendations(dominant)

    result_data = PrakritiResultData(
        vata=v_pct,
        pitta=p_pct,
        kapha=k_pct,
        dominant=dominant,
        sattva=profile.sattva or "Pravara",
        samhanana=profile.samhanana or "Madhyama",
        assessed_at=now.isoformat(),
        lifestyle_tips=tips
    )

    return PrakritiResponse(
        prakriti=result_data,
        assessment_version="CCRAS-2.1",
        assessed_at=now.isoformat(),
        message=f"Prakriti successfully assessed as {dominant}."
    )

@router.post("/prakriti/delta-check")
async def delta_check(req: DeltaCheckRequest, user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    prof_res = await db.execute(select(PatientProfile).where(PatientProfile.user_id == user.id))
    profile = prof_res.scalar_one_or_none()

    if not profile:
        raise HTTPException(status_code=404, detail="No baseline Prakriti profile found")

    profile.last_delta_check_at = datetime.datetime.utcnow()
    await db.commit()

    return {
        "status": "confirmed",
        "has_major_change": req.has_major_change,
        "dominant": profile.prakriti_dominant,
        "delta_checked_at": profile.last_delta_check_at.isoformat(),
        "reassess_required": req.reassess_requested or req.has_major_change
    }

@router.get("/emergency-contacts")
async def get_contacts(user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    ec_res = await db.execute(select(EmergencyContact).where(EmergencyContact.user_id == user.id))
    return ec_res.scalars().all()

@router.post("/emergency-contacts")
async def add_contact(req: EmergencyContactCreate, user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    contact = EmergencyContact(
        id=f"ec_{uuid.uuid4().hex[:8]}",
        user_id=user.id,
        contact_type=req.contact_type or "family",
        name=req.name,
        phone=req.phone,
        relation=req.relation,
        consent_flag=bool(req.consent_flag),
        active=True
    )
    db.add(contact)
    await db.commit()
    return {"status": "created", "contact": contact}

@router.delete("/emergency-contacts/{contact_id}")
async def delete_contact(contact_id: str, user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    await db.execute(delete(EmergencyContact).where(EmergencyContact.id == contact_id, EmergencyContact.user_id == user.id))
    await db.commit()
    return {"status": "deleted"}

@router.get("/export", response_model=ProfileExportResponse)
async def export_data(user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    prof_res = await db.execute(select(PatientProfile).where(PatientProfile.user_id == user.id))
    profile = prof_res.scalar_one_or_none()

    ec_res = await db.execute(select(EmergencyContact).where(EmergencyContact.user_id == user.id))
    contacts = ec_res.scalars().all()

    doc_res = await db.execute(select(Document).where(Document.user_id == user.id))
    docs = doc_res.scalars().all()

    vis_res = await db.execute(select(Visit).where(Visit.user_id == user.id))
    visits = vis_res.scalars().all()

    cons_res = await db.execute(select(Consent).where(Consent.user_id == user.id))
    consents = cons_res.scalars().all()

    # Log audit entry
    audit = AuditLog(
        id=f"aud_{uuid.uuid4().hex[:8]}",
        actor_type="patient",
        actor_id=user.id,
        action="DATA_EXPORT_DPDP",
        target_type="user",
        target_id=user.id,
        meta_json={"export_format": "JSON", "sections": ["profile", "documents", "visits", "consents"]},
        ip="127.0.0.1"
    )
    db.add(audit)
    await db.commit()

    return ProfileExportResponse(
        export_id=f"exp_{uuid.uuid4().hex[:8]}",
        generated_at=datetime.datetime.utcnow().isoformat(),
        user_data={
            "user": {
                "id": user.id, "name": user.name, "phone": user.phone,
                "dob": user.dob.isoformat() if user.dob else None,
                "gender": user.gender, "abha_id": user.abha_id, "language": user.language
            },
            "prakriti_profile": {
                "dominant": profile.prakriti_dominant if profile else None,
                "vata": profile.prakriti_vata if profile else None,
                "pitta": profile.prakriti_pitta if profile else None,
                "kapha": profile.prakriti_kapha if profile else None,
                "assessed_at": profile.assessed_at.isoformat() if profile and profile.assessed_at else None
            },
            "emergency_contacts": [{"name": c.name, "phone": c.phone, "relation": c.relation} for c in contacts],
            "documents_count": len(docs),
            "visits_count": len(visits),
            "consents_count": len(consents)
        }
    )

@router.post("/erase-request")
async def erase_request(user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    audit = AuditLog(
        id=f"aud_{uuid.uuid4().hex[:8]}",
        actor_type="patient",
        actor_id=user.id,
        action="ERASURE_REQUEST_DPDP",
        target_type="user",
        target_id=user.id,
        meta_json={"retention_policy": "Legal medical audit trails retained per NMC/DISHA guidelines"},
        ip="127.0.0.1"
    )
    db.add(audit)
    user.name = "Anonymized Patient"
    user.phone = f"anon_{uuid.uuid4().hex[:6]}"
    user.email = None
    user.abha_id = None
    await db.commit()

    return {
        "status": "processing",
        "message": "Personal identifiers removed in accordance with DPDP Act 2023. De-identified clinical audit trails preserved per clinical establishment guidelines."
    }
