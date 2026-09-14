# MediKiosk — AI-Powered Clinical History Intake & OPD Triage Platform

[![Build & Release](https://github.com/aditya/medikiosk/actions/workflows/build-and-release.yml/badge.svg)](https://github.com/aditya/medikiosk/actions/workflows/build-and-release.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform: Android & iOS](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-blue.svg)](https://flutter.dev)
[![Backend: FastAPI & Vercel](https://img.shields.io/badge/Backend-FastAPI%20%7C%20Vercel%20Serverless-green.svg)](https://fastapi.tiangolo.com)
[![Database: Supabase & SQLite](https://img.shields.io/badge/Database-Supabase%20%7C%20SQLite-3ECF8E.svg)](https://supabase.com)

> **Smart India Hackathon 2026** — Problem Statement **SIH26047**  
> **Sponsor**: Ministry of Ayush — All India Institute of Ayurveda (AIIA)  
> **Theme**: Smart Automation / Healthcare First-Mile Intake

---

## 🔴 IMPORTANT: Where to Replace Production Backend URL

> ### The exact file and line to replace in the codebase:
> **File**: [`V1/medikiosk_app/lib/core/constants/app_constants.dart`](file:///home/aditya/Downloads/SIH%202026/V1/medikiosk_app/lib/core/constants/app_constants.dart)  
> **Line Number**: **Line 20**
>
> ```dart
> // File: V1/medikiosk_app/lib/core/constants/app_constants.dart (Line 20)
> static const String defaultVercelUrl = String.fromEnvironment(
>   'VERCEL_URL',
>   defaultValue: 'https://medikiosk-backend.vercel.app/api/v1', // <<< REPLACE THIS WITH YOUR DEPLOYED BACKEND URL
> );
> ```
>
> *Alternatively*, you can provide the backend URL dynamically via build flags or GitHub Secrets (`PRODUCTION_BACKEND_URL`):
> ```bash
> flutter build apk --release --dart-define=APP_ENV=normal --dart-define=VERCEL_URL=https://your-domain.vercel.app/api/v1
> ```

---

## 🏛️ System Architecture: Dual Environment

```
                          ┌───────────────────────────────────────────────┐
                          │            MediKiosk Flutter App              │
                          │   (Patient Kiosk / Mobile Android & iOS)      │
                          └──────────────────────┬────────────────────────┘
                                                 │
                        ┌────────────────────────┴────────────────────────┐
                        │ Dynamic Environment Selector (Profile Screen)   │
                        └──────────────┬──────────────────┬───────────────┘
                                       │                  │
                [🧪 Beta Mode: Local]  │                  │  [☁️ Normal Mode: Cloud]
                                       ▼                  ▼
┌──────────────────────────────────────────────┐  ┌──────────────────────────────────────────────┐
│ Local FastAPI Backend (Port 8000)            │  │ Vercel Serverless Backend (Free Tier)        │
│ • Local SQLite DB (medikiosk.db)             │  │ • Serverless Edge ASGI Handler (api/index.py)│
│ • Local File Storage (uploads/)              │  │ • Supabase PostgreSQL Cloud Database         │
│ • Standalone Offline / Field Kiosk Mode      │  │ • Supabase Cloud Object Storage (Documents)  │
└──────────────────────────────────────────────┘  └──────────────────────────────────────────────┘
```

---

## 🚀 Key Features & Validated Workflows

1. **Patient Registration (5-Step Wizard)**:
   - Identity & Demographics with DOB picker.
   - Contact & 14-digit ABHA ID format validation.
   - Emergency contacts with DPDP pre-consent.
   - Granular audio-guided consent options.
   - Review cards with instant edit shortcuts.

2. **Phone OTP Authentication**:
   - 4-digit auto-advancing code entry.
   - JWT tokens stored in `FlutterSecureStorage`.

3. **Dual-Mode Clinical Intake**:
   - **General Mode**: Chief complaints (Fever, Cough, Pain) with adaptive follow-ups informed by patient medical history (e.g. Metformin dosing).
   - **AYUSH Mode**: Ashtavidha & Dashavidha Ayurvedic evaluation with real-time Prakriti baseline context (`Vata-Pitta`).

4. **OPD Appointments & DPDP Compliance**:
   - Nearest hospital & OPD doctor discovery with live wait times.
   - Complete booking wizard (Urgency triage, clinical context sharing, 4-hour consent window).
   - Instant OPD Token generation (`A-008`).
   - Newly booked appointments reflected immediately at the top of the list.
   - Full DPDP Act 2023 consent revocation & appointment cancellation.

5. **Medical Records & Multi-Stage OCR**:
   - 4-stage pipeline: Scanning $\rightarrow$ Handwriting OCR $\rightarrow$ Clinical NLP $\rightarrow$ Drug Safety Alert.
   - Interaction alert: Flags simultaneous Triphala Churna and Metformin intake (hypoglycemia risk).
   - Human-in-the-loop verification and immediate timeline persistence.

6. **Government Interoperability (ABDM / Bhashini)**:
   - **Bhashini ASR (IN-1)**: Multilingual Hindi speech-to-text integration with auto-fallback to device STT.
   - **ABHA V3 Login (IN-2)**: Secure Aadhaar-based OTP login with instant registration pre-fill.
   - **HIS FHIR Push (IN-3)**: Automatic HL7 FHIR R4 standard bundle dispatches to external Hospital Information Systems.
   - *For exact integration details and fallback testing, see the [Integration Test Report](V1/reports/MODULES_TEST_REPORT.md).*

---

## 📸 Real-Device Verification Screenshots

| User Registration Wizard | Environment Selector & Ping | AYUSH Clinical Intake |
| :---: | :---: | :---: |
| <img src="Docs/screenshots/device_screenshot_368.png" width="250" height="541"> | <img src="Docs/screenshots/device_screenshot_386.png" width="250" height="541"> | <img src="Docs/screenshots/device_screenshot_403.png" width="250" height="541"> |

| DPDP Consent Revoked | OPD Token Booked (A-008) | OCR & Drug Safety Alert |
| :---: | :---: | :---: |
| <img src="Docs/screenshots/device_screenshot_412.png" width="250" height="541"> | <img src="Docs/screenshots/device_screenshot_420.png" width="250" height="541"> | <img src="Docs/screenshots/device_screenshot_429.png" width="250" height="541"> |

---

## 🤖 GitHub Actions Workflow (`build-and-release.yml`)

The repository includes an automated CI/CD pipeline at [`.github/workflows/build-and-release.yml`](.github/workflows/build-and-release.yml):
- **Triggers**: On push to `main` branch or tag `v*`.
- **Merged Release Notes**: Automatically merges documentation from `V1/reports/COMMIT_REPORT.md` and `V1/reports/TEST_REPORT.md`.
- **Build Artifacts Published**:
  - `medikiosk-beta.apk` (Android Beta / Local SQLite testing)
  - `medikiosk-production.apk` (Android Production / Vercel + Supabase)
  - `medikiosk-production.aab` (Google Play Store Release)
  - `medikiosk-ios-beta.zip` (iOS Beta Runner)
  - `medikiosk-ios-production.zip` (iOS Production Runner)

---

## 🔒 Security & Credentials

- `.env` files, keystores, and credentials are strictly ignored in `.gitignore`.
- Zero credentials or database files are committed to version control.
- Configuration template provided in [`V1/backend/.env.example`](V1/backend/.env.example).

---

## 📄 Documentation Links
- **[Deployment & Release Guide](Docs/DEPLOYMENT_AND_RELEASE_GUIDE.md)**: Full Vercel, Supabase, and URL replacement instructions.
- **[Product Requirements Document (PRD)](Docs/PRD.md)**: Complete functional, technical, and regulatory requirements.
- **[Comprehensive Test Report](V1/reports/TEST_REPORT.md)**: End-to-end physical hardware test matrix.
- **[License](LICENSE)**: MIT License.
