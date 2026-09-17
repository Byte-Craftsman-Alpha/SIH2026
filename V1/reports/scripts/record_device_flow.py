#!/usr/bin/env python3
"""
ADB Automation & Hardware Screen Recording Suite for MediKiosk Patient App.
Coordinates high-bitrate screen recording directly on the physical Android hardware
(Xiaomi Redmi Note 8 - 509191a3), executing seamless taps, swipes, and screen transitions:
- Kiosk Welcome & Home Dashboard
- Clinical Intake (General complaints + AYUSH Dashavidha Mode)
- Emergency Red Flag Interruption Screen
- Prakriti Assessment & Donut Chart Results
- OPD Hospital & Doctor Slot Selection
- Booking Wizard, Token A-008 Generation & Digital Slip
- Document Upload & Multi-Stage OCR Extraction Pipeline
- Profile, DPDP Consent Management & Server Health Ping
"""

import subprocess
import time
import os
import signal

DEVICE = "509191a3"
OUTPUT_DIR = "/home/aditya/Downloads/SIH 2026/V1/reports/raw_videos"
LOCAL_VIDEO = os.path.join(OUTPUT_DIR, "device_flow.mp4")
REMOTE_VIDEO = "/sdcard/medikiosk_device_flow.mp4"

os.makedirs(OUTPUT_DIR, exist_ok=True)

def adb_cmd(cmd):
    full_cmd = f"adb -s {DEVICE} {cmd}"
    res = subprocess.run(full_cmd, shell=True, capture_output=True, text=True)
    return res.stdout.strip()

def tap(x, y, delay=1.2):
    adb_cmd(f"shell input tap {x} {y}")
    time.sleep(delay)

def swipe(x1, y1, x2, y2, duration_ms=400, delay=1.0):
    adb_cmd(f"shell input swipe {x1} {y1} {x2} {y2} {duration_ms}")
    time.sleep(delay)

def keyevent(key, delay=0.8):
    adb_cmd(f"shell input keyevent {key}")
    time.sleep(delay)

def text_input(text, delay=0.8):
    adb_cmd(f"shell input text '{text}'")
    time.sleep(delay)

def record_device_flow():
    print("=== Starting MediKiosk Hardware Screen Recording Suite ===")
    
    # 0. Prep device
    adb_cmd("shell input keyevent KEYCODE_WAKEUP")
    adb_cmd("reverse tcp:8000 tcp:8000")
    adb_cmd(f"shell rm -f {REMOTE_VIDEO}")
    
    # Start screenrecord process (up to 3 minutes, 16Mbps for pristine clarity)
    print("Launching native screenrecord daemon on Android device...")
    record_proc = subprocess.Popen(
        f"adb -s {DEVICE} shell screenrecord --size 1080x2340 --bit-rate 16000000 --time-limit 180 {REMOTE_VIDEO}",
        shell=True
    )
    time.sleep(2.0) # Let recording initialize
    
    try:
        print("[1/9] Home Dashboard & Overview...")
        # Navigate to Home tab (Bottom Nav index 0)
        tap(110, 2260, 2.0)
        swipe(540, 1600, 540, 900, 500, 1.8) # Smooth scroll down
        swipe(540, 900, 540, 1600, 500, 1.5) # Smooth scroll back up
        
        print("[2/9] Clinical Intake Flow (General & AYUSH Dashavidha Mode)...")
        # Tap Chat tab (Bottom Nav index 1)
        tap(330, 2260, 2.0)
        
        # Switch to General Mode
        tap(140, 320, 1.5)
        time.sleep(1.0)
        
        # Select Chief Complaint: Fever (बुखार)
        tap(260, 1330, 2.0)
        
        # Answer first SOCRATES question
        tap(540, 1850, 2.0)
        time.sleep(1.5)
        
        # Switch to AYUSH Dashavidha mode
        tap(380, 320, 2.0)
        time.sleep(2.0)
        
        print("[3/9] Emergency Red Flag Interruption...")
        # Tap Red Flag Emergency alert button at top right
        tap(920, 150, 2.5)
        time.sleep(2.0) # Highlight Emergency overlay
        
        # Go back to chat
        keyevent("KEYCODE_BACK", 1.2)
        
        print("[4/9] Prakriti Assessment & Donut Chart...")
        # Go to Profile tab
        tap(970, 2260, 2.0)
        
        # Tap 'Retake Assessment' on Profile
        tap(540, 1150, 2.0)
        time.sleep(1.5)
        
        # Start Prakriti Assessment
        tap(540, 2060, 2.0)
        # Answer 3 questions smoothly
        tap(540, 1100, 1.2)
        tap(540, 1300, 1.2)
        tap(540, 1500, 1.5)
        
        # Return to Profile to show Donut Chart
        keyevent("KEYCODE_BACK", 1.0)
        keyevent("KEYCODE_BACK", 1.8)
        
        print("[5/9] OPD Hospital Discovery & Doctor Slot Selection...")
        # Tap Appointments tab (Bottom Nav index 3)
        tap(760, 2260, 2.0)
        
        # Tap '+ New Appointment'
        tap(860, 150, 2.0)
        time.sleep(1.5)
        
        # Select first hospital (AIIA)
        tap(540, 680, 2.0)
        time.sleep(1.5)
        
        # Select OPD slot time chip
        tap(540, 1400, 1.5)
        # Proceed to booking wizard
        tap(540, 2100, 2.0)
        
        print("[6/9] Booking Wizard & Digital Token Slip...")
        # Confirm Booking
        tap(540, 2100, 2.5)
        time.sleep(2.0)
        
        # View Digital Token Slip modal
        tap(540, 1850, 2.5)
        time.sleep(2.5)
        # Close slip modal
        tap(540, 300, 1.5)
        
        print("[7/9] Medical Records Upload & 4-Stage OCR Pipeline...")
        # Tap Documents tab (Bottom Nav index 2)
        tap(540, 2260, 2.0)
        
        # Tap 'Upload Record'
        tap(540, 2060, 2.0)
        time.sleep(1.5)
        
        # Tap 'Start Upload & OCR'
        tap(540, 2060, 2.0)
        
        # Allow multi-stage OCR pipeline animation (Scan -> OCR -> Extraction -> Safety)
        print("Observing multi-stage OCR extraction animation...")
        time.sleep(5.0)
        
        # Clinical entity review screen with drug interaction alert
        time.sleep(3.0)
        # Save & return
        tap(540, 2060, 2.0)
        
        print("[8/9] Notifications & Alerts Console...")
        # Tap Home tab
        tap(110, 2260, 1.5)
        # Tap Notification bell at top right
        tap(920, 150, 2.5)
        time.sleep(2.0)
        keyevent("KEYCODE_BACK", 1.5)
        
        print("[9/9] Profile, DPDP Consents & Server Health Ping...")
        # Tap Profile tab
        tap(970, 2260, 2.0)
        
        # Tap 'Check Server Connection (Ping)'
        tap(540, 1850, 3.0)
        
        # Scroll down to display DPDP consents and rights
        swipe(540, 1800, 540, 800, 500, 2.0)
        time.sleep(2.0)
        
        print("Flow automation completed! Finishing recording...")
        time.sleep(1.0)
        
    finally:
        # Gracefully stop screenrecord
        print("Sending SIGINT to screenrecord on device...")
        adb_cmd("shell pkill -2 screenrecord")
        time.sleep(3.0) # Wait for MP4 container header to flush
        
        if record_proc.poll() is None:
            record_proc.terminate()
            record_proc.wait()

    # Pull recording to host machine
    print(f"Pulling recording from device to {LOCAL_VIDEO}...")
    pull_res = adb_cmd(f"pull {REMOTE_VIDEO} '{LOCAL_VIDEO}'")
    print("ADB Pull Result:", pull_res)
    
    if os.path.exists(LOCAL_VIDEO):
        file_size_mb = os.path.getsize(LOCAL_VIDEO) / (1024 * 1024)
        print(f"✓ Successfully captured hardware recording: {LOCAL_VIDEO} ({file_size_mb:.2f} MB)")
    else:
        print("⚠️ Warning: Failed to pull recorded video file.")

if __name__ == "__main__":
    record_device_flow()

