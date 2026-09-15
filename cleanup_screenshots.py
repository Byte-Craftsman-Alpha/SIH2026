import os
import re
from glob import glob

# Find all markdown files
md_files = glob("**/*.md", recursive=True)

# Collect all referenced image names
referenced_images = set()
for md_file in md_files:
    with open(md_file, "r", encoding="utf-8") as f:
        content = f.read()
        # Find all strings that look like image filenames
        matches = re.findall(r'([a-zA-Z0-9_-]+\.(?:png|jpg|jpeg|gif))', content)
        for m in matches:
            referenced_images.add(m)

# Let's also keep explicitly named useful ones just in case
keep_always = {'web_admin_portal.png', 'web_doctor_portal.png', 'device_screenshot_nav_color.png', 'reported_bug_context_issue.png'}
referenced_images.update(keep_always)

deleted_count = 0
for root, dirs, files in os.walk("."):
    # Avoid .git
    if ".git" in root: continue
    
    for file in files:
        if file.endswith((".png", ".jpg", ".jpeg")):
            # If it's a screenshot (e.g., in a screenshots folder)
            if "screenshot" in root.lower() or "device_screenshot" in file:
                if file not in referenced_images:
                    filepath = os.path.join(root, file)
                    os.remove(filepath)
                    print(f"Deleted unreferenced screenshot: {filepath}")
                    deleted_count += 1

print(f"Total deleted: {deleted_count}")
