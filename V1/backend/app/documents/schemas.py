from pydantic import BaseModel, Field
from typing import Literal, Optional, List

class MedicineItem(BaseModel):
    name: str
    dosage: str = ""
    frequency: str = ""
    duration: str = ""
    instructions: str = ""
    confidence: float = 0.85
    source_quote: str = ""

class TextQuoteItem(BaseModel):
    text: str = ""
    confidence: float = 0.85
    source_quote: str = ""

class PrescriptionData(BaseModel):
    doctor_name: str = ""
    doctor_specialty: str = ""
    date: str = ""
    medicines: List[MedicineItem] = Field(default_factory=list)
    diagnosis_hints: List[TextQuoteItem] = Field(default_factory=list)

class LabTestItem(BaseModel):
    name: str
    value: str
    unit: str = ""
    ref_range: str = ""
    flag: Literal["normal", "low", "high", "critical"] = "normal"
    confidence: float = 0.9
    source_quote: str = ""

class LabReportData(BaseModel):
    lab_name: str = ""
    date: str = ""
    panel: str = ""
    tests: List[LabTestItem] = Field(default_factory=list)

class DischargeData(BaseModel):
    hospital: str = ""
    admit_date: str = ""
    discharge_date: str = ""
    diagnoses: List[TextQuoteItem] = Field(default_factory=list)
    procedures: List[TextQuoteItem] = Field(default_factory=list)
    medicines: List[MedicineItem] = Field(default_factory=list)
    advice: str = ""

class VerifyEditItem(BaseModel):
    item_id: Optional[str] = None
    field: str
    new_value: str

class DocumentVerifyRequest(BaseModel):
    status: Literal["verified", "unverified"] = "verified"
    edits: List[VerifyEditItem] = Field(default_factory=list)
