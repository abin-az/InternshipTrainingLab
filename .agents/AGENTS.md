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

## 5. Network Portability & Zero-Friction Migration Rule
- **Isolated Internal Core**: All internal VMs, servers, databases, domain controllers, and services MUST be bound exclusively to the internal virtual bridge `vmbr1` on the `10.10.10.0/24` subnet.
- **Portability Guardrails**:
  - Never tie any internal service (AD, DNS, GLPI, BookStack, Zabbix, Wazuh, MariaDB) to the external uplink IP (`192.168.29.x` or any local ISP IP).
  - pfSense WAN MUST use DHCP or dynamic uplink routing on `vmbr0` so that migrating the server to any new site only requires updating the Proxmox host IP on `vmbr0`—with **ZERO configuration changes required on any VM or internal service**.
  - Always maintain and consult [Server_Migration_and_Portability_Runbook.md](file:///c:/Users/abinu/Documents/antigravity/optimistic-meitner/architecture/Server_Migration_and_Portability_Runbook.md) when proposing changes.

## 6. Turnkey Incident Logging, Granular Setting Tracking & Automated Git Syncing
- **Granular Incident & Setting Logging**:
  - Every single setup, package installation, minor configuration tweak, hardware quirk, and error/incident with its resolution MUST be recorded in [Troubleshooting_and_Incident_Log.md](file:///c:/Users/abinu/Documents/antigravity/optimistic-meitner/Troubleshooting_and_Incident_Log.md) and [Deployment_Changelog.md](file:///c:/Users/abinu/Documents/antigravity/optimistic-meitner/Deployment_Changelog.md).
  - The documentation must be turnkey and copy-paste ready for replicating the exact lab at another training institute.
- **Automated Git Versioning**:
  - Upon completing each module, feature setup, or incident resolution, stage, commit, and sync the changes to the Git repository so that the remote repository remains the single authoritative source of truth.

## 7. Technical Selection & Architectural Justification ("Why & How" Rationale)
- **Deep Clarity Requirement**:
  - For every tool, package, ISO image, driver, and operating system introduced or downloaded, always document **WHY** it is selected (pedagogical purpose, technical justification) and **HOW** it is used (VM binding, driver injection, configuration mechanics).
  - Explicitly maintain the hybrid Windows vs. Linux architectural rationale in [Technology_Selection_and_Architecture_Rationale.md](file:///c:/Users/abinu/Documents/antigravity/optimistic-meitner/architecture/Technology_Selection_and_Architecture_Rationale.md) and [ISO_Download_Manifest.md](file:///c:/Users/abinu/Documents/antigravity/optimistic-meitner/00_prerequisites/ISO_Download_Manifest.md).
