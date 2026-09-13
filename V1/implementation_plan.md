# MediKiosk — Conversational Module & Document Pipeline Implementation Plan

**Problem Statement:** SIH26047 — Patient Case-Taking Software  
**Architecture:** Gemini 2.5 Flash (`google-genai`) · Structured Output · Two-Call Safety Verifier (`Verdict`) · Supabase (Postgres + Storage) · FastAPI · Flutter App  
**Target Delivery:** Phased implementation adhering strictly to the user-provided specification and notebook pattern.

---

## User Review Required

> [!IMPORTANT]
> **Database & Storage Strategy (Supabase + Local SQLite Hybrid):**
> The existing backend currently runs on async SQLite (`medikiosk.db`) for immediate offline kiosk operation and local device testing. In this plan, we will introduce:
> 1. **Supabase Client (`app/supabase.py`)**: Connecting directly via `SUPABASE_URL` and `SERVICE_ROLE` from `.env`.
> 2. **Supabase Storage**: Private `medical-documents` bucket for secure file uploads and signed URL delivery.
> 3. **PostgreSQL / Supabase Schema & Migration Tool**: `scripts/migrate_to_supabase.py` with zero-data-loss export, transform, import, and verification.
> 4. **Gemini 2.5 Flash Multimodal Vision**: Replaces OCR pipeline for prescriptions and lab reports, enforcing the `source_quote` grounding rule on every extracted item.
> 5. **Two-Call Safety Verifier**: Proposal call (`InterviewStep`) + independent verification call (`Verdict`) to prevent hallucinations and ungrounded claims.

> [!NOTE]
> **API Contract Preservation:**
> All existing REST endpoints used by the Flutter mobile app (`/api/v1/chat/*`, `/api/v1/documents/*`, `/api/v1/auth/*`, `/portal/*`) will maintain complete backward-compatibility so the live Android device session remains unaffected.

---

## Proposed Changes by Phase

### Phase 1: Supabase Client, Schema Definition & Zero-Loss Migration
- Create `backend/app/supabase.py` providing a singleton Supabase client using `SUPABASE_URL` and `SERVICE_ROLE` from `.env`.
- Ensure private bucket `medical-documents` is initialized and accessible.
- Create `backend/scripts/migrate_to_supabase.py` providing zero-data-loss SQLite-to-Postgres migration, checksum validation, and schema verification.
- Update `backend/app/config.py` with settings for `GOOGLE_API_KEY`, `SUPABASE_URL`, `SUPABASE_KEY`, `SERVICE_ROLE`, `GEMINI_MODEL="gemini-2.5-flash"`, `VERIFY_ENABLED=True`, and `MOCK_GEMINI=False`.

#### [NEW] [supabase.py](file:///home/aditya/Downloads/SIH%202026/V1/backend/app/supabase.py)
#### [NEW] [migrate_to_supabase.py](file:///home/aditya/Downloads/SIH%202026/V1/backend/scripts/migrate_to_supabase.py)
#### [MODIFY] [config.py](file:///home/aditya/Downloads/SIH%202026/V1/backend/app/config.py)

---

### Phase 2: Gemini Core Client with Structured Output, Two-Call Verifier & Offline Mock
- Create `backend/app/gemini/schemas.py` containing Pydantic models:
  - `Question`: `id`, `text`, `text_en`, `input_type` (mcq, yesno, slider, date, text), `options`, `section`, `progress`.
  - `RedFlag`: `code`, `severity`, `reason`.
  - `InterviewStep`: `type` (question, complete, red_flag), `question`, `red_flag`, `grounded_on`.
  - `Verdict`: `valid: bool`, `reason: str`.
  - `ExtractionResult`: envelope for document extraction.
- Create `backend/app/gemini/client.py`:
  - Implements `GeminiClient` using the modern `google-genai` SDK (`genai.Client`).
  - `structured(system, payload, schema, images=None, max_retries=2)`: enforces `temperature=0`, `response_mime_type="application/json"`, and exponential backoff retry.
  - `verified(system, verifier_prompt, payload, proposal, schema)`: implements the notebook's two-call verification pattern, returning `None` if `verdict.valid == False` to trigger deterministic fallback.
  - `mock_mode`: deterministic mock responses when `MOCK_GEMINI=true` or when testing offline.
  - Safe error reporting: never leaks `GOOGLE_API_KEY` or raw PHI in logs/exceptions.
- Create `backend/tests/test_gemini_client.py` covering structured outputs, retries, verifier rejections, and mock mode.

#### [NEW] [schemas.py](file:///home/aditya/Downloads/SIH%202026/V1/backend/app/gemini/schemas.py)
#### [NEW] [client.py](file:///home/aditya/Downloads/SIH%202026/V1/backend/app/gemini/client.py)
#### [NEW] [test_gemini_client.py](file:///home/aditya/Downloads/SIH%202026/V1/backend/tests/test_gemini_client.py)

---

### Phase 3: Document Vision Pipeline with Grounding & Deterministic Flags
- Create `backend/app/documents/schemas.py`:
  - `MedicineItem`: `name`, `dosage`, `frequency`, `duration`, `instructions`, `confidence`, `source_quote`.
  - `PrescriptionData`: `doctor_name`, `doctor_specialty`, `date`, `medicines`, `diagnosis_hints`.
  - `LabTestItem`: `name`, `value`, `unit`, `ref_range`, `flag` (normal, low, high, critical), `confidence`, `source_quote`.
  - `LabReportData`: `lab_name`, `date`, `panel`, `tests`.
  - `DischargeData`: `hospital`, `admit_date`, `discharge_date`, `diagnoses`, `procedures`, `medicines`, `advice`.
- Create `backend/app/prompts/extractor.py`: system prompts strictly enforcing untrusted data handling, exact `source_quote` capture, and zero hallucination.
- Create `backend/app/documents/pipeline.py`:
  - Background task that takes `document_id`, fetches original image from Supabase Storage (or local storage fallback), runs Gemini 2.5 Flash vision extraction directly on image bytes.
  - Applies **deterministic lab flag rules** (e.g., glucose > 400 or K < 2.5 -> `critical`, numeric bounds against reference range).
  - Applies **deterministic drug interaction rules** (e.g., warfarin + aspirin).
  - Populates `document_items` with verified status and confidence flags.
- Create `backend/app/documents/routes.py` and connect with existing router:
  - `POST /api/v1/documents`: multipart upload to private bucket + background task.
  - `GET /api/v1/documents/{id}/status`: progress polling.
  - `GET /api/v1/documents/{id}/parsed`: parsed items with confidence and flags.
  - `POST /api/v1/documents/{id}/verify`: user confirmation / edits + audit log.
  - `GET /api/v1/documents/{id}/file`: signed URL.
- Create `backend/tests/test_document_pipeline.py`.

#### [NEW] [schemas.py](file:///home/aditya/Downloads/SIH%202026/V1/backend/app/documents/schemas.py)
#### [NEW] [extractor.py](file:///home/aditya/Downloads/SIH%202026/V1/backend/app/prompts/extractor.py)
#### [NEW] [pipeline.py](file:///home/aditya/Downloads/SIH%202026/V1/backend/app/documents/pipeline.py)
#### [NEW] [routes.py](file:///home/aditya/Downloads/SIH%202026/V1/backend/app/documents/routes.py)
#### [NEW] [test_document_pipeline.py](file:///home/aditya/Downloads/SIH%202026/V1/backend/tests/test_document_pipeline.py)

---

### Phase 4: Grounded Conversational Interviewer & Safety Verifier
- Create `backend/system_instruction.txt`: the master clinical interviewer instruction (bilingual Hindi/English, untrusted patient inputs, section progression: chief complaint -> HPI (SOCRATES) -> PMH -> drugs/allergies -> family -> personal -> ROS -> AYUSH).
- Create `backend/app/prompts/interviewer.py`: loader for system instruction + AYUSH extensions.
- Create `backend/app/prompts/verifier.py`: `VERIFIER_PROMPT` for call #2 verification.
- Create `backend/app/chat/ontology.py`:
  - Deterministic question graph (SOCRATES templates per complaint, ROS checklist, AYUSH Agni/Koshtha MCQs).
  - Deterministic red-flag keyword & regex rules (chest pain + dyspnea/sweating, FAST stroke, hematemesis, altered sensorium).
  - Offline fallback generator.
- Create `backend/app/chat/engine.py`:
  - `assemble_context()`: gathers recent messages, patient profile, visit answers so far, and patient's parsed document items.
  - `next_step()`: Two-call sequence (Proposal -> Verifier -> Ontology Fallback on rejection/failure).
  - Red-flag priority bypass: immediate return on critical danger signs.
- Update `backend/app/api/v1/chat.py` / `backend/app/chat/routes.py` to route sessions through the new engine.
- Create `backend/tests/test_chat_engine.py`.

#### [NEW] [system_instruction.txt](file:///home/aditya/Downloads/SIH%202026/V1/backend/system_instruction.txt)
#### [NEW] [interviewer.py](file:///home/aditya/Downloads/SIH%202026/V1/backend/app/prompts/interviewer.py)
#### [NEW] [verifier.py](file:///home/aditya/Downloads/SIH%202026/V1/backend/app/prompts/verifier.py)
#### [NEW] [ontology.py](file:///home/aditya/Downloads/SIH%202026/V1/backend/app/chat/ontology.py)
#### [NEW] [engine.py](file:///home/aditya/Downloads/SIH%202026/V1/backend/app/chat/engine.py)
#### [NEW] [test_chat_engine.py](file:///home/aditya/Downloads/SIH%202026/V1/backend/tests/test_chat_engine.py)

---

### Phase 5: Red Flags, Emergency Triage & 12-Section Summary Hook
- Implement deterministic emergency rule verification in `test_redflag.py`.
- Ensure minimal alert payload in triage queue (`app/api/v1/alerts.py`) preserving DPDP §7(c) data minimization.
- Connect summary generator (`app/services/summary_service.py`) to assemble all grounded patient answers and parsed documents into the 12-section clinical intake format with doctor versioning.
- Create `backend/tests/test_redflag.py`.

#### [NEW] [test_redflag.py](file:///home/aditya/Downloads/SIH%202026/V1/backend/tests/test_redflag.py)

---

### Phase 6: Flutter App Seamless Interop
- Validate that the existing Flutter app's chat screen (`P-08/P-09`), emergency overlay (`P-11`), document upload & review (`P-13/P-14/P-15`), and appointments continue to render seamlessly against the new engine.
- Verify hot reload with the running app on the physical Redmi Note 8.

---

### Phase 7: End-to-End Smoke Test Suite & Demo Verification
- Create `backend/scripts/e2e_smoke.py`:
  1. Register demo patient -> Obtain JWT
  2. Complete Prakriti assessment
  3. Start AYUSH chat session -> Answer questions -> Assert section ordering
  4. Upload sample document -> Poll ready -> Assert extracted medicines with `source_quote`
  5. Post verification -> Check verified flag
  6. Trigger red flag ("seene mein dard aur saans phool rahi hai") -> Assert immediate emergency response
  7. Generate summary -> Assert 12 sections
  8. Doctor portal -> Accept summary -> Assert version increment
- Execute full test suite (`pytest tests/ -v`).

#### [NEW] [e2e_smoke.py](file:///home/aditya/Downloads/SIH%202026/V1/backend/scripts/e2e_smoke.py)

---

## Verification Plan

### Automated Tests
- Run `pytest tests/test_gemini_client.py -v` to verify Gemini structured outputs and two-call verifier.
- Run `pytest tests/test_document_pipeline.py -v` to verify multimodal vision extraction and deterministic lab/drug flags.
- Run `pytest tests/test_chat_engine.py -v` to verify context assembly, grounding rule, and section progression.
- Run `pytest tests/test_redflag.py -v` to verify offline deterministic emergency alerts.
- Run `python scripts/e2e_smoke.py` against the running server to verify the full 10-step patient journey.

### Physical Device Verification
- Perform live chat interaction on the **Redmi Note 8**.
- Upload a test prescription photo from the phone camera/gallery and verify extracted medicine cards.
- Test emergency trigger on the phone and verify the emergency screen renders instantly.
- Check Doctor Web Portal at `http://127.0.0.1:8000/portal/queue` to confirm real-time synchronization.
