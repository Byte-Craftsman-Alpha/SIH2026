from pydantic import BaseModel, ConfigDict
from typing import Optional, List, Dict, Any

class SummaryGenerateRequest(BaseModel):
    visit_id: str
    include_documents: Optional[bool] = True

class SectionEdit(BaseModel):
    section: str
    new_value: Any

class DoctorDecisionRequest(BaseModel):
    decision: str  # "accepted" | "amended" | "rejected"
    edits: Optional[List[SectionEdit]] = []
    reason: Optional[str] = None

class SummaryResponse(BaseModel):
    id: str
    user_id: str
    visit_id: str
    appointment_id: Optional[str] = None
    content: Dict[str, Any]
    lang: str = "hi"
    status: str  # "draft" | "accepted" | "amended" | "rejected"
    doctor_id: Optional[str] = None
    version: int = 1
    created_at: Optional[str] = None
    model_config = ConfigDict(from_attributes=True)

class SummaryVersionItem(BaseModel):
    version: int
    status: str
    decision_by: Optional[str] = None
    timestamp: str
    notes: Optional[str] = None
