from pydantic import BaseModel, ConfigDict, Field
from typing import List, Optional, Dict, Any

class ProfileUpdateRequest(BaseModel):
    name: Optional[str] = None
    language: Optional[str] = None
    dob: Optional[str] = None
    gender: Optional[str] = None
    email: Optional[str] = None

class PrakritiResultData(BaseModel):
    vata: float
    pitta: float
    kapha: float
    dominant: str
    sattva: Optional[str] = "Pravara"
    samhanana: Optional[str] = "Madhyama"
    assessed_at: Optional[str] = None
    lifestyle_tips: Optional[List[str]] = []

class EmergencyContactDto(BaseModel):
    id: str
    contact_type: str
    name: str
    phone: str
    relation: str
    consent_flag: bool
    active: bool
    model_config = ConfigDict(from_attributes=True)

class ProfileResponse(BaseModel):
    user_id: str
    name: str
    phone_masked: str
    email: Optional[str] = None
    dob: Optional[str] = None
    age: Optional[int] = None
    gender: Optional[str] = None
    language: str
    abha_id_masked: Optional[str] = None
    profile_completeness: int
    prakriti: Optional[PrakritiResultData] = None
    emergency_contacts: List[EmergencyContactDto] = []

class AnswerItem(BaseModel):
    qid: str
    mode: Optional[str] = "mcq"
    option: Optional[str] = None
    transcript: Optional[str] = None
    mapped_option: Optional[str] = None
    confidence: Optional[float] = 1.0

class PrakritiAssessmentRequest(BaseModel):
    answers: List[AnswerItem]

class PrakritiResponse(BaseModel):
    prakriti: PrakritiResultData
    assessment_version: str = "CCRAS-2.1"
    assessed_at: str
    message: str

class DeltaCheckRequest(BaseModel):
    has_major_change: bool
    notes: Optional[str] = None
    reassess_requested: bool = False

class EmergencyContactCreate(BaseModel):
    contact_type: Optional[str] = "family"
    name: str
    phone: str
    relation: str
    consent_flag: Optional[bool] = True

class ProfileExportResponse(BaseModel):
    export_id: str
    generated_at: str
    dpdp_compliance: str = "Digital Personal Data Protection Act, 2023 - Section 6 Data Portability"
    user_data: Dict[str, Any]
