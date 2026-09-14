from playwright.sync_api import sync_playwright
import time
import os

os.makedirs("../reports/screenshots", exist_ok=True)

def run(playwright):
    browser = playwright.chromium.launch(headless=True)
    
    # 1. Test Doctor Login
    context = browser.new_context()
    page = context.new_page()
    print("Navigating to login page...")
    page.goto("http://localhost:8000/portal/login")
    page.screenshot(path="../reports/screenshots/1_login_page.png")
    
    print("Testing doctor login...")
    page.click("button:has-text('Doctor')")
    page.wait_for_url("**/portal/queue")
    time.sleep(2)
    page.screenshot(path="../reports/screenshots/2_doctor_queue.png")
    
    print("Testing doctor accessing admin (should be forbidden)...")
    try:
        page.goto("http://localhost:8000/portal/admin")
        time.sleep(1)
    except Exception as e:
        print("Error going to admin:", e)
    page.screenshot(path="../reports/screenshots/3_doctor_admin_forbidden.png")
    
    context.close()
    
    # 2. Test Admin Login
    context = browser.new_context()
    page = context.new_page()
    page.goto("http://localhost:8000/portal/login")
    
    print("Testing admin login...")
    page.click("button:has-text('Admin')")
    page.wait_for_url("**/portal/admin")
    time.sleep(2)
    page.screenshot(path="../reports/screenshots/4_admin_dashboard.png")
    
    print("Testing admin accessing queue...")
    page.goto("http://localhost:8000/portal/queue")
    time.sleep(1)
    page.screenshot(path="../reports/screenshots/5_admin_queue.png")
    
    context.close()
    browser.close()
    print("Testing complete. Screenshots saved.")

with sync_playwright() as playwright:
    run(playwright)
