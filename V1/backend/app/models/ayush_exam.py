from sqlalchemy import Column, String, ForeignKey, JSON
from app.database import Base, TimestampMixin

class AyushExam(Base, TimestampMixin):
    __tablename__ = "ayush_exams"
    id = Column(String, primary_key=True)
    visit_id = Column(String, ForeignKey("visits.id"))
    doctor_id = Column(String, ForeignKey("doctors.id"))
    exam_json = Column(JSON)
