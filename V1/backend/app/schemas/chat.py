from pydantic import BaseModel, ConfigDict
from typing import Optional, List, Dict, Any, Union

class ChatSessionCreate(BaseModel):
    mode: Optional[str] = "general"  # "general" | "ayush"
    complaint: Optional[str] = None
    visit_type: Optional[str] = "walkin"
    language: Optional[str] = "hi"

class ChatSessionResponse(BaseModel):
    session_id: str
    mode: str
    status: str
    first_question: Optional[Dict[str, Any]] = None

class AnswerRequest(BaseModel):
    question_id: str
    input_type: str
    answer: Dict[str, Any]
    session_lang: Optional[str] = "hi"

class QuestionOption(BaseModel):
    key: str
    label: Optional[str] = None
    label_en: Optional[str] = None
    label_hi: Optional[str] = None
    icon: Optional[str] = None
    dosha: Optional[str] = None

class QuestionPayload(BaseModel):
    id: str
    text: str
    text_en: str
    text_hi: Optional[str] = None
    input: str
    options: List[Dict[str, Any]] = []
    tts_audio_url: str
    section: str
    progress: Dict[str, int]

class AnswerResponse(BaseModel):
    type: str  # "question" | "red_flag" | "complete"
    question: Optional[Dict[str, Any]] = None
    red_flag: Optional[Dict[str, Any]] = None
    session_status: str
    summary_id: Optional[str] = None

class VoiceUploadResponse(BaseModel):
    transcript: str
    mapped_option: Optional[str] = None
    confidence: float = 0.92

class RedFlagResponse(BaseModel):
    is_flagged: bool
    code: Optional[str] = None
    severity: Optional[str] = None
    instruction: Optional[str] = None
    message: Optional[str] = None
