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
- **The Mandatory 6-Action Execution Protocol**:
  1. **Action 1: Granular Incident Logging** in `Troubleshooting_and_Incident_Log.md`:
     - Assign official sequential ID (e.g., `[INC-041]`, `[INC-042]`).
     - Document affected component & target host (`NMS-UBU-01`, `DC-WIN-01`, etc.).
     - Record exact symptoms (error codes, HTTP statuses, terminal outputs).
     - Explain root cause (the deep technical "why").
     - Provide turnkey copy-paste resolution commands and configuration snippets.
  2. **Action 2: Deployment Milestone Tracking** in `Deployment_Changelog.md`:
     - Exact configuration parameters (IPs, listening ports, service accounts, file paths).
     - Verification results (Zabbix green indicators, Prometheus targets UP, live Grafana telemetry, port scans).
     - Updated completion percentage and phase progression state.
  3. **Action 3: "Why & How" Architectural Justification** in `Technology_Selection_and_Architecture_Rationale.md`:
     - Pedagogical justification (enterprise relevance and intern learning value).
     - Technical implementation (`vmbr1` binding, domain integration, resource constraints).
  4. **Action 4: Zero-Friction Network Portability Verification**:
     - Strict isolation on `vmbr1` (`10.10.10.0/24`).
     - Zero hardcoded bindings to external physical ISP uplink IP (`192.168.29.x`).
     - Moving the server to any new site requires zero configuration changes on any VM.
  5. **Action 5: Automated Git Versioning & Synchronization**:
     - Stage all modified and new files (`git add .`).
     - Standardized commit messages (e.g., `docs: record INC-041 and P10 Wazuh agent completion`).
     - Sync to authoritative remote repository (`https://github.com/abin-az/InternshipTrainingLab`).
  6. **Action 6: Summary Handover & Curriculum Alignment**:
     - Curriculum status check (Phase 0 through Capstone).
     - Clean summary of what was accomplished, verified proof, and immediate next step.

## 7. Technical Selection & Architectural Justification ("Why & How" Rationale)
- **Deep Clarity Requirement**:
  - For every tool, package, ISO image, driver, and operating system introduced or downloaded, always document **WHY** it is selected (pedagogical purpose, technical justification) and **HOW** it is used (VM binding, driver injection, configuration mechanics).
  - Explicitly maintain the hybrid Windows vs. Linux architectural rationale in [Technology_Selection_and_Architecture_Rationale.md](file:///c:/Users/abinu/Documents/antigravity/optimistic-meitner/architecture/Technology_Selection_and_Architecture_Rationale.md) and [ISO_Download_Manifest.md](file:///c:/Users/abinu/Documents/antigravity/optimistic-meitner/00_prerequisites/ISO_Download_Manifest.md).

## 8. Company Identity & Domain Standard (Think Polaris)
- **Organization Name**: **Think Polaris** (or `ThinkPolaris`).
- **Active Directory Domain**: FQDN MUST be **`thinkpolaris.local`** (NetBIOS: **`THINKPOLARIS`**).
- **Public / Upstream Domain**: **`thinkpolaris.com`** (or company-purchased domain).
- **Subdomain Schema**:
  - GLPI: `glpi.thinkpolaris.local`
  - BookStack: `wiki.thinkpolaris.local` (or `kb.thinkpolaris.local`)
  - Zabbix: `zabbix.thinkpolaris.local`
  - Grafana: `grafana.thinkpolaris.local`
  - Wazuh: `wazuh.thinkpolaris.local`
  - pfSense WebGUI: `pfsense.thinkpolaris.local` (or `gw.thinkpolaris.local`)
  - Remote Support: `remote.thinkpolaris.local`

## 9. Enterprise Next-Gen Firewall (NGFW) & Office VLAN Architecture
- **Perimeter & Core Routing**: Virtual pfSense (VM 100) on bare-metal Dell PowerEdge R640 acts as the authoritative physical office and lab gateway, outperforming costly commercial appliances ($1,500–$4,000 FortiGate/Palo Alto) via Xeon/Ryzen compute and line-rate VirtIO switching.
- **6-Zone 802.1Q VLAN Model**:
  - `VLAN 10` (`10.10.10.0/24`): **MGMT (Infrastructure)** — Proxmox, iDRAC, Switch, pfSense WebGUI.
  - `VLAN 20` (`10.10.20.0/24`): **Lab Core Servers** — DC-WIN-01, GLPI, BookStack, Zabbix, Wazuh.
  - `VLAN 30` (`10.10.30.0/24`): **Students / Interns** — Isolated client subnets with controlled access to Lab Core.
  - `VLAN 40` (`10.10.40.0/24`): **Office / Staff / Faculty** — Administrative office network with internet priority.
  - `VLAN 50` (`10.10.50.0/24`): **Guest Wi-Fi** — Isolated captive portal for visitors and personal smartphones.
  - `VLAN 60` (`10.10.60.0/24`): **Security Sandbox / Target** — Strict quarantine zone holding DVWA and penetration test targets.
- **Enterprise pfSense Packages**:
  - `pfBlockerNG-devel`: GeoIP nation blocking and DNSBL threat filtering.
  - `Suricata`: Intrusion Detection & Prevention System (IDS/IPS) utilizing ET Open rulesets.
  - `FQ-CoDel`: Smart bandwidth shaping and anti-bufferbloat queuing.
  - `WireGuard / OpenVPN`: Secure remote hybrid access for instructors and remote learners.
  - `HAProxy + ACME`: Free automated internal SSL termination for `*.thinkpolaris.local`.

## 10. Real-World L1/L2 Troubleshooting & Fault Simulation Framework
- **Job-Readiness Imperative**: College interns must not merely follow installation guides; they must troubleshoot realistic enterprise helpdesk, desktop, network, and identity failure states.
- **Core Simulation Vectors**:
  - **Identity (AD DS)**: Account lockout loops (Event 4740), Kerberos time skew (>5 min), GPO sysvol permission breaks.
  - **Desktop / Endpoint**: Corrupted print spoolers (`spool\PRINTERS`), temp user profiles (`.bak`), DNS loopback misconfigurations, kernel BSOD dump analysis (`WinDbg`).
  - **Network & Gateway**: DHCP pool exhaustion, firewall port blackholing, Cisco Packet Tracer Campus Network Twin (VLAN trunk mismatches, spanning-tree loops).
  - **Server Operations**: Disk space exhaustion, expired SSL certificates, crashed database daemons.
- **Centralized Remote Management**: Deploy open-source **MeshCentral** and **Apache Guacamole** as clientless browser-based alternatives to proprietary Devolutions Server / ScreenConnect.
- **ServiceNow Developer Integration**: Supplement on-premise GLPI 10 with free cloud ServiceNow Personal Developer Instances (PDI) for enterprise resume alignment.

