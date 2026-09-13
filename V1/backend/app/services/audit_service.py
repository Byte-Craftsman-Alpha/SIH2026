from sqlalchemy.ext.asyncio import AsyncSession
from app.models.audit_log import AuditLog
import uuid

async def log_action(db: AsyncSession, actor_type, actor_id, action, target_type, target_id, meta_json):
    log = AuditLog(id=str(uuid.uuid4()), actor_type=actor_type, actor_id=actor_id, action=action, target_type=target_type, target_id=target_id, meta_json=meta_json)
    db.add(log)
    await db.commit()
