from pydantic import BaseModel, ConfigDict, Field
from typing import Optional, List, Dict, Any
from app.models.user import RoleEnum

class OTPSendRequest(BaseModel):
    phone: str

class OTPVerifyRequest(BaseModel):
    phone: str
    otp: str

class EmergencyContactItem(BaseModel):
    type: Optional[str] = "family"
    name: str
    relation: Optional[str] = "relative"
    phone: str

class ConsentData(BaseModel):
    data_capture: bool = True
    document_digitization: bool = True
    anonymous_analytics: bool = False
    audio_consent_flag: bool = True
    consent_version: str = "1.2"

class RegisterRequest(BaseModel):
    phone: str
    name: str
    dob: str
    gender: str
    email: Optional[str] = None
    language: Optional[str] = "hi"
    abha_id: Optional[str] = None
    aadhaar_ref: Optional[str] = None
    emergency_contacts: Optional[List[EmergencyContactItem]] = []
    emergency_pre_consent: Optional[bool] = True
    consent: Optional[ConsentData] = Field(default_factory=ConsentData)

class LoginRequest(BaseModel):
    phone: Optional[str] = None
    email: Optional[str] = None
    password: Optional[str] = None
    otp: Optional[str] = None
    abha_id: Optional[str] = None

class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    user_id: Optional[str] = None
    role: Optional[str] = "patient"
    name: Optional[str] = None

class UserResponse(BaseModel):
    id: str
    name: str
    phone: Optional[str] = None
    email: Optional[str] = None
    gender: Optional[str] = None
    dob: Optional[str] = None
    age: Optional[int] = None
    language: Optional[str] = "hi"
    abha_id: Optional[str] = None
    role: RoleEnum
    profile_completeness: Optional[int] = 85
    model_config = ConfigDict(from_attributes=True)
