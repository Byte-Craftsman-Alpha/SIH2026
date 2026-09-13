from sqlalchemy import Column, String, JSON
from app.database import Base, TimestampMixin

class AuditLog(Base, TimestampMixin):
    __tablename__ = "audit_logs"
    id = Column(String, primary_key=True)
    actor_type = Column(String)
    actor_id = Column(String)
    action = Column(String)
    target_type = Column(String)
    target_id = Column(String)
    meta_json = Column(JSON)
    ip = Column(String)
