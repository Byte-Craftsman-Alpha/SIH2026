from sqlalchemy import Column, String, Boolean, JSON, ForeignKey
from app.database import Base, TimestampMixin

class Doctor(Base, TimestampMixin):
    __tablename__ = "doctors"
    id = Column(String, primary_key=True)
    user_id = Column(String, ForeignKey("users.id"), nullable=True)
    hospital_id = Column(String, ForeignKey("hospitals.id"))
    name = Column(String)
    specialty = Column(String)
    languages = Column(JSON)
    is_ayush = Column(Boolean)
    slots_json = Column(JSON)
