from pydantic import BaseModel, Field
from typing import Literal, Optional, List

class QuestionOptionItem(BaseModel):
    key: str = ""
    label: str = ""
    label_en: str = ""
    label_hi: str = ""
    icon: str = ""
    dosha: str = ""

class ProgressInfo(BaseModel):
    done: int = 1
    total: int = 10

class Question(BaseModel):
    id: str
    text: str                                            # User language (e.g. Hindi)
    text_en: str = ""
    input_type: Literal["mcq", "yesno", "slider", "date", "text"]
    options: List[QuestionOptionItem] = Field(default_factory=list) # [{"key":"A","label":"...","icon":"food"}]
    section: str                                         # chief_complaint | hpi | past | drugs | family | personal | ros | ayush
    progress: ProgressInfo = Field(default_factory=ProgressInfo)

class RedFlag(BaseModel):
    code: str                                            # CHEST_PAIN_DYSPNEA, STROKE_FAST, HEMATEMESIS, etc.
    severity: Literal["high", "medium"] = "high"
    reason: str                                          # Grounded explanation of symptom detected

class InterviewStep(BaseModel):
    type: Literal["question", "complete", "red_flag"]
    question: Optional[Question] = None
    red_flag: Optional[RedFlag] = None
    grounded_on: List[str] = Field(default_factory=list) # Ref IDs of document items or profile fields

class Verdict(BaseModel):
    valid: bool
    reason: str

class ExtractedItem(BaseModel):
    category: str = ""
    label: str = ""
    value: str = ""
    unit: str = ""
    ref_range: str = ""
    flag: str = "normal"
    confidence: float = 0.9
    source_quote: str = ""

class ExtractionResult(BaseModel):
    """Generic envelope for parsed documents with itemized grounding."""
    doc_type: str
    items: List[ExtractedItem] = Field(default_factory=list)
    overall_confidence: float = 0.0
