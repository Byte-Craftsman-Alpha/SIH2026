from sqlalchemy import Column, String, DateTime, ForeignKey
from app.database import Base, TimestampMixin

class Visit(Base, TimestampMixin):
    __tablename__ = "visits"
    id = Column(String, primary_key=True)
    user_id = Column(String, ForeignKey("users.id"))
    mode = Column(String)
    status = Column(String)
    started_at = Column(DateTime)
    submitted_at = Column(DateTime, nullable=True)
    chief_complaint = Column(String)
    red_flag_code = Column(String, nullable=True)
