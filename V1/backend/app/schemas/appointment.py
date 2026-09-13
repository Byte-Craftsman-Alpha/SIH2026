from pydantic import BaseModel, ConfigDict, Field
from typing import Optional, List, Dict, Any

class HospitalResponse(BaseModel):
    id: str
    name: str
    address: str
    lat: float
    lng: float
    is_ayush: bool
    departments: List[str]
    queue_load: str
    phone: str
    distance_km: Optional[float] = None
    model_config = ConfigDict(from_attributes=True)

class DoctorResponse(BaseModel):
    id: str
    hospital_id: str
    hospital_name: Optional[str] = None
    name: str
    specialty: str
    languages: List[str]
    is_ayush: bool
    slots: List[str] = []
    next_available_slot: Optional[str] = None
    model_config = ConfigDict(from_attributes=True)

class SlotItem(BaseModel):
    slot_time: str
    is_available: bool = True
    slot_iso: Optional[str] = None

class BookingContext(BaseModel):
    summary_version_id: Optional[str] = None
    document_ids: Optional[List[str]] = []

class BookingConsent(BaseModel):
    scope: str = "summary_plus_documents"  # "summary_only" | "summary_plus_documents" | "full_record"
    purpose: str = "consultation"
    expires_at: Optional[str] = None
    consent_version: str = "1.2"

class BookingRequest(BaseModel):
    hospital_id: str
    doctor_id: str
    slot: str
    urgency: str = "regular"  # "regular" | "urgent"
    urgency_reason: Optional[str] = None
    context: Optional[BookingContext] = None
    consent: Optional[BookingConsent] = None

class BookingResponse(BaseModel):
    appointment_id: str
    token_no: str
    queue_status: str
    hospital_name: str
    doctor_name: str
    slot: str
    urgency: str
    consent_id: Optional[str] = None
    summary_snapshot_id: Optional[str] = None
    qr_code_url: Optional[str] = None

class AppointmentItemResponse(BaseModel):
    id: str
    token_no: str
    hospital_id: str
    hospital_name: str
    doctor_id: str
    doctor_name: str
    specialty: str
    slot_start: str
    slot_end: Optional[str] = None
    urgency: str
    status: str
    summary_version_id: Optional[str] = None
    consent_id: Optional[str] = None
    shared_data_summary: str
    can_revoke: bool = True
    model_config = ConfigDict(from_attributes=True)

class AppointmentDetailResponse(BaseModel):
    id: str
    token_no: str
    hospital: Dict[str, Any]
    doctor: Dict[str, Any]
    slot_start: str
    urgency: str
    status: str
    shared_data: Dict[str, Any]
    consent: Optional[Dict[str, Any]] = None
