# MediKiosk Engineering Commit & Architecture Report

**Commit ID / Tag**: `RELEASE-v2.1.0-VALIDATED`  
**Repository**: `MediKiosk / SIH 2026 V1`  
**Date**: 13 September 2026  
**Author**: Antigravity Full-Stack Agent  

---

## 1. Summary of Changes

### 1.1 Backend (`/backend`)
- **Dynamic JWT Authentication Middleware**: Implemented `get_current_user` in `backend/app/dependencies.py` with bearer token decoding, role extraction, and demo mode fallback for robust patient, doctor, and admin authentication.
- **Doctor and Admin Role Segregation**:
  - `RoleEnum.doctor`: Bounded to assigned patient queues, clinical pre-consultation summary review, Ashtavidha Pariksha recording, and clinical decision (Accept/Amend/Reject). Enforces DPDP consent check (`revoked_at is None`).
  - `RoleEnum.admin`: Bounded to system governance, immutable audit log monitoring (`GET /admin/audit`), DISHA/DPDP export compliance (`GET /admin/audit/export`), system-wide consent tracking (`GET /admin/consents`), and demo reset operations (`POST /admin/demo/reset`).
- **Appointment Booking & Token Lifecycle**: Corrected hospital and doctor identifier resolution in `backend/app/api/v1/appointments.py`. Ensured `POST /appointments` creates atomic consent instances and links longitudinal summaries.
- **DPDP Act 2023 Consent Revocation**: In `POST /appointments/{id}/revoke-access`, set `cons.revoked_at = datetime.datetime.utcnow()` and update `can_revoke = False` on serialized responses.
- **Appointment Cancellation**: In `POST /appointments/{id}/cancel`, transition appointment status to `cancelled` and log audit trail entry.

### 1.2 Frontend Flutter Application (`/medikiosk_app`)
- **`lib/core/services/api_client.dart`**: Added dynamic `Authorization: Bearer <token>` injection using `AuthService().getAccessToken()` on all outgoing HTTP requests.
- **`lib/data/repositories/auth_repository.dart`**: Implemented `sendOtp()`, `verifyOtp()`, `register()`, and `logout()` with token persistence via `FlutterSecureStorage`.
- **`lib/features/appointments/presentation/booking_wizard.dart`**:
  - Added configurable constructor parameters (`hospitalId`, `doctorId`, `slot`).
  - Replaced hardcoded dummy IDs with actual seeded database IDs (`hosp_aiia`, `doc_sharma`).
  - Wired live API call to `_appointmentRepo.bookAppointment(...)`.
- **`lib/features/appointments/presentation/doctor_slots_screen.dart`**: Updated navigation route to pass selected slot, doctor, and hospital query parameters to `/booking`.
- **`lib/core/routing/app_router.dart`**: Updated route handler for `/booking` to extract query parameters and instantiate `BookingWizard`.
- **`lib/features/appointments/presentation/appointments_list_screen.dart`**:
  - Added `RefreshIndicator` and live asynchronous loading of Upcoming and Past appointments.
  - Connected `_revokeConsent(appt)` and `_cancelAppointment(appt)` to backend endpoints with confirmation dialogs and optimistic UI state updates.
- **`lib/features/documents/presentation/history_screen.dart`**: Enabled live pull-to-refresh and empty state recovery.

---

## 2. File Modification Manifest

| File Path | Type | Key Modifications |
| :--- | :--- | :--- |
| `medikiosk_app/lib/features/appointments/presentation/booking_wizard.dart` | Modified | Added parameters; wired live booking to `_appointmentRepo.bookAppointment` using `hosp_aiia` and `doc_sharma`. |
| `medikiosk_app/lib/features/appointments/presentation/doctor_slots_screen.dart` | Modified | Updated navigation to pass `slot`, `hospitalId`, `doctorId` via URL query params. |
| `medikiosk_app/lib/core/routing/app_router.dart` | Modified | Extracted query parameters in `/booking` route builder. |
| `medikiosk_app/lib/data/repositories/appointment_repository.dart` | Modified | Mapped `can_revoke` to `consentRevoked` UI state; wired `cancelAppointment` and `revokeConsent`. |
| `medikiosk_app/lib/core/services/api_client.dart` | Modified | Added interceptor for dynamic Bearer token injection. |
| `medikiosk_app/lib/data/repositories/auth_repository.dart` | Modified | Implemented full OTP, registration, and logout token lifecycle. |
| `reports/test_report.md` | Created | Comprehensive real device test cases, steps, conditions, and outcomes. |
| `reports/commit_report.md` | Created | Architecture and engineering change summary. |

---

## 3. Verification & Compliance Verification

- **Code Quality**: `flutter analyze` executed with **0 issues found**.
- **Hardware Validation**: Built APK installed and validated on **Xiaomi Redmi Note 8** (`509191a3`).
- **Regulatory Standard (DPDP Act 2023)**:
  - Section 6(1) & 6(7): Transparent consent notice and unconditional right to revoke consent at any time. Verified through dialog, audit logging, and immediate UI badge update.

