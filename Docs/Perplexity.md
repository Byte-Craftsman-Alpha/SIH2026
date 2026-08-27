## 1) Problem Statement Breakdown (SIH26047)

- Core bottleneck: OPD consultation time in India is 2–5 minutes; history-taking (the most diagnostic part) is systematically truncated. [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)
- AYUSH adds complexity: Dashavidha/Ashtavidha/Trividha pariksha require deeper, structured intake that’s infeasible manually at scale. [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)
- Records fragmentation: Patients carry unstructured paper records; doctors waste time scanning them during consultation. [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)
- ABDM gap: National infrastructure (ABHA, HIE-CM, FHIR) exists, but the “first-mile” patient-facing intake (structured history + document digitization) is missing. [adrine](https://www.adrine.in/blog/abdm-fhir-integration-guide-2026)
- Opportunity: AI + multilingual ASR + OCR + FHIR can shift intake before the consult, improving throughput, accuracy, and personalization. [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)

***

## 2) Solution Decomposition (Modules)

Think of the platform as four tightly coupled modules.

### Module A — Conversational Multimodal History Engine
- Purpose: Capture structured clinical history via voice + touch before the consult.
- Key capabilities:
  - Multilingual ASR (Hindi/English + regional) with noise robustness. [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)
  - Adaptive clinical questioning (SOCRATES for pain, red-flag detection). [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)
  - Dual-mode input: speak or tap (icon/MCQ) for low-literacy/elderly users. [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)
  - AYUSH mode: extended Dashavidha parameters and Ahara-Vihara. [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)
  - Triage alerting: emergency symptoms → priority flag to staff. [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)

### Module B — Medical Document Digitization & Intelligence
- Purpose: Convert prior paper records into structured, timeline-ordered data.
- Key capabilities:
  - OCR for printed + handwritten prescriptions, lab reports, discharge summaries (multilingual). [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)
  - Entity extraction: diagnoses, meds (with dose/frequency), labs (values + ref ranges), procedures. [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)
  - Chronological ordering + abnormal-value highlighting + potential interaction flags. [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)

### Module C — Structured History Summary Generator
- Purpose: Synthesize conversation + documents into a physician-ready summary.
- Key capabilities:
  - Standard format: Chief Complaint → HPI → Past Hx → Drugs/Allergy → Family → Personal → ROS → Prior investigations. [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)
  - Editable draft: doctor can accept/amend/reject; never autonomous diagnosis. [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)
  - Bilingual outputs: patient audio confirmation (local language), physician summary (English/Hindi). [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)

### Module D — Consent, Privacy & ABDM Integration
- Purpose: Secure, compliant data flow into HIS/EMR and ABHA PHR.
- Key capabilities:
  - ABHA authentication + granular consent (audio-guided for low literacy). [adrine](https://www.adrine.in/blog/abdm-fhir-integration-guide-2026)
  - FHIR R4 bundles conformant to Indian profiles; HIE-CM consent flow. [ichelonconsulting](https://ichelonconsulting.com/insights/abdm-integrated-hospital-management-system-india-2026)
  - DPDP Act 2023 alignment: data minimization, purpose limitation, retention/erasure, audit logs. [pdpspectra](https://pdpspectra.com/blog/india-abdm-health-stack-architecture/)
  - India data residency; session data cleared post-submission. [pdpspectra](https://pdpspectra.com/blog/india-abdm-health-stack-architecture/)

***

## 3) MVP Scope (SIH Prototype-Ready)

Prioritize a working end-to-end flow for one OPD (e.g., General Medicine) in one language pair (Hindi + English), with optional AYUSH pilot.

- Must-have (MVP):
  - ABHA-lite login (or guest + mobile OTP) + consent capture. [adrine](https://www.adrine.in/blog/abdm-fhir-integration-guide-2026)
  - Voice + touch history for 3–5 common chief complaints (fever, cough, chest pain, abdominal pain, headache). [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)
  - Basic red-flag rules (e.g., chest pain + dyspnea → triage alert). [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)
  - Document upload (camera) + OCR + extract meds + basic labs; timeline view. [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)
  - Structured summary (CC, HPI, PMH, Drugs/Allergy, ROS-lite) shown on a “doctor screen”. [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)
  - FHIR R4 export (Patient, Encounter, Condition, MedicationStatement, Observation) to a local FHIR server or sandbox. [ichelonconsulting](https://ichelonconsulting.com/insights/abdm-integrated-hospital-management-system-india-2026)
  - Audit log + session wipe after submission. [pdpspectra](https://pdpspectra.com/blog/india-abdm-health-stack-architecture/)

- Nice-to-have (demo polish):
  - AYUSH mode (Dashavidha fields) for one OPD. [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)
  - Abnormal lab highlighting + simple drug–drug interaction check. [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)
  - Bilingual TTS confirmations for patient. [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)

***

## 4) Working Methodology (How It Operates End-to-End)

```mermaid
flowchart LR
  A[Patient Arrival] --> B["Identify & Consent"]
  B --> C["Conversational History (Voice+Touch)"]
  C --> D["Document Scan & OCR"]
  D --> E["Structure & Summarize"]
  E --> F["Push to HIS / ABHA (FHIR)"]
  F --> G["Doctor Review & Confirm"]
  G --> H[Consultation]
```

### Step-wise flow
- Identify & Consent:
  - ABHA ID / Aadhaar-based auth or guest + mobile OTP; language selection; audio-guided consent. [adrine](https://www.adrine.in/blog/abdm-fhir-integration-guide-2026)
- Conversational History:
  - ASR → dialogue manager (clinical ontology) → adaptive questions; red-flag rules trigger triage. [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)
- Document Scan:
  - Patient photographs prescriptions/labs; OCR → NER → normalize units; timeline construction. [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)
- Structure & Summarize:
  - Merge conversation + extracted entities → standardized summary (CC→HPI→PMH→Drugs/Allergy→Family→Personal→ROS). [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)
- Push to HIS/ABHA:
  - Generate FHIR R4 bundles; send via HIE-CM consent flow to hospital EMR/PHR. [ichelonconsulting](https://ichelonconsulting.com/insights/abdm-integrated-hospital-management-system-india-2026)
- Doctor Review:
  - Physician sees summary on screen; edits/confirms; proceeds to exam/counseling. [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)

***

## 5) Solution Architecture (High-Level)

```mermaid
flowchart TB
  subgraph Kiosk["MediKiosk (Patient-Facing)"]
    UI["Touch + Audio UI"]
    ASR["Indian-language ASR"]
    DM["Dialogue Manager / Clinical Ontology"]
    TTS["Text-to-Speech"]
    OCR["Document OCR + NER"]
    Summ["Summary Generator"]
  end

  subgraph Secure["Consent & Security Layer"]
    ConsentMgr["ABDM Consent Manager Client"]
    Auth["ABHA / OTP Auth"]
    Encrypt["Encryption (ECDH + AES-GCM)"]
    Audit["Audit Logs + Session Wipe"]
  end

  subgraph Backend["Hospital / ABDM"]
    FHIR["HAPI FHIR Server (R4)"]
    HIS["Hospital EMR/HIS"]
    HIECM["ABDM HIE-CM"]
    PHR["ABHA Personal Health Record"]
  end

  UI --> ASR --> DM --> Summ
  UI --> OCR --> Summ
  UI --> TTS
  Summ --> FHIR
  FHIR --> HIS
  ConsentMgr --> HIECM --> PHR
  Auth --> ConsentMgr
  Encrypt -.-> FHIR
  Audit -.-> Backend
  ```

- Edge/Kiosk:
  - Tablet/Android kiosk with mic; offline cache encrypted; session data purged post-submit. [pdpspectra](https://pdpspectra.com/blog/india-abdm-health-stack-architecture/)
- AI Services:
  - ASR: Bhashini/AI4Bharat or equivalent Indian-language models; TTS for audio prompts. [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)
  - LLM/Dialogue: constrained by clinical ontology; red-flag rules engine. [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)
  - OCR + NER: multilingual; unit normalization for labs. [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)
- Interop:
  - FHIR R4 server (e.g., HAPI) as middleware; map to ABDM Indian profiles; sandbox-first testing. [ichelonconsulting](https://ichelonconsulting.com/insights/abdm-integrated-hospital-management-system-india-2026)
- Security/Compliance:
  - DPDP-aligned data handling; India-region hosting; mTLS/HMAC for ABDM APIs. [pdpspectra](https://pdpspectra.com/blog/india-abdm-health-stack-architecture/)

***

## 6) Targeted Users & UX Principles

### Primary users
- Patients: high-volume OPD attendees; elderly; low-literacy; first-time visitors; rural/semi-urban. [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)
- Clinicians: OPD doctors (Allopathy + AYUSH) needing fast, reliable histories. [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)
- Hospital ops: triage nurses, registration desk, IT admins. [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)

### UX ideas (patient-facing)
- Zero-training design: large icons, progress bar, “Speak or Tap” on every screen. [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)
- Audio guidance: TTS prompts in local language; repeat/slow options. [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)
- Error tolerance: reprompt on low-confidence ASR; allow switching to tap mode anytime. [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)
- Privacy reassurance: clear consent screens with audio; “data will be shared only with your doctor” messaging. [pdpspectra](https://pdpspectra.com/blog/india-abdm-health-stack-architecture/)

### UX ideas (doctor-facing)
- One-screen summary: collapsible sections; red flags highlighted; timeline of prior records. [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)
- Editable fields: quick accept/amend; audit trail of changes. [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)
- Fast actions: “Mark reviewed”, “Add to EMR”, “Request labs”.

***

## 7) Data Collection → Processing → Response Generation

```mermaid
flowchart LR
  P["Patient Input"] --> V["Voice (ASR) / Touch"]
  P --> D["Document Images"]
  V --> N["NLU + Clinical Ontology"]
  D --> O["OCR + NER + Unit Normalization"]
  N --> S["Structured History Store"]
  O --> S
  S --> G["Summary Generator"]
  G --> R["Physician Summary (FHIR + UI)"]
```

- Collection:
  - Voice: short turns, guided prompts; touch MCQs/icons for key fields. [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)
  - Documents: camera capture; auto-crop/de-skew; language detection. [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)
- Processing:
  - ASR → NLU mapping to ontology (CC, HPI, PMH, Drugs, Allergy, Family, Personal, ROS). [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)
  - OCR → NER → normalize units; detect abnormal labs; build timeline. [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)
  - Red-flag rules: immediate triage tag if emergency patterns detected. [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)
- Response generation:
  - Summarizer creates a concise, standardized note; bilingual outputs. [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)
  - FHIR R4 bundle generation for EMR/ABHA; doctor UI renders the same structured data. [ichelonconsulting](https://ichelonconsulting.com/insights/abdm-integrated-hospital-management-system-india-2026)

***

## 8) Dependencies, Migration, and Feature Extensions

### Dependencies (tech & compliance)
- ABDM stack: ABHA auth, HIE-CM consent, FHIR R4 profiles (Indian IG). [ichelonconsulting](https://ichelonconsulting.com/insights/abdm-integrated-hospital-management-system-india-2026)
- ASR/TTS: Bhashini/AI4Bharat or equivalent Indian-language models. [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)
- OCR: multilingual, handwritten + printed; consider hybrid (cloud + on-device for privacy). [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)
- FHIR server: HAPI FHIR (local) + sandbox.abdm.gov.in for testing. [dev](https://dev.to/hgvanpariya/fhir-in-indian-healthcare-it-what-every-developer-building-hmis-software-needs-to-know-3lp7)
- Security: ECDH + AES-GCM encryption; mTLS/HMAC for ABDM APIs; CERT-In WASA before production. [adrine](https://www.adrine.in/blog/abdm-fhir-integration-guide-2026)

### Migration path (brownfield hospitals)
- Side-car FHIR layer: don’t refactor entire EMR; write a translation layer to FHIR R4. [dev](https://dev.to/hgvanpariya/fhir-in-indian-healthcare-it-what-every-developer-building-hmis-software-needs-to-know-3lp7)
- Patient linking first: map local IDs ↔ ABHA; then add one document type (OPD prescription) end-to-end. [dev](https://dev.to/hgvanpariya/fhir-in-indian-healthcare-it-what-every-developer-building-hmis-software-needs-to-know-3lp7)
- Consent webhooks: implement async handlers with retries for consent artefacts. [adrine](https://www.adrine.in/blog/abdm-fhir-integration-guide-2026)
- Sandbox → production: validate bundles against NRCeS profiles before go-live. [ringsafe](https://ringsafe.in/abdm-health-data-guide/)

### Feature extensions (post-MVP)
- AYUSH deep mode: full Dashavidha/Ashtavidha with scoring and Prakriti aids. [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)
- Multilingual scale: add major regional languages; accent adaptation. [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)
- Clinical safety: drug–drug/drug–allergy checks; guideline-based red flags. [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)
- Analytics: OPD throughput, missing-data rates, triage escalations, consent revocations. [pdpspectra](https://pdpspectra.com/blog/india-abdm-health-stack-architecture/)
- Integration: lab interfaces (LIS), e-pharmacy, e-referrals; AB-PMJAY workflows. [nirmitee](https://nirmitee.io/blog/abdm-compliance-ab-pmjay-hospitals-2026-deadline/)

***

## 9) Prototype Build Plan (SIH Timeline-Friendly)

- Week 1:
  - Finalize ontology (CC/HPI/PMH/Drugs/Allergy/Family/Personal/ROS-lite).
  - Set up HAPI FHIR + ABDM sandbox credentials. [dev](https://dev.to/hgvanpariya/fhir-in-indian-healthcare-it-what-every-developer-building-hmis-software-needs-to-know-3lp7)
  - Build kiosk UI (language select, consent, 3 chief complaints).
- Week 2:
  - Integrate ASR/TTS; implement adaptive questioning + red-flag rules. [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)
  - Document upload + OCR + basic NER (meds + labs). [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)
  - Summary generator + doctor screen.
- Week 3:
  - FHIR R4 bundle generation (Patient, Encounter, Condition, MedicationStatement, Observation). [ichelonconsulting](https://ichelonconsulting.com/insights/abdm-integrated-hospital-management-system-india-2026)
  - Security hardening; audit logs; session wipe. [pdpspectra](https://pdpspectra.com/blog/india-abdm-health-stack-architecture/)
  - Demo script + PPT.

***

## 10) PPT Outline (for SIH)

- Problem: OPD time crunch, records fragmentation, ABDM first-mile gap. [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)
- Solution: MediKiosk modules (A–D) with patient journey. [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)
- Architecture: Kiosk + AI + FHIR + ABDM + security. [pdpspectra](https://pdpspectra.com/blog/india-abdm-health-stack-architecture/)
- MVP: Scope, demo flow, tech stack. [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)
- Compliance: DPDP + ABDM consent + data residency. [pdpspectra](https://pdpspectra.com/blog/india-abdm-health-stack-architecture/)
- Impact: throughput, accuracy, patient experience, AYUSH personalization. [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)
- Roadmap: languages, AYUSH depth, hospital integrations. [play.google](https://play.google.com/store/apps/details?id=com.medoc.doctor&hl=en_IN)

***

## 1) End-to-End Patient Journey (High-Level)

```mermaid
flowchart LR
  A["Patient Arrival at OPD"] --> B["Identify & Authenticate"]
  B --> C["Consent Capture (ABDM)"]
  C --> D["Conversational History (Voice + Touch)"]
  D --> E["Document Scan & OCR"]
  E --> F["Structure & Summarize"]
  F --> G["Push to HIS / ABHA (FHIR R4)"]
  G --> H["Doctor Review & Confirm"]
  H --> I["Consultation & Counselling"]

  style A fill:#e3f2fd,stroke:#1565c0
  style B fill:#fff3e0,stroke:#ef6c00
  style C fill:#e8f5e9,stroke:#2e7d32
  style D fill:#f3e5f5,stroke:#7b1fa2
  style E fill:#fff8e1,stroke:#f9a825
  style F fill:#e0f7fa,stroke:#00838f
  style G fill:#e8eaf6,stroke:#3949ab
  style H fill:#ffebee,stroke:#c62828
  style I fill:#f1f8e9,stroke:#558b2f
```

***

## 2) Detailed System Architecture & Data Flow

```mermaid
flowchart TB
  subgraph Kiosk["MediKiosk Kiosk (Patient-Facing)"]
    UI["Touch + Audio UI"]
    ASR["Indian-language ASR<br/>(Bhashini/AI4Bharat)"]
    DM["Dialogue Manager<br/>(Clinical Ontology)"]
    TTS["Text-to-Speech Prompts"]
    OCR["Document OCR + NER<br/>(Printed + Handwritten)"]
    Summ["Summary Generator<br/>(CC → HPI → PMH → Drugs/Allergy → ROS)"]
    RedFlag["Red-Flag Rules Engine<br/>(Triage Alert)"]
  end

  subgraph Secure["Consent & Security Layer"]
    Auth["ABHA / OTP Auth"]
    ConsentMgr["ABDM Consent Manager Client<br/>(HIE-CM)"]
    Encrypt["Encryption: ECDH + AES-GCM"]
    Audit["Audit Logs + Session Wipe"]
    DPDP["DPDP 2023 Controls<br/>(Purpose, Retention, Erasure)"]
  end

  subgraph Backend["Hospital / ABDM Backend"]
    FHIR["HAPI FHIR Server (R4)<br/>Patient, Encounter, Condition,<br/>MedicationStatement, Observation"]
    HIS["Hospital EMR/HIS"]
    HIECM["ABDM HIE-CM Gateway"]
    PHR["ABHA Personal Health Record"]
  end

  UI --> ASR --> DM --> Summ
  UI --> OCR --> Summ
  UI --> TTS
  DM --> RedFlag
  Summ --> FHIR
  FHIR --> HIS
  ConsentMgr --> HIECM --> PHR
  Auth --> ConsentMgr
  Encrypt -.-> FHIR
  Audit -.-> Backend
  DPDP -.-> Secure

  style Kiosk fill:#e3f2fd,stroke:#1565c0
  style Secure fill:#e8f5e9,stroke:#2e7d32
  style Backend fill:#e0f7fa,stroke:#00838f
```

***

## 3) ABDM Consent Flow (HIU → HIE-CM → HIP → PHR)

```mermaid
sequenceDiagram
  participant P as "Patient (Kiosk)"
  participant K as "MediKiosk (HIU)"
  participant CM as "ABDM HIE-CM"
  participant HIP as "Prior Hospital / Lab (HIP)"
  participant PHR as "ABHA PHR"

  P->>K: Authenticate (ABHA/OTP) + Select Language
  K->>CM: Consent Request<br/>(Data types: Condition, MedicationStatement, Observation,<br/>Purpose: Treatment, Duration: 30 days)
  CM->>P: Consent Notification (Patient App / SMS)
  P->>CM: Grant Consent (Granular, Revocable)
  CM->>K: Consent Artefact (Signed, Machine-Readable) [23][24]
  K->>HIP: Fetch Records (Present Consent Artefact) [25]
  HIP->>K: FHIR R4 Bundle (Conditions, Meds, Labs) [dev](https://dev.to/hgvanpariya/fhir-in-indian-healthcare-it-what-every-developer-building-hmis-software-needs-to-know-3lp7)
  K->>PHR: Push New Encounter + Summary (FHIR R4) [hapi.fhir](https://hapi.fhir.org/resource?serverId=home_r4&pretty=true&_summary=&resource=Patient)
  K->>K: Audit Log + Session Wipe [atrius](https://atrius.in/fhir/r4/atrius-in/atrius-and-ndhm.html)

  note right of K: Consent artefact specifies<br/>who, what, purpose, duration [23]
```

***

## 4) AI & Data Processing Pipeline (Voice/Touch + Documents → Summary)

```mermaid
flowchart LR
  subgraph Input["Patient Input"]
    V["Voice (ASR)"]
    T["Touch (MCQ/Icons)"]
    D["Document Images<br/>(Prescriptions, Labs, Discharge)"]
  end

  subgraph Process["Processing"]
    ASR["ASR → Text (Hindi/English/Regional)"]
    NLU["NLU + Clinical Ontology Mapping<br/>(CC, HPI, PMH, Drugs, Allergy, Family, Personal, ROS)"]
    OCR["OCR + NER<br/>(Diagnoses, Meds, Labs, Procedures)"]
    Norm["Unit Normalization + Abnormal Flagging"]
    Merge["Merge: Conversation + Extracted Entities"]
    Rules["Red-Flag Rules (Triage)"]
  end

  subgraph Output["Outputs"]
    Summ["Structured Summary<br/>(Physician-Ready)"]
    FHIR["FHIR R4 Bundle<br/>(Patient, Encounter, Condition,<br/>MedicationStatement, Observation)"]
    Alert["Triage Alert (if emergency)"]
  end

  V --> ASR --> NLU --> Merge
  T --> NLU
  D --> OCR --> Norm --> Merge
  Merge --> Rules
  Merge --> Summ
  Summ --> FHIR
  Rules --> Alert

  style Input fill:#fff8e1,stroke:#f9a825
  style Process fill:#e3f2fd,stroke:#1565c0
  style Output fill:#e8f5e9,stroke:#2e7d32
```

***

## 5) Doctor/HIS Integration & Edit Loop

```mermaid
flowchart TB
  A["Doctor Opens Patient Queue"] --> B["Load Structured Summary<br/>(CC → HPI → PMH → Drugs/Allergy → ROS)"]
  B --> C["Review Timeline of Prior Records<br/>(Labs, Prescriptions, Discharge Summaries)"]
  C --> D["Edit/Confirm Fields<br/>(Add/Amend/Reject)"]
  D --> E["Save to EMR (FHIR R4 Update)"]
  E --> F["Proceed to Examination & Counselling"]

  subgraph EMR["Hospital EMR / HIS"]
    E
  end

  style A fill:#ffebee,stroke:#c62828
  style B fill:#e3f2fd,stroke:#1565c0
  style C fill:#e8f5e9,stroke:#2e7d32
  style D fill:#fff3e0,stroke:#ef6c00
  style E fill:#e0f7fa,stroke:#00838f
  style F fill:#f1f8e9,stroke:#558b2f
  style EMR fill:#e8eaf6,stroke:#3949ab
```

***

## How to Use These in Your PPT

- **Slide 1 (Problem → Solution):** Use Diagram 1 (Patient Journey) to show the before/after flow.
- **Slide 2 (Architecture):** Use Diagram 2 for tech stack, modules, and security.
- **Slide 3 (Compliance):** Use Diagram 3 (ABDM Consent) to demonstrate DPDP + ABDM alignment. [caladriushealth](https://caladriushealth.ai/blog/2026/07/22/Consent-By-Design/)
- **Slide 4 (AI Pipeline):** Use Diagram 4 to explain how voice/touch + documents become a structured summary.
- **Slide 5 (Doctor Workflow):** Use Diagram 5 to show physician control and EMR integration.

