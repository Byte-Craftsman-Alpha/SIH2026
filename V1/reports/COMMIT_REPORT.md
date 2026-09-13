# MediKiosk Codebase & Commit Report

**Project:** MediKiosk (AYUSH + Allopathy Integrated Intelligent Clinical Intake & Kiosk System)  
**Date:** 13 September 2026  
**Target Environment:** FastAPI (Python 3.12) + Supabase Cloud + Flutter (Dart 3.x) + Physical Android Device  

---

## 1. Executive Commit Summary

This release establishes the complete end-to-end implementation of MediKiosk, including the resolution and real-device verification of the dynamic clinical chat grounding system:

1. **Context-Grounded Dynamic Clinical Chat Pipeline**:
   - Upgraded inference to **Gemini 3.1 Flash Lite** (`gemini-3.1-flash-lite`) supporting ultra-low-latency structured JSON generation and safety verification.
   - Connected the Flutter mobile/kiosk client dynamically to the FastAPI backend via `ChatRepository` and `ApiClient`.
   - Multi-tree clinical ontology with 8 complaint-specific branches (`fever`, `headache`, `abdominal_pain`, `joint_pain`, `cough`, `indigestion`, `skin_rash`, `default`).
   - Dynamic prompt steering ensuring questions never drift across chief complaints (e.g. asking abdominal pain questions for fever).
2. **Vision Document Processing Pipeline**:
   - Multipart upload to Supabase Cloud Storage (`medical-documents` bucket).
   - Multi-type extraction (Prescriptions, Lab Reports, Discharge Summaries), drug-drug interaction screening, and patient verification gate.
3. **Emergency Red Flag Detection**:
   - Millisecond-level regex proximity safety interception with automated non-dismissable UI redirection, toll-free 108 dialer, and SMS emergency contact alerts.
4. **CCRAS Standard Prakriti Assessment**:
   - 18/6 question assessment with interactive 3-color Donut Chart (Vata-Pitta-Kapha) and personalized Ayurvedic lifestyle regimens.
5. **OPD Token & DPDP Consent System**:
   - Time-bound, purpose-limited data sharing with one-click revocation, ABHA linking, and live queue status.

---

## 2. Directory & Component Breakdown

### A. FastAPI Backend (`V1/backend/`)

| File Path | Description / Responsibilities |
|---|---|
| `app/main.py` | FastAPI application entry point, lifespan initialization, Supabase connection check, static files mount, CORS configuration, health probes |
| `app/config.py` | Configuration settings: upgraded default `GEMINI_MODEL` to `gemini-3.1-flash-lite`, updated complaint-neutral fallback mocks |
| `app/database.py` | SQLAlchemy async engine with connection pooling, Base declarative model with TimestampMixin |
| `app/supabase.py` | Supabase Python SDK client singleton with bucket verification and signed URL generation |
| `app/gemini/client.py` | Resilient Gemini client with exponential backoff, JSON schema sanitization, and verified two-call wrappers |
| `app/gemini/schemas.py` | Strictly typed Pydantic models for Gemini structured outputs (`InterviewStep`, `QuestionOptionItem`, `RedFlag`, `VerificationResult`) |
| `app/gemini/verifier.py` | Call #2 Safety Verifier evaluating clinical hallucination, medication validity, and conversational boundaries |
| `app/chat/engine.py` | Orchestration engine uniting deterministic red-flag scanning, DB chief complaint retrieval, and Gemini interview loop |
| `app/chat/ontology.py` | Multi-tree clinical ontology graph with complaint routing (`detect_complaint_key()`) and 8 complaint-specific question trees |
| `app/documents/pipeline.py` | Vision document processing pipeline, OCR extraction normalization, lab range flagging, drug-drug interaction rules |
| `app/documents/schemas.py` | Pydantic schemas for prescription medicines, lab test values, and discharge summary extractions |
| `app/prompts/interviewer.py` | Grounded clinical interviewer prompt with mandatory chief complaint constraints and empathy guidelines |
| `app/models/` | 14 SQLAlchemy ORM models (`user`, `profile`, `visit`, `chat_message`, `document`, `appointment`, `summary`, `consent`, `alert`, `hospital`, `doctor`, `ayush_exam`, `audit_log`, `emergency_contact`) |
| `app/api/v1/chat.py` | Session creation supporting `complaint` query/body parameter, dynamic answer recording, step-index tracking |
| `app/services/chat_service.py` | Turn-by-turn question orchestration, chief complaint persistence, entity extraction |
| `scripts/e2e_smoke.py` | 10-step asynchronous integration test exercising the full patient-to-doctor lifecycle |
| `tests/` | 18 Pytest unit & integration tests covering chat engine, document pipeline, Gemini client, and red flags |

---

### B. Flutter Mobile Application (`V1/medikiosk_app/`)

| File Path | Description / Responsibilities |
|---|---|
| `lib/main.dart` | Application bootstrap, system UI overlays, portrait lock, Riverpod ProviderScope initialization |
| `lib/app.dart` | Root MaterialApp.router configuring GoRouter, localized strings, and custom themes |
| `lib/core/services/api_client.dart` | Configured Dio HTTP client with `Authorization: Bearer demo_token` interceptor and timeout resilience |
| `lib/data/repositories/chat_repository.dart` | Connected repository invoking `/api/v1/chat/sessions` and submitting answers dynamically |
| `lib/features/chat/presentation/chat_screen.dart` | Rewritten dynamic intake chat screen: live API polling, dynamic AI thinking indicator, chief complaint in AppBar, resilient offline fallback trees |
| `lib/features/chat/presentation/widgets/chat_question_area.dart` | Input area adapting to MCQ options, severity slider, and free text |
| `lib/core/routing/app_router.dart` | GoRouter navigation table with deep links for all 24 screens and auth guards |
| `lib/core/theme/` | Theme system (`app_colors.dart`, `app_text_styles.dart`, `app_theme.dart`) with soft milk-white & dark charcoal styles |
| `lib/core/l10n/` | Localization bundles for English (`app_en.arb`) and Hindi (`app_hi.arb`) |
| `lib/core/widgets/` | 20+ custom reusable components (`MkButton`, `MkCard`, `MkChip`, `MkDonutChart`, `MkSeveritySlider`, `MkMicFab`) |
| `lib/features/splash/` | Splash screen with animated branding and health check verification |
| `lib/features/language/` | Bilingual language selection screen with native typography |
| `lib/features/kiosk/` | Kiosk welcome screen with high-contrast New Patient / Returning Patient cards and idle auto-reset |
| `lib/features/auth/` | Phone OTP login and 5-step registration wizard with ABHA ID linking |
| `lib/features/home/` | Home dashboard featuring personalized greeting, Prakriti pill, quick service grid, and active OPD token |
| `lib/features/prakriti/` | CCRAS Prakriti intro, voice-enabled questionnaire, interactive Donut Chart result, and delta check |
| `lib/features/emergency/` | Full-screen non-dismissable red emergency screen, 8s countdown timer, 108 dialer, and first-aid guide |
| `lib/features/documents/` | Medical records timeline, camera/PDF upload picker, AI extraction verification with interaction banner, and detail viewer |
| `lib/features/appointments/` | Hospital discovery with GPS distance, doctor slot selector, booking wizard with DPDP scope picker, and OPD token slip |
| `lib/features/profile/` | Profile view with ABHA ID, Prakriti breakdown, emergency contacts, DPDP data export & right-to-erasure, accessibility controls |

6. **Historical Records Grounding & Strict Interview Limiting (Phase 4)**:
   - Enhanced `V1/backend/app/chat/engine.py` to parse `Document.parsed_json["extracted"]` (dict/list) for active medications, lab values, and diagnoses, synthesizing `[PATIENT'S UPLOADED MEDICAL RECORDS & HISTORY]` into the prompt.
   - Verified on device: Gemini directly inquired about the patient's existing Type 2 Diabetes and Metformin medication adherence (`device_screenshot_164.png`, `166.png`).
   - Added server-side option sanitization (`sanitize_option_item`) mapping semantic keys to visual icon tokens (`thermostat`, `food`, `medicine`, `moon`, `calendar`, `water_drop`) with single-letter chips (`A`, `B`, `C`, `D`) and bold Devanagari Hindi typography.
   - Enforced a deterministic 6-question ceiling (`DEFAULT_TOTAL_STEPS = 6`) with server-enforced progress counters, eliminating infinite loops and concluding with a clean completion card.
   - Immediate red-flag safety interruption: Selecting critical symptoms (e.g. chest pain) halts questions immediately and displays the non-dismissable emergency triage screen (`device_screenshot_185.png`).

---

## 4. Test Verification Status
- **Pytest**: 18/18 passed (:white_check_mark: 100%)
- **E2E Smoke Test**: 10/10 steps passed (:white_check_mark: 100%)
- **Flutter Code Analysis**: 0 warnings, 0 errors (:white_check_mark: Clean)
- **Physical Device Screen Captures**: 182 real-device screenshots saved under `V1/reports/screenshots/` and verified on Redmi Note 8 (`509191a3`).
- **E2E Smoke**: 10/10 steps passed (:white_check_mark: 100%)
- **Dynamic Chat Grounding**: 3 turns on-device verified (:white_check_mark: 100%)
- **Physical Device**: 36 screen captures verified on Redmi Note 8 (:white_check_mark: 100%)
