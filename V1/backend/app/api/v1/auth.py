from app.models.audit_log import AuditLog
import uuid
import datetime
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.schemas.auth import (
    OTPSendRequest, OTPVerifyRequest, RegisterRequest,
    LoginRequest, TokenResponse, UserResponse
)
from app.models.user import User, RoleEnum
from app.models.emergency_contact import EmergencyContact
from app.models.consent import Consent
from app.models.profile import PatientProfile
from app.core.security import create_access_token, create_refresh_token, verify_password, hash_password
from app.database import get_db
from app.dependencies import get_current_user

router = APIRouter()

# In-memory mock OTP store for demo
OTP_STORE = {"9876543210": "1234", "9999990001": "1234"}

@router.post("/otp/send")
async def otp_send(req: OTPSendRequest):
    # In demo mode, accept any 10-digit number and set OTP to 1234
    clean_phone = req.phone.replace("+91", "").replace(" ", "").replace("-", "")
    OTP_STORE[clean_phone] = "1234"
    return {
        "status": "success",
        "message": "OTP sent successfully to " + req.phone,
        "cooldown_seconds": 30,
        "demo_hint": "Demo OTP is 1234"
    }

@router.post("/otp/verify")
async def otp_verify(req: OTPVerifyRequest, db: AsyncSession = Depends(get_db)):
    clean_phone = req.phone.replace("+91", "").replace(" ", "").replace("-", "")
    expected = OTP_STORE.get(clean_phone, "1234")
    if req.otp == expected or req.otp == "1234":
        user = (await db.execute(select(User).where(User.phone == clean_phone))).scalar_one_or_none()
        if not user:
            user = (await db.execute(select(User).where(User.id == "user_ramesh"))).scalar_one_or_none()
        user_id = user.id if user else "user_ramesh"
        role = user.role.value if user else "patient"
        token = create_access_token({"sub": user_id, "role": role})
        refresh = create_refresh_token({"sub": user_id})
        return {
            "valid": True,
            "token": token,
            "access_token": token,
            "refresh_token": refresh,
            "user_id": user_id,
            "message": "OTP verified successfully"
        }
    return {"valid": False, "token": None, "access_token": None, "message": "Invalid OTP. Use 1234 for demo."}

@router.post("/register", status_code=status.HTTP_201_CREATED)
async def register(req: RegisterRequest, db: AsyncSession = Depends(get_db)):
    clean_phone = req.phone.replace("+91", "").replace(" ", "").replace("-", "")
    
    # Auto-fill from ABHA profile if provided
    final_name = req.name
    final_gender = req.gender
    final_dob = req.dob
    abha_id = req.abha_id
    
    if req.abha_verified_profile:
        ab = req.abha_verified_profile
        if not final_name and ab.get("name"): final_name = ab["name"]
        if not final_gender and ab.get("gender"): final_gender = ab["gender"]
        if not final_dob and ab.get("yearOfBirth"):
            final_dob = f'{ab["yearOfBirth"]}-{ab.get("monthOfBirth", "01")}-{ab.get("dayOfBirth", "01")}'
        if ab.get("abhaNumber"):
            abha_id = ab["abhaNumber"]
    
    # Check if user exists
    existing = (await db.execute(select(User).where(User.phone == clean_phone))).scalar_one_or_none()
    if existing:
        token = create_access_token({"sub": existing.id, "role": existing.role.value})
        return {
            "status": "existing_user",
            "message": "User already registered. Logged in automatically.",
            "user_id": existing.id,
            "profile_completeness": 85,
            "jwt": {
                "access_token": token,
                "refresh_token": create_refresh_token({"sub": existing.id}),
                "token_type": "bearer"
            }
        }

    # Parse DOB
    try:
        dob_date = datetime.date.fromisoformat(final_dob)
    except Exception:
        dob_date = datetime.date(1990, 1, 1)

    user_id = f"usr_{uuid.uuid4().hex[:8]}"
    new_user = User(
        id=user_id,
        name=final_name,
        dob=dob_date,
        gender=final_gender.lower(),
        phone=clean_phone,
        email=req.email,
        language=req.language or "hi",
        abha_id=abha_id or f"91-{clean_phone[:4]}-{clean_phone[4:8]}-{clean_phone[8:]}",
        role=RoleEnum.patient,
        hashed_password=None,
        is_active=True
    )
    db.add(new_user)

    # Add emergency contacts
    if req.emergency_contacts:
        for ec in req.emergency_contacts:
            contact = EmergencyContact(
                id=f"ec_{uuid.uuid4().hex[:8]}",
                user_id=user_id,
                contact_type=ec.type or "family",
                name=ec.name,
                phone=ec.phone,
                relation=ec.relation or "Relative",
                consent_flag=bool(req.emergency_pre_consent),
                active=True
            )
            db.add(contact)

    # Add default Profile
    profile = PatientProfile(
        user_id=user_id,
        prakriti_vata=0.0,
        prakriti_pitta=0.0,
        prakriti_kapha=0.0,
        prakriti_dominant="Unassessed",
        sattva="Unassessed",
        samhanana="Unassessed",
        assessment_version=1,
        assessed_at=datetime.datetime.utcnow(),
        last_delta_check_at=datetime.datetime.utcnow()
    )
    db.add(profile)

    # Add Consent record
    consent = Consent(
        id=f"cons_{uuid.uuid4().hex[:8]}",
        user_id=user_id,
        scope="data_capture_and_digitization",
        purpose="clinical_intake",
        target_type="system",
        target_id="medikiosk_system",
        appointment_id=None,
        granted_at=datetime.datetime.utcnow(),
        expires_at=datetime.datetime.utcnow() + datetime.timedelta(days=365),
        revoked_at=None,
        consent_version=1,
        audio_flag=req.consent.audio_consent_flag if req.consent else True
    )
    db.add(consent)
    if req.abha_verified_profile:
        audit = AuditLog(
            id=f"al_{uuid.uuid4().hex[:8]}",
            actor_type="patient",
            actor_id=user_id,
            action="ABHA_VERIFIED_LOGIN",
            target_type="system",
            target_id=user_id,
            meta_json={"abha": abha_id},
            ip="0.0.0.0"
        )
        db.add(audit)


    await db.commit()

    token = create_access_token({"sub": user_id, "role": "patient"})
    refresh = create_refresh_token({"sub": user_id})

    return {
        "status": "created",
        "user_id": user_id,
        "profile_completeness": 65,
        "jwt": {
            "access_token": token,
            "refresh_token": refresh,
            "token_type": "bearer"
        }
    }

@router.post("/login", response_model=TokenResponse)
async def login(req: LoginRequest, db: AsyncSession = Depends(get_db)):
    # 1. Staff login via email + password
    if req.email and req.password:
        user = (await db.execute(select(User).where(User.email == req.email))).scalar_one_or_none()
        if user and user.hashed_password and verify_password(req.password, user.hashed_password):
            token = create_access_token({"sub": user.id, "role": user.role.value})
            return TokenResponse(
                access_token=token,
                refresh_token=create_refresh_token({"sub": user.id}),
                token_type="bearer",
                user_id=user.id,
                role=user.role.value,
                name=user.name
            )
        # Check demo password fallback
        if req.password in ["demo123", "admin123"]:
            if "doctor" in req.email:
                user = (await db.execute(select(User).where(User.id == "user_doc_sharma"))).scalar_one_or_none()
            else:
                user = (await db.execute(select(User).where(User.id == "user_admin"))).scalar_one_or_none()
            if user:
                token = create_access_token({"sub": user.id, "role": user.role.value})
                return TokenResponse(
                    access_token=token,
                    refresh_token=create_refresh_token({"sub": user.id}),
                    token_type="bearer",
                    user_id=user.id,
                    role=user.role.value,
                    name=user.name
                )
        raise HTTPException(status_code=401, detail="Invalid staff credentials")

    # 2. Patient phone login
    if req.phone:
        clean_phone = req.phone.replace("+91", "").replace(" ", "").replace("-", "")
        user = (await db.execute(select(User).where(User.phone == clean_phone))).scalar_one_or_none()
        if not user:
            # In demo mode, if phone is provided, log in as Ramesh or auto-create
            user = (await db.execute(select(User).where(User.id == "user_ramesh"))).scalar_one_or_none()
        if user:
            token = create_access_token({"sub": user.id, "role": user.role.value})
            return TokenResponse(
                access_token=token,
                refresh_token=create_refresh_token({"sub": user.id}),
                token_type="bearer",
                user_id=user.id,
                role=user.role.value,
                name=user.name
            )

    # Default demo token
    return TokenResponse(
        access_token="demo_token",
        refresh_token="demo_refresh",
        token_type="bearer",
        user_id="user_ramesh",
        role="patient",
        name="Ramesh Kumar"
    )

@router.post("/refresh")
async def refresh():
    new_token = create_access_token({"sub": "user_ramesh", "role": "patient"})
    return {"access_token": new_token, "token_type": "bearer"}

@router.post("/logout")
async def logout():
    return {"status": "ok", "message": "Session terminated and local storage cleared"}

@router.post("/abha/link")
async def link_abha(req: dict, user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    abha_id = req.get("abha_id", "91-1234-5678-9012")
    user.abha_id = abha_id
    await db.commit()
    return {"status": "linked", "abha_id": abha_id, "message": "ABHA ID successfully linked to health account"}

@router.get("/me", response_model=UserResponse)
async def get_me(user: User = Depends(get_current_user)):
    age = None
    if user.dob:
        today = datetime.date.today()
        age = today.year - user.dob.year - ((today.month, today.day) < (user.dob.month, user.dob.day))
    
    return UserResponse(
        id=user.id,
        name=user.name,
        phone=user.phone,
        email=user.email,
        gender=user.gender,
        dob=user.dob.isoformat() if user.dob else None,
        age=age,
        language=user.language or "hi",
        abha_id=user.abha_id,
        role=user.role,
        profile_completeness=90 if user.abha_id else 70
    )
