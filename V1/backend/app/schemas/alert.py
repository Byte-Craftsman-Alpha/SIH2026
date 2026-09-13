from pydantic import BaseModel, ConfigDict
from typing import Optional, List, Dict, Any

class TriageAlertRequest(BaseModel):
    kiosk_id: Optional[str] = "Kiosk-01"
    flag_code: str
    patient_name: Optional[str] = None
    patient_age: Optional[int] = None
    symptoms: Optional[str] = None

class ContactAlertRequest(BaseModel):
    flag_code: str
    location: Optional[Dict[str, float]] = None
    channel: Optional[str] = "sms"  # "sms" | "whatsapp"

class AlertItemResponse(BaseModel):
    id: str
    user_id: Optional[str] = None
    patient_name: Optional[str] = None
    patient_age: Optional[int] = None
    flag_code: str
    channel: str
    status: str  # "pending" | "acked" | "resolved"
    acked_by: Optional[str] = None
    created_at: str
    location: Optional[str] = None
    model_config = ConfigDict(from_attributes=True)
