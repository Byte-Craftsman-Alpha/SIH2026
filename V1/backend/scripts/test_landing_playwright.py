import asyncio
from playwright.async_api import async_playwright

async def run():
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        
        # Test Landing Page
        context = await browser.new_context(viewport={'width': 1280, 'height': 800})
        page = await context.new_page()
        print("Navigating to http://localhost:8000/ ...")
        await page.goto("http://localhost:8000/")
        
        # Wait for images to load (dynamic src)
        await page.wait_for_timeout(3000)
        
        # Take full page screenshot
        print("Taking screenshot...")
        await page.screenshot(path="../reports/screenshots/web_landing_page.png", full_page=True)
        await context.close()
        await browser.close()
        print("Done.")

if __name__ == "__main__":
    asyncio.run(run())
