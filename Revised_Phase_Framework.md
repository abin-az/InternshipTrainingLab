# IT Internship Training Program — Simulated Enterprise Framework

> **Version**: 3.0 | **Updated**: 2026-07-03
> **Pedagogy**: Simulated Enterprise Operations (Role-Based L1-L3)
> **Goal**: Students act as newly hired IT staff managing a pre-built, production-grade corporate network hosted on a central Proxmox server.

---

## Program Overview

This framework fundamentally shifts the internship from a "build-from-scratch" lab to a **"manage and troubleshoot"** production environment. 

The instructors (Admins) will pre-build the entire corporate infrastructure on a central physical server. The 10 interns will be issued standard physical laptops, connect to the corporate network, and immediately begin resolving IT tickets and managing infrastructure, progressing from L1 Helpdesk to L3 Security Operations.

### Architecture Summary

#### 1. Core Datacenter (Admin-Built)
- **Hypervisor**: Proxmox VE (Physical 1U/2U Server, e.g., Dell R630, 64GB RAM, 1TB SSD)
- **Network**: Managed Gigabit Switch (Server + 10 Student Laptops)
- **Domain**: `apex.local` (Active Directory)

#### 2. Core Virtual Machines (Hosted on Proxmox)
| VM | IP Address | Role |
|---|---|---|
| **pfSense** | 10.10.10.1 | Edge Firewall, NAT, VLAN Routing |
| **Windows Server 2022** | 10.10.10.10 | Domain Controller (DC01), DNS, DHCP, WSUS, File Server |
| **Ubuntu Server (App)** | 10.10.10.20 | Apache, MariaDB, GLPI (Ticketing), BookStack (Wiki) |
| **Ubuntu Server (NMS)** | 10.10.10.30 | Zabbix (Monitoring), Wazuh (SIEM), OpenVAS (Scanning) |

#### 3. Student Endpoints
- **Hardware**: 10x Refurbished Physical Laptops (e.g., i5, 8GB RAM, 256GB SSD)
- **OS**: Windows 10/11 Pro
- **Access**: Joined to the `apex.local` domain or accessing via VPN/Local Network.

---

## The Curriculum: Role-Based Sprints

The training is divided into 5 sprints simulating career progression in an enterprise IT department.

### Sprint 1: L1 Helpdesk & Access Management
**Role**: Junior IT Support Specialist
**Focus**: User management, access control, and ticketing.
- **Tasks**:
  - Log into the GLPI ticketing system to claim incoming L1 tickets.
  - Connect to the Domain Controller via RSAT or RDP.
  - Reset simulated user passwords in Active Directory.
  - Unlock user accounts and force password changes on next login.
  - Add users to specific Security Groups (e.g., `HR_Access`, `IT_Admins`).
  - Use MeshCentral/RDP to remotely troubleshoot a simulated Windows 10 client issue.

### Sprint 2: L2 System Administration (Windows)
**Role**: Systems Administrator
**Focus**: Core infrastructure services and Group Policy.
- **Tasks**:
  - Manage DHCP scopes (e.g., adding IP exclusions and MAC reservations for printers).
  - Add and modify DNS A-records and CNAMEs for new internal services.
  - Create and deploy Group Policy Objects (GPOs) to map network drives and enforce wallpaper policies across the domain.
  - Provision a new network File Share and assign strict NTFS permissions based on AD Security Groups.
  - Approve and push a simulated Windows Update via WSUS.

### Sprint 3: L2 Network & Linux Administration
**Role**: Infrastructure Operations Engineer
**Focus**: Linux server management and proactive monitoring.
- **Tasks**:
  - Connect via SSH (PuTTY) to the Ubuntu App Server.
  - Troubleshoot and restart a crashed Apache/PHP service (`systemctl restart apache2`).
  - Review Zabbix monitoring dashboards.
  - Respond to a simulated high CPU/Memory or low disk space alert.
  - Read Linux system logs (`/var/log/syslog` or `journalctl`) to identify why a service failed.

### Sprint 4: L3 Security & Firewall Management
**Role**: Network Security Engineer
**Focus**: Perimeter defense and traffic routing.
- **Tasks**:
  - Log into the pfSense WebGUI.
  - Review firewall logs to identify blocked traffic from a simulated internal threat.
  - Create a new NAT Port Forwarding rule to securely expose a specific internal service (e.g., a web server) to an external IP.
  - Create strict egress firewall rules to block a specific subnet from accessing the internet.

### Sprint 5: L3 Security Operations (SOC)
**Role**: SOC Analyst
**Focus**: Vulnerability management and threat hunting.
- **Tasks**:
  - Investigate a simulated brute-force SSH login attempt using the Wazuh SIEM dashboard.
  - Run an OpenVAS vulnerability scan against the Windows Server DC.
  - Export the vulnerability report and write a brief remediation plan.
  - Implement the remediation (e.g., disabling a vulnerable protocol or applying a patch).

---

## Instructor Notes

To make this curriculum work, instructors must proactively generate "noise" and "tickets" in the environment:
1. Use PowerShell scripts to randomly lock AD accounts or create fake users to trigger Sprint 1.
2. Use Linux `stress` tools to spike CPU usage and trigger Zabbix alerts for Sprint 3.
3. Use Kali Linux (or similar) to run nmap scans/hydra brute-force attacks against the servers to trigger Wazuh alerts for Sprint 5.
