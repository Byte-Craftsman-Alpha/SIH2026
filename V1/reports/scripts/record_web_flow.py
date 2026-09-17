#!/usr/bin/env python3
"""
Playwright Automation Suite for MediKiosk Doctor Portal Desktop Recording.
Captures full 1920x1080 60fps video of:
- Staff 1-Click Login
- Today's OPD Queue & Triage Priority Queue
- 12-Section AI-Drafted Clinical Summary (Accept / Amend / Language Switch)
- Ashtavidha Pariksha (Ayurvedic 8-Fold Clinical Examination)
- Real-Time Triage Alert Feed
- DPDP Consent Audit Trail & Cryptographic Verification
"""

import os
import time
import shutil
from playwright.sync_api import sync_playwright

OUTPUT_DIR = "/home/aditya/Downloads/SIH 2026/V1/reports/raw_videos"
TEMP_VIDEO_DIR = "/home/aditya/Downloads/SIH 2026/V1/reports/raw_videos/temp_web"
BASE_URL = "https://backend-three-alpha-77.vercel.app"

os.makedirs(OUTPUT_DIR, exist_ok=True)
os.makedirs(TEMP_VIDEO_DIR, exist_ok=True)

def record_portal_flow():
    print("=== Starting Playwright Doctor Portal Desktop Recording ===")
    
    with sync_playwright() as p:
        browser = p.chromium.launch(
            headless=True,
            args=[
                "--no-sandbox",
                "--disable-setuid-sandbox",
                "--disable-dev-shm-usage",
                "--font-render-hinting=none"
            ]
        )
        
        context = browser.new_context(
            viewport={"width": 1920, "height": 1080},
            record_video_dir=TEMP_VIDEO_DIR,
            record_video_size={"width": 1920, "height": 1080}
        )
        
        page = context.new_page()
        
        # 1. Login Page
        print("[1/6] Loading Staff Login Screen...")
        page.goto(f"{BASE_URL}/portal/login", wait_until="networkidle")
        page.wait_for_timeout(2000)
        
        # Highlight and click Doctor 1-Click login
        page.hover("button:has-text('Doctor (Dr. Sharma)')")
        page.wait_for_timeout(1000)
        page.click("button:has-text('Doctor (Dr. Sharma)')")
        
        # 2. OPD Queue
        print("[2/6] Recording Today's OPD Queue...")
        page.wait_for_url("**/portal/queue", timeout=10000)
        page.wait_for_timeout(2500)
        
        # Showcase filters
        page.hover(".pill-item:has-text('Summary Ready')")
        page.wait_for_timeout(1000)
        page.click(".pill-item:has-text('Summary Ready')")
        page.wait_for_timeout(1500)
        
        page.hover(".pill-item:has-text('Urgent Priority')")
        page.wait_for_timeout(1000)
        page.click(".pill-item:has-text('Urgent Priority')")
        page.wait_for_timeout(1500)
        
        page.click(".pill-item:has-text('All Patients')")
        page.wait_for_timeout(1500)
        
        # Scroll through queue
        page.mouse.wheel(0, 400)
        page.wait_for_timeout(1500)
        page.mouse.wheel(0, -400)
        page.wait_for_timeout(1000)
        
        # 3. Clinical Summary (Ramesh Kumar / First ready summary)
        print("[3/6] Navigating to 12-Section Clinical Intake Summary...")
        summary_link = page.locator("a:has-text('View Summary')").first
        if summary_link.is_visible():
            summary_link.click()
        else:
            page.goto(f"{BASE_URL}/portal/summary/summary_demo_01", wait_until="networkidle")
            
        page.wait_for_timeout(2500)
        
        # Smooth scroll through 12-section summary
        for _ in range(4):
            page.mouse.wheel(0, 350)
            page.wait_for_timeout(1000)
            
        # Switch language to Hindi
        hi_pill = page.locator(".pill-item:has-text('हिंदी')")
        if hi_pill.is_visible():
            hi_pill.click()
            page.wait_for_timeout(1500)
            # Switch back to English
            page.click(".pill-item:has-text('English')")
            page.wait_for_timeout(1200)
            
        # Doctor decision action: Accept Clinical Summary
        accept_btn = page.locator("button:has-text('Accept Summary')")
        if accept_btn.is_visible():
            accept_btn.hover()
            page.wait_for_timeout(1000)
            accept_btn.click()
            page.wait_for_timeout(2000)
            
        # 4. Ashtavidha Pariksha Examination Form
        print("[4/6] Recording Ashtavidha Pariksha Examination...")
        page.goto(f"{BASE_URL}/portal/exam/visit_ramesh_01", wait_until="networkidle")
        page.wait_for_timeout(2000)
        page.mouse.wheel(0, 300)
        page.wait_for_timeout(1500)
        page.mouse.wheel(0, 300)
        page.wait_for_timeout(1500)
        
        # 5. Real-Time Triage Console
        print("[5/6] Recording Real-Time Triage Alert Feed...")
        page.goto(f"{BASE_URL}/portal/triage", wait_until="networkidle")
        page.wait_for_timeout(3000)
        
        # 6. DPDP Audit Trail & Admin Console
        print("[6/6] Recording DPDP Consent Audit Trail...")
        page.goto(f"{BASE_URL}/portal/admin", wait_until="networkidle")
        page.wait_for_timeout(2500)
        page.mouse.wheel(0, 400)
        page.wait_for_timeout(2000)
        
        print("Closing context to finalize video recording...")
        page.wait_for_timeout(1000)
        context.close()
        browser.close()

    # Move recorded video file
    video_files = [f for f in os.listdir(TEMP_VIDEO_DIR) if f.endswith(".webm") or f.endswith(".mp4")]
    if video_files:
        raw_video = os.path.join(TEMP_VIDEO_DIR, video_files[0])
        final_video = os.path.join(OUTPUT_DIR, "doctor_portal_raw.webm")
        shutil.move(raw_video, final_video)
        print(f"✓ Doctor Portal Web Video recorded successfully: {final_video}")
        
        # Convert to MP4 with high fidelity
        mp4_final = os.path.join(OUTPUT_DIR, "doctor_portal.mp4")
        convert_cmd = f"ffmpeg -y -i '{final_video}' -c:v libx264 -pix_fmt yuv420p -r 30 -crf 18 '{mp4_final}'"
        os.system(convert_cmd)
        print(f"✓ Converted to 1080p MP4: {mp4_final}")
    else:
        print("⚠️ Warning: No video file found in temp directory.")

if __name__ == "__main__":
    record_portal_flow()

