from sqlalchemy import Column, String, Integer, ForeignKey, JSON
from app.database import Base, TimestampMixin

class Summary(Base, TimestampMixin):
    __tablename__ = "summaries"
    id = Column(String, primary_key=True)
    user_id = Column(String, ForeignKey("users.id"))
    visit_id = Column(String, ForeignKey("visits.id"))
    appointment_id = Column(String, ForeignKey("appointments.id"), nullable=True)
    content_json = Column(JSON)
    lang = Column(String)
    status = Column(String)
    doctor_id = Column(String, ForeignKey("doctors.id"), nullable=True)
    version = Column(Integer)
