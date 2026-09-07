# Real-World L1/L2 Troubleshooting & Fault Simulation Framework

> **Authoritative Pedagogical & Operational Blueprint**  
> **Target Audience**: College Interns $\rightarrow$ Job-Ready L1/L2 Service Desk, Desktop Support, NOC & SOC Engineers  
> **Domain Standard**: `thinkpolaris.local` | `thinkpolaris.com`

---

## 1. Executive Vision: Moving from "Server Builder" to "Troubleshooting Engineer"

Deploying servers following a checklist is only 20% of an IT professional's daily job. In enterprise IT departments, Managed Service Providers (MSPs), and Global Capability Centers (GCCs), **80% of daily engineering time is spent resolving ambiguous, frustrated user tickets and diagnosing live system failures.**

To guarantee college interns land high-paying IT jobs, the **Think Polaris Training Lab** incorporates a dedicated **Fault Injection Engine** and **Multi-Tier Simulation Framework**.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                 THE 4-LAYER REAL-WORLD SIMULATION FRAMEWORK                 │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │
  ┌────────────────────────────────────┼────────────────────────────────────┐
  ▼                                    ▼                                    ▼
[Layer 1: ITSM Ticketing]   [Layer 2: Remote Management]   [Layer 3: Network Twin]
• GLPI 10 (On-Premise)      • MeshCentral (Agent RMM)     • Cisco Packet Tracer
• ServiceNow PDI (Cloud)    • Apache Guacamole (Browser)  • 3-Tier Campus Topology
• SLA / ITIL Incident Flow  • Screen Recording / Audit    • Spanning Tree / Trunking
  │                                    │                                    │
  └────────────────────────────────────┼────────────────────────────────────┘
                                       ▼
                     [Layer 4: Fault Injection Vectors]
                     • AD Account Lockout Loops (Event 4740)
                     • Kerberos Time Skew (>5 min)
                     • GPO Sysvol Permission Break
                     • Print Spooler Crash (C:\Windows\...\spool)
                     • Corrupt User Profile Registry (.bak)
                     • DNS Loopback Misconfiguration
                     • BSOD Memory Dump Analysis (WinDbg)
                     • DHCP Scope Exhaustion
```

---

## 2. Layer 1: ITSM Ticketing & Human Communication (GLPI + ServiceNow)

### Dual-Platform Strategy:
1. **GLPI 10.0.16 (On-Premise Production Core)**:
   - Synchronized with Active Directory LDAP (`DC-WIN-01`).
   - Serves as the daily ticketing engine for all incident creation, assignment, time tracking, SLA escalation, and resolution closure.
2. **ServiceNow Personal Developer Instance (PDI - Cloud Module)**:
   - Free cloud tenant for each intern.
   - Interns learn the enterprise ServiceNow UI, Incident Management tables, CMDB Configuration Items (CIs), and Request Fulfillment to bolster their resumes for enterprise corporate roles.

### Soft-Skills & ITIL Communication Requirements:
- Every resolved ticket must include a professional, jargon-free **Customer-Facing Resolution Note** and a separate, detailed **Internal Technical Root Cause Analysis (RCA)**.

---

## 3. Layer 2: Centralized Remote Support (MeshCentral & Apache Guacamole)

### The Open-Source "Devolutions Server" Alternative:
Instead of costly proprietary software (Devolutions Server, ConnectWise ScreenConnect, TeamViewer Tensor):
1. **Apache Guacamole (Clientless Browser Gateway - `remote.thinkpolaris.local`)**:
   - Web-based portal accessed via Chrome/Edge.
   - Centralizes RDP, SSH, and VNC connections to all lab servers and test workstations with full cryptographic session recording.
2. **MeshCentral (Enterprise RMM Agent)**:
   - Deploys a lightweight background agent on client PCs.
   - Provides background PowerShell/Bash terminal, real-time file transfer, system device manager, and remote desktop without interrupting the end-user.

---

## 4. Layer 3: Cisco Packet Tracer Campus Network Twin

Before touching physical server cables, interns troubleshoot enterprise routing and switching in a pre-built logical **Packet Tracer Network Twin** mirroring the lab:
- **Topology**: Core Switch $\rightarrow$ Distribution Switches $\rightarrow$ Access Switches $\rightarrow$ Department Subnets (`10.10.10.0/24`, `10.10.20.0/24`, `10.10.30.0/24`, `10.10.40.0/24`).
- **Simulated Network Breaks**:
  - **Trunk Native VLAN Mismatch**: Switchport trunk native vlan configured incorrectly, causing spanning-tree BPDU inconsistencies.
  - **DHCP Snooping & Rogue DHCP**: Detecting unauthorized DHCP servers on access ports.
  - **Access Control List (ACL) Misconfigurations**: Diagnosing blocked inter-VLAN communications.

---

## 5. Layer 4: Real-World Fault Injection Scenarios (L1/L2 Trouble Tickets)

| Incident Scenario | Target Layer | Injected Fault Mechanism | Student Investigation & Resolution Path |
| :--- | :--- | :--- | :--- |
| **1. VIP Account Lockout Loop** | Identity / AD DS | A hidden background scheduled task on a client machine repeatedly queries `DC-WIN-01` with bad credentials, locking out a VIP user every 5 minutes. | 1. Query Security Event Log on DC for **Event ID 4740** (Account Locked).<br>2. Extract `Caller Computer Name` from the event metadata.<br>3. Remote into caller machine, inspect Task Scheduler / Credential Manager, and delete stale task. |
| **2. Kerberos Auth Time Drift** | Identity / Domain | Client machine clock is drifted by +8 minutes from Domain Controller (`10.10.10.10`). | 1. User cannot access domain shares (`\\dc-win-01\SYSVOL`).<br>2. Diagnose Kerberos 5-minute maximum tolerance limit.<br>3. Run `w32tm /resync` or configure NTP synchronization. |
| **3. Print Spooler Crash Loop** | Desktop / Windows | Corrupted 0-byte `.SHD` and `.SPL` print job files injected into `C:\Windows\System32\spool\PRINTERS`. | 1. `spoolsv.exe` crashes immediately upon starting.<br>2. Stop Spooler service, purge `C:\Windows\System32\spool\PRINTERS\*`, and restart service. |
| **4. Temporary Profile Fallback** | Desktop / Registry | User SID in `HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList` appended with `.bak`. | 1. Windows logs user into a temporary profile (`C:\Users\TEMP`).<br>2. Edit registry, remove `.bak` key suffix, verify `RefCount = 0` and `State = 0`, and reboot. |
| **5. DNS Misconfiguration / Loopback** | Network / Client | Client adapter DNS set to `127.0.0.1` or `8.8.8.8` instead of AD DC (`10.10.10.10`). | 1. Client has internet access but cannot resolve `thinkpolaris.local` or map network drives.<br>2. Run `ipconfig /all` and `nslookup`, correct DNS to `10.10.10.10`, and flush cache. |
| **6. Kernel BSOD Dump Triage** | OS / Diagnostics | Kernel memory crash dump (`MEMORY.DMP`) provided to intern. | 1. Open dump in **WinDbg** or **BlueScreenView**.<br>2. Run `!analyze -v` to extract bugcheck code (e.g., `DRIVER_IRQL_NOT_LESS_OR_EQUAL`) and identify faulty driver (`.sys`). |
| **7. Disk Space Saturation** | Linux Server | `/var/log` filled with dummy 20GB zero-byte sparse file, halting MariaDB and GLPI. | 1. Diagnose `df -h` and `du -sh /var/log/*`.<br>2. Safely rotate logs, truncate junk files, and restart MySQL/MariaDB. |

---

## 6. Student Assessment & Professional Portfolio Artifacts

Upon completing these simulation labs, interns export and maintain:
1. **The Internship Master Runbook**: Markdown SOPs for every resolved incident.
2. **GitHub Portfolio Repository**: Containing custom PowerShell automation scripts, Wireshark `.pcapng` analysis reports, and architectural diagrams.
3. **Verified Resume Bullet Points**: Verifiable experience in Active Directory, ITIL Ticketing, pfSense Next-Gen Firewalls, Zabbix/Prometheus Monitoring, and Wazuh SIEM Triage.
