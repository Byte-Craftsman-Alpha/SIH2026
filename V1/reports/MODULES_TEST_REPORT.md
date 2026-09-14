# MediKiosk - Module Testing Report

## Overview
This report details the on-device testing (via ADB) of the newly integrated modules in the MediKiosk application:
1. **Bhashini ASR (IN-1)**
2. **ABDM Sandbox (ABHA V3) (IN-2)**
3. **HIS Push (IN-3)**

**Test Environment:**
- **Device:** Android Hardware Device (connected via ADB `509191a3`)
- **Backend:** Local network staging environment `10.139.158.195:8000`
- **Application:** MediKiosk App (`V1/medikiosk_app`)

---

## 1. Bhashini ASR Integration (IN-1)
**Objective:** Verify that voice recording captures 16kHz audio, streams to the backend, and returns Bhashini-translated text when online.
**Test Steps:**
1. Navigated to the Intake Chat Screen.
2. Tapped the microphone icon.
3. Observed the `VoiceOverlay` display "Bhashini (Govt ASR)" indicator.
4. Spoke Hindi text: "मुझे कल रात से बुखार है".
5. Verified the transcript appeared in the chat text box accurately.
**Result:** **PASS**
**Evidence:** The backend received the `multipart/form-data` audio file successfully, passed it to ULCA auth and Dhruva inference pipelines, returning the correct Hindi translation. 

## 2. ABDM Sandbox - ABHA Login (IN-2)
**Objective:** Verify that users can request an OTP via ABHA mobile number and that the app auto-routes to registration with prefilled profile details on successful verification.
**Test Steps:**
1. Opened the app and navigated to `LoginScreen`.
2. Verified the presence of the new **"ABHA से लॉगिन करें (Govt. Verified)"** card.
3. Entered an ABHA-linked phone number (`9876543210`) and tapped "ABHA OTP".
4. Confirmed redirection to the `OtpScreen` with the `abhaTxnId` successfully extracted from query parameters.
5. Entered the mock OTP (`1234`).
6. Verified success snackbar and automatic redirection to the `/register` screen.
**Result:** **PASS**
**Evidence:** The backend correctly mapped to `/abdm/abha/otp/send` and `/verify`. The `OtpScreen` correctly branched into the `verifyAbhaOtp` repository logic instead of standard auth. 

## 3. HIS Push & Appointment Status Notifications (IN-3)
**Objective:** Verify that booking an appointment triggers an offline/mock HIS push, and cancelling/rescheduling notifies the HIS without failing the API request on timeout.
**Test Steps:**
1. Completed a mock patient intake summary.
2. Booked an appointment; observed the API response time did not degrade.
3. Examined backend Audit Logs for `ABDM_FHIR_BUNDLE_DISPATCH`.
4. Rescheduled and cancelled the appointment from the patient dashboard.
5. Verified the backend handled `requests.exceptions.Timeout` correctly when the HIS Push server was mock-delayed.
**Result:** **PASS**
**Evidence:** The `fhir.py` and `appointments.py` helper `notify_his_status_change` fired and properly suppressed connection exceptions, preventing any UI blocking or crashes on the kiosk.

---

## Conclusion
All three Government integrations (IN-1, IN-2, IN-3) have been tested directly on-device over the local network backend. Offline/Timeout fallback measures function correctly without causing user-facing disruptions. The source codebase has been correctly updated to route through `AbdmService` and `BhashiniService` proxies.

