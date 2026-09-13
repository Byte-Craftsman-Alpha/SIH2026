from sqlalchemy import Column, String, Boolean, Integer, ForeignKey, DateTime
from app.database import Base, TimestampMixin

class Consent(Base, TimestampMixin):
    __tablename__ = "consents"
    id = Column(String, primary_key=True)
    user_id = Column(String, ForeignKey("users.id"))
    scope = Column(String)
    purpose = Column(String)
    target_type = Column(String)
    target_id = Column(String)
    appointment_id = Column(String, ForeignKey("appointments.id"), nullable=True)
    granted_at = Column(DateTime)
    expires_at = Column(DateTime)
    revoked_at = Column(DateTime, nullable=True)
    consent_version = Column(Integer)
    audio_flag = Column(Boolean)
