import os
import json
import re

base_dir = r"D:\Internship_Lab_Project\IT-Internship-Training-Program"

# 1. Build Master_Runbook.md
runbook_path = os.path.join(base_dir, "Master_Runbook.md")

with open(runbook_path, "w", encoding="utf-8") as f:
    f.write("# IT Internship Training Program - Master Runbook\n\n")
    f.write("> **Note:** This is the complete offline manual, aligned with the Management Evaluation & Tooling PDFs.\n\n")
    
    # Add Framework
    f.write("## 1. Project Framework\n\n")
    try:
        with open(os.path.join(base_dir, "Revised_Phase_Framework.md"), "r", encoding="utf-8") as pf:
            f.write(pf.read() + "\n\n")
    except: pass
    
    # Add Prerequisites (P0-P3 & Day Zero)
    f.write("## 2. Admin Setup & Prerequisites\n\n")
    prereq_dir = os.path.join(base_dir, "00_prerequisites")
    if os.path.exists(prereq_dir):
        for file in sorted(os.listdir(prereq_dir)):
            if file.endswith(".md"):
                with open(os.path.join(prereq_dir, file), "r", encoding="utf-8") as pf:
                    f.write(pf.read() + "\n\n---\n\n")

    # Add Phases
    phases = [
        ("phase-1-support", "3. Phase 1: Support Fundamentals"),
        ("phase-2-network-security", "4. Phase 2: Network Monitoring & Security"),
        ("phase-3-advanced-automation", "5. Phase 3: Advanced Administration & Automation")
    ]
    
    for folder, title in phases:
        f.write(f"## {title}\n\n")
        phase_dir = os.path.join(base_dir, folder)
        if os.path.exists(phase_dir):
            for file in sorted(os.listdir(phase_dir)):
                if file.endswith(".md"):
                    with open(os.path.join(phase_dir, file), "r", encoding="utf-8") as sf:
                        f.write(sf.read() + "\n\n---\n\n")

print("Master_Runbook.md created.")

# 2. Update Kanban Board (Replace sprints array)
kanban_path = os.path.join(base_dir, "kanban.html")
if os.path.exists(kanban_path):
    with open(kanban_path, "r", encoding="utf-8") as f:
        kanban_html = f.read()
    
    # Define new 3-phase cards for Kanban
    new_cards_js = """
const defaultCards = [
  {
    id:"p1", sprint:"Phase 1", title:"Support Fundamentals", column:"backlog",
    color:"var(--sprint-1)",
    desc:"Day Zero orientation, Basic Networking, Active Directory, GLPI, and BookStack.",
    tags:["AD DS","GLPI","BookStack","ITIL"], est:"Week 1-2",
    tasks:[
      {text:"Deliver Day Zero Orientation", done:false},
      {text:"Create AD Users and reset passwords (P4)", done:false},
      {text:"Connect via PuTTY and WinSCP (P5)", done:false},
      {text:"Resolve a ticket in GLPI (P6)", done:false},
      {text:"Write an SOP in BookStack (P6)", done:false},
      {text:"Inventory endpoint via OCS (P7)", done:false}
    ],
    guide:`Please refer to Phase 1 in the Master Runbook for full guided scenarios.`
  },
  {
    id:"p2", sprint:"Phase 2", title:"Network Monitoring & Security", column:"backlog",
    color:"var(--sprint-2)",
    desc:"Packet analysis, live monitoring, log analysis, and safe vulnerability scanning.",
    tags:["Zabbix","Wazuh","Wireshark","OpenVAS"], est:"Week 3-4",
    tasks:[
      {text:"Acknowledge Zabbix Alerts (P8)", done:false},
      {text:"View Grafana Metrics (P9)", done:false},
      {text:"Capture packets in Wireshark (P10)", done:false},
      {text:"Track failed logins in Wazuh (P11)", done:false},
      {text:"Run OpenVAS against DVWA (P12)", done:false}
    ],
    guide:`Please refer to Phase 2 in the Master Runbook for full guided scenarios.`
  },
  {
    id:"p3", sprint:"Phase 3", title:"Advanced Admin & Automation", column:"backlog",
    color:"var(--sprint-3)",
    desc:"Disaster recovery, patch management, cloud, and script automation.",
    tags:["Veeam","WSUS","Azure","PowerShell"], est:"Week 5-6",
    tasks:[
      {text:"Run Veeam Backup & Restore (P13)", done:false},
      {text:"Approve WSUS Patches via GPO (P14)", done:false},
      {text:"Remote support via MeshCentral (P15)", done:false},
      {text:"Explore Entra ID & ServiceNow (P16)", done:false},
      {text:"Automate AD users with PowerShell (P17)", done:false}
    ],
    guide:`Please refer to Phase 3 in the Master Runbook for full guided scenarios.`
  }
];
"""
    # Use regex to replace the defaultCards array in the HTML
    kanban_html = re.sub(r'const defaultCards = \[.*?\];', new_cards_js.strip(), kanban_html, flags=re.DOTALL)
    
    # Force a reset of localStorage so it loads the new cards when the user refreshes
    kanban_html = kanban_html.replace(
        "let sprints = JSON.parse(localStorage.getItem('apex_kanban_sprints')) || defaultCards;",
        "localStorage.removeItem('apex_kanban_sprints');\n  let sprints = defaultCards;"
    )

    with open(kanban_path, "w", encoding="utf-8") as f:
        f.write(kanban_html)
    print("kanban.html updated with 3-Phase structure!")

print("Build complete!")
