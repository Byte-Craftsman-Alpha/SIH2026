from sqlalchemy import Column, String, Float, Integer, ForeignKey, DateTime
from app.database import Base, TimestampMixin

class PatientProfile(Base, TimestampMixin):
    __tablename__ = "patient_profiles"
    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(String, ForeignKey("users.id"))
    prakriti_vata = Column(Float, default=0.0)
    prakriti_pitta = Column(Float, default=0.0)
    prakriti_kapha = Column(Float, default=0.0)
    prakriti_dominant = Column(String)
    sattva = Column(String)
    samhanana = Column(String)
    assessment_version = Column(Integer)
    assessed_at = Column(DateTime)
    last_delta_check_at = Column(DateTime)
