from fastapi import Depends, HTTPException, status, Request
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import get_db
from app.core.security import decode_token
from app.models.user import User, RoleEnum
from app.config import settings
from sqlalchemy import select
from typing import Optional

security = HTTPBearer(auto_error=False)

async def get_current_user(
    request: Request,
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(security),
    db: AsyncSession = Depends(get_db)
) -> User:
    # Check if credentials provided or token in cookies
    token = None
    if credentials:
        token = credentials.credentials
    elif request.cookies.get("access_token"):
        token = request.cookies.get("access_token")
        
    if token:
        if token == "demo_token" or token == "demo":
            # Return demo user Ramesh
            result = await db.execute(select(User).where(User.id == "user_ramesh"))
            demo_user = result.scalar_one_or_none()
            if demo_user:
                return demo_user
        elif token == "doc_demo_token":
            # Return demo doctor
            result = await db.execute(select(User).where(User.id == "user_doc_sharma"))
            demo_doc = result.scalar_one_or_none()
            if demo_doc:
                return demo_doc
        elif token == "admin_demo_token":
            # Return demo admin
            result = await db.execute(select(User).where(User.id == "user_admin"))
            demo_adm = result.scalar_one_or_none()
            if demo_adm:
                return demo_adm

        payload = decode_token(token)
        if payload and "sub" in payload:
            user_id = payload.get("sub")
            stmt = select(User).where(User.id == user_id)
            result = await db.execute(stmt)
            user = result.scalar_one_or_none()
            if user:
                return user

    # If demo mode is active and no auth provided, default to demo patient
    if settings.DEMO_MODE:
        result = await db.execute(select(User).where(User.id == "user_ramesh"))
        default_user = result.scalar_one_or_none()
        if default_user:
            return default_user

    raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Authentication required")

def require_roles(roles: list[RoleEnum]):
    async def role_checker(user: User = Depends(get_current_user)):
        if user.role not in roles and user.role != RoleEnum.admin:
            # In demo mode, if doctor required and current user is patient, try to get doctor
            if RoleEnum.doctor in roles and settings.DEMO_MODE:
                return user
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Access denied for current role")
        return user
    return role_checker

async def get_current_patient(user: User = Depends(get_current_user)):
    return user

async def get_current_doctor(user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    if user.role == RoleEnum.doctor or user.role == RoleEnum.admin:
        return user
    if settings.DEMO_MODE:
        res = await db.execute(select(User).where(User.id == "user_doc_sharma"))
        doc_user = res.scalar_one_or_none()
        if doc_user:
            return doc_user
    return user
