from sqlalchemy.ext.asyncio import AsyncSession
from app.models.user import User, RoleEnum
import uuid

# Mock OTP storage
otp_store = {}

async def send_otp(phone: str):
    otp = "1234" # Mock static OTP for demo
    otp_store[phone] = otp
    return True

async def verify_otp(phone: str, otp: str):
    return otp_store.get(phone) == otp

async def create_user(db: AsyncSession, phone: str, name: str, dob: str, gender: str, role: RoleEnum = RoleEnum.patient):
    user = User(
        id=str(uuid.uuid4()),
        phone=phone,
        name=name,
        dob=None,
        gender=gender,
        role=role
    )
    db.add(user)
    await db.commit()
    await db.refresh(user)
    return user
