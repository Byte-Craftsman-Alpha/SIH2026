# SIH26047 — Patient Case-Taking Software  
## Proposed Solution: MediKiosk

---

# 1. Problem Statement Breakdown

## 1.1 Core Problem

Government and AYUSH hospitals manage thousands of OPD patients daily, but doctors often get only **2–5 minutes per patient**. This creates:

- Incomplete clinical history
- Repeated questioning across visits
- Missed allergies, medications, comorbidities, and previous procedures
- Poor documentation
- Long OPD queues
- Delayed identification of emergency symptoms
- Difficulty reviewing paper-based medical records

## 1.2 Major Problem Areas

### A. Clinical History-Taking Bottleneck

The physician needs to collect:

- Chief complaint
- History of present illness
- Past medical history
- Past surgical history
- Drug history
- Allergy history
- Family history
- Personal and social history
- Review of systems
- Previous investigations

However, this process is time-consuming and often incomplete.

### B. Patient Diversity

The system must support:

- Hindi, English, and regional languages
- Elderly patients
- Low-literacy patients
- Rural and first-time hospital visitors
- Patients with limited smartphone experience
- Patients uncomfortable with typing
- Patients who prefer voice interaction

### C. Paper-Based Medical Records

Patients may carry:

- Prescriptions
- Laboratory reports
- Discharge summaries
- Imaging reports
- Referral notes
- Surgery records
- Handwritten medical documents

These documents are often:

- Unstructured
- In different languages
- Chronologically disorganized
- Difficult to read
- Not digitally connected to hospital records

### D. AYUSH-Specific Requirements

Ayurvedic consultation may require:

- Prakriti
- Vikriti
- Sara
- Samhanana
- Pramana
- Satmya
- Sattva
- Ahara Shakti
- Vyayama Shakti
- Vaya
- Agni
- Koshtha
- Ahara-Vihara
- Nidana
- Samprapti

A generic allopathic intake form does not adequately support this workflow.

### E. Lack of Interoperability

Existing registration software commonly stores only:

- Patient name
- Age
- Gender
- Contact number
- Appointment
- Department
- Token number

It usually does not provide:

- Structured clinical history
- OCR-based medical record extraction
- ABHA-linked records
- FHIR-based exchange
- Physician-editable AI summaries
- Consent tracking

---

# 2. Proposed Solution

## 2.1 Solution Name

## MediKiosk

An AI-powered, multilingual, patient-facing clinical intake platform that enables patients to:

1. Register or identify themselves
2. Give their medical history through voice or touch
3. Scan previous medical documents
4. Receive adaptive clinical questions
5. Detect possible red-flag symptoms
6. Generate a structured medical history
7. Share the summary with the doctor after consent
8. Connect relevant data with the hospital system and ABDM ecosystem

## 2.2 Main Objective

> To collect a comprehensive, structured, and verifiable patient history before doctor consultation, thereby reducing documentation burden and improving OPD efficiency without replacing the physician.

---

# 3. Solution Modules

## Module A — Patient Registration and Consent

### Functions

- New patient registration
- Existing patient lookup
- ABHA ID entry or scan
- Hospital ID/token lookup
- Language selection
- Audio-guided consent
- Consent withdrawal or cancellation
- Optional demographic verification

### Important Design Principle

Aadhaar should not be treated as the default medical identifier. The system should prioritize:

- ABHA ID
- Hospital patient ID
- Token number
- Consent-based identity matching

---

## Module B — Conversational Clinical History Engine

### Functions

- Voice-based interview
- Touch-based questionnaire
- Language selection
- Automatic translation where required
- Adaptive follow-up questions
- Clinical history completeness tracking
- Patient confirmation before final submission

### Example

If the patient says:

> “I have chest pain.”

The system may ask:

- When did the pain start?
- Is it continuous or intermittent?
- Where exactly is the pain?
- Does it spread to the arm, jaw, shoulder, or back?
- Is it burning, squeezing, stabbing, or heavy?
- Does it increase on walking?
- Is there breathlessness, sweating, dizziness, or vomiting?
- Has this happened before?

### Clinical Frameworks

The system can use complaint-specific templates such as:

- SOCRATES for pain
- OPQRST for symptom analysis
- Respiratory symptom template
- Gastrointestinal symptom template
- Neurological symptom template
- Obstetric and gynaecological template
- Paediatric template
- AYUSH/Dashavidha Pariksha template

The framework should support clinician-approved question paths rather than unrestricted AI questioning.

---

## Module C — Red-Flag Detection

### Potential Red Flags

- Severe chest pain with breathlessness
- Facial deviation or limb weakness
- Severe bleeding
- Unconsciousness
- Sudden severe headache
- Severe allergic reaction
- Pregnancy-related emergency symptoms
- Severe abdominal pain with shock-like symptoms
- Suicidal thoughts or immediate mental-health risk

### Action

The system should not diagnose. It should:

1. Detect a predefined emergency pattern
2. Stop routine questioning if necessary
3. Display and play an urgent message
4. Alert the triage desk
5. Assign a priority flag
6. Record the alert in the audit trail

### Example Alert

> “Possible urgent symptoms detected. Please wait. A healthcare worker has been notified.”

---

## Module D — Medical Document Digitization

### Workflow

- Capture document image through scanner or camera
- Detect document boundaries
- Improve image quality
- Perform OCR
- Identify document type
- Extract medical entities
- Ask patient to verify extracted information
- Add the record to the medical timeline

### Documents Supported

- Printed prescriptions
- Handwritten prescriptions
- Lab reports
- Discharge summaries
- Referral letters
- Imaging reports
- Operation notes
- Medication lists
- Vaccination records

### Extracted Data

- Date
- Hospital or provider
- Diagnosis
- Medication name
- Dosage
- Frequency
- Duration
- Investigation name
- Result
- Unit
- Reference range
- Procedure
- Surgery
- Allergy
- Follow-up instruction

### Important Limitation

OCR output must be labelled as:

- Extracted
- Patient-verified
- Physician-verified

No extracted information should be treated as clinically confirmed until verified by a healthcare professional.

---

## Module E — Timeline Generator

The system creates a chronological view of:

- Previous illnesses
- Hospital admissions
- Surgeries
- Investigations
- Medication changes
- Allergies
- Major clinical events

### Example

```text
2019 ── Diabetes diagnosed
2021 ── Cataract surgery
2023 ── High blood pressure reported
2024 ── Kidney function test performed
2026 ── Current OPD complaint
```

---

## Module F — Structured Summary Generator

### Physician-Facing Summary

```text
Patient Identification
Chief Complaint
History of Present Illness
Past Medical History
Past Surgical History
Drug History
Allergy History
Family History
Personal and Social History
Review of Systems
Previous Investigations
Current Medications
AI-Detected Alerts
Patient-Reported Information
OCR-Extracted Information
Unverified Fields
```

### Summary Requirements

- Concise
- Chronological
- Bilingual if required
- Editable
- Source-linked
- Confidence-labelled
- Non-diagnostic
- Physician-verifiable

---

## Module G — Doctor Review Dashboard

The doctor should be able to:

- View the complete summary
- Open the original scanned document
- See extracted text beside the image
- Correct errors
- Add missing information
- Mark data as verified
- Reject incorrect entries
- View red-flag alerts
- Add clinical notes
- Export or save the final record
- Push approved data to HIS/EMR

---

## Module H — ABDM and HIS Integration

### Possible Integration Components

- ABHA lookup
- Consent artefact management
- FHIR-based clinical data exchange
- Hospital patient ID mapping
- HIS/EMR record update
- Digital health record linking
- Doctor authentication
- Access audit logs

### Integration Principle

The prototype should use a modular integration layer so that it can initially work with mock APIs and later connect to:

- Hospital Information System
- Electronic Medical Record
- ABDM ecosystem
- FHIR server
- Laboratory Information System
- Pharmacy system

---

# 4. Minimum Viable Product

The MVP should demonstrate the complete patient-to-doctor workflow without trying to solve every possible clinical scenario.

## 4.1 MVP Scope

### Patient Side

- Language selection: Hindi and English
- New patient or existing patient flow
- Consent screen
- Basic demographics
- Voice and touch input
- History collection for 3–5 common complaints
- Patient confirmation screen
- Document image upload
- OCR for printed documents
- Basic extraction of medicines and laboratory values
- Structured summary generation
- Mock ABHA/HIS integration

### Doctor Side

- Doctor login
- Patient queue
- Structured history summary
- Original document preview
- Extracted information
- Red-flag alert
- Edit and verify functionality
- Final submission

## 4.2 Recommended MVP Complaints

Choose common and demonstrable cases:

1. Fever
2. Cough and breathlessness
3. Chest pain
4. Abdominal pain
5. Headache

For the SIH demonstration, **chest pain and fever** are useful because they demonstrate both adaptive questioning and red-flag detection.

## 4.3 MVP AYUSH Extension

The MVP can include a limited AYUSH module with:

- Prakriti
- Agni
- Koshtha
- Ahara
- Vihara
- Sleep
- Bowel habits
- Current symptoms
- Selected Dashavidha Pariksha parameters

The complete Ayurvedic framework can be included in the product roadmap.

## 4.4 MVP Exclusions

To control scope, the first prototype should not attempt:

- Autonomous diagnosis
- Autonomous prescription
- Fully reliable handwritten OCR for all scripts
- Real-time integration with every hospital HIS
- Complete support for all Indian languages
- Automatic drug-interaction decisions
- Direct emergency medical intervention
- Unverified patient-generated data being written permanently into the medical record

---

# 5. MVP Demonstration Scenario

## Scenario

A patient arrives at a government hospital with chest discomfort and previous laboratory reports.

### Patient Flow

1. Selects Hindi
2. Scans ABHA card or enters temporary patient ID
3. Listens to consent explanation
4. Gives consent
5. Reports chest pain through voice
6. Answers adaptive questions
7. Reports sweating and breathlessness
8. System generates a red-flag alert
9. Triage staff receives the alert
10. Patient scans a previous lab report
11. OCR extracts cholesterol and blood sugar values
12. Patient confirms the extracted values
13. System creates a structured history summary
14. Doctor opens the summary
15. Doctor reviews, corrects, and confirms it

---

# 6. End-to-End Working Methodology

## 6.1 High-Level Process

```mermaid
flowchart TD
    A[Patient Arrives] --> B[Registration or Patient Lookup]
    B --> C[Language Selection]
    C --> D[Consent Collection]
    D --> E[Voice and Touch History Interview]
    E --> F{Red Flag Detected?}
    F -->|Yes| G[Alert Triage Staff]
    F -->|No| H[Continue History]
    G --> H
    H --> I[Scan Previous Documents]
    I --> J[OCR and Document Classification]
    J --> K[Clinical Entity Extraction]
    K --> L[Patient Verification]
    L --> M[Structured Summary Generation]
    M --> N[Doctor Dashboard]
    N --> O[Doctor Edits and Verifies]
    O --> P[Save to HIS or EMR]
    P --> Q[Optional ABDM Linking]
```

---

## 6.2 Patient History Workflow

```mermaid
flowchart TD
    A[Start Interview] --> B[Chief Complaint]
    B --> C[Complaint-Specific Questions]
    C --> D[Past Medical and Surgical History]
    D --> E[Medication and Allergy History]
    E --> F[Family and Personal History]
    F --> G[Review of Systems]
    G --> H[AYUSH Questions if AYUSH Mode]
    H --> I[Patient Reviews Answers]
    I --> J{Patient Confirms?}
    J -->|No| K[Edit or Repeat Answer]
    K --> I
    J -->|Yes| L[Save Structured History]
```

---

## 6.3 Voice and Touch Interaction

```mermaid
flowchart LR
    A[Question Displayed] --> B[Audio Prompt]
    B --> C{Patient Input Method}
    C -->|Voice| D[ASR]
    C -->|Touch| E[Buttons, Icons, Sliders]
    D --> F[Language Processing]
    E --> G[Answer Normalization]
    F --> G
    G --> H[Clinical Data Object]
    H --> I[Next Adaptive Question]
```

---

## 6.4 Document Processing Workflow

```mermaid
flowchart TD
    A[Capture Document] --> B[Quality Check]
    B --> C{Image Usable?}
    C -->|No| D[Ask Patient to Recapture]
    D --> A
    C -->|Yes| E[Document Classification]
    E --> F[OCR]
    F --> G[Language and Layout Detection]
    G --> H[Entity Extraction]
    H --> I[Confidence Scoring]
    I --> J[Patient Verification]
    J --> K[Timeline Placement]
    K --> L[Summary Integration]
```

---

# 7. Solution Architecture

## 7.1 Architecture Diagram

```mermaid
flowchart TB
    subgraph Client Layer
        A[Patient Kiosk]
        B[Patient Mobile or Tablet]
        C[Doctor Web Dashboard]
        D[Triage Dashboard]
    end

    subgraph API Layer
        E[API Gateway]
        F[Authentication Service]
        G[Consent Service]
        H[Session Manager]
    end

    subgraph Application Layer
        I[History Interview Service]
        J[Dialogue Manager]
        K[Red Flag Engine]
        L[Document Processing Service]
        M[Summary Generator]
        N[Timeline Service]
        O[Notification Service]
    end

    subgraph AI Layer
        P[Indian Language ASR]
        Q[Language Detection and Translation]
        R[Clinical NLP and Entity Extraction]
        S[OCR Engine]
        T[Text to Speech]
        U[Rule-Based Safety Layer]
    end

    subgraph Data Layer
        V[Patient Database]
        W[Clinical History Store]
        X[Document Object Storage]
        Y[Audit Log Database]
        Z[Search and Timeline Index]
    end

    subgraph Integration Layer
        AA[Hospital HIS or EMR]
        AB[FHIR Server]
        AC[ABDM Integration]
        AD[Laboratory or Pharmacy Systems]
    end

    A --> E
    B --> E
    C --> E
    D --> E

    E --> F
    E --> G
    E --> H

    H --> I
    I --> J
    I --> K
    I --> L
    I --> M
    I --> N
    K --> O

    J --> P
    J --> Q
    J --> T
    L --> S
    L --> R
    M --> R
    K --> U

    I --> W
    L --> X
    M --> W
    N --> Z
    E --> V
    G --> Y
    F --> Y

    M --> AA
    M --> AB
    G --> AC
    AA --> AD
```

---

## 7.2 Recommended Technology Stack

| Layer | Recommended Technology |
|---|---|
| Patient kiosk UI | React, Next.js, Flutter, or Android |
| Doctor dashboard | React or Angular |
| Backend APIs | FastAPI, Node.js, or Spring Boot |
| Database | PostgreSQL |
| Document storage | S3-compatible object storage |
| Search and timeline | OpenSearch or PostgreSQL indexing |
| ASR | Bhashini, AI4Bharat, or approved Indian-language ASR |
| OCR | PaddleOCR, Tesseract, cloud OCR, or medical OCR model |
| NLP | Clinical NLP model plus constrained LLM |
| TTS | Bhashini or Indian-language TTS |
| Authentication | OAuth2, OpenID Connect, hospital identity provider |
| Integration | FHIR APIs and REST APIs |
| Deployment | Hospital private cloud, government cloud, or secure hybrid cloud |
| Monitoring | Centralized logs, audit trails, metrics, and alerts |

---

# 8. Data Collection

## 8.1 Data Sources

### Patient-Generated Data

- Voice responses
- Touch responses
- Patient-entered demographics
- Consent selections
- Confirmation and correction actions

### Document Data

- Prescription images
- Lab report images
- Discharge summary images
- Referral notes
- Imaging reports

### Hospital Data

- Patient ID
- Department
- Token number
- Appointment details
- Previous encounters
- Doctor assignment

### ABDM-Related Data

- ABHA identifier
- Consent information
- Shared health record references
- FHIR resources, where integration is available

---

## 8.2 Data Collection Principles

- Collect only necessary information
- Explain why each category is required
- Use explicit consent
- Use local-language audio instructions
- Allow patients to skip non-mandatory questions
- Allow correction of answers
- Record the source of every data element
- Never silently infer sensitive medical details
- Separate patient-reported information from verified clinical information

---

## 8.3 Sample Structured Data Object

```json
{
  "patient_id": "HOSP-2026-001245",
  "language": "hi-IN",
  "consent": {
    "history_capture": true,
    "document_processing": true,
    "doctor_sharing": true,
    "abdm_linking": false
  },
  "chief_complaint": {
    "value": "Chest pain",
    "source": "voice",
    "confidence": 0.96,
    "patient_verified": true
  },
  "history_of_present_illness": {
    "onset": "2 hours ago",
    "character": "pressure-like",
    "radiation": "left arm",
    "associated_symptoms": [
      "breathlessness",
      "sweating"
    ],
    "source": "voice",
    "patient_verified": true
  },
  "red_flag": {
    "status": true,
    "reason": "Chest pain with breathlessness and sweating",
    "action": "triage_alert_sent"
  },
  "documents": [
    {
      "document_type": "laboratory_report",
      "date": "2025-11-15",
      "ocr_status": "patient_verified",
      "extracted_entities": [
        {
          "test": "Fasting blood glucose",
          "value": "148",
          "unit": "mg/dL"
        }
      ]
    }
  ]
}
```

---

# 9. Data Processing Pipeline

## 9.1 Voice Processing

```text
Patient speech
      ↓
Noise reduction
      ↓
Language and speech detection
      ↓
Automatic speech recognition
      ↓
Text normalization
      ↓
Clinical entity extraction
      ↓
Question-specific answer mapping
      ↓
Patient confirmation
      ↓
Structured clinical field
```

## 9.2 Document Processing

```text
Document image
      ↓
Blur and quality detection
      ↓
Crop and perspective correction
      ↓
Document classification
      ↓
OCR
      ↓
Layout understanding
      ↓
Medical entity extraction
      ↓
Confidence scoring
      ↓
Patient verification
      ↓
Physician verification
```

## 9.3 Response Generation

The system should generate different outputs for different users.

### Patient Output

- Simple language
- Local-language audio
- Confirmation prompts
- Next-step instructions
- No alarming diagnostic statements

### Triage Output

- Priority flag
- Reason for alert
- Patient location
- Token number
- Relevant symptoms
- Time of detection

### Physician Output

- Structured history
- Chronological timeline
- Medication list
- Allergies
- Abnormal laboratory values
- Source and confidence labels
- Original document links
- Red-flag indicators

### Hospital Administrator Output

- Number of patients processed
- Average intake time
- Completion rate
- Average doctor review time
- Number of triage alerts
- OCR correction rate
- Language-wise usage
- Kiosk uptime

---

# 10. Targeted Users

## 10.1 Primary Users

### Patients

Especially:

- Government hospital OPD patients
- Elderly patients
- Low-literacy users
- Rural patients
- First-time visitors
- Patients carrying paper records
- Patients speaking Indian regional languages
- Patients with limited smartphone access

### Doctors

- General physicians
- Specialists
- AYUSH practitioners
- Medical officers
- Emergency and triage doctors

### Nursing and Triage Staff

- Monitor emergency alerts
- Assist patients
- Handle incomplete sessions
- Escalate urgent cases

---

## 10.2 Secondary Users

- Registration desk staff
- Medical record department
- Hospital administrators
- Medical students
- Public health researchers
- IT administrators
- ABDM or digital health integration teams

---

# 11. Expected User Experience

## 11.1 UX Principles

- Speak first, type less
- One question at a time
- Large buttons
- High contrast
- Minimal text
- Audio instructions
- Local-language support
- Visible progress indicator
- Easy correction
- No technical terminology
- Assisted mode for staff
- Clear privacy explanations

## 11.2 Patient UX Flow

```mermaid
journey
    title Patient MediKiosk Experience
    section Arrival
      Find kiosk: 4: Patient
      Select language: 5: Patient
      Understand consent: 3: Patient
    section History
      Answer by speaking: 4: Patient
      Answer by tapping: 4: Patient
      Correct an answer: 4: Patient
    section Documents
      Scan a document: 3: Patient
      Confirm extracted data: 3: Patient
    section Completion
      View progress: 4: Patient
      Receive token or confirmation: 5: Patient
      Reach doctor with summary ready: 5: Patient
```

## 11.3 Patient Screen Sequence

### Screen 1 — Welcome

- “Namaste”
- Language selection
- Start button
- Assisted mode button

### Screen 2 — Identity

- Scan ABHA card
- Enter hospital ID
- Continue as new patient
- Staff assistance option

### Screen 3 — Consent

- Audio explanation
- Simple visual icons
- Accept, decline, or ask for help
- Separate consent categories

### Screen 4 — Interview

- Large question text
- Audio playback
- Speak button
- Touch answer options
- Repeat question button
- Progress indicator

### Screen 5 — Document Capture

- Document placement illustration
- Automatic image quality check
- Retake option
- Add another document option

### Screen 6 — Confirmation

- Read-back of major answers
- Edit option
- Submit option

### Screen 7 — Completion

- Token number
- Estimated next step
- Emergency instruction if applicable
- Audio confirmation

---

# 12. Physician Experience

## 12.1 Doctor Dashboard Layout

```text
------------------------------------------------------
Patient Name | Age | Gender | Token | Language
------------------------------------------------------
RED FLAG: Possible urgent symptoms
------------------------------------------------------
Chief Complaint
History of Present Illness
Past History
Medication and Allergy History
Family and Personal History
Review of Systems
------------------------------------------------------
Previous Documents | Timeline | Lab Values
------------------------------------------------------
[Edit] [Verify] [Reject Field] [Save to HIS]
```

## 12.2 Physician Controls

- Expand or collapse sections
- Show only abnormal findings
- View evidence source
- Play original patient audio if permitted
- Open scanned document
- Correct extracted text
- Mark information as verified
- Add clinical notes
- Export summary
- Reject AI-generated content

---

# 13. Privacy, Consent, and Security

## 13.1 Consent Requirements

Consent should clearly cover:

- Clinical history recording
- Voice processing
- Document scanning
- AI-assisted structuring
- Sharing with the treating doctor
- HIS/EMR storage
- ABDM linking
- Future research use, if applicable

These should be separate and granular rather than combined into one broad consent.

## 13.2 Security Measures

- Encryption in transit
- Encryption at rest
- Role-based access control
- Doctor and staff authentication
- Session timeout
- Device locking
- Temporary audio deletion after processing
- Document access logging
- Consent audit trail
- Data retention policy
- Backup and disaster recovery
- Network segmentation
- Secure API gateway

## 13.3 Data Classification

| Data Type | Example | Protection |
|---|---|---|
| Identity data | Name, age, ABHA ID | High |
| Health data | Symptoms, diagnosis history | Very high |
| Biometric-like data | Voice recording | Very high |
| Documents | Prescription, discharge summary | Very high |
| Operational data | Token number | Medium |
| Anonymous analytics | Completion rate | Low to medium |

---

# 14. AI Safety and Clinical Governance

## 14.1 System Must Not

- Diagnose the patient autonomously
- Prescribe medication
- Change a physician's decision
- Hide uncertain information
- Convert low-confidence OCR into confirmed facts
- Delay emergency escalation
- Present AI output as a final medical opinion

## 14.2 Required Safety Controls

- Rule-based red-flag engine
- Clinician-approved question bank
- Confidence scoring
- Source attribution
- Patient confirmation
- Doctor verification
- Audit trail
- Human override
- Safe fallback to manual intake
- Offline or degraded-mode operation

## 14.3 Confidence Display

Example:

```text
Medication: Metformin 500 mg
Source: Scanned prescription
OCR confidence: Medium
Patient verified: Yes
Physician verified: No
```

---

# 15. Dependencies

## 15.1 Technical Dependencies

- Kiosk or tablet hardware
- Microphone and speaker
- Document scanner or camera
- Stable hospital network
- Secure server or cloud environment
- ASR service
- TTS service
- OCR engine
- Clinical NLP model
- Database
- HIS/EMR APIs
- FHIR server
- ABDM integration access

## 15.2 Operational Dependencies

- Hospital administration approval
- Doctor and nurse participation
- Patient assistance staff
- Language and clinical content validation
- Triage escalation protocol
- Consent policy
- Data retention policy
- IT support and maintenance
- Device cleaning and physical security

## 15.3 Regulatory and Governance Dependencies

- Applicable data protection compliance
- Hospital ethics and governance approval
- ABDM integration guidelines
- User consent framework
- Role-based access policy
- Clinical validation of questionnaires
- Medical device classification review, if applicable

---

# 16. Migration Strategy from Existing Systems

The system should not require immediate replacement of existing registration or HIS software.

## 16.1 Phase 1 — Standalone Pilot

- Deploy MediKiosk separately
- Use temporary patient IDs
- Generate downloadable summaries
- Doctor accesses a separate dashboard
- No live HIS integration required

## 16.2 Phase 2 — Registration Integration

- Connect to hospital registration system
- Import patient name, age, gender, department, and token
- Return completion status and summary ID

## 16.3 Phase 3 — HIS/EMR Integration

- Map MediKiosk data to hospital records
- Push only doctor-approved data
- Preserve original document references
- Add audit trails

## 16.4 Phase 4 — FHIR and ABDM Integration

- Map data to appropriate FHIR resources
- Implement consent management
- Support ABHA-linked record sharing
- Enable patient-controlled sharing

## 16.5 Migration Diagram

```mermaid
flowchart LR
    A[Existing Registration System] --> B[MediKiosk Adapter]
    B --> C[MediKiosk Intake Platform]
    C --> D[Doctor Review]
    D --> E[Approved Clinical Summary]
    E --> F[HIS or EMR]
    E --> G[FHIR Server]
    G --> H[ABDM Ecosystem]
```

---

# 17. Feature Extension Roadmap

## Phase 1 — Prototype

- Hindi and English
- Basic patient registration
- Voice and touch history
- Five complaint pathways
- Printed document OCR
- Structured summary
- Doctor dashboard
- Mock integration
- Red-flag alert

## Phase 2 — Pilot

- More languages
- Regional accent improvement
- Better handwritten OCR
- AYUSH history module
- Staff-assisted mode
- Offline queueing
- Hospital integration
- Usage analytics

## Phase 3 — Production

- ABDM integration
- FHIR interoperability
- Multi-hospital deployment
- Role-based administration
- Device management
- Advanced audit and monitoring
- Human review workflows

## Phase 4 — Advanced Features

- Personal health record timeline
- Follow-up visit comparison
- Medication adherence questions
- Patient education
- Voice-based report explanation
- Specialist-specific intake
- Paediatric and obstetric modules
- Mental-health screening with appropriate safeguards
- Population-level anonymized analytics

---

# 18. Scalability and Extensibility

## 18.1 Modular Design

Each major capability should be an independent service:

- Registration
- Consent
- Interview
- OCR
- NLP
- Summary
- Notifications
- Integration
- Analytics

This allows new modules to be added without rebuilding the entire platform.

## 18.2 Configuration-Based Clinical Questionnaires

Questionnaires should be stored as configurable templates rather than hard-coded.

```json
{
  "complaint": "fever",
  "questions": [
    {
      "id": "fever_duration",
      "text": "How long have you had fever?",
      "type": "duration",
      "required": true
    },
    {
      "id": "associated_symptoms",
      "text": "Do you have cough, vomiting, or body ache?",
      "type": "multi_select",
      "required": false
    }
  ]
}
```

This allows hospitals to add:

- New symptoms
- Specialty-specific questions
- AYUSH questionnaires
- Paediatric templates
- Department-specific workflows

## 18.3 API-First Integration

The platform should expose APIs for:

- Patient lookup
- Session creation
- Consent recording
- History retrieval
- Document upload
- Summary retrieval
- Doctor verification
- HIS submission
- Audit access

---

# 19. Prototype Architecture for SIH

## 19.1 Suggested Prototype Components

### Frontend

- Patient kiosk interface
- Doctor dashboard
- Triage alert panel
- Admin analytics page

### Backend

- User and patient management
- Session management
- Questionnaire engine
- OCR processing
- Summary generation
- Alert service
- Mock HIS connector

### AI Demonstration

For the prototype, use:

- Predefined clinical question flows
- Speech-to-text API or mock voice input
- OCR API or sample document processing
- Rule-based red-flag detection
- Controlled LLM summarization
- Text-to-speech for Hindi and English

## 19.2 Suggested Demo Data

Prepare three synthetic patient cases:

### Case 1 — Routine Fever

- Fever for three days
- Body ache
- No emergency symptoms
- Previous CBC report

### Case 2 — Chest Pain Red Flag

- Chest pressure
- Breathlessness
- Sweating
- Previous diabetes history
- Immediate triage alert

### Case 3 — AYUSH Consultation

- Digestive complaints
- Irregular diet
- Sleep disturbance
- Agni and Koshtha questions
- Dashavidha Pariksha summary

Use synthetic data only in the prototype.

---

# 20. Success Metrics

## 20.1 Patient Metrics

- Percentage of patients completing intake
- Average completion time
- Voice versus touch usage
- Language-wise completion rate
- Assistance requests
- Patient correction rate

## 20.2 Clinical Metrics

- Average doctor review time
- History completeness
- Number of missed fields
- OCR verification rate
- Red-flag detection sensitivity
- False-alert rate
- Percentage of summaries edited by doctors

## 20.3 Hospital Metrics

- OPD throughput
- Reduction in registration-to-consultation time
- Reduction in repeated questioning
- Kiosk uptime
- HIS integration success rate
- Number of patients processed per kiosk per day

## 20.4 Suggested Pilot Targets

These can be presented as prototype goals rather than guaranteed outcomes:

- Complete patient intake within 8–12 minutes
- Reduce physician history-taking time by 30–50%
- Achieve over 80% completion for supported questions
- Make 100% of AI summaries physician-editable
- Route 100% of configured red-flag cases to triage review
- Maintain full auditability of shared data

---

# 21. Key Differentiators

- Designed for Indian public hospital OPDs
- Patient-facing rather than only doctor-facing
- Works through voice and touch
- Supports multilingual and low-literacy users
- Includes clinical history, not merely registration
- Digitizes previous paper documents
- Supports AYUSH history-taking
- Includes emergency red-flag routing
- Produces physician-ready summaries
- Consent-first and ABDM-compatible
- Designed to integrate with existing systems
- Keeps the physician in control

---

# 22. One-Line Value Proposition

> MediKiosk converts a patient’s spoken history, touch responses, and paper medical records into a verified, structured clinical summary before consultation, helping doctors spend less time documenting and more time treating.

---

# 23. Recommended SIH Prototype Story

Use the following narrative during the demonstration:

```text
A patient enters a busy government hospital OPD.
The patient selects Hindi and gives consent using audio guidance.
MediKiosk collects the history through voice and touch.
When the patient reports chest pain with breathlessness and sweating,
the system immediately alerts the triage team.
The patient then scans an old laboratory report.
The system extracts relevant values, asks the patient to verify them,
and creates a chronological medical summary.
The doctor opens the dashboard, reviews the summary, corrects one field,
and submits the verified record to the hospital system.
```

This single workflow demonstrates:

- Multilingual accessibility
- Voice interaction
- Touch fallback
- Adaptive questioning
- Red-flag detection
- Document OCR
- Timeline generation
- Human verification
- Doctor dashboard
- HIS integration concept
- Patient safety and privacy

---

# 24. Suggested PPT Structure

1. Title Slide  
2. Problem Statement  
3. Impact of the Current System  
4. Existing Solutions and Their Limitations  
5. Proposed Solution: MediKiosk  
6. Target Users  
7. Patient Journey  
8. Core Modules  
9. AI-Powered History-Taking Workflow  
10. Medical Document Digitization Workflow  
11. Solution Architecture  
12. Data Collection and Processing  
13. Doctor Dashboard  
14. AYUSH Mode  
15. Privacy, Consent, and Security  
16. MVP Scope  
17. Prototype Demonstration  
18. Integration and Migration Strategy  
19. Scalability and Future Extensions  
20. Expected Impact  
21. Technology Stack  
22. Team Roles and Responsibilities  
23. Business or Deployment Model  
24. Conclusion

Below is a detailed Mermaid flowchart for **MediKiosk — Patient Case-Taking Software**, based on your previous project workflow but redesigned for SIH26047.

You can paste this directly into:

- Mermaid Live Editor
- GitHub Markdown
- Notion
- Obsidian
- draw.io using **Arrange → Insert → Advanced → Mermaid**
- Mermaid-supported documentation tools

---

# MediKiosk Complete System Flowchart

```mermaid
flowchart TB

%% =====================================================
%% ENTRY POINT
%% =====================================================

START([Patient Arrives at Hospital OPD])

START --> ACCESS{How will patient access MediKiosk?}

ACCESS -->|Self-service kiosk| KIOSK[Patient Kiosk]
ACCESS -->|Tablet assisted by staff| TABLET[Staff-Assisted Tablet]
ACCESS -->|Mobile or web link| MOBILE[Mobile/Web Interface]

KIOSK --> LANGUAGE
TABLET --> LANGUAGE
MOBILE --> LANGUAGE

%% =====================================================
%% LANGUAGE AND ACCESSIBILITY
%% =====================================================

subgraph ACCESSIBILITY["1. Language, Accessibility and Device Setup"]

LANGUAGE[Select Preferred Language]

LANGUAGE --> LANG_OPTIONS{Supported Language}

LANG_OPTIONS -->|Hindi| HINDI[Hindi Interface and Audio]
LANG_OPTIONS -->|English| ENGLISH[English Interface and Audio]
LANG_OPTIONS -->|Regional Language| REGIONAL[Regional Language Interface]
LANG_OPTIONS -->|Not Comfortable| ASSISTED[Request Staff Assistance]

HINDI --> ACCESS_MODE
ENGLISH --> ACCESS_MODE
REGIONAL --> ACCESS_MODE
ASSISTED --> ACCESS_MODE

ACCESS_MODE{Select Interaction Mode}

ACCESS_MODE -->|Voice| VOICE_MODE[Voice-Based Interaction]
ACCESS_MODE -->|Touch| TOUCH_MODE[Touch and Icon-Based Interaction]
ACCESS_MODE -->|Voice + Touch| HYBRID_MODE[Hybrid Interaction]

VOICE_MODE --> DEVICE_CHECK
TOUCH_MODE --> DEVICE_CHECK
HYBRID_MODE --> DEVICE_CHECK

DEVICE_CHECK[Check Microphone, Speaker, Camera and Network]

DEVICE_CHECK --> DEVICE_STATUS{Device Ready?}

DEVICE_STATUS -->|Yes| IDENTIFICATION
DEVICE_STATUS -->|No| DEVICE_HELP[Show Troubleshooting or Call Staff]
DEVICE_HELP --> IDENTIFICATION

end

%% =====================================================
%% PATIENT IDENTIFICATION
%% =====================================================

subgraph REGISTRATION["2. Patient Identification and Registration"]

IDENTIFICATION[Identify Patient]

IDENTIFICATION --> ID_METHOD{Identification Method}

ID_METHOD -->|Scan ABHA QR or Card| ABHA_SCAN[Scan ABHA Identifier]
ID_METHOD -->|Enter ABHA Number| ABHA_INPUT[Enter ABHA Number]
ID_METHOD -->|Hospital ID| HOSPITAL_ID[Enter Hospital Patient ID]
ID_METHOD -->|Appointment or Token| TOKEN[Enter Appointment or Token Number]
ID_METHOD -->|New Patient| NEW_PATIENT[Create Temporary Patient Profile]

ABHA_SCAN --> PATIENT_LOOKUP
ABHA_INPUT --> PATIENT_LOOKUP
HOSPITAL_ID --> PATIENT_LOOKUP
TOKEN --> PATIENT_LOOKUP

PATIENT_LOOKUP[Search Existing Patient Profile]

PATIENT_LOOKUP --> PROFILE_FOUND{Profile Found?}

PROFILE_FOUND -->|Yes| PROFILE_CONFIRM[Confirm Patient Details]
PROFILE_FOUND -->|No| NEW_PATIENT

NEW_PATIENT --> DEMOGRAPHICS
PROFILE_CONFIRM --> DEMOGRAPHICS

DEMOGRAPHICS[Collect or Confirm Basic Demographics]

DEMOGRAPHICS --> DEMOGRAPHIC_FIELDS[
Name, Age, Gender, Contact Number,
Address, Guardian Details,
Preferred Language and Department
]

DEMOGRAPHIC_FIELDS --> REGISTRATION_COMPLETE[Create OPD Intake Session]

end

%% =====================================================
%% CONSENT
%% =====================================================

subgraph CONSENT["3. Consent, Privacy and Session Control"]

REGISTRATION_COMPLETE --> CONSENT_INTRO[Explain Data Use in Patient Language]

CONSENT_INTRO --> AUDIO_CONSENT[Play Audio Explanation]
AUDIO_CONSENT --> CONSENT_OPTIONS

CONSENT_OPTIONS{Patient Consent Options}

CONSENT_OPTIONS -->|Allow history capture| HISTORY_CONSENT[Consent for Clinical History]
CONSENT_OPTIONS -->|Allow document processing| DOCUMENT_CONSENT[Consent for Medical Documents]
CONSENT_OPTIONS -->|Allow doctor sharing| SHARING_CONSENT[Consent to Share with Treating Doctor]
CONSENT_OPTIONS -->|Allow ABDM linking| ABDM_CONSENT[Optional Consent for ABDM Linking]

HISTORY_CONSENT --> CONSENT_STATUS
DOCUMENT_CONSENT --> CONSENT_STATUS
SHARING_CONSENT --> CONSENT_STATUS
ABDM_CONSENT --> CONSENT_STATUS

CONSENT_STATUS[Store Consent Record with Time, Purpose and Version]

CONSENT_STATUS --> CONSENT_VALID{Minimum Consent Available?}

CONSENT_VALID -->|Yes| CREATE_SESSION[Create Secure Intake Session]
CONSENT_VALID -->|No| CONSENT_REJECTED[Offer Manual Registration or Exit]

CONSENT_REJECTED --> END_MANUAL([Manual History-Taking or Session Closed])

CREATE_SESSION --> SESSION_SECURITY[Generate Session ID and Access Token]

end

%% =====================================================
%% CLINICAL MODE
%% =====================================================

subgraph MODE_SELECTION["4. Clinical Department and History Mode"]

SESSION_SECURITY --> DEPARTMENT[Select Department or Consultation Type]

DEPARTMENT --> MODE{Select History Framework}

MODE -->|General Medicine| GENERAL_MODE[General Clinical History]
MODE -->|Speciality| SPECIALTY_MODE[Speciality Questionnaire]
MODE -->|AYUSH| AYUSH_MODE[AYUSH History and Dashavidha Pariksha]
MODE -->|Follow-up| FOLLOWUP_MODE[Follow-Up History]

GENERAL_MODE --> CHIEF_COMPLAINT
SPECIALTY_MODE --> CHIEF_COMPLAINT
AYUSH_MODE --> CHIEF_COMPLAINT
FOLLOWUP_MODE --> CHIEF_COMPLAINT

end

%% =====================================================
%% HISTORY TAKING
%% =====================================================

subgraph HISTORY["5. Conversational Clinical History Collection"]

CHIEF_COMPLAINT[Ask Chief Complaint]

CHIEF_COMPLAINT --> INPUT_METHOD{Patient Response Method}

INPUT_METHOD -->|Voice Response| CAPTURE_VOICE[Capture Patient Voice]
INPUT_METHOD -->|Touch Response| CAPTURE_TOUCH[Capture Touch, Icons or Options]
INPUT_METHOD -->|Unable to Respond| STAFF_INPUT[Staff-Assisted Entry]

CAPTURE_VOICE --> AUDIO_PROCESSING
CAPTURE_TOUCH --> ANSWER_NORMALIZATION
STAFF_INPUT --> ANSWER_NORMALIZATION

AUDIO_PROCESSING[Noise Reduction and Voice Preprocessing]
AUDIO_PROCESSING --> LANGUAGE_DETECTION[Detect Language and Speech]
LANGUAGE_DETECTION --> ASR[Indian Language Speech-to-Text]
ASR --> TRANSLATION[Normalize or Translate to Clinical Working Language]
TRANSLATION --> ANSWER_NORMALIZATION

ANSWER_NORMALIZATION[Normalize Answer into Structured Clinical Field]

ANSWER_NORMALIZATION --> COMPLAINT_CLASSIFICATION[Classify Chief Complaint]

COMPLAINT_CLASSIFICATION --> ADAPTIVE_QUESTIONS[Select Complaint-Specific Questions]

ADAPTIVE_QUESTIONS --> HPI[History of Present Illness]

HPI --> HPI_FIELDS[
Onset, Duration, Location, Character,
Severity, Progression, Aggravating Factors,
Relieving Factors and Associated Symptoms
]

HPI_FIELDS --> PAST_HISTORY[Past Medical History]

PAST_HISTORY --> PAST_HISTORY_FIELDS[
Diabetes, Hypertension, Asthma,
Heart Disease, Kidney Disease,
TB, Previous Admissions and Other Conditions
]

PAST_HISTORY_FIELDS --> SURGICAL_HISTORY[Past Surgical and Procedure History]

SURGICAL_HISTORY --> MEDICATION_HISTORY[Current and Previous Medication History]

MEDICATION_HISTORY --> ALLERGY_HISTORY[Drug, Food and Environmental Allergy History]

ALLERGY_HISTORY --> FAMILY_HISTORY[Family History]

FAMILY_HISTORY --> PERSONAL_HISTORY[Personal and Social History]

PERSONAL_HISTORY --> PERSONAL_FIELDS[
Diet, Sleep, Bowel and Bladder Habits,
Occupation, Tobacco, Alcohol,
Physical Activity and Living Conditions
]

PERSONAL_FIELDS --> ROS[Review of Systems]

ROS --> ROS_FIELDS[
General, Respiratory, Cardiovascular,
Gastrointestinal, Neurological,
Musculoskeletal, Genitourinary,
Skin and Mental Health Symptoms
]

ROS_FIELDS --> AYUSH_CHECK{Is AYUSH Mode Enabled?}

AYUSH_CHECK -->|No| COMPLETENESS_CHECK
AYUSH_CHECK -->|Yes| AYUSH_HISTORY

AYUSH_HISTORY[Capture AYUSH and Dashavidha Pariksha Parameters]

AYUSH_HISTORY --> AYUSH_FIELDS[
Prakriti, Vikriti, Sara, Samhanana,
Pramana, Satmya, Sattva,
Ahara Shakti, Vyayama Shakti, Vaya,
Agni, Koshtha, Ahara, Vihara,
Nidana and Samprapti
]

AYUSH_FIELDS --> COMPLETENESS_CHECK

COMPLETENESS_CHECK[Check Required Fields and Interview Completeness]

COMPLETENESS_CHECK --> INCOMPLETE{Important Information Missing?}

INCOMPLETE -->|Yes| FOLLOWUP[Ask Missing or Clarifying Questions]
FOLLOWUP --> INPUT_METHOD

INCOMPLETE -->|No| PATIENT_REVIEW

end

%% =====================================================
%% SAFETY AND RED FLAGS
%% =====================================================

subgraph SAFETY["6. Red-Flag and Safety Screening"]

HPI --> RED_FLAG_ENGINE
ROS --> RED_FLAG_ENGINE
MEDICATION_HISTORY --> RED_FLAG_ENGINE
AYUSH_HISTORY --> RED_FLAG_ENGINE

RED_FLAG_ENGINE[Rule-Based Red-Flag Detection]

RED_FLAG_ENGINE --> RED_FLAG_STATUS{Potential Emergency Pattern?}

RED_FLAG_STATUS -->|Yes| EMERGENCY_ALERT[Create Priority Triage Alert]
RED_FLAG_STATUS -->|No| CONTINUE_ROUTINE[Continue Normal Intake]

EMERGENCY_ALERT --> URGENT_MESSAGE[Show and Play Urgent Patient Message]
URGENT_MESSAGE --> TRIAGE_NOTIFY[Notify Triage Staff]
TRIAGE_NOTIFY --> TRIAGE_DASHBOARD[Triage Dashboard]
TRIAGE_DASHBOARD --> TRIAGE_ACTION{Triage Decision}

TRIAGE_ACTION -->|Immediate Assessment| PRIORITY_QUEUE[Move Patient to Priority Queue]
TRIAGE_ACTION -->|Needs Staff Review| STAFF_REVIEW[Staff Reviews Alert]
TRIAGE_ACTION -->|False or Non-Urgent| NORMAL_QUEUE[Continue Normal Queue]

CONTINUE_ROUTINE --> PATIENT_REVIEW
PRIORITY_QUEUE --> PATIENT_REVIEW
STAFF_REVIEW --> PATIENT_REVIEW
NORMAL_QUEUE --> PATIENT_REVIEW

end

%% =====================================================
%% PATIENT VERIFICATION
%% =====================================================

subgraph VERIFICATION["7. Patient Review and Verification"]

PATIENT_REVIEW[Read Back Important Answers]

PATIENT_REVIEW --> OUTPUT_METHOD{Patient Review Method}

OUTPUT_METHOD -->|Text| TEXT_REVIEW[Display Simple Text]
OUTPUT_METHOD -->|Audio| AUDIO_REVIEW[Play Local-Language Audio]
OUTPUT_METHOD -->|Staff Assistance| STAFF_REVIEW_INPUT[Staff Helps Review]

TEXT_REVIEW --> ANSWERS_CORRECT
AUDIO_REVIEW --> ANSWERS_CORRECT
STAFF_REVIEW_INPUT --> ANSWERS_CORRECT

ANSWERS_CORRECT{Are Answers Correct?}

ANSWERS_CORRECT -->|No| CORRECTION[Correct, Repeat or Remove Answer]
CORRECTION --> PATIENT_REVIEW

ANSWERS_CORRECT -->|Yes| SAVE_HISTORY[Save Patient-Verified History]

SAVE_HISTORY --> HISTORY_STATUS[Label Data as Patient-Reported and Patient-Verified]

end

%% =====================================================
%% DOCUMENT DIGITIZATION
%% =====================================================

subgraph DOCUMENTS["8. Medical Document Digitization"]

HISTORY_STATUS --> DOCUMENT_DECISION{Does Patient Have Previous Documents?}

DOCUMENT_DECISION -->|Yes| DOCUMENT_CAPTURE[Capture or Upload Medical Document]
DOCUMENT_DECISION -->|No| DOCUMENT_SKIP[Skip Document Collection]

DOCUMENT_CAPTURE --> IMAGE_QUALITY[Check Image Quality]

IMAGE_QUALITY --> QUALITY_STATUS{Image Clear and Complete?}

QUALITY_STATUS -->|No| RECAPTURE[Ask Patient to Recapture Document]
RECAPTURE --> DOCUMENT_CAPTURE

QUALITY_STATUS -->|Yes| DOCUMENT_STORAGE[Securely Store Temporary Document]

DOCUMENT_STORAGE --> DOCUMENT_TYPE[Classify Document Type]

DOCUMENT_TYPE --> TYPE_OPTIONS[
Prescription, Laboratory Report,
Discharge Summary, Imaging Report,
Referral Note, Surgery Record or Other
]

TYPE_OPTIONS --> IMAGE_PREPROCESSING[Crop, Rotate, Denoise and Enhance Image]

IMAGE_PREPROCESSING --> OCR[Printed and Handwritten OCR]

OCR --> OCR_LANGUAGE[Detect Script and Document Language]

OCR_LANGUAGE --> OCR_EXTRACTION[Extract Text and Document Layout]

OCR_EXTRACTION --> MEDICAL_NLP[Extract Medical Entities]

MEDICAL_NLP --> ENTITY_TYPES[
Diagnosis, Medication, Dosage,
Frequency, Duration, Allergy,
Investigation, Result, Unit,
Reference Range, Procedure and Date
]

ENTITY_TYPES --> CONFIDENCE[Calculate Extraction Confidence]

CONFIDENCE --> LOW_CONFIDENCE{Low-Confidence Information?}

LOW_CONFIDENCE -->|Yes| MANUAL_CONFIRM[Ask Patient or Staff to Confirm]
LOW_CONFIDENCE -->|No| DOCUMENT_VERIFICATION

MANUAL_CONFIRM --> DOCUMENT_VERIFICATION[Mark Source and Verification Status]

DOCUMENT_VERIFICATION --> MORE_DOCUMENTS{Add Another Document?}

MORE_DOCUMENTS -->|Yes| DOCUMENT_CAPTURE
MORE_DOCUMENTS -->|No| TIMELINE_ENGINE[Create Medical Timeline]

DOCUMENT_SKIP --> TIMELINE_ENGINE

end

%% =====================================================
%% TIMELINE AND SUMMARY
%% =====================================================

subgraph SUMMARY["9. Timeline and Clinical Summary Generation"]

TIMELINE_ENGINE[Organize Records Chronologically]

TIMELINE_ENGINE --> DATE_EXTRACTION[Extract or Ask for Document Dates]
DATE_EXTRACTION --> EVENT_SORTING[Sort Medical Events by Date]

EVENT_SORTING --> TIMELINE[
Medical Events Timeline:
Illnesses, Admissions, Surgeries,
Investigations, Medication Changes and Follow-Ups
]

TIMELINE --> SUMMARY_ENGINE
HISTORY_STATUS --> SUMMARY_ENGINE
DOCUMENT_VERIFICATION --> SUMMARY_ENGINE

SUMMARY_ENGINE[Controlled Clinical Summary Generator]

SUMMARY_ENGINE --> SUMMARY_FORMAT[
Chief Complaint,
History of Present Illness,
Past Medical History,
Past Surgical History,
Drug and Allergy History,
Family History,
Personal History,
Review of Systems,
AYUSH Findings,
Prior Investigations,
Current Medicines,
Red-Flag Alerts and Unverified Fields
]

SUMMARY_FORMAT --> SUMMARY_CHECK[Check Completeness, Contradictions and Confidence]

SUMMARY_CHECK --> CONTRADICTION{Contradictory Information?}

CONTRADICTION -->|Yes| FLAG_CONTRADICTION[Flag for Doctor Review]
CONTRADICTION -->|No| BILINGUAL_OUTPUT

FLAG_CONTRADICTION --> BILINGUAL_OUTPUT

BILINGUAL_OUTPUT[Generate Patient Language and Physician Language Views]

end

%% =====================================================
%% DOCTOR DASHBOARD
%% =====================================================

subgraph DOCTOR["10. Doctor and Clinical Staff Dashboard"]

BILINGUAL_OUTPUT --> DOCTOR_QUEUE[Add Patient to Doctor Queue]

DOCTOR_QUEUE --> DOCTOR_LOGIN[Doctor or Authorized Staff Login]

DOCTOR_LOGIN --> ACCESS_CONTROL[Check Role, Department and Consent]

ACCESS_CONTROL --> ACCESS_VALID{Authorized Access?}

ACCESS_VALID -->|No| ACCESS_DENIED[Block Access and Record Attempt]
ACCESS_VALID -->|Yes| DOCTOR_VIEW[Open Patient Clinical Summary]

DOCTOR_VIEW --> RED_FLAG_VIEW[View Red-Flag and Triage Status]
DOCTOR_VIEW --> HISTORY_VIEW[View Structured Patient History]
DOCTOR_VIEW --> DOCUMENT_VIEW[View Original Documents and OCR Text]
DOCTOR_VIEW --> TIMELINE_VIEW[View Chronological Medical Timeline]
DOCTOR_VIEW --> SOURCE_VIEW[View Source and Confidence of Each Field]

RED_FLAG_VIEW --> DOCTOR_ACTION
HISTORY_VIEW --> DOCTOR_ACTION
DOCUMENT_VIEW --> DOCTOR_ACTION
TIMELINE_VIEW --> DOCTOR_ACTION
SOURCE_VIEW --> DOCTOR_ACTION

DOCTOR_ACTION{Doctor Action}

DOCTOR_ACTION -->|Edit| EDIT_SUMMARY[Edit Incorrect or Missing Information]
DOCTOR_ACTION -->|Verify| VERIFY_SUMMARY[Mark Information as Clinically Verified]
DOCTOR_ACTION -->|Reject| REJECT_DATA[Reject Incorrect AI or OCR Field]
DOCTOR_ACTION -->|Add Note| CLINICAL_NOTE[Add Doctor's Clinical Note]
DOCTOR_ACTION -->|Request More History| MORE_HISTORY[Send Patient for Additional Questions]
DOCTOR_ACTION -->|Save| FINALIZE[Finalize Clinical Intake]

MORE_HISTORY --> PATIENT_REVIEW
EDIT_SUMMARY --> FINAL_REVIEW[Final Doctor Review]
VERIFY_SUMMARY --> FINAL_REVIEW
REJECT_DATA --> FINAL_REVIEW
CLINICAL_NOTE --> FINAL_REVIEW
FINAL_REVIEW --> FINALIZE

end

%% =====================================================
%% INTEGRATION
%% =====================================================

subgraph INTEGRATION["11. HIS, EMR, FHIR and ABDM Integration"]

FINALIZE --> FINAL_STATUS{Doctor Approved?}

FINAL_STATUS -->|No| DRAFT_STATUS[Keep as Draft]
FINAL_STATUS -->|Yes| APPROVED_RECORD[Create Approved Clinical Record]

APPROVED_RECORD --> HIS_ADAPTER[Hospital HIS or EMR Adapter]

HIS_ADAPTER --> HIS_UPDATE[Update Patient Encounter and OPD Record]

APPROVED_RECORD --> FHIR_MAPPING[Map Data to FHIR Resources]

FHIR_MAPPING --> FHIR_RESOURCES[
Patient, Encounter,
Condition, Observation,
MedicationStatement,
AllergyIntolerance,
DocumentReference and Consent
]

FHIR_RESOURCES --> FHIR_SERVER[Secure FHIR Server]

ABDM_CONSENT --> ABDM_GATEWAY
ABDM_GATEWAY[ABDM Integration Gateway]

ABDM_GATEWAY --> ABDM_STATUS{ABDM Sharing Consent Granted?}

ABDM_STATUS -->|Yes| ABDM_SHARE[Share Approved Data through Consent Framework]
ABDM_STATUS -->|No| NO_ABDM[Do Not Share with ABDM]

ABDM_SHARE --> ABHA_RECORD[Link to Patient ABHA Record]

HIS_UPDATE --> CONSULTATION[Doctor Consultation]
ABHA_RECORD --> CONSULTATION
NO_ABDM --> CONSULTATION

end

%% =====================================================
%% PHARMACY AND FOLLOW-UP EXTENSIONS
%% =====================================================

subgraph OPTIONAL["12. Optional Future Extensions"]

CONSULTATION --> PRESCRIPTION{Doctor Prescribes Medicine?}

PRESCRIPTION -->|Yes| E_PRESCRIPTION[Create Digital Prescription]
PRESCRIPTION -->|No| FOLLOWUP_PLAN

E_PRESCRIPTION --> PHARMACY_INTEGRATION[Optional Pharmacy Integration]
PHARMACY_INTEGRATION --> PHARMACY_OPTIONS[
Hospital Pharmacy,
Verified Medical Store,
Government Pharmacy or
Authorized Delivery Partner
]

PHARMACY_OPTIONS --> PATIENT_CHOICE[Patient Chooses Purchase Method]
PATIENT_CHOICE --> MEDICINE_DISPENSING[Medicine Dispensed or Ordered]

CONSULTATION --> FOLLOWUP_PLAN[Doctor Creates Follow-Up Plan]

FOLLOWUP_PLAN --> REMINDER[Set Follow-Up Reminder]
REMINDER --> REFERRAL{Referral Required?}

REFERRAL -->|Yes| REFERRAL_SERVICE[Create Referral to Doctor or Organization]
REFERRAL -->|No| FOLLOWUP_RECORD[Save Follow-Up Record]

REFERRAL_SERVICE --> FOLLOWUP_RECORD
MEDICINE_DISPENSING --> FOLLOWUP_RECORD

end

%% =====================================================
%% PATIENT PORTAL
%% =====================================================

subgraph PATIENT_PORTAL["13. Patient Record Access and Control"]

APPROVED_RECORD --> PATIENT_ACCESS[Patient Accesses Own Record]

PATIENT_ACCESS --> PATIENT_OPTIONS{Patient Action}

PATIENT_OPTIONS -->|View History| VIEW_HISTORY[View Date-Wise Medical History]
PATIENT_OPTIONS -->|View Documents| VIEW_DOCUMENTS[View Uploaded and Verified Documents]
PATIENT_OPTIONS -->|Manage Consent| MANAGE_CONSENT[Grant or Revoke Access]
PATIENT_OPTIONS -->|View Access| ACCESS_LIST[View Organizations with Access]
PATIENT_OPTIONS -->|View Logs| ACCESS_LOGS[View Who Accessed Which Record]
PATIENT_OPTIONS -->|View Appointments| APPOINTMENT_HISTORY[View Previous Appointments]
PATIENT_OPTIONS -->|View Doctors| DOCTOR_ORG_DETAILS[View Doctor and Organization Details]

MANAGE_CONSENT --> CONSENT_UPDATE[Update Consent Status]
CONSENT_UPDATE --> CONSENT_AUDIT[Record Consent Change in Audit Log]

end

%% =====================================================
%% SECURITY, MONITORING AND DATA LIFECYCLE
%% =====================================================

subgraph SECURITY["14. Security, Audit and Data Lifecycle"]

CREATE_SESSION --> ENCRYPTION[Encrypt Data in Transit and at Rest]
ENCRYPTION --> RBAC[Role-Based Access Control]

RBAC --> AUDIT_LOG[Record Every Access, Edit, Share and Export]

AUDIT_LOG --> MONITORING[System Monitoring and Security Alerts]

MONITORING --> ADMIN_DASHBOARD[Administrator Dashboard]

ADMIN_DASHBOARD --> ADMIN_METRICS[
Patient Completion Rate,
Average Intake Time,
Doctor Review Time,
OCR Correction Rate,
Red-Flag Count,
Language Usage and Kiosk Uptime
]

FINALIZE --> RETENTION_POLICY[Apply Data Retention Policy]

RETENTION_POLICY --> TEMP_DATA_DELETE[Delete Temporary Audio and Unsubmitted Files]
RETENTION_POLICY --> PERMANENT_RECORD[Retain Approved Clinical Record According to Policy]

ACCESS_DENIED --> AUDIT_LOG
CONSENT_UPDATE --> AUDIT_LOG
ABDM_SHARE --> AUDIT_LOG
HIS_UPDATE --> AUDIT_LOG

end

%% =====================================================
%% FINAL OUTCOME
%% =====================================================

CONSULTATION --> OUTCOME[Doctor Consults with Structured History Available]

OUTCOME --> END_SESSION[Close Patient Intake Session]

END_SESSION --> SESSION_CLEANUP[Clear Temporary Session Data]

SESSION_CLEANUP --> COMPLETE([MediKiosk Workflow Completed])
```

---

# Simplified Demo Flow for SIH Presentation

Use this shorter flow during your live prototype demonstration:

```mermaid
flowchart LR

A([Patient Arrives]) --> B[Select Language]
B --> C[Scan ABHA or Enter Patient ID]
C --> D[Give Consent]
D --> E[Voice and Touch History]

E --> F{Red Flag?}

F -->|Yes| G[Alert Triage Staff]
F -->|No| H[Continue Interview]

G --> H
H --> I[Scan Previous Medical Document]
I --> J[OCR and Medical Data Extraction]
J --> K[Patient Verifies Data]
K --> L[Generate Structured History Summary]
L --> M[Doctor Dashboard]
M --> N[Doctor Reviews and Edits]
N --> O[Doctor Verifies Summary]
O --> P[Push to HIS or FHIR Server]
P --> Q([Consultation Begins])
```

---

# Main Modules to Show in the Architecture

Your diagram should clearly communicate these modules:

1. Patient registration
2. Language and accessibility layer
3. Consent management
4. Voice interaction
5. Touch interaction
6. Clinical questionnaire engine
7. Adaptive question engine
8. AYUSH history mode
9. Red-flag detection
10. OCR and document processing
11. Medical entity extraction
12. Data verification
13. Medical timeline
14. Clinical summary generation
15. Doctor dashboard
16. Triage dashboard
17. HIS/EMR integration
18. FHIR integration
19. ABDM integration
20. Patient record access
21. Audit logs
22. Security and data lifecycle
23. Analytics and administration

---

# Important Corrections to the Previous Workflow

Your previous workflow contains a pharmacy delivery feature. For **SIH26047**, this should not be part of the core MVP because the problem statement primarily focuses on:

- Clinical history-taking
- Document digitization
- Structured summaries
- Red-flag detection
- Consent
- ABDM and HIS integration

You can retain medicine ordering as an **optional future extension**, but the main prototype should focus on the clinical intake workflow.

Also, avoid using wording such as:

```text
Diagnosis generated by AI
Medicine recommendation by AI
Medicine automatically ordered
```

Use safer wording:

```text
Doctor-reviewed clinical summary
AI-extracted medical information
Potential red-flag alert
Doctor-approved prescription
Optional pharmacy integration
```

The final decision should always remain with the treating healthcare professional.