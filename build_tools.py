import os
import json
import re

base_dir = r"D:\Internship_Lab_Project\IT-Internship-Training-Program"

# 1. Build Master_Runbook.md
runbook_path = os.path.join(base_dir, "Master_Runbook.md")

with open(runbook_path, "w", encoding="utf-8") as f:
    f.write("# IT Internship Training Program - Master Runbook\n\n")
    f.write("> **Note:** This is the complete offline manual. It contains all project frameworks, task lists, and step-by-step guides.\n\n")
    
    # Add Framework
    f.write("## 1. Project Framework\n\n")
    try:
        with open(os.path.join(base_dir, "Revised_Phase_Framework.md"), "r", encoding="utf-8") as pf:
            f.write(pf.read() + "\n\n")
    except: pass
    
    # Add Prerequisites
    f.write("## 2. Prerequisites & ISO Downloads\n\n")
    try:
        with open(os.path.join(base_dir, "00_prerequisites", "iso_download_guide.md"), "r", encoding="utf-8") as pf:
            f.write(pf.read() + "\n\n")
    except: pass

    # Add Sprint 1
    f.write("## 3. Sprint 1: Foundation\n\n")
    sprint1_dir = os.path.join(base_dir, "sprint-1-foundation")
    if os.path.exists(sprint1_dir):
        files = sorted(os.listdir(sprint1_dir))
        for file in files:
            if file.endswith(".md"):
                with open(os.path.join(sprint1_dir, file), "r", encoding="utf-8") as sf:
                    f.write(f"### {file}\n\n")
                    f.write(sf.read() + "\n\n---\n\n")
                    
    # Add Placeholders
    for i in range(2, 9):
        f.write(f"## {i+2}. Sprint {i}\n\n*Guides for this sprint will be generated when the sprint begins.*\n\n")

print("Master_Runbook.md created.")

# 2. Extract Sprint 1 text to inject into Kanban
sprint1_text = ""
sprint1_dir = os.path.join(base_dir, "sprint-1-foundation")
if os.path.exists(sprint1_dir):
    files = sorted(os.listdir(sprint1_dir))
    for file in files:
        if file.endswith(".md"):
            with open(os.path.join(sprint1_dir, file), "r", encoding="utf-8") as sf:
                sprint1_text += f"\n\n========================================\nFILE: {file}\n========================================\n\n"
                sprint1_text += sf.read()

# Escape for JS backticks
sprint1_text_js = sprint1_text.replace('\\', '\\\\').replace('`', '\\`').replace('$', '\\$')

# 3. Update kanban.html - inject guide data for Sprint 1
kanban_path = os.path.join(base_dir, "kanban.html")
if os.path.exists(kanban_path):
    with open(kanban_path, "r", encoding="utf-8") as f:
        kanban_html = f.read()

    # Look for the Sprint 1 guide placeholder and replace it
    # The kanban stores guide data in the card objects
    old_guide = 'guideData: "Sprint 1 guides will be injected by build_tools.py"'
    if old_guide in kanban_html:
        kanban_html = kanban_html.replace(old_guide, f'guideData: `{sprint1_text_js}`')
        with open(kanban_path, "w", encoding="utf-8") as f:
            f.write(kanban_html)
        print("kanban.html updated with Sprint 1 guide data.")
    else:
        print("kanban.html: No placeholder found for guide injection (may already be injected or using different format).")
else:
    print("kanban.html not found. Skipping guide injection.")

print("\nBuild complete!")
