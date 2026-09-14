import os
import re

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Regex to find ![alt](url)
    # We want to replace it with <img src="url" width="250">
    pattern = re.compile(r'!\[([^\]]*)\]\(([^)]+)\)')
    
    new_content = pattern.sub(r'<img src="\2" width="250">', content)
    
    if new_content != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Updated {filepath}")

for root, dirs, files in os.walk('.'):
    if 'node_modules' in root or 'venv' in root or '.dart_tool' in root or '.expo' in root or 'build' in root:
        continue
    for file in files:
        if file.endswith('.md'):
            process_file(os.path.join(root, file))
