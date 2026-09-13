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

## 📱 3. End-to-End Verified Workflows & Visual Evidence

### 3.1 User Registration (5-Step Wizard)
| Step 1: Identity | Step 2: Contact & ABHA | Step 3: Emergency Contacts |
| :---: | :---: | :---: |
| ![Identity](screenshots/device_screenshot_368.png) | ![Contact](screenshots/device_screenshot_369.png) | ![Emergency](screenshots/device_screenshot_371.png) |

| Step 4: DPDP Consent | Step 5: Review & Submit | Dashboard Transition |
| :---: | :---: | :---: |
| ![Consent](screenshots/device_screenshot_372.png) | ![Review](screenshots/device_screenshot_373.png) | ![Home](screenshots/device_screenshot_374.png) |

---

### 3.2 Authentication & Dual-Mode Ping
| Login (Phone) | OTP Verification | Live Ping (Beta 115ms) |
| :---: | :---: | :---: |
| ![Login](screenshots/device_screenshot_379.png) | ![OTP](screenshots/device_screenshot_380.png) | ![Ping](screenshots/device_screenshot_386.png) |

---

### 3.3 Clinical Intake Chat: General & AYUSH
| Complaint Selector | General Intake Question | AYUSH Mode & Prakriti Chip |
| :---: | :---: | :---: |
| ![Complaint](screenshots/device_screenshot_397.png) | ![General Question](screenshots/device_screenshot_398.png) | ![AYUSH Mode](screenshots/device_screenshot_403.png) |

---

### 3.4 Appointments, DPDP Revocation & Booking
| DPDP Consent Revocation | Appointment Cancellation | Hospital Selection |
| :---: | :---: | :---: |
| ![Revoke Consent](screenshots/device_screenshot_409.png) | ![Cancel Appointment](screenshots/device_screenshot_413.png) | ![Hospitals](screenshots/device_screenshot_415.png) |

| Doctor & Slot Selection | Booking Wizard | Token Generated (A-008) |
| :---: | :---: | :---: |
| ![Slots](screenshots/device_screenshot_416.png) | ![Wizard](screenshots/device_screenshot_417.png) | ![Token](screenshots/device_screenshot_420.png) |

| Reflected in Appointments List | Digital OPD Token Slip |
| :---: | :---: |
| ![Appointments List](screenshots/device_screenshot_422.png) | ![Digital Slip](screenshots/device_screenshot_424.png) |

---

### 3.5 Medical Records, Multi-Stage OCR & Drug Safety
| Upload Screen | 4-Stage OCR Pipeline | Extracted Entities & Drug Alert |
| :---: | :---: | :---: |
| ![Upload](screenshots/device_screenshot_427.png) | ![OCR Pipeline](screenshots/device_screenshot_428.png) | ![Drug Alert](screenshots/device_screenshot_429.png) |

