# IT Internship Training Program — Revised Phase Framework

> **Version**: 2.0 | **Updated**: 2026-06-28
> **Goal**: Build a zero-cost, enterprise-grade Minimum Viable Lab (MVL) on a single laptop using VirtualBox.

---

## Program Overview

This framework trains IT interns on real-world enterprise infrastructure by building a fully integrated lab environment from scratch. The program is divided into 8 sprints, each building on the previous one.

### Architecture Summary
- **Hypervisor**: VirtualBox 7.x (Host: Windows 11 laptop)
- **Network**: 10.10.10.0/24 (Internal network behind pfSense gateway)
- **Storage**: D:\LabVMs\ (VMs), D:\LabISOs\ (ISOs)
- **Domain**: apex.local (Active Directory)

### VM Allocation

| VM | IP Address | RAM | Disk | Role |
|---|---|---|---|---|
| pfSense | 10.10.10.1 | 512 MB | 8 GB | Firewall / NAT Gateway |
| Windows Server 2022 | 10.10.10.10 | 3 GB | 40 GB | DC, DNS, DHCP, GPO, WSUS, Veeam |
| Ubuntu Server 22.04 | 10.10.10.20 | 2 GB | 30 GB | GLPI, BookStack, Zabbix, Grafana, Wazuh, OpenVAS |
| Windows 10 Client | 10.10.10.100 | 2 GB | 30 GB | Domain-joined workstation |

---

## Sprint Breakdown

### Sprint 1 — Foundation (4-5 hrs)
**Goal**: Set up the hypervisor, network gateway, and core Windows infrastructure.
- Install VirtualBox 7.x with Extension Pack
- Deploy pfSense VM as NAT gateway (WAN: NAT, LAN: 10.10.10.1/24)
- Deploy Windows Server 2022 VM
- Install AD DS, promote to DC (apex.local)
- Configure DNS (forward lookup zone) and DHCP (10.10.10.100-200)

### Sprint 2 — Linux Services (3-4 hrs)
**Goal**: Deploy the Linux service hub with ticketing and knowledge base.
- Deploy Ubuntu Server 22.04 VM (10.10.10.20)
- Install Apache2, PHP, MariaDB (shared backend)
- Install GLPI (IT Service Management / Ticketing)
- Install BookStack (Knowledge Base / Wiki)

### Sprint 3 — Monitoring (3-4 hrs)
**Goal**: Build the monitoring and observability stack.
- Install Zabbix Server on Ubuntu + agents on all VMs
- Configure pfSense SNMP for Zabbix polling
- Install Grafana, connect to Zabbix as data source
- Build infrastructure dashboards and alert rules

### Sprint 4 — Security & SIEM (4-5 hrs)
**Goal**: Deploy the security operations stack.
- Install Wazuh Manager (SIEM) + agents on all VMs
- Configure pfSense syslog forwarding to Wazuh
- Install OpenVAS/Greenbone (vulnerability scanner)
- Deploy DVWA as a scan target

### Sprint 5 — Network & Scanning (2-3 hrs)
**Goal**: Hands-on network analysis and security scanning labs.
- Deploy Windows 10 Client VM, join to apex.local
- Install Nmap and Wireshark on Win10
- Advanced pfSense firewall rule labs
- Cisco Packet Tracer network design exercises

### Sprint 6 — Remote Management & Backup (3-4 hrs)
**Goal**: Enterprise remote management and disaster recovery.
- Install MeshCentral (remote desktop gateway)
- Install OCS Inventory (asset management)
- Install Veeam CE on Windows Server (backup & restore)

### Sprint 7 — Cloud & Developer Tools (5-6 hrs)
**Goal**: Cloud identity, SSO, zero-trust networking, and developer tools.
- Sign up for M365 Dev Tenant, Azure Free, ServiceNow Dev
- Register custom domain + Cloudflare (Free Tier)
- Configure Cloudflare Tunnel to expose local Apache
- Set up Okta Developer Account
- Configure Okta SSO (OIDC) for BookStack
- Install desktop tools (VS Code, Git, Python, PuTTY, WinSCP, etc.)

### Sprint 8 — Architecture & Final Documentation (3-4 hrs)
**Goal**: Finalize all documentation and create production migration spec.
- Create network architecture diagrams (Draw.io)
- Create tool ecosystem dependency map
- Write troubleshooting runbooks for each component
- Create Proxmox production deployment specification
- Final review and git commit

---

## Tool Stack Summary (33 Tools)

| Category | Tools |
|---|---|
| Virtualization | VirtualBox |
| Networking | pfSense |
| Core Server (Windows) | AD DS, DNS, DHCP, GPO, WSUS |
| Core Server (Linux) | Ubuntu Server 22.04, Apache, MariaDB |
| Ticketing / ITSM | GLPI |
| Knowledge Base | BookStack |
| Monitoring | Zabbix, Grafana |
| SIEM / Logging | Wazuh |
| Vulnerability Scanning | OpenVAS/Greenbone |
| Security Testing | DVWA, Nmap, Wireshark |
| Remote Management | MeshCentral, RustDesk |
| Asset Management | OCS Inventory |
| Backup | Veeam CE |
| Cloud / Identity | M365, Azure, ServiceNow, Okta, Cloudflare |
| Desktop Tools | VS Code, Git, Python, PuTTY, WinSCP, Sysinternals, Cisco Packet Tracer, Draw.io |
