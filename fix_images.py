import os
import re

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    original = content

    def replacer(match):
        alt = match.group(1)
        url = match.group(2)
        if 'shields.io' in url or 'badge' in url.lower():
            return match.group(0) # don't touch badges
        return f'<img src="{url}" alt="{alt}" width="250">'

    content = re.sub(r'!\[([^\]]*)\]\(([^)]+\.(?:png|jpg|jpeg|gif).*?)\)', replacer, content)

    if content != original:
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"Updated {filepath}")

for root, dirs, files in os.walk('.'):
    if 'node_modules' in root or '.git' in root or 'venv' in root or '.dart_tool' in root or 'build' in root:
        continue
    for file in files:
        if file.endswith('.md'):
            process_file(os.path.join(root, file))
