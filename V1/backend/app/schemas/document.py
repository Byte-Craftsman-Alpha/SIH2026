from pydantic import BaseModel, ConfigDict, Field
from typing import Optional, List, Dict, Any

class DocumentItemResponse(BaseModel):
    id: str
    user_id: str
    doc_type: str
    original_path: str
    doc_date: Optional[str] = None
    uploaded_at: Optional[str] = None
    confidence: float
    verify_status: str
    flags: Optional[Dict[str, Any]] = {}
    model_config = ConfigDict(from_attributes=True)

class DocumentUploadResponse(BaseModel):
    document_id: str
    status: str
    message: str
    job_id: str

class DocumentStatusResponse(BaseModel):
    document_id: str
    status: str  # "uploaded" | "ocr_processing" | "extracting" | "ready" | "failed"
    progress_percent: int
    estimated_seconds: int

class ExtractedItem(BaseModel):
    name: str
    dosage: Optional[str] = None
    frequency: Optional[str] = None
    duration: Optional[str] = None
    instructions: Optional[str] = None
    confidence: float = 0.9

class DocumentParsedResponse(BaseModel):
    doc_id: str
    doc_type: str
    doc_date: Optional[str] = None
    ocr_lang: List[str] = ["hi", "en"]
    overall_confidence: float
    extracted: Any
    flags: Dict[str, Any]
    verify_status: str

class DocumentEditItem(BaseModel):
    field: str
    old_value: Any
    new_value: Any

class DocumentVerifyRequest(BaseModel):
    status: str = "verified"  # "verified" | "unverified"
    edits: Optional[List[DocumentEditItem]] = []

class TimelineEvent(BaseModel):
    id: str
    type: str  # "prescription" | "lab_report" | "discharge_summary" | "visit_summary"
    title: str
    date: str
    year: str
    summary_text: Optional[str] = None
    verified: bool
    has_flags: bool
    doctor_name: Optional[str] = None
    details_url: str
