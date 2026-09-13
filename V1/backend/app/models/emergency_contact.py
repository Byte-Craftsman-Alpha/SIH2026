from sqlalchemy import Column, String, Boolean, ForeignKey
from app.database import Base, TimestampMixin

class EmergencyContact(Base, TimestampMixin):
    __tablename__ = "emergency_contacts"
    id = Column(String, primary_key=True)
    user_id = Column(String, ForeignKey("users.id"))
    contact_type = Column(String)
    name = Column(String)
    phone = Column(String)
    relation = Column(String)
    consent_flag = Column(Boolean)
    active = Column(Boolean)
