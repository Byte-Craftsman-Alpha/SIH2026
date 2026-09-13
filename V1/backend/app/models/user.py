from sqlalchemy import Column, String, Date, Boolean, Enum
from app.database import Base, TimestampMixin
import enum

class RoleEnum(str, enum.Enum):
    patient = "patient"
    doctor = "doctor"
    triage = "triage"
    admin = "admin"

class User(Base, TimestampMixin):
    __tablename__ = "users"
    id = Column(String, primary_key=True)
    name = Column(String)
    dob = Column(Date)
    gender = Column(String)
    phone = Column(String, unique=True)
    email = Column(String)
    language = Column(String)
    abha_id = Column(String)
    role = Column(Enum(RoleEnum))
    hashed_password = Column(String, nullable=True)
    is_active = Column(Boolean, default=True)
