from sqlalchemy import Column, String, Float, Boolean, JSON
from app.database import Base, TimestampMixin

class Hospital(Base, TimestampMixin):
    __tablename__ = "hospitals"
    id = Column(String, primary_key=True)
    name = Column(String)
    address = Column(String)
    lat = Column(Float)
    lng = Column(Float)
    is_ayush = Column(Boolean)
    departments = Column(JSON)
    queue_load = Column(String)
    phone = Column(String)
