# MediKiosk — Patient Case-Taking Software (SIH26047)
## Complete Solution Documentation: *How Do We Solve It & How It Works*

**Problem Statement ID:** SIH26047 · **Organisation:** All India Institute of Ayurveda, Ministry of Ayush
**Category:** Software · **Theme:** Medtech / Biotech / Healthtech
**Team:** Byte-Craftsman-Alpha

---

# PART 1 — THE CORE ISSUE (What exactly is broken?)

## 1.1 The 2-to-5-Minute Consultation

History-taking is the single most important diagnostic activity in medicine — the evidence across five landmark studies (Lancet 1947 → BMJ 1975 → JAPI 2000 → UCLA 2009) shows the medical history alone yields the final diagnosis in **56–88% of cases, pooled mean 75.9%** — corroborated by modern literature (JMIR 2024: ~80%; Nature 2025: 60–80%) — before any examination or investigation. Yet in India's public hospital OPDs:

- Tertiary government hospitals register **4,000–10,000 OPD patients per day** — AIIMS New Delhi alone serves **~8,000–10,000 OPD patients daily (~35 lakh/year)** with only ~2,500–4,050 seats for waiting patients (Union Health Ministry figures via *The Hindu*, 14 Jan 2019; AIIMS charter; Hindustan Times, 9 Jul 2015). The PS sponsor itself, **AIIA, logged 3,28,193 OPD patients in FY 2024–25 alone** (Ministry of Ayush "11 Years of AYUSH" report, 16 Sep 2025).
- The **BMJ Open (2017)** systematic review across **67 countries, 179 studies, 28.5 million consultations** placed India's average primary-care consultation at **~2 minutes** — among the shortest globally (48 s in Bangladesh to 22.5 min in Sweden; 18 countries covering ~50% of world population at ≤5 min).
- Inside those 2–5 minutes, a physician must simultaneously elicit history, examine the patient, read prior paper records, diagnose, counsel, and prescribe.

**The inevitable result:** systematic under-elicitation of history, missed comorbidities and allergies, repeated questioning across visits, diagnostic error, and physician burnout.

> **📊 Every claim in Part 1 is backed by verified data — see `SIH26047_Problem_Evidence_Base.md` for the full source list with publication dates.** Headline numbers: diagnostic errors occur in **5–20% of physician–patient encounters (WHO, 13 Sep 2023)** and **~1 in 14 hospital patients suffers a harmful — 85% preventable — diagnostic error, with history-taking failures carrying 2.5× risk (BMJ Quality & Safety, 2 Oct 2024)**; Indian hospitals show a **34% median medication-error incidence concentrated at the prescribing stage (systematic review, 2025)**; **98.6% of patients still keep paper records and 27% have lost them (Indian J Med Res, 2024)**; **90+ crore ABHAs exist (PIB, 30 May 2026) but under 1.6 lakh facilities run ABDM software (PIB, 11 Feb 2025)**; and **68,584 hit-and-run accidents in 2024 (MoRTH)** produced thousands of "blank patients" for whom emergency access is life-critical.

## 1.2 The Paper Records Problem

Indian patients typically arrive carrying a plastic bag of paper — prescriptions, lab reports, discharge summaries, imaging films — from multiple previous providers. These documents are:

- **Unstructured** (free-form, half-filled templates)
- **Multilingual** (Hindi, English, regional languages, often mixed with Latin drug names)
- **Chronologically disordered** (the newest report is often at the bottom of the pile)
- **Frequently handwritten** and partially illegible

The physician burns a significant share of the consultation just *reading the bag*. There is no point-of-entry mechanism that digitizes, structures, and chronologically organizes these records before the patient reaches the consultation room.

## 1.3 The AYUSH Multiplier

AYUSH institutions (the PS sponsor is AIIA, Ministry of Ayush) face an extra layer: Ayurvedic case-taking requires **Trividha, Ashtavidha and Dashavidha Pariksha** — Prakriti (constitution), Vikriti (imbalance), Agni, Koshtha, Sara, Samhanana, Pramana, Satmya, Sattva, Ahara Shakti, Vyayama Shakti, Vaya, plus Ahara-Vihara (diet/lifestyle), Nidana and Samprapti analysis. This is a *far* deeper interview framework than allopathic intake. Capturing it manually inside a 2-minute OPD slot is effectively impossible — so practitioners abbreviate the very assessment that defines personalized Ayurvedic care.

## 1.4 The "First-Mile" Gap in ABDM

The Ayushman Bharat Digital Mission has built the rails — ABHA IDs, the Health Information Exchange, FHIR-based interoperability standards. But the **first mile is missing**: there is no patient-facing software that captures structured clinical history and digitizes documents *into* the ABDM ecosystem before the clinical encounter begins. Registration systems capture demographics; nothing captures the *clinical story*.

## 1.5 The Silent Failures

Beyond slowness, the current system has three dangerous failure modes:

1. **Missed allergies / drug interactions** — a penicillin allergy buried in a 3-year-old handwritten prescription never surfaces; a drug is prescribed that interacts with the patient's current medication.
2. **Missed red flags** — a patient with chest pain + breathlessness + sweating sits in the routine queue for 2 hours because nobody structured their complaint before triage.
3. **The blank patient** — in accidents and emergencies, the unresponsive patient arrives with *no history at all*. Doctors treat blind, with no access to prior diagnoses, medications, allergies, or even blood group.

---

# PART 2 — WHY IT MATTERS

| Stakeholder | What the status quo costs them |
|---|---|
| **Patient** | Repeats their story at every visit; waits hours; suffers missed allergies and delayed emergency care; loses paper records; gets generic (non-personalized) AYUSH care. |
| **Doctor** | Spends the majority of a 2–5 min consult on data-gathering instead of reasoning; faces medico-legal exposure from undocumented history; burnout from queue pressure. |
| **Hospital** | Low OPD throughput, duplicated tests (because prior reports can't be found), medico-legal risk, no analytics on case mix. |
| **Ministry / Public Health** | ABDM rails exist but carry no clinical data; no population-level insight from OPDs; AYUSH personalization remains theoretical. |

A well-conducted history drives 70–80% of diagnoses. **Every minute a doctor spends reading a paper bag is a minute not spent thinking.** MediKiosk attacks exactly this waste.

---

# PART 3 — THE SOLUTION: MediKiosk

## 3.1 One-Line Value Proposition

> **MediKiosk converts a patient's spoken words, touch responses, and paper medical records into a verified, structured, physician-ready clinical summary — before the consultation begins — and makes that history available in emergencies through consent-governed ABHA-based access.**

## 3.2 What MediKiosk Is (and Is Not)

**It is:**
- A **patient-facing AI clinical intake platform** with two surfaces: a **walk-in kiosk/tablet** at the hospital and a **patient mobile/web app** for pre-visit and at-home intake.
- A **document digitization and intelligence pipeline** (OCR → classification → medical entity extraction → chronological timeline).
- A **physician dashboard** that renders the AI-drafted summary, the timeline, the original scans, and source/confidence labels — with full edit/verify/reject control.
- A **consent-first, ABDM-compatible integration layer** (ABHA, FHIR, HIS/EMR).
- An **emergency access ("break-glass") service** letting verified healthcare organizations retrieve a critically needed history via ABHA ID under strict audit.
- A **tamper-evident record layer** using cryptographic hash-anchoring, so any alteration of a stored record is mathematically detectable.

**It is NOT:**
- A diagnostic engine. It never diagnoses, never prescribes, never replaces physician judgment. The AI output is always a *draft for a human to verify*.
- A blockchain gimmick. We deliberately use **lightweight hash-anchoring** (Merkle roots anchored on a permissioned ledger / signed WORM audit logs) rather than storing medical data on-chain — this preserves DPDP 2023 data-erasure rights while still guaranteeing tamper-evidence.

## 3.3 Design Philosophy (the five pillars)

1. **Speak first, type less** — voice-first, touch-always. Every question is answerable by speaking *or* tapping; nothing requires literacy.
2. **Consent before capture** — granular, revocable, audio-explained consent, recorded with timestamp, purpose and version.
3. **Human-in-command** — every AI-extracted field carries a source label (`patient-reported`, `OCR-extracted`, `patient-verified`, `physician-verified`) and a confidence score. Nothing enters the permanent record unverified by a professional.
4. **Fit the rails that exist** — ABDM (ABHA, consent manager, FHIR), hospital HIS/EMR, DPDP 2023. We plug into the ecosystem; we don't ask hospitals to rip anything out.
5. **Safety before speed** — a rule-based red-flag engine (not probabilistic AI) can interrupt the routine flow and summon a human in seconds.

---

# PART 4 — HOW IT WORKS (Detailed)

## 4.1 The Two Windows (Dual-Surface Model)

MediKiosk provides **two coordinated windows**:

### Window 1 — Patient (Kiosk / Mobile / Web App)
- **Identify:** ABHA QR scan / ABHA number / hospital ID / token number / new-patient flow. Language selection (Hindi, English + regional via Bhashini).
- **Consent:** audio-guided, granular consent (history capture / document processing / doctor sharing / ABDM linking) — each separately toggleable.
- **Quick Profile:** blood group, allergies, current medications, age, emergency contacts — captured once, editable forever.
- **Converse:** the adaptive AI history interview (voice + touch).
- **Scan:** upload/photograph prior prescriptions, lab reports, discharge summaries.
- **Chat:** a conversational assistant grounded in *their own* records (medication reminders, "what did my last report say?", pre-visit guidance) with an Ayurveda mode.
- **Control:** view timeline, manage consent grants, see exactly which organizations accessed which record and when.

### Window 2 — Verified Healthcare Organization (Web Portal)
- **Doctor dashboard:** queue, structured summary, timeline, original scans beside extracted text, red-flag alerts, edit/verify/reject/save-to-HIS.
- **Triage dashboard:** real-time red-flag alerts with patient location and token.
- **Emergency access ("break-glass"):** retrieve a critically needed record by ABHA ID under emergency protocol (see §4.6).
- **Admin analytics:** throughput, intake time, OCR correction rates, language usage — all anonymized.

> **Why two windows matters:** the patient owns the data and the consent; the organization gets the clinical value. This mirrors ABDM's consent-manager architecture rather than fighting it.

## 4.2 End-to-End Patient Journey (Happy Path)

```
ARRIVE → IDENTIFY → CONSENT → CONVERSE → SCAN → VERIFY → SUMMARIZE & ROUTE → CONSULT
```

1. **Identify (≈30 s):** Patient selects language, scans ABHA card or enters ABHA number / hospital ID / token; new patients create a temporary profile. Aadhaar is *not* the default medical identifier — ABHA/hospital ID/token are prioritized.
2. **Consent (≈45 s):** Audio explanation in the chosen language; separate toggles for history capture, document processing, doctor sharing, and optional ABDM linking; decline → graceful fallback to manual intake.
3. **Converse (6–10 min):** The conversational engine conducts the structured interview — chief complaint → adaptive follow-ups (SOCRATES/OPQRST) → past medical/surgical → drugs & allergies → family/personal → review of systems → optional AYUSH mode (Dashavidha Pariksha). Every question is voice-answerable *and* tap-answerable. Progress is visible. Answers can be corrected at any time.
4. **Red-flag check (continuous):** A deterministic rule engine watches every answer. "Chest pain" + "breathlessness" + "sweating" → immediate audio+visual message to patient, instant alert to triage dashboard, priority token. The routine interview may continue (or pause) under triage direction.
5. **Scan (2–5 min):** Patient photographs each paper document. Quality check on-device (blur/glare/crop) → auto re-capture prompts → document classification (prescription / lab report / discharge summary / referral / imaging / other) → OCR (printed + handwritten, multilingual) → medical entity extraction (diagnoses, medications + dosage/frequency/duration, investigation values + units + reference ranges, procedures, dates, issuing doctor/hospital).
6. **Verify (≈1 min):** The system reads back the extracted items; the patient confirms or corrects each (touch or voice). Low-confidence extractions are explicitly flagged for confirmation.
7. **Summarize & Route (seconds):** The summary engine fuses conversational history + verified document data into the standard physician format, builds the chronological timeline, and pushes to the doctor dashboard. On physician approval, the record maps to FHIR resources (Patient, Encounter, Condition, Observation, MedicationStatement, AllergyIntolerance, DocumentReference, Consent) and links to the ABHA PHR via ABDM consent APIs.
8. **Consult:** The doctor opens a completed, structured, source-labelled history — reads it in **seconds**, amends anything, verifies, and spends the consultation on examination, reasoning and counselling.

## 4.3 Module A — Conversational Multimodal History Engine

- **Dual-mode input:** every single question answerable by speaking OR tapping (icons, yes/no, body-map, sliders, multi-select). Literacy is never a gate.
- **Adaptive questioning:** a dialogue manager constrained by a clinician-approved clinical-history ontology branches on the chief complaint and prior answers. Saying "chest pain" triggers SOCRATES (Site, Onset, Character, Radiation, Associated symptoms, Timing, Exacerbating/relieving, Severity); "fever" triggers onset/duration/chills/rash/cough triads, etc. Question paths are **clinician-approved templates**, not free-running LLM dialogue — this is a safety feature.
- **Multilingual ASR/TTS:** Bhashini / AI4Bharat models for Indian languages and accents, with noise reduction tuned for hospital environments.
- **Completeness tracking:** a coverage meter per history section so the engine knows what is missing and asks follow-ups before closing.
- **AYUSH Mode:** extended interview capturing Dashavidha Pariksha (Prakriti, Vikriti, Sara, Samhanana, Pramana, Satmya, Sattva, Ahara Shakti, Vyayama Shakti, Vaya) plus Agni, Koshtha, Ahara-Vihara, Nidana and Samprapti — questionnaire-configurable per department.
- **Patient review step:** before submission, key answers are read back in local language for confirmation.

## 4.4 Module B — Medical Document Digitization & Intelligence

Pipeline per document: **capture → quality check → classification → OCR → layout analysis → entity extraction → confidence scoring → patient verification → timeline placement.**

- **Intelligent extraction:** diagnoses, medications (name/dose/frequency/duration), investigation results with values/units/reference ranges, procedures/surgeries, allergies, follow-up instructions, issuing provider, date.
- **Chronological organization:** documents auto-dated and merged into a coherent medical timeline (illnesses, admissions, surgeries, medication changes).
- **Abnormal-value highlighting:** out-of-range lab values and potential drug–drug or drug–allergy conflicts flagged for the physician.
- **Honest limitation handling:** every extracted item is labelled `extracted` / `patient-verified` / `physician-verified` with a confidence score. OCR output is *never* silently treated as clinical fact.

## 4.5 Module C — Structured Summary Generator + Physician Dashboard

**Standard clinical format:** Chief Complaint → HPI → Past Medical/Surgical → Drug & Allergy → Family → Personal/Social → ROS → Prior Investigations → Current Medications → Red-Flag Alerts → **Unverified Fields** (explicitly listed).

- **Editable & verifiable:** the summary is a draft to accept, amend, or reject — never an autonomous diagnosis. Physician controls: edit, verify, reject field, add note, request more history from patient, save-to-HIS.
- **Bilingual output:** patient-facing audio confirmation in local language; physician-facing summary in English/Hindi.
- **Source-linked:** every field shows its provenance (voice answer on 2026-09-04 / OCR of prescription dated 2025-11-15) and confidence.

## 4.6 Module D — Emergency Access ("Break-Glass") 🚨

*The differentiator no registration system has.*

**Scenario:** an accident victim arrives unconscious. No bag of papers, no relative, no history. Today the team treats blind.

**MediKiosk flow:**
1. Verified hospital staff (authenticated, HFR-registered facility) enters/scans the patient's ABHA ID or Aadhaar-linked ABHA.
2. **Emergency protocol** triggers: minimal-verification retrieval (OTP to registered contact / Aadhaar demographic match where available), explicitly marked as emergency access.
3. A **restricted emergency view** opens: blood group, allergies, current medications, comorbidities (diabetes, epilepsy, cardiac history, anticoagulants), recent surgeries, implants — exactly what an ER team needs in the first 10 minutes.
4. **Mandatory governance:** every break-glass access is (a) written to an immutable audit log, (b) post-hoc reviewed by the hospital's privacy officer, (c) notified to the patient (SMS/app on recovery), (d) reported on the patient's access log. Abuse = revocation of the facility's verification.

This directly answers the PS's unspoken nightmare case and the Ministry's interest in ABDM actually *serving* emergency care.

## 4.7 Module E — Record Assistant (Patient Chat, Grounded + Ayurveda Mode)

- **Grounded RAG chat:** patients ask questions in text or voice; answers are retrieved *from their own verified records* (last HbA1c value, current medicines and timings, what a report term means in simple language, when the next dose is due). Guardrails: no diagnosis, no prescription advice — escalation to "consult your doctor / book appointment" for anything clinical.
- **Ayurveda Mode:** constitution-aware lifestyle guidance (diet, dinacharya, sleep) consistent with the patient's Prakriti/Vikriti captured in AYUSH Mode — educational content, clearly labelled as such.
- **Critical-condition pathway:** if the chat or interview surfaces red-flag patterns, the UI pivots to a one-tap "book emergency appointment / alert triage" action.

## 4.8 Module F — Consent, Privacy, Security & Tamper-Evidence

- **DPDP 2023 compliant:** purpose-limited collection, granular consent, right to correction, right to erasure, grievance contact. Data minimization is enforced at the questionnaire level (skip non-mandatory questions freely).
- **ABDM consent framework:** consent artefacts managed per ABDM spec; ABHA-linked sharing only with explicit consent; revocable at any time.
- **Security:** encryption in transit (TLS 1.3) and at rest (AES-256), role-based access control, session timeouts, device locking, temporary audio deleted after processing, full access audit trails, network segmentation, secure API gateway.
- **Tamper-evidence via hash-anchoring (no heavy blockchain):**
  - Medical documents and record payloads are stored encrypted off-chain (object storage + PostgreSQL), **never on-chain** — preserving erasure rights.
  - On each record finalization, a SHA-256 hash (and periodic Merkle root aggregating many records) is anchored to a **permissioned, append-only ledger** (e.g., Hyperledger Fabric channel among verified healthcare organizations, or a signed WORM audit-log service).
  - Any subsequent alteration of a record changes its hash → mismatch with the anchor → **mathematically detectable tampering**, with the audit log naming who touched what and when.
  - This gives judges the integrity story of "blockchain" without its latency, cost, energy waste, or DPDP conflict — and we say exactly that on stage.
- **Session hygiene:** temporary session data cleared immediately after submission; retention policy applied per record class.

## 4.9 Data Classification & Handling

| Data class | Examples | Protection |
|---|---|---|
| Identity data | Name, age, ABHA ID | High (RBAC, encrypted) |
| Health data | Symptoms, history, timeline | Very high (+ consent-gated) |
| Voice recordings | Raw ASR audio | Very high (deleted post-processing) |
| Documents | Scans, OCR text | Very high (+ hash-anchored) |
| Operational | Token, department | Medium |
| Anonymized analytics | Completion rates | Low |

**Separation principle (from your original design, retained):** patient identity data lives in a normal relational database; medical content lives in an encrypted clinical store; the two are linked by an opaque internal identifier. An organization that legitimately holds the medical record cannot silently enumerate identities, and vice versa.

## 4.10 System Architecture (Summary)

```
┌──────────────── CLIENT LAYER ────────────────┐
│ Patient Kiosk │ Patient App │ Doctor Portal  │
│ Triage Panel  │ (React/Flutter, multilingual)│
└──────────────────┬───────────────────────────┘
                   ▼
┌──────────────── API LAYER ───────────────────┐
│ API Gateway │ Auth (OAuth2/OIDC) │ Consent   │
│ Service     │ Session Manager               │
└──────────────────┬───────────────────────────┘
                   ▼
┌──────────── APPLICATION LAYER ───────────────┐
│ Interview Service │ Dialogue Manager │ Red-  │
│ Flag Engine │ Doc Processing │ Summary Gen   │
│ Timeline │ Notification │ Emergency Access   │
└──────────────────┬───────────────────────────┘
                   ▼
┌──────────────── AI LAYER ────────────────────┐
│ Bhashini/AI4Bharat ASR │ Translation │ TTS  │
│ OCR (PaddleOCR/cloud) │ Clinical NLP │      │
│ Rule-Based Safety Layer (deterministic)      │
└──────────────────┬───────────────────────────┘
                   ▼
┌──────────────── DATA LAYER ──────────────────┐
│ PostgreSQL (identity) │ Encrypted Clinical   │
│ Store │ Object Storage (docs) │ Audit Log    │
│ (hash-anchored, WORM) │ Search/Timeline Index│
└──────────────────┬───────────────────────────┘
                   ▼
┌──────────── INTEGRATION LAYER ───────────────┐
│ HIS/EMR adapters │ FHIR Server │ ABDM (ABHA, │
│ Consent Mgr) │ Pharmacy/LIS (roadmap)        │
└──────────────────────────────────────────────┘
```

**Recommended stack:** React/Next.js + Flutter (patient surfaces), React (doctor portal), FastAPI or Node.js backend, PostgreSQL + object storage (Supabase-compatible — matches team's existing codebase), Bhashini ASR/TTS, PaddleOCR + medical-layout models, constrained LLM for summarization behind a rule-based safety layer, FHIR server (HAPI), OAuth2/OIDC, deployment on hospital private cloud / MeghRaj (GI Cloud).

---

# PART 5 — HOW OUR SELECTED-PS SOLUTION MAPS TO (AND ENHANCES) THE PS

| PS requirement | MediKiosk delivery |
|---|---|
| Patient-facing, purpose-built software | Kiosk + app, zero-training UI, voice-first |
| Natural spoken conversation + guided touchscreen | Dual-mode engine on every question |
| Multilingual, multi-accent in noisy environments | Bhashini/AI4Bharat ASR + noise reduction |
| Low-literacy & elderly accessibility | Icon UI, audio prompts, assisted mode, large text/high contrast |
| Structured history (CC→HPI→…→ROS) | Ontology-constrained adaptive interview, SOCRATES/OPQRST templates |
| AYUSH Dashavidha Pariksha | Dedicated AYUSH Mode + Ayurveda chat mode |
| Document OCR (handwritten+printed, multilingual) | Full digitization pipeline + entity extraction + timeline |
| Physician-ready structured summary | Module C, editable/verifiable, bilingual |
| Red-flag detection | Deterministic rule engine + triage alert + priority queue |
| DPDP 2023 + ABDM consent compliance | Consent-first design, granular, revocable, audited |
| HIS + ABHA integration | FHIR-mapped, consent-manager compliant |
| *(your enhancements)* Emergency access via ABHA | Break-glass module with governance |
| *(your enhancements)* Tamper-proof records | Hash-anchoring on permissioned ledger |
| *(your enhancements)* Patient chat grounded on records | RAG assistant + Ayurveda mode |

---

# PART 6 — COMPARISON WITH EXISTING SOLUTIONS

| Solution class | What it does | Why it falls short vs. MediKiosk |
|---|---|---|
| **Hospital registration systems** (current HIS registration modules) | Demographics, appointment, token | Zero clinical history, no document processing, no ABHA clinical linkage |
| **Patient check-in kiosks** (developed-country hospitals) | Administrative check-in only | No AI history acquisition, no OCR, no multilingual voice, not built for 2-minute OPD realities |
| **Mobile health apps / tele-triage chatbots** | Symptom checkers, bookings | Need smartphone literacy, connectivity, pre-enrolment — excludes the elderly, rural, low-literacy, first-visit majority of government OPDs |
| **Nurse-led triage / history desks** | Human interview before consult | HR-limited, doesn't scale to 5,000+/day, reintroduces the transcription bottleneck |
| **Generic document scanners / DMS** | Digitize images | No OCR intelligence, no entity extraction, no chronology, no link to history or ABHA |
| **ABDM ecosystem apps** (ABHA creation, PHR apps) | Identity + record linking | Assume the records already exist digitally; they don't solve *creation* of structured history from paper and speech |
| **EMR/EHR systems** | Doctor-facing documentation | Shift the typing burden to the doctor — worsen the 2-minute problem; none are patient-facing intake |
| **MediKiosk** | ✅ All of the above gaps in one platform: voice+touch intake, document AI, red flags, AYUSH mode, physician verification, ABDM/HIS integration, emergency access, tamper-evidence | — |

**The honest framing for judges:** we are not competing with ABDM — we are the missing *first-mile producer* of structured clinical data that makes ABDM's rails carry real payloads. We are not competing with HIS — we feed verified summaries *into* HIS.

---

# PART 7 — UNIQUENESS, INNOVATION & USP

**Innovation claims (defensible):**
1. **First patient-facing conversational clinical-intake platform designed for Indian public OPD constraints** — 2-minute-consultation reality, multilingual, low-literacy, zero-training.
2. **Dual-mode (voice ⊕ touch) on every question** — most "voice AI" demos fail the literacy test; we treat touch as a first-class equal, not a fallback.
3. **Ontology-constrained adaptive dialogue** — LLM fluency caged inside clinician-approved question paths; adaptive like a doctor, safe like a protocol.
4. **Fused intake:** conversational history + OCR'd paper records merge into *one* verified timeline — nobody else combines both at point of entry.
5. **Deterministic red-flag safety layer** — emergency escalation that doesn't depend on probabilistic AI confidence.
6. **AYUSH-native design** (the PS sponsor's own need) — Dashavidha Pariksha as a configurable questionnaire mode; allopathic systems don't even attempt this.
7. **Break-glass emergency access via ABHA** with governance — turns ABDM from a filing system into a life-saving emergency tool.
8. **Hash-anchored tamper-evidence without blockchain baggage** — integrity guarantees compatible with DPDP erasure rights.
9. **Provenance/confidence labelling on every data field** — an audit trail of *knowledge*, not just access.

**USP (the one sentence for the pitch):** *"MediKiosk is the only platform that turns what a patient says and carries on paper into a doctor-verified, emergency-accessible, AYUSH-aware digital history — in their own language, before the doctor calls their token."*

---

# PART 8 — FEASIBILITY

## 8.1 Technical
- **ASR for Indian languages:** mature via Bhashini ( Govt. of India National Language Translation Mission) and AI4Bharat open models; noisy-environment robustness is engineering, not research.
- **OCR (printed + handwritten, multilingual):** production-grade engines exist (PaddleOCR, cloud OCR, Indic-specific models); handwriting remains the hardest nut — mitigated by patient-verification step and honest confidence labels.
- **Constrained clinical dialogue:** LLM + clinician-approved ontology/templates = demonstrable today; no exotic research needed.
- **ABDM/FHIR:** public sandboxes and well-documented APIs (HAPI FHIR); mock-first integration strategy de-risks the demo.
- **Team readiness:** existing React/TypeScript/Vite/Supabase codebase (MediCareX, Clinic Ease) provides the frontend + backend scaffolding; Agents.md already specifies modules, data objects, and demo scenarios.

## 8.2 Operational
- Kiosk hardware = commodity tablet + mic/speaker/camera; assisted mode covers device failures; offline queueing handles network drops.
- Staff role is supervisory (help, triage alerts), not transcriptional — net *reduces* HR load.
- Migration is phased: standalone pilot → registration integration → HIS/EMR push → FHIR/ABDM. No big-bang replacement.

## 8.3 Regulatory / Legal
- DPDP 2023: consent-first, minimization, erasure-compatible architecture (no on-chain data).
- ABDM: consent-manager artefacts, purpose-limited sharing.
- Clinical governance: system never diagnoses/prescribes; physician verification is mandatory before HIS write; red-flag rules clinician-approved.
- Data localization: deployable on hospital private cloud / MeghRaj.

## 8.4 Feasibility verdict
**High.** Every component relies on mature or government-backed (Bhashini, ABDM sandbox) technology; the innovation is in the *integration and workflow design*, which is exactly what a 36-hour hackathon prototype can demonstrate credibly.

---

# PART 9 — SCALABILITY & EXTENSIBILITY

- **Horizontal scale:** stateless API services scale behind a gateway; AI calls are the bottleneck → queue-based async processing, GPU autoscaling, and on-device ASR caching where possible. One kiosk handles ~40–60 intakes/day; a 10-kiosk hospital processes 400–600 pre-structured patients/day.
- **Multi-hospital:** tenant-per-hospital data partitioning; shared AI services; central anonymized analytics.
- **Configurability:** questionnaires are data (JSON templates), not code — new complaints, specialties, languages, and AYUSH protocols deploy without engineering.
- **Language scale:** architecture is language-agnostic via Bhashini; adding a language = adding templates + TTS/ASR model, not re-architecture.
- **Roadmap:** Phase 1 prototype (Hindi/English, 5 complaint pathways, printed OCR, mock ABDM) → Phase 2 pilot (more languages, handwriting, AYUSH module, HIS integration, offline) → Phase 3 production (full ABDM/FHIR, multi-hospital, device management) → Phase 4 advanced (follow-up comparison, medication-adherence questions, patient education audio, specialist modules, mental-health screening with safeguards, anonymized population analytics).
- **The compounding effect:** every visit enriches the longitudinal timeline — follow-up visits become *faster* than first visits, unlike every paper-based system where each visit restarts from zero.

---

# PART 10 — ADAPTABILITY: WHO USES IT AND WHY

| User | Why they use it (despite existing options) |
|---|---|
| **Elderly / low-literacy rural patient** | Speaks instead of types; hears questions in own language; nobody asks them to read or write. *No app they currently have does this.* |
| **First-time / walk-in OPD patient** | No pre-enrolment needed; ABHA created/linked on the spot; token + summary ready before consultation. |
| **Government OPD doctor** | Walks in to a finished, structured, source-labelled history; edits 30 seconds instead of eliciting 8 minutes; red flags already escalated; medico-legal documentation improved. |
| **AYUSH practitioner (AIIA etc.)** | Finally gets Dashavidha Pariksha captured in full without doubling consult time — the PS sponsor's own pain point. |
| **Triage / nursing staff** | Gets deterministic emergency alerts with location and reason instead of discovering crises by chance. |
| **ER team (accident cases)** | Break-glass access to allergies/medications/comorbidities of an unconscious stranger — today this information simply does not exist at point of care. |
| **Hospital administration** | OPD throughput up, duplicated investigations down, ABDM-compliance demonstrable, audit-ready records. |
| **Ministry of Ayush / public health** | Structured AYUSH intake data at population scale; ABDM rails finally carrying clinical payloads. |

**Why adoption beats the alternatives:** existing options each solve one slice (registration, or scheduling, or document storage). MediKiosk is the only option whose *unit of value* is the physician's scarcest resource — consultation minutes — and whose failure mode is a graceful fallback to today's manual process (manual intake always remains possible).

---

# PART 11 — IMPACT (with measurable targets)

| Dimension | Impact mechanism | Pilot target (presented as goals) |
|---|---|---|
| **Doctor time** | History pre-elicited and pre-structured | 30–50% reduction in history-taking time; consult reallocated to examination/counselling |
| **Patient wait** | Parallel intake while queueing | Registration-to-consultation time reduced materially; intake completed in 8–12 min during the wait patients already endure |
| **Safety** | Red-flag rules + allergy/drug-interaction surfacing | 100% of configured red-flag patterns routed to triage; allergy list present on every summary |
| **Completeness** | Ontology-driven coverage meter | >80% question completion; near-elimination of repeated questioning across visits |
| **Records** | OCR + timeline | Prior paper records chronologically organized for 100% of patients who carry them |
| **AYUSH care quality** | Full Dashavidha capture | Personalized (Prakriti-aware) care becomes operationally feasible in OPD time |
| **Emergencies** | Break-glass access | Critical history available in minutes for unidentified/unresponsive patients |
| **Systemic** | ABDM data creation | First-mile structured data flowing into national digital-health rails; reduced duplicate investigations |

---

# PART 12 — MVP SCOPE FOR SIH (what we build in 36 hours)

**Patient side:** Hindi + English; new/existing patient flow; consent screen; voice+touch interview for **fever** and **chest pain** pathways (demonstrates adaptivity *and* red-flag); document image upload; OCR for printed lab report/prescription; basic entity extraction; patient confirmation screen; structured summary generation; mock ABHA/HIS integration.

**Doctor side:** login; patient queue; structured summary with sections; original document preview beside extracted text; red-flag banner; edit/verify/reject; final save.

**Demo story (single take):** Hindi-speaking patient arrives with chest discomfort + an old lab report → selects Hindi → scans ABHA → audio consent → says "seene mein dard hai" → adaptive SOCRATES questions → reports sweating + breathlessness → **red-flag alert fires, triage dashboard pings** → scans lab report → OCR extracts sugar/cholesterol values → patient verifies → summary appears on doctor dashboard → doctor corrects one field, verifies, saves → record maps to FHIR and (mock) pushes to ABDM. **Second pass:** AYUSH Mode + emergency break-glass retrieval on a tablet. Q&A-ready.

**Explicit non-goals for MVP (state these proudly):** no autonomous diagnosis, no autonomous prescription, no claim of perfect handwriting OCR, no real HIS connection (mocked), 2 languages only, synthetic data only.

---

# PART 13 — RISKS & MITIGATIONS

| Risk | Mitigation |
|---|---|
| Handwritten OCR errors | Patient-verification step + confidence labels + physician verification gate |
| ASR failure in noise/certain accents | Touch fallback on every question; assisted mode; per-language model selection |
| False red-flag alerts | Deterministic rules tuned with clinicians; triage human decides; false-alert rate tracked |
| Patient distrust of AI/consent fatigue | Audio explanations, granular toggles, visible data deletion, staff assistance |
| Hospital IT integration resistance | Phased adapters; standalone-pilot first; FHIR standards; no rip-and-replace |
| DPDP non-compliance | No on-chain data; erasure-compatible stores; privacy-officer review of break-glass |
| LLM hallucination in summaries | Constrained generation to structured fields; rule-based safety layer; all output physician-verified |
| Device vandalism/downtime | Rugged enclosures; offline queueing; manual-intake fallback always available |

---

# PART 14 — FAQs (anticipated judge/mentor questions)

**Q1. Isn't this just a chatbot asking questions?**
No. A chatbot does free dialogue. MediKiosk is an ontology-constrained clinical interview engine with dual-mode input, completeness tracking, deterministic red-flag safety, document-AI fusion, and a mandatory human-verification gate. The LLM is a component, not the product.

**Q2. What if the patient can't read, can't speak clearly, or is too frail?**
Touch/icons answer every question without literacy; staff-assisted mode exists; family members can complete intake with the patient present; assisted mode is a designed path, not an error state.

**Q3. How accurate is the OCR, especially handwriting?**
Printed documents: high accuracy with modern engines. Handwriting: assisted by patient verification — the patient *confirms or corrects* each extraction, and the physician verifies before the record is finalized. Every field carries a confidence score; nothing low-confidence is silently trusted.

**Q4. Does the AI diagnose?**
Never. It structures, summarizes, and flags emergencies by deterministic rules. Diagnosis and prescription remain exclusively with the physician, who must verify the summary before it enters the HIS.

**Q5. Why did you drop blockchain? Your earlier pitch mentioned it.**
Deliberately. On-chain medical data conflicts with DPDP 2023 erasure rights, adds latency/cost, and buys nothing a permissioned hash-anchor doesn't. We anchor SHA-256 hashes/Merkle roots of finalized records on an append-only permissioned ledger — tampering becomes mathematically detectable, while data stays erasable and fast. Integrity without the baggage.

**Q6. How does the emergency access respect privacy?**
Break-glass is restricted to authenticated staff of verified (HFR-registered) facilities, retrieves a minimal emergency view, is 100% audit-logged, post-hoc reviewed, and notified to the patient. Repeated unjustified use revokes facility access.

**Q7. What about hospitals with no internet / power cuts?**
Offline queueing with store-and-forward sync; kiosks can run on UPS; assisted manual intake is always the fallback. The design degrades gracefully instead of failing closed.

**Q8. How does this integrate with our existing HIS?**
Phased: standalone pilot → registration-system adapter → HIS/EMR push of doctor-approved summaries → FHIR/ABDM linking. We never require replacing existing systems.

**Q9. What about dialects and code-mixed speech (Hinglish)?**
Bhashini/AI4Bharat models support code-mixed Indian speech; the dialogue manager normalizes into structured fields; language can be switched mid-interview.

**Q10. Who owns the data?**
The patient. Consent is granular and revocable; every access appears in the patient's access log; ABDM linking is opt-in.

**Q11. Can't a nurse just do this?**
That's today's model — and it's exactly the bottleneck: it doesn't scale to 5,000+ daily patients, consumes the same scarce HR, and reintroduces transcription errors. MediKiosk makes staff supervisors of the process instead of its labor.

**Q12. What stops a hospital from accessing records without consent?**
RBAC + consent artefacts enforced at the API layer + hash-anchored audit logs + break-glass governance + patient-visible access logs. Unauthorized access is both technically blocked and forensically traceable.

**Q13. Is this compliant with DPDP 2023 and ABDM?**
Yes by design: purpose limitation, minimization, granular consent, correction/erasure rights, data localization options, and ABDM consent-manager artefacts.

**Q14. What languages are supported at launch?**
Hindi and English for MVP; architecture supports 10+ Indian languages via Bhashini; adding a language is configuration, not re-engineering.

**Q15. What happens if the patient declines consent?**
Graceful fallback: manual registration and traditional history-taking proceed exactly as today. Nothing is blocked.

**Q16. How is this different from PHR apps like the ABDM-linked record apps?**
PHR apps assume digital records already exist. MediKiosk *creates* structured digital history from speech and paper — the first mile those apps are missing.

**Q17. Cost per hospital?**
Commodity tablets/kiosks + cloud or on-prem deployment; the AI layer uses government-backed (Bhashini) and open-source components to keep marginal cost per intake near-zero. Pilots can run on as little as 2–4 tablets.

**Q18. Why would a busy government doctor actually open this dashboard?**
Because it arrives *before* the patient: the summary is on screen when the token is called, abnormalities and allergies are pre-highlighted, and editing is faster than eliciting. The 30-second review replaces 8 minutes of questioning.

---

# PART 15 — CLOSING NARRATIVE (for pitch decks)

> India's doctors diagnose in two minutes not because the medicine is simple, but because the history arrives unwritten, scattered across a plastic bag of paper, in a language the system doesn't speak. MediKiosk gives every patient — literate or not, young or elderly, allopathic or Ayurvedic — a voice in their own language, turns their paper past into a verified digital timeline, puts a finished clinical summary on the doctor's screen before the token is called, summons help in seconds when seconds matter, and hands the emergency team the history of a patient who can't speak at all. We don't replace the doctor. We give the doctor back the one thing the system steals from them: **time to think.**

