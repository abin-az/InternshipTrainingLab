# IT Internship Training Program — Revised Phase Framework

> **Version**: 4.0 | **Updated**: 2026-07-03
> **Alignment**: Strictly aligned with Management Internship Evaluation & Tooling PDFs.
> **Architecture**: Proxmox VE central server (instructor-built) with 10 student laptops.

---

## Program Overview

This training program is a **3-Phase** progressive curriculum designed for college students with zero prior enterprise IT exposure. It focuses on a gradual ramp-up from basic IT orientation to advanced infrastructure automation, utilizing a simplified, beginner-friendly tool stack.

### Setup Priority (Admin P0-P3)
*Instructors must build the core foundation before Phase 1 begins.*
*   **P0**: Lab Design (Draw.io IP plans, subnetting, safety rules)
*   **P1**: Proxmox VE (Base virtualization on physical hardware)
*   **P2**: pfSense (Core network routing, NAT, DHCP)
*   **P3**: Windows Server & Ubuntu Server (Core VMs for domain and apps)

---

## Phase 1: Support Fundamentals

**Focus**: Helpdesk operations, documentation, and user management.
**Pre-requisite Modules**: Day Zero IT Orientation, Basic Networking (IP, DNS, DHCP), ITIL Basics.

### Tools Taught (P4-P7)
*   **Identity & Access**: Active Directory, DNS, DHCP, basic GPOs. (Windows Server)
*   **Access Utilities**: PuTTY, WinSCP, RDP.
*   **Service Desk**: GLPI (Ticketing), BookStack (Knowledge Base), MariaDB (Backend).
*   **Asset Management**: OCS Inventory (integrated with GLPI).

### Scenario Focus
Students act as L1 Support. They receive simulated tickets in GLPI, connect to the Windows Server via RDP/PuTTY, reset passwords in AD, create knowledge base articles in BookStack, and inventory endpoints.

---

## Phase 2: Network Monitoring & Security

**Focus**: Network analysis, observability, and basic security operations.
**Pre-requisite Modules**: OSI basics, subnetting, firewall basics, network diagrams.

### Tools Taught (P8-P12)
*   **Monitoring**: Zabbix (Basic agent monitoring, triggers, alerts).
*   **Networking Labs**: Cisco Packet Tracer, Wireshark, Nmap.
*   **Security Monitoring**: Wazuh (SIEM, log analysis, failed login tracking).
*   **Vulnerability Scanning**: OpenVAS / Greenbone, DVWA (Safe scan target).

### Scenario Focus
Students transition to L2 Infrastructure/Security. They analyze packet captures in Wireshark, trace malicious logins via Wazuh alerts, and perform safe vulnerability scans on DVWA using OpenVAS.

---

## Phase 3: Advanced Administration & Automation

**Focus**: Advanced system administration, disaster recovery, cloud, and scripting.
**Pre-requisite Modules**: Linux terminal basics, understanding of APIs.

### Tools Taught (P13-P18)
*   **Backup & Recovery**: Veeam Community Edition.
*   **Patch Management**: WSUS (integrated with AD).
*   **Remote Endpoint Control**: MeshCentral, RustDesk, Sysinternals Suite.
*   **Cloud Exposure**: Microsoft 365 Developer, Azure Free Account, ServiceNow Developer.
*   **Modern Observability**: Prometheus + Grafana (Time-series metrics).
*   **Automation**: PowerShell 7, Python, VS Code, Git, GitHub.

### Scenario Focus
Students execute L3 Engineering tasks. They configure Veeam backups, approve Windows updates via WSUS, build custom Grafana dashboards using Prometheus metrics, and write PowerShell/Python scripts to automate user creation in AD (pushing scripts to GitHub).

---

## Tools Removed / Deprioritized
*Per management directive, the following tools are excluded from the main track to reduce beginner overwhelm:*
*   OPNsense, GNS3, Security Onion, Freshservice, Zammad, Nagios Core, Checkmk, Bacula, UrBackup, Open-AudIT, VMware Workstation.
