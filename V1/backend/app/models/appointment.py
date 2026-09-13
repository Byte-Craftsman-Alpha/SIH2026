from sqlalchemy import Column, String, DateTime, ForeignKey
from app.database import Base, TimestampMixin

class Appointment(Base, TimestampMixin):
    __tablename__ = "appointments"
    id = Column(String, primary_key=True)
    user_id = Column(String, ForeignKey("users.id"))
    hospital_id = Column(String, ForeignKey("hospitals.id"))
    doctor_id = Column(String, ForeignKey("doctors.id"))
    slot_start = Column(DateTime)
    slot_end = Column(DateTime)
    urgency = Column(String)
    status = Column(String)
    summary_version_id = Column(String, nullable=True)
    consent_id = Column(String, nullable=True)
    token_no = Column(String)
