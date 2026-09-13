#!/usr/bin/env python3
"""
MediKiosk Design System (MDS) v1.0 Automated Physical Device Screenshot Suite.
Interacts with the attached Android device (509191a3) via ADB, visits every screen,
captures high-resolution screenshots, and copies them to both reports/screenshots/
and Docs/screenshots/.
"""

import subprocess
import time
import os
import shutil

DEVICE = "509191a3"
REPORTS_DIR = "/home/aditya/Downloads/SIH 2026/V1/reports/screenshots"
DOCS_DIR = "/home/aditya/Downloads/SIH 2026/Docs/screenshots"
ARTIFACT_DIR = "/home/aditya/.gemini/antigravity/brain/f8952fdc-0e64-47a3-af20-092898a297b3"

os.makedirs(REPORTS_DIR, exist_ok=True)
os.makedirs(DOCS_DIR, exist_ok=True)

def adb_cmd(cmd):
    full_cmd = f"adb -s {DEVICE} {cmd}"
    res = subprocess.run(full_cmd, shell=True, capture_output=True, text=True)
    return res.stdout.strip()

def tap(x, y, delay=1.5):
    adb_cmd(f"shell input tap {x} {y}")
    time.sleep(delay)

def keyevent(key, delay=0.5):
    adb_cmd(f"shell input keyevent {key}")
    time.sleep(delay)

def text_input(text, delay=0.8):
    adb_cmd(f"shell input text '{text}'")
    time.sleep(delay)

def capture(name, description=""):
    time.sleep(1.0)
    filename = f"{name}.png"
    target_reports = os.path.join(REPORTS_DIR, filename)
    target_docs = os.path.join(DOCS_DIR, filename)
    target_artifact = os.path.join(ARTIFACT_DIR, filename)
    
    subprocess.run(f"adb -s {DEVICE} exec-out screencap -p > '{target_reports}'", shell=True)
    shutil.copyfile(target_reports, target_docs)
    shutil.copyfile(target_reports, target_artifact)
    print(f"✓ Captured: {filename} - {description}")

print("=== Starting MDS v1.0 Screenshot Capture Suite ===")

# Make sure device is awake and reversed
adb_cmd("shell input keyevent KEYCODE_WAKEUP")
adb_cmd("reverse tcp:8000 tcp:8000")

# Currently on Clinical Intake Chat screen
capture("17_chat_intake_ayush_mode", "Clinical Intake in AYUSH Dashavidha mode with Prakriti context chip")

# Switch to General Mode
tap(140, 320, 1.5)
capture("15_chat_intake_general_complaints", "Clinical Intake in General mode with Chief Complaints grid")

# Select Fever (बुखार)
tap(260, 1330, 2.0)
capture("16_chat_intake_question_fever", "Intake question 1 with diabetic context & MCQ options")

# Select Option A
tap(540, 1850, 2.0)
capture("16b_chat_intake_answered_bubble", "Intake question answered with user bubble and next AI question")

# Tap Red Flag Emergency Icon at top right
tap(920, 150, 2.0)
capture("18_emergency_red_flag_screen", "Non-dismissable Emergency screen with 108, Alert Family, First Aid")

# Go back to chat
keyevent("KEYCODE_BACK", 1.5)
# Go back to Home Dashboard
keyevent("KEYCODE_BACK", 2.0)
capture("10_home_dashboard", "Home dashboard with personalized greeting, Prakriti card, and quick tiles")

# Navigate to Profile Tab (Bottom Nav Index 4)
tap(970, 2260, 2.0)
capture("29_profile_screen", "Profile screen with MDS Prakriti Donut Chart and Environment Switcher")

# Tap 'Check Server Connection (Ping)'
tap(540, 1850, 2.5)
capture("13_server_ping_result", "Server connection ping result showing Beta local SQLite active")

# Tap 'Retake Assessment' on Profile
tap(540, 1150, 2.0)
capture("11_prakriti_intro", "Prakriti assessment introductory explanation and start CTA")

# Start Prakriti Assessment
tap(540, 2060, 2.0)
capture("12_prakriti_questions", "Prakriti assessment question with dosha MCQ cards and progress indicator")

# Answer 2 questions quickly
tap(540, 1100, 1.0)
tap(540, 1300, 1.0)
# Go back to Profile
keyevent("KEYCODE_BACK", 1.0)
keyevent("KEYCODE_BACK", 1.5)

# Navigate to Appointments Tab (Bottom Nav Index 3)
tap(760, 2260, 2.0)
capture("19_appointments_list", "Appointments list with Upcoming and Past OPD tokens")

# Tap '+ New Appointment'
tap(860, 150, 2.0)
capture("20_hospitals_discovery", "Hospital discovery screen with AIIA, AIIMS, and queue loads")

# Tap first hospital (AIIA)
tap(540, 680, 2.0)
capture("21_doctor_slots", "Doctor list and available OPD date/time slot chips")

# Select a slot and proceed
tap(540, 1400, 1.5)
tap(540, 2100, 2.0)
capture("22_booking_wizard", "Booking wizard with Urgency selection and DPDP Consent Scope")

# Confirm Booking
tap(540, 2100, 2.5)
capture("23_booking_confirmation", "Appointment confirmation with Token A-008 and QR badge")

# View Digital Slip Modal
tap(540, 1850, 2.0)
capture("24_digital_token_slip", "Digital OPD Token Slip with full patient metadata")

# Close slip modal and go to Medical Records / Documents Tab (Bottom Nav Index 2)
tap(540, 300, 1.0)
tap(540, 2260, 2.0)
capture("25_document_history", "Medical records timeline and document filter tabs")

# Tap 'Upload Record'
tap(540, 2060, 2.0)
capture("26_document_upload", "Document upload screen with source picker and document type selector")

# Tap 'Start Upload & OCR'
tap(540, 2060, 1.5)
capture("27_ocr_pipeline_progress", "Multi-stage OCR pipeline animation (Scan -> OCR -> Extraction -> Safety)")

# Wait for extraction completion
time.sleep(4.0)
capture("28_ocr_clinical_extraction", "Extracted clinical entities (Metformin, Amlodipine, Triphala) and drug interaction alert")

# Save & return to records
tap(540, 2060, 2.0)

# Navigate to Notifications Screen (from Home top right)
tap(110, 2260, 1.5) # Home
tap(920, 150, 2.0)  # Notification bell
capture("32_notifications_screen", "Notifications screen with appointment and clinical intake alerts")
keyevent("KEYCODE_BACK", 1.5)

# Logout from Profile Screen to capture Registration Flow
tap(970, 2260, 1.5)
# Scroll down on Profile
adb_cmd("shell input swipe 540 1800 540 500 300")
time.sleep(1.0)
# Tap Logout button
tap(540, 1950, 2.0)

# Now on Login Screen, tap "Register Here"
tap(540, 1280, 2.0)
capture("06_registration_step1_identity", "Registration Step 1: Identity, DOB, and Gender selection")

# Fill Step 1
tap(540, 560, 0.5)
text_input("Aditya Sharma", 0.8)
tap(540, 750, 1.0) # DOB picker
tap(800, 1500, 0.8) # Confirm DOB
tap(260, 1050, 0.8) # Male gender
tap(540, 2100, 2.0) # Next
capture("07_registration_step2_contact", "Registration Step 2: Phone, Email, and 14-digit ABHA ID")

# Fill Step 2
tap(540, 750, 0.5)
text_input("aditya@example.com", 0.8)
tap(540, 950, 0.5)
text_input("14-1234-5678-9012", 0.8)
tap(540, 2100, 2.0) # Next
capture("08_registration_step3_emergency", "Registration Step 3: Emergency Contacts and DPDP Pre-consent")

# Step 3 Next
tap(540, 2100, 2.0)
capture("09_registration_step4_consent", "Registration Step 4: Audio-guided DPDP consent toggles")

# Accept consent and Next
tap(540, 1950, 1.0)
tap(540, 2100, 2.0)
capture("10_registration_step5_review", "Registration Step 5: Final review and registration submit")

print("=== Screenshot Capture Suite Completed Successfully! ===")

