from pydantic import BaseModel

class AuditLogResponse(BaseModel):
    logs: list

class AuditExportResponse(BaseModel):
    url: str
