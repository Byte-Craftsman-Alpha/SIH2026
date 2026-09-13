from sqlalchemy import Column, String, ForeignKey, JSON, Float, DateTime
from app.database import Base, TimestampMixin

class Document(Base, TimestampMixin):
    __tablename__ = "documents"
    id = Column(String, primary_key=True)
    user_id = Column(String, ForeignKey("users.id"))
    doc_type = Column(String)
    original_path = Column(String)
    parsed_json = Column(JSON)
    confidence = Column(Float)
    verify_status = Column(String)
    doc_date = Column(DateTime)
    uploaded_at = Column(DateTime)
    flags_json = Column(JSON)
