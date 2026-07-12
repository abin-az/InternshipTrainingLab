# Think Polaris IT Internship Training Program - Core Rules

These rules must be strictly followed when generating documentation, suggesting changes, or modifying the lab architecture. They are derived from the official Management Phase Evaluation and Tooling PDFs.

## 1. Architectural Structure
- **Hypervisor**: The lab is built on a centralized, bare-metal Proxmox VE server. 
- **Student Access**: Students connect to the environment using physical laptops. They DO NOT install VMs locally (VirtualBox is strictly optional/fallback).
- **Core VMs**: pfSense (Firewall/Routing), Windows Server 2022 (AD, DNS, DHCP, WSUS, Veeam), Ubuntu Server 22.04 (GLPI, BookStack, Zabbix, Wazuh, OpenVAS, etc.).

## 2. Curriculum Phases
The curriculum MUST adhere to the following chronological structure. Do not invent new phases or revert to a 5-sprint model.
1. **Phase 0**: Instructor Admin Build (P0-P3).
2. **Day Zero**: Intern Orientation & Basics (Networking, ITIL).
3. **Phase 1**: Support Fundamentals (Identity, Ticketing).
4. **Phase 2**: Network Monitoring & Security.
5. **Phase 3**: Advanced Admin & Automation.
6. **Capstone**: Final Architecture Diagram and Troubleshooting Runbook.

## 3. Tool Constraints
- **Approved Tools**: Proxmox, Windows Server, Ubuntu, pfSense, Active Directory, GLPI, BookStack, MariaDB, Zabbix, Prometheus, Grafana, Wireshark, Packet Tracer, Nmap, Wazuh, OpenVAS, DVWA, Veeam, WSUS, MeshCentral, RustDesk, Sysinternals, M365/Azure, VS Code, PowerShell, Python, Git.
- **Banned Tools (Do NOT Introduce)**: GNS3, OPNsense, Security Onion, Freshservice, Zammad, Nagios, Checkmk, Bacula, UrBackup, Open-AudIT.
- **Kali Linux**: Strictly an instructor demo tool. Do not assign Kali tasks to students.

## 4. Pedagogical Requirements
- **Scenario-Based**: Tasks must be framed as real-world IT scenarios, not just installation checklists.
- **Assessments**: Every phase must conclude with a structured assessment (e.g., live demonstration).
- **Soft Skills**: Phase 1 must include soft-skills practice (e.g., drafting professional ticket responses).
