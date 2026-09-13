from sqlalchemy.ext.asyncio import AsyncSession
from app.models.hospital import Hospital
from sqlalchemy import select

async def list_hospitals(db: AsyncSession):
    res = await db.execute(select(Hospital))
    return res.scalars().all()
