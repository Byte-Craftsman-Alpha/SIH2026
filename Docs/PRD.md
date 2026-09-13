# MediKiosk — AI-Powered Clinical History Intake Platform

## Product Requirements Document (PRD) v1.0

| | |
|---|---|
| **Problem Statement** | SIH26047 — Patient Case-Taking Software |
| **Sponsor** | Ministry of Ayush — All India Institute of Ayurveda (AIIA) |
| **Category / Theme** | Software / Smart Automation |
| **Tech Stack (fixed)** | Patient app: **Flutter** · Backend: **Python Flask** · DB: PostgreSQL |
| **Status** | Draft for team alignment & submission prep |

---

## 1. Document Overview

### 1.1 Purpose
This PRD defines the complete functional, technical and compliance scope of **MediKiosk** — an AI-powered, patient-facing clinical history intake platform that lets a patient record a comprehensive medical history (voice + touch), digitize prior medical documents, and generate a physician-ready structured summary **before** entering the consultation room — with AYUSH (Ayurvedic) history support and ABDM/ABHA interoperability.

### 1.2 Glossary

| Term | Meaning |
|---|---|
| **ABHA** | Ayushman Bharat Health Account — national digital health ID |
| **ABDM** | Ayushman Bharat Digital Mission — national digital health infra |
| **FHIR** | HL7 FHIR — healthcare data interchange standard used by ABDM |
| **HIS / EMR** | Hospital Information System / Electronic Medical Record |
| **DPDP Act 2023** | Digital Personal Data Protection Act, 2023 (India) |
| **Dashavidha Pariksha** | Ayurvedic 10-point patient examination: Prakriti, Vikriti, Sara, Samhanana, Pramana, Satmya, Sattva, Ahara Shakti, Vyayama Shakti, Vaya |
| **Prakriti** | Body constitution (Vata/Pitta/Kapha) — fixed at birth |
| **Vikriti** | Current imbalance / morbidity state — changes every visit |
| **Agni / Koshtha** | Digestive capacity / bowel nature |
| **Nidana / Samprapti** | Causative factors / pathogenesis (disease pathway) |
| **SOCRATES** | Standard probing framework for pain: Site, Onset, Character, Radiation, Associations, Time, Exacerbating/relieving, Severity |
| **HPI / ROS** | History of Present Illness / Review of Systems |
| **ASR / TTS** | Automatic Speech Recognition / Text-to-Speech |
| **OCR** | Optical Character Recognition (printed + handwritten) |
| **Red flag** | Symptom pattern suggesting immediate medical danger |
| **Triage** | Prioritization of patients by urgency |

### 1.3 Core product promise (one line)
> Patient shares their complete story **once** (by voice or tap), their old papers get **digitized and structured**, and the doctor receives a **draft clinical summary in seconds** — every visit, with consent, privacy and audit trail.

---

## 2. Problem & Goals

### 2.1 Problem (from the PS)
- Indian government hospital OPDs see 4,000–10,000 patients/day; average consultation time is 2–5 minutes (BMJ Open 2017: India ≈ 2 min).
- 70–80% of diagnoses come from good history-taking alone — but there is no time to take it.
- Ayurvedic intake (Dashavidha Pariksha, Prakriti, Agni, Koshtha, Ahara-Vihara, Nidana) is far more extensive and gets abbreviated in practice.
- Patients carry paper prescriptions, lab reports, discharge summaries — unstructured, multilingual, chronologically disordered.
- No patient-facing platform captures structured history + digitizes documents **before** the consultation ("first-mile problem" of ABDM).

### 2.2 Goals
| ID | Goal |
|---|---|
| G1 | Patient can independently complete a deep clinical history intake (voice + touch) in under 10 minutes first visit, under 3 minutes repeat visit |
| G2 | Prakriti & static AYUSH profile captured **once**, delta-checked on every visit (no repeated questioning) |
| G3 | Physical medical documents digitized, structured, chronologically organized |
| G4 | A physician-ready structured summary generated per visit and delivered to the doctor before/at consultation |
| G5 | Full consent lifecycle (granular grant, time-bound auto-revoke, audio explanation, audit log) with DPDP 2023 + ABDM compliance |
| G6 | Red-flag (emergency) detection with a working escalation path in both kiosk and app contexts |

### 2.3 Non-goals (out of scope)
- Autonomous diagnosis or prescription by the AI (AI output is always a draft for the doctor)
- Telemedicine / video consultation
- e-Pharmacy, payments, insurance processing
- Building a full hospital HIS (we integrate with HIS via adapters/mocks)

---

## 3. Success Metrics

| Metric | Target |
|---|---|
| First-visit intake completion time | ≤ 10 min |
| Repeat-visit intake time | ≤ 3 min (delta-check model) |
| Doctor time to read history | < 1 min (vs ~3–5 min manual elicitation) |
| Prakriti assessment | ~12 min new patient / ≤ 30 sec returning patient |
| Red-flag detection | sensitivity high on curated emergency patterns; every alert audit-logged |
| Document pipeline | OCR + extraction with user confirmation on every document (human-in-the-loop) |
| Consent coverage | 100% of data shares covered by a consent record |

---

## 4. Personas

| Persona | Profile | Key needs |
|---|---|---|
| **P1 — Elderly / low-literacy patient** | First-time user, Hindi speaker, may not read | Icon-driven UI, audio prompts, voice answers, minimal taps |
| **P2 — Urban repeat patient** | Smartphone comfortable, has old reports | Fast repeat intake, document upload, timeline view |
| **P3 — OPD doctor (Ayurvedic)** | 4–5 min per patient, wants structured history | Read summary in seconds, edit/confirm, see source docs & flags |
| **P4 — Triage nurse / desk staff** | Manages OPD flow | Receive red-flag alerts, locate patient (kiosk ID), prioritize |
| **P5 — Hospital admin** | Compliance owner | Consent ledger, audit logs, DPDP readiness |

---

## 5. System Overview & Architecture

### 5.1 High-level flow

```
PATIENT SIDE (Flutter)                    BACKEND (Flask)                     DOCTOR SIDE
┌──────────────────────┐                ┌─────────────────────┐            ┌──────────────────┐
│ 1. Registration      │                │  Auth + ABHA mock   │            │ Doctor Web Portal │
│ 2. Prakriti intake   │─── REST ──────▶│  Profile engine     │            │ (Flask-served)    │
│ 3. Chat (voice/MCQ)  │                │  Chat/dialogue API  │            │ - Summary screen  │
│ 4. Document upload   │                │  OCR+Parse queue    │── FHIR ───▶│ - Edit/Confirm    │
│ 5. Appointments      │                │  Summary generator  │   (mock)   │ - Source docs     │
│ 6. Emergency flow    │                │  Consent ledger     │            │ - AYUSH exam form │
└──────────────────────┘                │  Audit log          │            └──────────────────┘
                                        │  PostgreSQL         │
                                        └─────────────────────┘
```

### 5.2 Tech-stack mapping

| Layer | Technology | What it does in this product |
|---|---|---|
| Patient app | **Flutter** (mobile; responsive layout for kiosk/tablet) | Registration, Prakriti MCQ, chat UI, camera/gallery upload, consent screens, emergency screen, appointments |
| Voice input | **Bhashini / AI4Bharat ASR** APIs (production) → offline fallback: Vosk / whisper-tiny bundled or stubbed | Hindi/English/regional speech → text |
| Voice output | **flutter_tts / platform TTS** | Audio prompts & confirmations for low-literacy users |
| Backend | **Python Flask** (REST, JWT) | All business APIs, dialogue orchestration, consent & audit services |
| Async jobs | **Celery + Redis** | OCR, document extraction, summary generation (long-running) |
| OCR | **PaddleOCR / EasyOCR** (Hindi+English, printed+handwritten), Tesseract fallback | Document text extraction |
| Extraction & dialogue | **LLM with JSON-schema constrained output** (hosted API or local open model) | Clinical entity extraction, adaptive questions, summarization |
| DB | **PostgreSQL + SQLAlchemy** | All entities below (§7) |
| File store | Local disk (dev) → S3-compatible bucket (prod) | Original documents + parsed JSON |
| Interop | **FHIR adapter (stub in demo)** | Push summary to HIS/ABHA; attachment fallback |
| Offline demo | Seeded fixture data + local fallback models | Judging environment has no guaranteed internet |

> **Offline-first rule:** every AI capability has a graceful fallback (rule-based questions, template extraction, canned demo data). The demo must run fully offline.

---

## 6. Functional Requirements

### FR-1 — Onboarding & Registration

**FR-1.1 Data collected at registration**

| Field | Required | Notes |
|---|---|---|
| Full name | Yes | |
| Date of birth / Age | Yes | Age auto-derived & updated yearly |
| Gender | Yes | |
| Phone (OTP verified) | Yes | Primary login |
| Email | Optional | |
| Preferred language | Yes | Hindi, English, + regional list |
| ABHA ID | Optional | Enter or scan; **mocked in demo** |
| Aadhaar | Optional | Only if ABHA absent; masked storage |
| Emergency contact #1 (family) | Optional | Name, relation, phone; purpose + consent explained |
| Emergency contact #2 (family doctor/hospital) | Optional | Same as above |
| Emergency pre-consent | Optional | "May we alert your contacts / nearest partner hospital in a medical emergency?" |
| Data capture consent | Yes (mandatory) | Audio-guided, plain language, revocable anytime |

**FR-1.2 Requirements**
- Registration must be completable in **under 3 minutes**.
- Entire flow is dual-mode: **audio-guided (TTS) + icon/tap UI** — usable with zero literacy.
- Language selected here drives ALL subsequent TTS, ASR and UI language.
- Consent version + timestamp recorded in consent ledger (§FR-9).

### FR-2 — First Interaction: AYUSH Profile (Dashavidha) Assessment

**FR-2.1 What is captured on first use (after registration)**
A guided **MCQ + voice interview** (questionnaire validated against CCRAS/AIIA standardized Prakriti scales). Every question is answerable by **tapping** or **speaking**.

**FR-2.2 Assessment order on first interaction**
1. **Prakriti** (Vata/Pitta/Kapha scoring → dominant + secondary constitution)
2. **Sattva** (mental temperament)
3. **Samhanana** (body compactness/build)
4. **Sara** (tissue quality — self-report items)
5. **Pramana** (body measurements — self-reported height/weight)
6. **Satmya** (habits & suitability — diet/lifestyle tolerances)

**FR-2.3 Static vs dynamic classification (data model driver)**

| Parameter | Nature | Capture frequency |
|---|---|---|
| Prakriti | **Fixed for life** | Once; delta-confirm each visit |
| Sattva | Mostly fixed | Once; delta-confirm |
| Samhanana | Mostly fixed | Once; delta-confirm |
| Sara | Slow change | Once; yearly refresh prompt |
| Pramana | Changes | Refresh on demand / yearly |
| Satmya | Changes with habits | Delta-check each visit |
| Vaya (age) | Changes | Auto-computed |
| **Vikriti** | **Changes every visit** | Fresh in every chat |
| **Agni** | Changes (season/diet/illness) | Fresh in every visit chat |
| **Koshtha** | Changes | Fresh in every visit chat |
| **Ahara-Vihara** | Changes | Fresh in every visit chat |
| **Nidana / Samprapti** | Per-episode | Fresh per episode in chat |

**FR-2.4 Requirements**
- Results stored in the **static profile layer** (one-time) — never re-asked in full.
- Return visits run a **10–30 second delta-check**: "Your Prakriti was recorded as Vata-Pitta. Any major health or lifestyle change since last time?" → Yes triggers targeted re-assessment, No skips.
- Partial completion allowed; unanswered items marked `unassessed` and offered again next visit.
- Physical-exam-only items of Dashavidha (Nadi, Jihva, Mutra, Mala, Sparsha, Drik, Akriti — the Ashtavidha subset) are **NOT collected by the AI**; they are captured by the doctor via the AYUSH exam form (§FR-8.4).

### FR-3 — Chat Module (History Elicitation Engine)

**FR-3.1 Modes**
- **General (allopathic) mode** — default, complaint-first.
- **AYUSH mode** — extended interview: current Vikriti, Agni, Koshtha, Ahara-Vihara, Nidana, Samprapti + reference to stored Prakriti. Toggleable in-app.

**FR-3.2 Conversation flow**
1. Open question: "Aapko kya takleef hai?" (voice or tap-to-type / preset complaint chips)
2. Adaptive follow-up driven by complaint → **SOCRATES** probing in General mode; **Ayurvedic framework** (onset, aggravating/relieving, agni changes, koshtha, aahar links) in AYUSH mode.
3. Follow-ups personalized from profile & history: e.g., diabetic patient is asked "sugar kab check hui thi?" without being re-asked their disease list.
4. Structured intake targets (all modes): chief complaint → HPI → past medical/surgical → drug & allergy → family → personal → ROS.

**FR-3.3 Input modalities**
- **MCQ-first**: ≥80% of questions are multiple-choice chips / yes-no / sliders (severity 0–10).
- **Voice**: every question also answerable by speech (ASR); patient can switch mid-session.
- **Minimal text**: free text only for names/places/details where chips fail.

**FR-3.4 Accessibility**
- Large fonts/icons, TTS reads every question aloud, auto-advance on answer, progress indicator ("5 of 12 done").
- If the patient stops responding for 60s, a friendly re-prompt + "ek attendant ko bulayein?" option (kiosk).

**FR-3.5 Session handling**
- Draft auto-saved; on completion the session is marked `submitted`.
- **Temporary session data (raw audio, transcripts) is cleared immediately after submission** — only the structured answers persist (DPDP data minimization).

### FR-4 — Emergency / Red-Flag Flow

**FR-4.1 Detection**
- Dual engine: (a) **rule-based flag list** (e.g., chest pain + breathlessness, FAST stroke signs, hematemesis, altered sensorium, severe dehydration in child/elderly), (b) **LLM safety classifier** over each answer.
- Runs on **every answer** during chat, and also flags newly parsed documents (e.g., critical lab values).

**FR-4.2 Kiosk mode (patient on hospital premises)**
- Alert → **triage desk** of the hospital the kiosk is registered to: desktop popup + sound, showing Kiosk ID, flag type, patient name/age (minimal data only).
- Staff attendant goes to the kiosk; patient is routed out of the normal queue.

**FR-4.3 App mode (patient at home)**
- A **non-skippable emergency screen** appears with 3 large buttons:
  1. **Call 108** (always available, needs no contact data)
  2. **Alert my emergency contacts** — one tap sends SMS/WhatsApp with minimal data (flag, name, location link); requires the optional registration-time consent + contacts
  3. **Nearest ER route** — GPS navigation to nearest emergency department
- **In-app first-aid guidance** (CPR, recovery position, stroke FAST) shown with zero data sharing.
- **Auto-action fallback**: if no tap within **10 seconds** → if contacts exist, auto-alert them; else auto-dial 108. (Legal basis: DPDP Act 2023 §7(c) — processing necessary to respond to a medical emergency involving threat to life/health.)

**FR-4.4 Alert payload (data minimization)**
`{ flag_code, patient_name, age, kiosk_id | gps, timestamp }` — never the full history. Full data stays locked until a proper consent flow.

**FR-4.5 Red flag vs urgent booking (must stay separate)**
- **Urgent booking** = the patient *feels* it is urgent (fever, fracture) → priority slot in normal appointment flow.
- **Red flag** = the *system* detects possible danger (patient may not realize it) → bypasses booking entirely, goes to FR-4.2/4.3.
- Both flows are independent and never mixed.

### FR-5 — History Page & Document Digitization

**FR-5.1 Upload**
- Sources: camera capture (multi-page), gallery/files.
- Types: prescriptions, lab reports, discharge summaries, imaging reports (text-side), handwritten notes.
- Formats: JPG/PNG/PDF (PDF pages rasterized for OCR).
- Multi-language OCR: Hindi + English minimum; regional languages via model config.

**FR-5.2 Pipeline (per document)**
```
Capture → Preprocess (denoise/deskew/contrast) → OCR → LLM extraction
→ Structured JSON → Patient review screen → Confirm/Edit → Store
(original file + parsed JSON) → Add to chronological timeline
```

**FR-5.3 What is parsed, per document type**

| Document type | Extracted entities (JSON schema) |
|---|---|
| **Prescription** | `doctor_name, doctor_specialty, date, medicines[{name, dosage, frequency, duration, instructions}], diagnosis_hints[]` |
| **Lab report** | `lab_name, date, panel, tests[{name, value, unit, ref_range, flag(normal|low|high|critical)}]` |
| **Discharge summary** | `hospital, admit_date, discharge_date, diagnoses[], procedures[], medications[], advice, follow_up` |
| **Generic/other** | `doc_type, patient_name_match, date, key_entities[], raw_confidence` |

- Every extracted item carries a **confidence score**.
- Cross-document intelligence (doctor-facing): **abnormal lab values highlighted**, **potential drug–drug interaction flags**, **duplicate medicine warnings**.

**FR-5.4 Verification (human-in-the-loop)**
- After parsing, the patient sees a **simple visual review**: each extracted item as an icon-card ("Dawai: Metformin 500mg — roz 2 baar ✓/✗").
- Actions: **Confirm all / Fix (tap-to-edit) / Skip review**.
- If skipped → status `unverified`; shown to doctor with an **"Unverified" badge**. Confirmed → `verified`.
- Low-confidence items are visually marked amber and default to `unverified`.

**FR-5.5 Storage & timeline**
- Store **original file** (source of truth) + **parsed JSON** (machine-readable) — linked as one record.
- Timeline view on History page: all documents + past visit summaries in **reverse-chronological order**, filterable by type/year.
- Edit/delete allowed; deletion removes both file and JSON, logged in audit trail.

### FR-6 — Appointments

> Note: appointment booking is a **value-add on top of the PS** (PS scope is pre-consult intake). It is included because it completes the patient journey and carries the summary to the doctor. Keep it slim; don't let it bloat the demo.

**FR-6.1 Discovery**
- List of **nearest partner hospitals / doctors** (GPS-based), search by name/specialty, language-filterable.
- In demo: seeded dataset of 5–10 hospitals/doctors; live discovery is roadmap.

**FR-6.2 Booking flow**
1. Choose hospital/doctor → slot (calendar) → **type: Regular / Urgent**.
2. **Urgent** = same-day priority slots, flagged to doctor/desk with reason chip.
3. Attach medical context: the current **AI summary + selected parsed records** (patient picks scope).
4. **Consent picker** (§FR-9): choose what this doctor may see — Summary only / Summary + documents / Full record — with time window.
5. Confirm → booking with token; patient's app shows queue status.
6. **Summary attachment**: the appointment record carries the generated summary snapshot + linked documents; a **mock FHIR Bundle** is also produced and "pushed" to HIS/ABHA (stub adapter in demo).

**FR-6.3 Access window & revoke**
- Doctor's data access opens at appointment start and **auto-revokes at appointment end** (or 24h after slot, configurable).
- Patient can revoke early anytime (Settings → active consents).
- Post-visit, the visit summary is saved to patient's History timeline.

**FR-6.4 Appointment history**
- Upcoming / past lists; cancel & reschedule (urgent cancellations flagged to staff); per-appointment view of what data was shared.

### FR-7 — Summary Generation (Module C)

**FR-7.1 Inputs**
- Structured chat answers (current visit) + AYUSH dynamic parameters (Vikriti, Agni, Koshtha, Nidana)
- Static profile (Prakriti, allergies, past history)
- Verified parsed documents (timeline + extracted entities)

**FR-7.2 Output structure (standard clinical format)**
```
1. Patient identity (masked essentials)
2. Chief complaint
3. History of Present Illness
4. Past medical / surgical history
5. Drug & allergy history
6. Family history
7. Personal history (habits/lifestyle)
8. Review of Systems
9. Prior investigations summary (from parsed docs, abnormal values highlighted)
10. AYUSH block: Prakriti snapshot, Vikriti, Agni, Koshtha, Ahara-Vihara, Nidana
11. Red flags raised (if any)
12. Data sources & confidence ("This is an AI-generated draft — not a diagnosis")
```

**FR-7.3 Language & delivery**
- **Patient-facing**: audio confirmation in local language ("Aapki jankari record ho gayi. Doctor ko dikha di jayegi.")
- **Doctor-facing**: English/Hindi toggle on the summary screen.
- Draft-only by design: doctor must **Accept / Amend / Reject**; edits create a new summary version, and the doctor's final version is saved back to the record.

### FR-8 — Doctor View

**FR-8.1 Delivery**
- Lightweight **doctor web portal served by Flask** (no separate app needed). Doctors open the appointment → summary.

**FR-8.2 Features**
- Structured summary screen (§FR-7.2) readable in < 1 minute.
- **Accept / Amend / Reject** with edit history (versions).
- **Source documents panel**: original images/PDFs beside parsed data; "Unverified" badges; abnormal lab values highlighted; drug-interaction flags.
- **Timeline view** of patient's full history (past visits + documents).
- Patient history accessible **only within the consent window of an active appointment**; every open is audit-logged.

**FR-8.3 AYUSH exam form (Ashtavidha subset)**
- The physical exam part of Dashavidha that the AI cannot do: **Nadi (pulse), Jihva (tongue), Mutra (urine), Mala (stool), Sparsha (touch), Drik (eyes), Akriti (build)** — quick structured form with Ayurvedic descriptor pickers.
- Doctor's entries merge into the final visit record, completing the Dashavidha picture.

### FR-9 — Consent, Privacy & ABDM Integration (Module D)

**FR-9.1 Consent design**
- **Granular scopes**: capture consent (registration), share consent per appointment (summary only / summary + docs / full record), emergency contact alert consent (optional).
- **Time-bound**: appointment consents auto-expire at visit end.
- **Revocable anytime**: Settings → Consents → Revoke (immediate effect).
- **Audio-guided consent**: TTS explains what is being collected/why, in plain language; explicit Yes/No tap.
- Every consent stored as a **ledger record**: `{id, patient, scope, purpose, granted_at, expires_at, revoked_at, consent_version, audio_consent_flag}`.

**FR-9.2 Privacy & security**
- DPDP Act 2023 compliance posture: purpose limitation, data minimization, consent notice, right to access/erase (in-app), breach-ready logs.
- Emergency processing under **DPDP §7(c)** documented in-app & in audit log.
- Data at rest encrypted (AES-256), TLS in transit, JWT auth, phone OTP.
- **Session termination**: raw audio, transcripts and kiosk session data wiped after submission.
- ABHA linkage & FHIR push via **mock/sandbox adapters** in demo; production-ready interface documented.

### FR-10 — Audit & Compliance Logging
- Logged events: registration, consent grant/revoke/expiry, document upload/confirm/edit/delete, summary generation/doctor edits, appointment data access (who opened what, when), red-flag alerts sent (channel + payload hash), FHIR push attempts.
- Audit log is append-only, admin-viewable, and exportable (CSV) for the compliance demo.

---

## 7. Data Model (PostgreSQL via SQLAlchemy)

| Table | Key fields |
|---|---|
| `users` | id, name, dob, age, gender, phone(unique), email, language, abha_id(masked), aadhaar_ref, created_at |
| `emergency_contacts` | id, user_id, contact_type(family/doctor/hospital), name, phone, relation, consent_flag, active |
| `patient_profiles` | user_id, prakriti_primary, prakriti_secondary, sattva, samhanana, sara, pramana_json, satmya_json, assessment_version, assessed_at, last_delta_check_at |
| `visits` | id, user_id, mode(general/ayush), status(draft/submitted), started_at, submitted_at, chief_complaint, red_flag_code(nullable) |
| `chat_messages` | id, visit_id, sender(patient/system), input_type(mcq/voice/text), question_id, question_text, answer_json, language |
| `documents` | id, user_id, doc_type, original_path, parsed_json, confidence, verify_status(unverified/verified/edited), doc_date, uploaded_at, flags_json(abnormal_values, drug_interactions) |
| `appointments` | id, user_id, hospital_id, doctor_id, slot_start, slot_end, urgency(regular/urgent), status, summary_version_id, consent_id |
| `summaries` | id, user_id, visit_id, appointment_id, content_json, lang, status(draft/accepted/amended/rejected), doctor_id, version, created_at |
| `consents` | id, user_id, scope, purpose, granted_at, expires_at, revoked_at, consent_version, audio_flag |
| `audit_logs` | id, actor_type, actor_id, action, target_type, target_id, meta_json, ip, created_at |
| `alerts` | id, user_id, flag_code, channel(triage/contacts/108), payload_hash, status, created_at |
| `hospitals` / `doctors` | seed data: name, location, specialty, ayush_allopathic, languages, slots |

---

## 8. API Surface (Flask REST)

| Group | Endpoints |
|---|---|
| Auth | `POST /api/auth/register`, `POST /api/auth/otp/verify`, `POST /api/auth/login`, `POST /api/auth/abha/link` (mock) |
| Profile | `GET/PUT /api/profile`, `POST /api/profile/prakriti/assessment`, `POST /api/profile/prakriti/delta-check` |
| Chat | `POST /api/chat/sessions`, `POST /api/chat/{session}/answer` (returns next question JSON), `POST /api/chat/{session}/voice` (audio upload → transcript), `POST /api/chat/{session}/submit` |
| Documents | `POST /api/documents` (upload → job), `GET /api/documents/{id}/parsed`, `POST /api/documents/{id}/confirm`, `PUT /api/documents/{id}`, `DELETE /api/documents/{id}`, `GET /api/documents/timeline` |
| Appointments | `GET /api/hospitals/nearest`, `GET /api/doctors`, `GET /api/slots`, `POST /api/appointments`, `GET /api/appointments`, `POST /api/appointments/{id}/cancel` |
| Summary | `POST /api/summaries/generate`, `GET /api/summaries/{id}`, `POST /api/summaries/{id}/doctor-edit` |
| Doctor | `GET /api/doctor/appointments`, `GET /api/doctor/appointments/{id}/summary`, `GET /api/doctor/patients/{id}/timeline` (consent-gated), `POST /api/doctor/exam/ayush` |
| Consent | `POST /api/consent/grant`, `POST /api/consent/{id}/revoke`, `GET /api/consent/active` |
| Alerts | `POST /api/alerts/triage` (internal), `POST /api/alerts/contacts`, `GET /api/alerts` (staff) |
| Interop | `POST /api/fhir/push` (mock Bundle), `GET /api/admin/audit` (export) |

---

## 9. AI/ML Component Specifications

| Component | Approach | Fallback (offline demo) |
|---|---|---|
| ASR (voice → text) | Bhashini / AI4Bharat ASR APIs (Hindi + regional) | Bundled Vosk/whisper-tiny; else canned transcripts for demo |
| TTS (text → speech) | Platform TTS (flutter_tts) | Pre-recorded Hindi/English prompt audio files |
| Dialogue manager | LLM constrained by a clinical history ontology (question bank + branch graph); SOCRATES/Ayurvedic frameworks | Static rule-based question graph (fully offline) |
| Red-flag classifier | Rules list + LLM safety classification per answer | Pure rule list (keyword/pattern matching) |
| OCR | PaddleOCR/EasyOCR (Hindi+English, handwritten+printed) | Tesseract fallback; pre-seeded demo documents |
| Clinical extraction | LLM with JSON-schema-constrained output, per-document schema (§FR-5.3) | Template/regex extractor for seeded docs |
| Summary generator | LLM merge of visit answers + profile + parsed docs into §FR-7.2 template | Jinja template assembly (always works) |
| Abnormal values / drug interactions | Lab ref-range rules + drug-interaction lookup table | Same tables (static, offline-safe) |

---

## 10. Non-Functional Requirements

| Category | Requirement |
|---|---|
| Accessibility | WCAG-minded icon UI, ≥48px touch targets, full TTS coverage, audio-only completion path |
| Languages | UI/TTS/ASR: Hindi + English minimum; regional extensible |
| Offline | Demo runs without internet; production supports offline queue + sync |
| Performance | Next-question latency < 2s; OCR job async with progress; summary gen < 15s |
| Security | TLS, JWT, AES-256 at rest, OTP, masked Aadhaar/ABHA storage, session wipe |
| Compliance | DPDP 2023 posture, ABDM consent framework alignment, FHIR R4 outputs |
| Scalability | Stateless Flask behind WSGI; Celery workers scale for OCR/summary queues |

---

## 11. MVP Thin Slice (what the demo shows)

**One complete input → outcome path, no dead screens:**
1. Register (Hindi, audio-guided) → 2. Prakriti assessment (6–8 MCQs, voice-capable) → 3. Chat: chief complaint with adaptive SOCRATES follow-ups → 4. (Seeded) document upload → parse preview → confirm → 5. Summary generated (English/Hindi) → 6. Book appointment with consent scope → 7. Doctor portal: summary + source docs + accept/amend → 8. Red-flag demo: type a chest-pain pattern → emergency screen/triage alert fires.

**Demo KPIs to state:** intake time (min:sec), doctor read-time before/after, red-flag alert latency, consent ledger screenshot.

**Everything else** (live ABHA, live Bhashini, full OCR accuracy, hospital discovery) = roadmap, explicitly labelled.

---

## 12. Roadmap

| Phase | Scope |
|---|---|
| P0 (SIH demo) | MVP thin slice above, fully offline, seeded data |
| P1 | Real ASR/TTS integration, better OCR accuracy, FHIR sandbox (ABDM) integration |
| P2 | Kiosk hardware deployment package, hospital admin console, HIS adapters (real hospitals) |
| P3 | Regional language expansion, on-device models, AIIA pilot |

---

## 13. Risks & Mitigations

| Risk | Mitigation |
|---|---|
| ASR fails on rural accents/noise | MCQ-first design (voice optional); noise-cancelling kiosk mic guidance; fallback ASR |
| OCR/extraction errors | Human-in-the-loop confirm; unverified badge; confidence display |
| No internet at judging | Fully seeded offline demo; all AI paths have rule/template fallback |
| Over-scoping (appointments etc.) | PS-core first; appointments as slim value-add; roadmap label |
| Legal ambiguity (consent/emergency) | DPDP §7(c) documented; minimal payload; audit log; medical review disclaimer |
| AI draft misused as diagnosis | Hard banner "draft, not diagnosis"; doctor accept/amend/reject mandatory |

---

## 14. Open Questions for the Team

1. Which 2–3 languages beyond Hindi/English for the demo? (PS says "major regional languages")
2. Should the doctor portal be Hindi-first or English-first for the demo?
3. Do we simulate ABHA via QR generation in-app, or a text ID field?
4. Which LLM provider fits the budget (hosted API vs local model) — and does the finale venue allow internet?

*End of PRD v1.0*

