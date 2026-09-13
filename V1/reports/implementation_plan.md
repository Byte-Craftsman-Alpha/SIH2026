# Implementation Plan: Context-Grounded Clinical Chat & Bounded Questioning with Visual Icons

Fix the clinical intake chat so that:
1. **Question limits are strictly enforced** (target: 5–6 questions max), with user consent required to ask 2 additional clarifying questions if the diagnosis is ambiguous, and immediate abortion to the emergency flow if critical conditions/red flags are detected.
2. **Options always have clear Hindi text** (bilingual with English secondary text), eliminating missing Hindi translations.
3. **Every option displays a meaningful visual icon** (e.g., sun for morning, moon for evening, clock for continuous, calendar for days, snowflake for chills, thermometer for fever) instead of truncated text badges.
4. **Questions are deeply grounded in the patient's uploaded medical records** (past prescriptions, abnormal lab reports, discharge history) retrieved from the database.

---

## User Review Required

> [!IMPORTANT]
> - **Question Count Target**: Standard clinical intake will be bounded to **5 to 6 questions**.
> - **Consent Extension**: If the problem remains ambiguous at question 6, an interactive consent card will ask: *"लक्षणों को और गहराई से समझने के लिए 2 और प्रश्न पूछने की आवश्यकता है। क्या आप जारी रखना चाहते हैं?"* (Yes / Conclude Now).
> - **Emergency Precedence**: If any red-flag symptom is detected at any turn, questioning halts immediately with zero additional questions and transfers directly to the emergency flow (`/emergency`).
> - **Medical Records Integration**: Past medications (e.g., Metformin, Amlodipine, Triphala), abnormal labs (e.g., Fasting Glucose: 186 mg/dL, HbA1c: 8.2%), and previous diagnoses will be actively woven into the AI interviewer prompt.

---

## Proposed Changes

### 1. Backend: Context Grounding & Document History Parser

#### [MODIFY] [engine.py](file:///home/aditya/Downloads/SIH%202026/V1/backend/app/chat/engine.py)
- Fix `assemble_context()`: Properly parse `d.parsed_json["extracted"]` when it is a `dict` (e.g., `medicines`, `tests`, `diagnosis_hints`) or a `list`.
- Format a clean `patient_history_summary` string in `payload`:
  - Ongoing medications (e.g. Metformin, Amlodipine, Triphala)
  - Abnormal lab results (e.g. Fasting Blood Sugar 186 mg/dL, HbA1c 8.2%)
  - Past diagnoses (e.g. Type 2 Diabetes Mellitus)
- Track `step_index` and `total_questions` deterministically (default `total_questions = 6`).
- When `step_index >= total_questions`:
  - If clear, return `InterviewStep(type="complete")`.
  - If ambiguous and user consent not yet requested, return a consent question step:
    `id: "CONSENT_EXTEND_INTAKE"`, asking user if they consent to 2 additional clarifying questions.

#### [MODIFY] [interviewer.py](file:///home/aditya/Downloads/SIH%202026/V1/backend/app/prompts/interviewer.py) & [system_instruction.txt](file:///home/aditya/Downloads/SIH%202026/V1/backend/system_instruction.txt)
- Enforce strict JSON output rules:
  - `key`: MUST be a single letter (`"A"`, `"B"`, `"C"`, `"D"`, etc.).
  - `label_hi`: MANDATORY Hindi text for the option. NEVER empty.
  - `label_en`: English translation of the option.
  - `icon`: Standard icon key (`"sun"`, `"moon"`, `"clock"`, `"calendar"`, `"thermostat"`, `"chills"`, `"pain"`, `"stomach"`, `"medicine"`, `"lungs"`, etc.).
- Add `[PATIENT MEDICAL RECORDS]` section to the system prompt, instructing Gemini to ground questions on the patient's existing conditions and medications where clinically relevant (e.g. checking if fever/appetite affects blood sugar medication).

#### [MODIFY] [schemas.py](file:///home/aditya/Downloads/SIH%202026/V1/backend/app/gemini/schemas.py)
- Ensure `QuestionOptionItem` fields have sane defaults and sanitizer for `key` and `icon`.

---

### 2. Frontend: Dynamic Question Bounds, Visual Icons & Hindi Typography

#### [MODIFY] [chat_question_area.dart](file:///home/aditya/Downloads/SIH%202026/V1/medikiosk_app/lib/features/chat/presentation/widgets/chat_question_area.dart)
- Replace the 28x28 circle containing truncated text (`cons`, `eve`, `mor`) with:
  1. A dedicated 40x40 rounded container displaying a **rich visual icon** (e.g., `Icons.wb_sunny_rounded`, `Icons.nightlight_round`, `Icons.access_time_rounded`, `Icons.calendar_month_rounded`, `Icons.ac_unit_rounded`, `Icons.thermostat_rounded`, `Icons.medication_rounded`, `Icons.healing_rounded`, `Icons.restaurant_rounded`, etc.).
  2. Smart icon inference function `_resolveIcon(opt)`: Maps `opt["icon"]` or analyzes Hindi/English keywords (e.g., morning/सुबह -> sun, evening/शाम -> moon, all day/लगातार -> clock, days/हफ्ते -> calendar, chills/ठंड -> snow, medicine/दवा -> pills).
  3. A neat letter badge chip (`A`, `B`, `C`, `D`).
  4. Primary display of `label_hi` in clear, bold typography, with `label_en` underneath as a subtitle.

#### [MODIFY] [chat_screen.dart](file:///home/aditya/Downloads/SIH%202026/V1/medikiosk_app/lib/features/chat/presentation/chat_screen.dart)
- Update question progress tracking:
  - Cap default intake to **6 questions** (`प्रश्न current / total`), incrementing only with turn progression.
  - Prevent Gemini from hallucinating out-of-order progress (e.g., `प्रश्न 8 / 12`).
  - Handle `CONSENT_EXTEND_INTAKE`: Render an interactive consent prompt asking if the user consents to 2 clarifying questions, updating `total` to 8 if approved, or immediately completing if declined.
  - On `res["type"] == "red_flag"`: Immediately interrupt and navigate to `/emergency`.
  - On `res["type"] == "complete"`: Show complete summary message and CTA to view generated clinical summary.

---

## Verification Plan

### Automated Tests
1. Backend Unit Tests:
   ```bash
   cd /home/aditya/Downloads/SIH\ 2026/V1/backend && ./venv/bin/pytest tests/ -v
   ```
   - Verify `assemble_context` extracts medications & abnormal labs from `Document` dictionary fixtures.
   - Verify deterministic red-flag abort behavior.
   - Verify schema validation of `QuestionOptionItem` with `label_hi` and `icon`.
2. E2E Integration Smoke Test:
   ```bash
   cd /home/aditya/Downloads/SIH\ 2026/V1/backend && ./venv/bin/python scripts/e2e_smoke.py
   ```

### Real Device Manual Verification (Redmi Note 8, `509191a3`)
1. Launch clinical intake on Redmi Note 8 via ADB.
2. Select **"बुखार (Fever)"**.
3. Verify Turn 1:
   - Question counter correctly displays **"प्रश्न 1 / 6"** (not 8/12).
   - Options show clear Hindi text with English subtitle.
   - Options show proper visual icons (e.g. calendar for duration, clock for time).
4. Verify Turn 2 (pattern):
   - Options show sun for morning, moon for evening, clock for constant throughout day.
   - No truncated text circle (`cons`, `eve`, `mor`).
5. Verify Question Bounds:
   - Intake completes at question 6, or displays consent card to add 2 questions.
6. Verify Grounding on History:
   - Check that the AI references or incorporates known context (e.g. diabetic history or Metformin) during the interview.
7. Capture on-device screenshots and update `walkthrough.md`, `TEST_REPORT.md`, and `COMMIT_REPORT.md`.
