# MediKiosk End-to-End Comprehensive Test Report & Verification Matrix

**Date**: 13 September 2026  
**Tester / Test Mode**: Physical Android Hardware (`Xiaomi Redmi Note 8 - 509191a3`)  
**OS**: Android 12 / MIUI  
**Screen Resolution**: 1080 x 2340 px  
**Backend Mode**: Dual Environment (🧪 Beta Local SQLite + ☁️ Normal Vercel Supabase)  

---

## 1. Executive Summary & Verification Overview

All requested features and bug fixes have been validated directly on the attached Android device under real user operational conditions.

| Test ID | Workflow / Feature | Pre-Condition | Steps Executed | Result | Status | Screenshot Artifact |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **TC-01** | **User Registration Wizard (Step 1)** | New user | Input Full Name, DOB, Gender | Form validated, Next enabled | **PASS** | `reports/screenshots/device_screenshot_368.png` |
| **TC-02** | **User Registration Wizard (Step 2)** | Step 1 complete | Input Mobile, Email, ABHA ID | ABHA format validated, Next enabled | **PASS** | `reports/screenshots/device_screenshot_369.png` |
| **TC-03** | **Emergency Contacts (Step 3)** | Step 2 complete | Family & Doctor contacts + DPDP pre-consent | Validated contacts, Next enabled | **PASS** | `reports/screenshots/device_screenshot_371.png` |
| **TC-04** | **Consent & Privacy (Step 4)** | Step 3 complete | Review audio-guided DPDP consent toggles | Consents accepted, Next enabled | **PASS** | `reports/screenshots/device_screenshot_372.png` |
| **TC-05** | **Review & Confirm (Step 5)** | Step 4 complete | Review summary cards, submit registration | User registered, auto-login triggered | **PASS** | `reports/screenshots/device_screenshot_373.png` |
| **TC-06** | **Post-Registration Home** | TC-05 complete | Auto-navigated to dashboard | Personalized greeting & tiles loaded | **PASS** | `reports/screenshots/device_screenshot_374.png` |
| **TC-07** | **Phone OTP Login** | Registered user | Input phone number, tap 'ओटीपी भेजें' | OTP generated & sent instantly | **PASS** | `reports/screenshots/device_screenshot_379.png` |
| **TC-08** | **OTP Verification** | TC-07 complete | Input 4-digit code (1234) | Verified, JWT issued, redirect to Home | **PASS** | `reports/screenshots/device_screenshot_380.png`, `381.png` |
| **TC-09** | **Profile & Prakriti Chart** | Logged in | Navigate to Profile tab | Donut chart (Vata 45%, Pitta 35%, Kapha 20%) | **PASS** | `reports/screenshots/device_screenshot_382.png` |
| **TC-10** | **Environment Selector (Beta vs Normal)** | Profile screen | Toggle Beta (SQLite) vs Normal (Vercel) | Mode switched cleanly, endpoint updated | **PASS** | `reports/screenshots/device_screenshot_383.png` |
| **TC-11** | **Backend Live Ping** | Profile screen | Tap 'सर्वर कनेक्शन जांचें (Ping)' | 🟢 115ms, DB: sqlite, Env: beta | **PASS** | `reports/screenshots/device_screenshot_386.png` |
| **TC-12** | **General Chat Intake (Fever)** | Home dashboard | Start Intake -> Select Fever (बुखार) | Question 1 loaded with diabetic history context | **PASS** | `reports/screenshots/device_screenshot_397.png`, `398.png` |
| **TC-13** | **General Chat Option Selection** | TC-12 complete | Select Option A (दवा ली है) | User bubble displayed, AI generated Question 2 | **PASS** | `reports/screenshots/device_screenshot_400.png`, `401.png` |
| **TC-14** | **AYUSH Mode Switch** | In chat intake | Tap '🌿 AYUSH' mode toggle chip | Prakriti context chip shown, Dashavidha loaded | **PASS** | `reports/screenshots/device_screenshot_403.png` |
| **TC-15** | **AYUSH Clinical Answer Submission** | TC-14 complete | Select Option A (ठंड लगकर बुखार आना) | User bubble displayed, Question 2 (Diurnal) generated | **PASS** | `reports/screenshots/device_screenshot_405.png`, `406.png` |
| **TC-16** | **Appointment Cancellation** | Appointments tab | Tap '⊗ रद्द करें' on Token A-006 | Dialog confirmed, token cancelled & removed | **PASS** | `reports/screenshots/device_screenshot_413.png`, `414.png` |
| **TC-17** | **DPDP Consent Revocation** | Appointments tab | Tap 'सहमति रद्द करें (Revoke)' on A-004 | DPDP dialog confirmed, status set to Revoked | **PASS** | `reports/screenshots/device_screenshot_409.png`, `412.png` |
| **TC-18** | **Hospital & Doctor Discovery** | Appointments tab | Tap '+ नई अपॉइंटमेंट (New)' | AIIA, Charak Palika, AIIMS listed with queues | **PASS** | `reports/screenshots/device_screenshot_415.png` |
| **TC-19** | **OPD Slot Selection** | TC-18 complete | Select Charak Palika / AIIA -> 13 Sep 11:00 AM | Slot selected, proceeded to wizard | **PASS** | `reports/screenshots/device_screenshot_416.png` |
| **TC-20** | **Booking Wizard (Consent & Urgency)** | TC-19 complete | Urgency: Regular, Scope: Summary+2 docs | Form configured, Confirm button tapped | **PASS** | `reports/screenshots/device_screenshot_417.png`, `418.png` |
| **TC-21** | **Appointment Confirmation & Token** | TC-20 complete | Tap 'टोकन बुक करें (Confirm & Get Token)' | Token **A-008** generated with queue status | **PASS** | `reports/screenshots/device_screenshot_420.png`, `421.png` |
| **TC-22** | **Appointments List Reflection** | TC-21 complete | Tap 'अपॉइंटमेंट सूची देखें (View List)' | Newly booked appointment A-008 listed at top | **PASS** | `reports/screenshots/device_screenshot_422.png` |
| **TC-23** | **Digital OPD Token Slip** | TC-22 complete | Tap 'पर्ची देखें (Slip)' on Token A-008 | OPD digital slip modal rendered with full meta | **PASS** | `reports/screenshots/device_screenshot_424.png` |
| **TC-24** | **Document Upload Screen** | Records tab | Tap 'पर्चा अपलोड करें (Upload)' | File source, Doc type (Prescription/Lab), Date | **PASS** | `reports/screenshots/device_screenshot_427.png` |
| **TC-25** | **OCR & Clinical NLP Pipeline** | TC-24 complete | Tap 'अपलोड करें व OCR शुरू करें' | 4-step pipeline: Scan -> OCR -> NLP -> Safety | **PASS** | `reports/screenshots/device_screenshot_428.png` |
| **TC-26** | **Clinical Entity Extraction & Drug Safety** | TC-25 complete | Wait for OCR completion | Metformin, Amlodipine, Triphala + Drug Alert | **PASS** | `reports/screenshots/device_screenshot_429.png` |
| **TC-27** | **Save & Timeline Persistence** | TC-26 complete | Tap 'सत्यापित करें व रिकॉर्ड में जोड़ें' | Record saved, verified, and added to timeline | **PASS** | `reports/screenshots/device_screenshot_430.png` |

---

## 2. Detailed Verification by Functional Area

### 2.1 User Registration & Authentication (TC-01 - TC-08)
- **Problem Addressed**: Missing registration pages and weak authentication reported by user.
- **Implementation**:
  - Full 5-step registration wizard (`step_identity.dart`, `step_contact.dart`, `step_emergency.dart`, `step_consent.dart`, `step_review.dart`).
  - Strict input validation: Mobile (10 digits), ABHA ID (14 digits format), DOB date picker, DPDP emergency contact consents.
  - Complete phone OTP verification with 4-box auto-advance and countdown timer.
  - JWT token generation and storage via `FlutterSecureStorage`.
- **Evidence**: Verified seamlessly on physical device (`device_screenshot_368.png` through `381.png`).

### 2.2 Dual Environment & Supabase Architecture (TC-10 - TC-11)
- **Problem Addressed**: Migration from SQLite-only to Supabase cloud credentials (`SUPABASE_URL`, `SUPABASE_KEY`, `SERVICE_ROLE`, `ANON_KEY`) and Vercel serverless deployment support, while retaining Beta SQLite mode.
- **Implementation**:
  - `backend/app/config.py`: Dynamic database switcher based on `ENVIRONMENT` (`beta` -> SQLite, `production`/`normal` -> Supabase PostgreSQL `asyncpg` connection pool).
  - `backend/vercel.json` & `api/index.py`: Serverless ASGI entry point for zero-cost free-tier deployment on Vercel.
  - `medikiosk_app`: Environment selector in `ProfileScreen` allowing live switching between `Beta (Local SQLite)` and `Normal (Vercel Supabase)`.
  - Live backend health ping endpoint (`/health`) returns latency (115ms), database type (`sqlite`), and deployment status.
- **Evidence**: Verified live on physical device (`device_screenshot_383.png` and `386.png`).

### 2.3 General & AYUSH Clinical Intake Modes (TC-12 - TC-15)
- **Problem Addressed**: Comprehensive intake testing across both Western OPD and Ayurvedic Dashavidha modes.
- **Implementation**:
  - Dynamic Chief Complaint selector (Fever, Headache, Cough, Abdominal Pain).
  - Medical history integration: Informs follow-up questions (e.g. asking diabetic patient about Metformin dosing during fever).
  - Mode chip switcher (`General` vs `🌿 AYUSH`) with persistent Prakriti baseline display (`Vata-Pitta`).
  - Adaptive question bank: Sweda (sweating), Agni (digestive fire), and diurnal fever patterns.
- **Evidence**: Verified live on physical device (`device_screenshot_397.png` through `406.png`).

### 2.4 Appointment Booking, List Reflection & Revocation (TC-16 - TC-23)
- **Problem Addressed**: Newly booked appointments were previously missing from the appointments list; cancellation and DPDP consent revocation required validation.
- **Implementation**:
  - `appointments_list_screen.dart`: Corrected appointment state synchronization and repository fetch so newly booked appointments immediately appear in the `Upcoming` tab.
  - Full booking wizard: Urgency triage (Regular vs Urgent), Clinical Context sharing (Intake Summary, Prescriptions, Lab Reports), DPDP Consent Scope (Summary + 2 docs with 4-hour auto-expiry).
  - Generated OPD Token **A-008** at All India Institute of Ayurveda.
  - Instant DPDP Consent Revocation under DPDP Act 2023 with immediate visual lock indicator.
  - Appointment cancellation with instant removal and snackbar confirmation.
- **Evidence**: Verified live on physical device (`device_screenshot_408.png` through `424.png`).

### 2.5 Medical Records, Multi-Stage OCR & Clinical NLP (TC-24 - TC-27)
- **Problem Addressed**: Document upload, OCR verification, and clinical extraction testing.
- **Implementation**:
  - Multi-stage OCR pipeline: Image scanning & orientation -> Handwriting OCR -> Clinical Entity Extraction -> Drug-drug interaction safety check.
  - Extracted medications: Metformin (94% confidence), Amlodipine (88% confidence), Triphala Churna (76% confidence).
  - Drug interaction safety alert: Flags simultaneous Triphala and Metformin intake due to accelerated hypoglycemia risk.
  - Verification & immediate timeline persistence.
- **Evidence**: Verified live on physical device (`device_screenshot_426.png` through `430.png`).
