import os
from typing import Dict, Any
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore"
    )

    DATABASE_URL: str = ""
    ENV_MODE: str = "beta"  # "beta" (local SQLite) or "production" (Vercel + Supabase)
    USE_SUPABASE: bool = False
    JWT_SECRET_KEY: str = "medikiosk_super_secure_sha256_jwt_secret_key_aiia_new_delhi_2026_sih"
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7
    APP_VERSION: str = "2.0.0"
    DEMO_MODE: bool = True

    # Supabase credentials
    SUPABASE_URL: str = ""
    SUPABASE_KEY: str = ""
    SERVICE_ROLE: str = ""
    ANON_KEY: str = ""

    # Google Gemini credentials & settings
    GOOGLE_API_KEY: str = ""
    GEMINI_MODEL: str = "gemini-3.1-flash-lite"
    VERIFY_ENABLED: bool = True
    MOCK_GEMINI: bool = False

    # Mock responses for testing / offline demo
    MOCK_RESPONSES: Dict[str, Any] = {
        "InterviewStep": {
            "type": "question",
            "question": {
                "id": "HPI_01",
                "text": "यह समस्या आपको कब और कैसे शुरू हुई?",
                "text_en": "When and how did this condition begin?",
                "input_type": "mcq",
                "options": [
                    {"key": "acute_hours", "label": "अचानक कुछ घंटों पहले (Past few hours)"},
                    {"key": "subacute_days", "label": "पिछले 2-3 दिनों से (Past 2-3 days)"},
                    {"key": "chronic_weeks", "label": "1 हफ्ते या अधिक समय से (>1 week)"}
                ],
                "section": "hpi",
                "progress": {"done": 2, "total": 10}
            },
            "grounded_on": ["chief_complaint"]
        },
        "Verdict": {
            "valid": True,
            "reason": "Follows section progression and grounded in reported complaint."
        },
        "PrescriptionData": {
            "doctor_name": "Dr. Rajesh Sharma",
            "doctor_specialty": "Kayachikitsa",
            "date": "2026-09-10",
            "medicines": [
                {
                    "name": "Avipattikar Churna",
                    "dosage": "3g",
                    "frequency": "Twice daily",
                    "duration": "14 days",
                    "instructions": "Before meals with lukewarm water",
                    "confidence": 0.94,
                    "source_quote": "Avipattikar Churna 3g BD before food"
                },
                {
                    "name": "Kamdudha Ras",
                    "dosage": "250mg",
                    "frequency": "Twice daily",
                    "duration": "14 days",
                    "instructions": "After meals with honey/water",
                    "confidence": 0.91,
                    "source_quote": "Kamdudha Ras 1 tab BD"
                }
            ],
            "diagnosis_hints": [
                {"text": "Amlapitta (Hyperacidity / Acid reflux)", "confidence": 0.89, "source_quote": "Dx: Amlapitta"}
            ]
        },
        "LabReportData": {
            "lab_name": "Dr. Lal PathLabs",
            "date": "2026-09-08",
            "panel": "Metabolic Panel & Blood Glucose",
            "tests": [
                {
                    "name": "Fasting Blood Sugar (FBS)",
                    "value": "112",
                    "unit": "mg/dL",
                    "ref_range": "70 - 100",
                    "flag": "high",
                    "confidence": 0.96,
                    "source_quote": "Fasting Blood Sugar: 112 mg/dL (Ref: 70-100)"
                },
                {
                    "name": "HbA1c",
                    "value": "6.2",
                    "unit": "%",
                    "ref_range": "4.0 - 5.6",
                    "flag": "high",
                    "confidence": 0.98,
                    "source_quote": "HbA1c: 6.2 % (Normal: 4.0 - 5.6)"
                }
            ]
        }
    }

settings = Settings()

# Auto-detect Vercel serverless environment
if os.environ.get("VERCEL") or os.environ.get("VERCEL_ENV"):
    settings.ENV_MODE = "production"
    settings.USE_SUPABASE = True

# Resolve effective DATABASE_URL
if not settings.DATABASE_URL:
    if os.environ.get("VERCEL") or os.environ.get("VERCEL_ENV"):
        settings.DATABASE_URL = "sqlite+aiosqlite:////tmp/medikiosk.db"
    else:
        settings.DATABASE_URL = "sqlite+aiosqlite:///./medikiosk.db"
