# MediKiosk Deployment, Configuration & Release Guide

---

## 🎯 KEY ACTION ITEM: Where to Replace Production Backend Server URL

> [!IMPORTANT]
> ### 🔴 THE EXACT FILE AND LINE TO REPLACE:
> **File Path**: [`V1/medikiosk_app/lib/core/constants/app_constants.dart`](file:///home/aditya/Downloads/SIH%202026/V1/medikiosk_app/lib/core/constants/app_constants.dart)  
> **Line Number**: **Line 20**
>
> ```dart
> // File: V1/medikiosk_app/lib/core/constants/app_constants.dart
> // Lines 17-21:
>
>   // Deployed Normal Backend (Vercel Serverless + Supabase cloud storage & database)
>   static const String defaultVercelUrl = String.fromEnvironment(
>     'VERCEL_URL',
> >>> defaultValue: 'https://medikiosk-backend.vercel.app/api/v1', <<< // REPLACE THIS URL
>   );
> ```
>
> Replace `'https://medikiosk-backend.vercel.app/api/v1'` with your actual deployed Vercel URL (e.g., `'https://your-medikiosk.vercel.app/api/v1'`).
>
> **Alternative (Zero Code Change via CI/CD or Build Command)**:  
> You can also supply the production URL at build time without editing the source code by passing `--dart-define`:
> ```bash
> flutter build apk --release \
>   --dart-define=APP_ENV=normal \
>   --dart-define=VERCEL_URL=https://your-medikiosk.vercel.app/api/v1
> ```
> And in GitHub Actions, simply configure the repository secret **`PRODUCTION_BACKEND_URL`**.

---

## 🏗️ Dual Environment Architecture: Beta vs Normal

| Property | 🧪 Beta Version (Testing & Demo) | ☁️ Normal / Production Version (Cloud) |
| :--- | :--- | :--- |
| **Backend Target** | Local FastAPI running on `0.0.0.0:8000` | Vercel Serverless Edge deployment |
| **App Base URL** | `http://127.0.0.1:8000/api/v1` (or `10.0.2.2:8000`) | `https://your-vercel-domain.vercel.app/api/v1` |
| **Database** | Embedded SQLite (`backend/medikiosk.db`) | Supabase PostgreSQL Cloud Database (`DATABASE_URL`) |
| **Storage Engine** | Local filesystem (`backend/uploads/`) | Supabase Cloud Storage bucket (`SUPABASE_BUCKET`) |
| **Flutter Build Flag** | `--dart-define=APP_ENV=beta` | `--dart-define=APP_ENV=normal` |
| **In-App Switching** | Available in `ProfileScreen` under Server & DB | Available in `ProfileScreen` under Server & DB |

---

## ☁️ 1. Deploying the Backend on Vercel (Free Tier)

The FastAPI backend is fully optimized for Vercel's serverless runtime using `vercel.json` and ASGI handler `api/index.py`.

### Step 1: Install Vercel CLI (or connect GitHub repository)
```bash
npm install -g vercel
cd V1/backend
```

### Step 2: Configure Environment Variables on Vercel
In your Vercel Dashboard (Project Settings $\rightarrow$ Environment Variables), set:
- `ENVIRONMENT`: `normal`
- `SUPABASE_URL`: `https://your-project.supabase.co`
- `SUPABASE_KEY`: `your_supabase_anon_key`
- `SERVICE_ROLE`: `your_supabase_service_role_key`
- `ANON_KEY`: `your_supabase_anon_key`
- `SUPABASE_BUCKET`: `medical-records`
- `DATABASE_URL`: `postgresql+asyncpg://postgres:[PASSWORD]@db.[PROJECT-REF].supabase.co:5432/postgres`
- `JWT_SECRET_KEY`: `your_random_production_secret_key`

### Step 3: Deploy
```bash
vercel --prod
```
Your backend will be live at `https://[your-project-name].vercel.app`.

---

## 🚀 2. GitHub Actions CI/CD Pipeline (`.github/workflows/build-and-release.yml`)

The GitHub Actions workflow triggers on push to `main` (or when a tag `v*` is created) and performs automated building, testing, and release distribution.

### What the Workflow Builds:
1. **Android Beta APK**: `medikiosk-beta.apk` (pre-configured for local SQLite testing)
2. **Android Production APK**: `medikiosk-production.apk` (connected to Vercel/Supabase)
3. **Android Production AAB**: `medikiosk-production.aab` (ready for Google Play Store upload)
4. **iOS Beta Bundle**: `medikiosk-ios-beta.zip` (release build for TestFlight/device install)
5. **iOS Production Bundle**: `medikiosk-ios-production.zip` (production release build)
6. **Merged Release Notes**: Automatically aggregates notes from `V1/reports/COMMIT_REPORT.md` and `V1/reports/TEST_REPORT.md` into GitHub Releases.

### GitHub Secrets to Configure:
In your GitHub Repository $\rightarrow$ **Settings** $\rightarrow$ **Secrets and variables** $\rightarrow$ **Actions**:
- `PRODUCTION_BACKEND_URL`: Your Vercel backend URL (e.g. `https://your-medikiosk.vercel.app/api/v1`).

---

## 📱 3. End-to-End Verified Workflows & Visual Evidence (MDS v1.0 Physical Hardware)

All screenshots below were captured directly from the attached physical hardware (**Xiaomi Redmi Note 8 - 1080x2340 px**) running the updated build compliant with the **MediKiosk Design System (MDS) v1.0**.

### 3.1 Onboarding & Authentication Flow
| Splash Screen | Language Selection | Kiosk Welcome |
| :---: | :---: | :---: |
| ![Splash](screenshots/01_splash_screen.png) | ![Language](screenshots/02_language_selection.png) | ![Welcome](screenshots/03_kiosk_welcome.png) |

| Phone Login | OTP Verification (4-digit) | Home Dashboard |
| :---: | :---: | :---: |
| ![Login](screenshots/04_login_screen.png) | ![OTP](screenshots/05_otp_screen.png) | ![Home](screenshots/10_home_dashboard.png) |

---

### 3.2 Registration Wizard (5 Steps + Review)
| Step 1: Identity & DOB | Step 2: Contact & ABHA | Step 3: Emergency Contacts |
| :---: | :---: | :---: |
| ![Step 1](screenshots/06_registration_step1_identity.png) | ![Step 2](screenshots/07_registration_step2_contact.png) | ![Step 3](screenshots/08_registration_step3_emergency.png) |

| Step 4: Audio-Guided Consent | Step 5: Summary Review | Post-Registration Dashboard |
| :---: | :---: | :---: |
| ![Step 4](screenshots/09_registration_step4_consent.png) | ![Step 5](screenshots/10_registration_step5_review.png) | ![Post-Reg](screenshots/11_home_post_registration.png) |

---

### 3.3 Prakriti Assessment & Dual Environment Settings
| Prakriti Intro | Prakriti Assessment MCQ | Live Server Ping (Beta) |
| :---: | :---: | :---: |
| ![Intro](screenshots/11_prakriti_intro.png) | ![MCQ](screenshots/12_prakriti_questions.png) | ![Ping](screenshots/13_server_ping_result.png) |

---

### 3.4 Clinical Intake: General, AYUSH & Emergency Red Flags
| Chief Complaints Grid | General Question (Fever) | Answer Bubble & Follow-up |
| :---: | :---: | :---: |
| ![Complaints](screenshots/15_chat_intake_general_complaints.png) | ![Question](screenshots/16_chat_intake_question_fever.png) | ![Bubble](screenshots/16b_chat_intake_answered_bubble.png) |

| AYUSH Dashavidha Mode | Emergency Red Flag Triage (108) | Notifications Screen |
| :---: | :---: | :---: |
| ![AYUSH](screenshots/17_chat_intake_ayush_mode.png) | ![Emergency](screenshots/18_emergency_red_flag_screen.png) | ![Notifications](screenshots/32_notifications_screen.png) |

---

### 3.5 OPD Appointments, Discovery & Booking Wizard
| Appointments List | Hospital Discovery | Doctor OPD Slots |
| :---: | :---: | :---: |
| ![Appointments](screenshots/19_appointments_list.png) | ![Hospitals](screenshots/20_hospitals_discovery.png) | ![Slots](screenshots/21_doctor_slots.png) |

| Booking Wizard & DPDP Scope | Token Confirmation (A-008) | Digital OPD Token Slip |
| :---: | :---: | :---: |
| ![Wizard](screenshots/22_booking_wizard.png) | ![Confirm](screenshots/23_booking_confirmation.png) | ![Slip](screenshots/24_digital_token_slip.png) |

---

### 3.6 Medical Records, Multi-Stage OCR & Clinical Extraction
| Records Timeline | Document Upload | 4-Stage OCR Animation |
| :---: | :---: | :---: |
| ![History](screenshots/25_document_history.png) | ![Upload](screenshots/26_document_upload.png) | ![OCR Progress](screenshots/27_ocr_pipeline_progress.png) |

| Extracted Entities & Drug Safety | Profile & Donut Chart |
| :---: | :---: |
| ![Clinical Extraction](screenshots/28_ocr_clinical_extraction.png) | ![Profile Screen](screenshots/29_profile_screen.png) |

