from pydantic import BaseModel, ConfigDict
from typing import Optional, List, Dict, Any

class ConsentGrantRequest(BaseModel):
    scope: str = "summary_plus_documents"  # "summary_only" | "summary_plus_documents" | "full_record"
    purpose: str = "consultation"
    target_type: str = "doctor"
    target_id: str
    appointment_id: Optional[str] = None
    expires_at: Optional[str] = None
    consent_version: str = "1.2"
    audio_flag: bool = True

class ConsentItemResponse(BaseModel):
    id: str
    user_id: str
    scope: str
    purpose: str
    target_type: str
    target_id: str
    target_name: Optional[str] = None
    appointment_id: Optional[str] = None
    granted_at: str
    expires_at: str
    revoked_at: Optional[str] = None
    status: str  # "active" | "revoked" | "expired"
    consent_version: int
    audio_flag: bool
    model_config = ConfigDict(from_attributes=True)
