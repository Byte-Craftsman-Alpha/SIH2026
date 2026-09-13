from sqlalchemy import Column, String, ForeignKey
from app.database import Base, TimestampMixin

class Alert(Base, TimestampMixin):
    __tablename__ = "alerts"
    id = Column(String, primary_key=True)
    user_id = Column(String, ForeignKey("users.id"))
    flag_code = Column(String)
    channel = Column(String)
    payload_hash = Column(String)
    status = Column(String)
    acked_by = Column(String, nullable=True)
