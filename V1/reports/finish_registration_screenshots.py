#!/usr/bin/env python3
import subprocess
import time
import os
import shutil

DEVICE = "509191a3"
REPORTS_DIR = "/home/aditya/Downloads/SIH 2026/V1/reports/screenshots"
DOCS_DIR = "/home/aditya/Downloads/SIH 2026/Docs/screenshots"
ARTIFACT_DIR = "/home/aditya/.gemini/antigravity/brain/f8952fdc-0e64-47a3-af20-092898a297b3"

def adb(cmd):
    return subprocess.run(f"adb -s {DEVICE} {cmd}", shell=True, capture_output=True, text=True).stdout.strip()

def tap(x, y, delay=1.5):
    adb(f"shell input tap {x} {y}")
    time.sleep(delay)

def capture(name, desc=""):
    time.sleep(1.0)
    filename = f"{name}.png"
    p1 = os.path.join(REPORTS_DIR, filename)
    p2 = os.path.join(DOCS_DIR, filename)
    p3 = os.path.join(ARTIFACT_DIR, filename)
    subprocess.run(f"adb -s {DEVICE} exec-out screencap -p > '{p1}'", shell=True)
    shutil.copyfile(p1, p2)
    shutil.copyfile(p1, p3)
    print(f"✓ Saved: {filename} ({desc})")

# 1. On Language Screen
capture("02_language_selection", "Language selection screen")

# 2. Tap English to go to Kiosk Welcome Screen
tap(540, 1360, 2.0)
capture("03_kiosk_welcome", "Kiosk Welcome screen with New and Returning patient actions")

# 3. Tap "New Patient" to go to Registration Wizard
tap(270, 1200, 2.0)
capture("06_registration_step1_identity", "Registration Step 1: Personal Identity & DOB")

# Fill Step 1
tap(540, 560, 0.5)
adb("shell input text 'Aditya Sharma'")
time.sleep(0.5)
# Tap Next
tap(540, 2100, 2.0)
capture("07_registration_step2_contact", "Registration Step 2: Mobile & ABHA ID")

# Fill Step 2
tap(540, 2100, 2.0)
capture("08_registration_step3_emergency", "Registration Step 3: Emergency Contacts & Pre-consent")

# Next to Step 4
tap(540, 2100, 2.0)
capture("09_registration_step4_consent", "Registration Step 4: Audio-guided DPDP Consent toggles")

# Next to Step 5
tap(540, 2100, 2.0)
capture("10_registration_step5_review", "Registration Step 5: Summary review cards & submit")

# Submit Registration
tap(540, 2100, 2.5)
capture("11_home_post_registration", "Home dashboard after registration")

print("Finished capturing remaining registration screens!")

