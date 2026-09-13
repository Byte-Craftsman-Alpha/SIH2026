from sqlalchemy.ext.asyncio import AsyncSession
from app.models.profile import PatientProfile

async def get_profile(db: AsyncSession, user_id: str):
    return None

async def calculate_prakriti(answers: list):
    return {"vata": 33.3, "pitta": 33.3, "kapha": 33.3, "dominant": "Vata"}
