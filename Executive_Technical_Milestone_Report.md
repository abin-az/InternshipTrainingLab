# Think Polaris IT Internship Training Program
## Enterprise Lab Infrastructure & Milestone Status Report

> **Document Classification**: Internal Management & Technical Handover  
> **Prepared For**: IT Leadership & Training Management  
> **Organization**: Think Polaris (`thinkpolaris.local` / `thinkpolaris.com`)  
> **Environment Status**: **Phase 0 (100%)** | **Phase 1 (100%)** | **Phase 2 (100%)** | **Phase 3 (Active - P13 Complete)**  
> **Date**: October 2026  

---

## 1. Executive Summary

This report documents the architecture, operational baseline, security delegations, and access credentials deployed for the **Think Polaris IT Internship Training Program**. 

The laboratory environment is built on a bare-metal enterprise server running Proxmox VE hypervisor with an isolated multi-tier virtualized infrastructure. The platform provides realistic, enterprise-grade Service Desk (SD) Engineer and Network/Security Operations training, simulating real-world Fortune 500 workflows while enforcing strict pedagogical guardrails.

### Key Milestones Achieved
1. **Bare-Metal Hypervisor & Perimeter Firewall**: Dell PowerEdge R640 deployed with Proxmox VE 9.2-1 and virtual pfSense NGFW running line-rate routing across isolated virtual bridges.
2. **Zero-Friction Network Portability (Rule 5)**: All lab services, databases, directory servers, and monitoring appliances reside exclusively on the internal virtual bridge `vmbr1` (`10.10.10.0/24`), enabling zero-reconfiguration physical migration between campuses.
3. **Active Directory Identity & Delegated L1 Sandbox**: Enterprise AD DS domain (`thinkpolaris.local`) promoted with granular Access Control Lists (ACLs) delegating user administration over 10 reusable test accounts while strictly locking out intern access to Domain Admins.
4. **Integrated ITSM Service Desk (GLPI 10)**: Bidirectional LDAP sync between Windows Server 2022 and GLPI 10 on Ubuntu, validated with dual-role capability: **Self-Service** (end-user ticket submitters) and **Technician** (Service Desk operators).
5. **Master Workstation Golden Template (`VM 110`)**: Pristine Windows 11 Pro 25H2 master image provisioned with TPM 2.0, VirtIO SCSI, and RSAT administrative tools, converted to a Proxmox template for instantaneous student workstation cloning.
6. **Enterprise Monitoring & SIEM Operations (Phase 2)**: Full telemetry active via Zabbix 6.4 LTS, Prometheus/Node Exporter, Grafana 10 dashboards, and Wazuh SIEM 4.8.2.
7. **Disaster Recovery & Backup Repository (P13)**: Centralized Veeam Backup repository on Windows Server 2022 (`BKP-WIN-01`) with automated agent-based backups for both Windows Domain Controllers and Linux application servers, including verified file-level disaster restore.

---

## 2. Physical & Hypervisor Architecture

| Parameter | Configuration Specification | Notes |
| :--- | :--- | :--- |
| **Server Hardware** | Dell PowerEdge R640 (1U Rack Server) | Service Tag: `B5FQRZ2` |
| **Compute / CPU** | Dual Intel Xeon Platinum 8163 (48 Cores / 96 Threads) | AVX-512 instruction set enabled |
| **Storage Architecture** | 2x Samsung 960GB Enterprise SSDs (MZ7LH960) | PERC H730 Mini in HBA Mode |
| **Storage Pool** | ZFS RAID-1 Software Mirror (`rpool`) | Real-time bit-rot protection |
| **Hypervisor OS** | Proxmox VE 9.2-1 (Debian Bookworm Kernel) | Community repository stream |
| **Hypervisor IP** | `https://192.168.1.25:8006` (or `192.168.68.25`) | Bound to physical `vmbr0` (Port 1) |
| **Out-of-Band (iDRAC)**| Dedicated iDRAC9 Enterprise (`https://192.168.1.50`) | Isolated hardware management |

---

## 3. Network Architecture & Security Zones

The network adheres to **Rule 5 (Zero-Friction Network Portability)** and **Rule 9 (Enterprise NGFW Routing)**.

```
+---------------------------------------------------------------------------------------+
|                              PHYSICAL UPLINK / CAMPUS LAN                             |
|                        Subnet: 192.168.1.0/24 (Dynamic DHCP / Gateway)                |
+---------------------------------------------------------------------------------------+
                                           |
                                  [vmbr0 - Physical Bridge]
                                           |
                                           v
               +-------------------------------------------------------+
               |      VM 100: pfSense Next-Gen Firewall / Router       |
               |  WAN: DHCP (Dynamic)  |  LAN Gateway: 10.10.10.1/24   |
               +-------------------------------------------------------+
                                           |
                                  [vmbr1 - Internal Bridge]
                               (Isolated Subnet: 10.10.10.0/24)
                                           |
        +----------------------------------+----------------------------------+
        |                                  |                                  |
        v                                  v                                  v
+------------------+              +------------------+              +------------------+
|    DC-WIN-01     |              |    APP-UBU-01    |              |    NMS-UBU-01    |
|   10.10.10.10    |              |   10.10.10.20    |              |   10.10.10.30    |
|  AD DS, DNS, GPO |              | GLPI, BookStack  |              | Zabbix, Wazuh SIEM|
+------------------+              +------------------+              +------------------+
        |                                  |                                  |
        v                                  v                                  v
+------------------+              +------------------+              +------------------+
|    SEC-UBU-01    |              |    BKP-WIN-01    |              |  CLIENT TEMPLATE |
|   10.10.10.40    |              |   10.10.10.50    |              |  VM 110 (Win 11) |
| DVWA, Docker Sec |              | Veeam Repository |              | RSAT, Golden Img |
+------------------+              +------------------+              +------------------+
```

---

## 4. Virtual Machine Master Inventory

All production virtual machines are permanently anchored to virtual bridge **`vmbr1`** on the **`10.10.10.0/24`** subnet:

| VM ID | Hostname | Operating System | Internal IP | Roles & Hosted Applications |
| :---: | :--- | :--- | :---: | :--- |
| **100** | `FW-PFSENSE-01` | FreeBSD / pfSense 2.7.2 | `10.10.10.1` | Edge Gateway, DHCP Server, Firewall, NAT, DNS Forwarding |
| **101** | `DC-WIN-01` | Windows Server 2022 | `10.10.10.10` | Primary Domain Controller (`thinkpolaris.local`), Authoritative DNS |
| **102** | `APP-UBU-01` | Ubuntu 22.04 LTS | `10.10.10.20` | GLPI 10.0.16 ITSM, BookStack Wiki, Apache, MariaDB 10.6 |
| **103** | `NMS-UBU-01` | Ubuntu 22.04 LTS | `10.10.10.30` | Zabbix 6.4 LTS, Prometheus, Grafana 10, Wazuh SIEM 4.8.2 |
| **104** | `SEC-UBU-01` | Ubuntu 22.04 LTS | `10.10.10.40` | Security Quarantine Sandbox, Docker Engine, DVWA Target |
| **105** | `BKP-WIN-01` | Windows Server 2022 | `10.10.10.50` | Centralized Veeam Backup Repository (`\\10.10.10.50\VeeamBackups`) |
| **110** | `CLIENT-WIN11-MASTER` | Windows 11 Pro 25H2 | `Template` | **Proxmox Golden Template**: TPM 2.0, VirtIO SCSI, RSAT Tools |

---

## 5. Master Credentials & Access Directory

> [!IMPORTANT]
> The following table represents the authoritative credential ledger for administrative and training accounts across all systems.

### 5.1 Infrastructure & Administrative Logins

| System / Service | URL / Access Path | Username | Password | Access Level |
| :--- | :--- | :--- | :--- | :--- |
| **Proxmox VE Host** | `https://192.168.1.25:8006/` | `root` | `Guardian@2026_$` | Cluster Superuser |
| **pfSense WebGUI** | `https://10.10.10.1/` | `admin` | `Guardian@2026_$` | Firewall Administrator |
| **Active Directory** | RDP / Console `10.10.10.10` | `THINKPOLARIS\Administrator` | `Guardian@2026_$` | Enterprise / Domain Admin |
| **Ubuntu Core (`APP`)**| SSH / Console `10.10.10.20` | `administrator` | `Guardian@2026_$` | Linux `sudo` Administrator |
| **Ubuntu NMS (`NMS`)** | SSH / Console `10.10.10.30` | `administrator` | `Guardian@2026_$` | Linux `sudo` Administrator |
| **Veeam Backup Host** | RDP / Console `10.10.10.50` | `THINKPOLARIS\Administrator` | `Guardian@2026_$` | Backup Administrator |
| **GLPI Super-Admin** | `http://10.10.10.20/` | `Administrator` or `glpi` | `Guardian@2026_$` (or `glpi`)| GLPI Super-Admin Profile |
| **BookStack Wiki** | `http://10.10.10.20:8080/` | `admin@admin.com` | `Guardian@2026_$` (or `password`)| Knowledge Base Admin |
| **Zabbix Frontend** | `http://10.10.10.30/zabbix` | `Admin` | `zabbix` | Zabbix Super Administrator |
| **Grafana Metrics** | `http://10.10.10.30:3000/` | `admin` | `Guardian@2026_$` | Grafana Organization Admin |
| **Wazuh SOC Portal** | `https://10.10.10.30/` | `admin` | `RU78SD9qcDdm.KV6bZOx6NnBZJ4M7m.S` | SOC / SIEM Administrator |

---

### 5.2 Phase 1 Intern & Training User Accounts

| Account Name | Account Type | User Principal Name (UPN) | Password | Assigned Profiles & Rights |
| :--- | :--- | :--- | :--- | :--- |
| **`intern01`** | **Intern Technician** | `intern01@thinkpolaris.local` | `PolarisPass@2026!` | • **AD**: `L1_Intern_Technicians` Group<br>• **AD Rights**: Delegated L1 control on `Test_Targets`<br>• **GLPI**: **Technician** Profile (can claim/solve tickets)<br>• **Workstation**: Standard non-admin client user |
| **`TestUser01`** | Reusable Training Dummy | `TestUser01@thinkpolaris.local` | `PolarisTest@2026!` | • **AD**: Training Sandbox Target User<br>• **GLPI**: **Self-Service** Profile (Ticket submitter) |
| **`TestUser02`** | Reusable Training Dummy | `TestUser02@thinkpolaris.local` | `PolarisTest@2026!` | • **AD**: Training Sandbox Target User<br>• **GLPI**: **Self-Service** Profile (Ticket submitter) |
| **`TestUser03`** | Reusable Training Dummy | `TestUser03@thinkpolaris.local` | `PolarisTest@2026!` | • **AD**: Training Sandbox Target User<br>• **GLPI**: **Self-Service** Profile (Ticket submitter) |
| **`TestUser04`** | Reusable Training Dummy | `TestUser04@thinkpolaris.local` | `PolarisTest@2026!` | • **AD**: Training Sandbox Target User<br>• **GLPI**: **Self-Service** Profile (Ticket submitter) |
| **`TestUser05`** | Reusable Training Dummy | `TestUser05@thinkpolaris.local` | `PolarisTest@2026!` | • **AD**: Training Sandbox Target User<br>• **GLPI**: **Self-Service** Profile (Ticket submitter) |
| **`TestUser06`** | Reusable Training Dummy | `TestUser06@thinkpolaris.local` | `PolarisTest@2026!` | • **AD**: Training Sandbox Target User<br>• **GLPI**: **Self-Service** Profile (Ticket submitter) |
| **`TestUser07`** | Reusable Training Dummy | `TestUser07@thinkpolaris.local` | `PolarisTest@2026!` | • **AD**: Training Sandbox Target User<br>• **GLPI**: **Self-Service** Profile (Ticket submitter) |
| **`TestUser08`** | Reusable Training Dummy | `TestUser08@thinkpolaris.local` | `PolarisTest@2026!` | • **AD**: Training Sandbox Target User<br>• **GLPI**: **Self-Service** Profile (Ticket submitter) |
| **`TestUser09`** | Reusable Training Dummy | `TestUser09@thinkpolaris.local` | `PolarisTest@2026!` | • **AD**: Training Sandbox Target User<br>• **GLPI**: **Self-Service** Profile (Ticket submitter) |
| **`TestUser10`** | Reusable Training Dummy | `TestUser10@thinkpolaris.local` | `PolarisTest@2026!` | • **AD**: Training Sandbox Target User<br>• **GLPI**: **Self-Service** Profile (Ticket submitter) |

---

## 6. Phase 1 Active Directory Training Scaffolding

### 6.1 Organizational Unit (OU) Hierarchy
The Active Directory structure is segregated into corporate production versus designated training boundaries:

```
DC=thinkpolaris,DC=local
│
├── OU=ThinkPolaris (Corporate Production Structure)
│   ├── OU=Executive
│   ├── OU=Finance
│   ├── OU=Human Resources
│   ├── OU=Information Technology
│   └── OU=Operations
│
└── OU=ThinkPolaris_Training (Designated Intern Training Boundary)
    ├── OU=Intern_Accounts
    │   ├── User: intern01
    │   └── Security Group: L1_Intern_Technicians
    │
    └── OU=Test_Targets (Intern Delegated Modification Sandbox)
        ├── User: TestUser01
        ├── User: TestUser02
        ├── User: TestUser03
        ├── ...
        └── User: TestUser10
```

### 6.2 Granular Delegation of Control (ACLs)
Interns are explicitly restricted from full Domain Administration. Using native directory access control entries (`dsacls`), the group **`THINKPOLARIS\L1_Intern_Technicians`** is granted delegated rights strictly within **`OU=Test_Targets,OU=ThinkPolaris_Training,DC=thinkpolaris,DC=local`**:

* **Password Management**: Permission to reset user passwords (`CA;Reset Password;user`).
* **Account Unlock**: Read/Write authority on the `lockoutTime` attribute (`RPWP;lockoutTime;user`).
* **Account State**: Read/Write authority on the `userAccountControl` attribute (`RPWP;userAccountControl;user`).
* **Contact Attributes**: Read/Write authority over `title`, `department`, `telephoneNumber`, and `description`.
* **Security Boundary Verification**: Validated live. Password reset operations against `TestUser01` **succeed**, while attempts against `Administrator` or root-level objects return **"Access is denied"**.

---

## 7. ITSM Service Desk & Identity Integration (GLPI 10)

1. **Enterprise Front-Controller Architecture**: GLPI 10.0.16 is deployed on `APP-UBU-01` (`10.10.10.20`) with Apache's `DocumentRoot` pointed to `/var/www/html/glpi/public`, ensuring directory isolation and CSRF/cookie hardening.
2. **Active Directory LDAP Directory Link**:
   * Base DN: `DC=thinkpolaris,DC=local`
   * Bind User: `CN=Administrator,CN=Users,DC=thinkpolaris,DC=local`
   * Synchronization Port: TCP 389 (LDAP)
3. **Dual-Profile Role-Based Access Control (RBAC)**:
   * **Test Target Accounts (`TestUser01` - `TestUser10`)**: Synchronized to GLPI and granted the **Self-Service** profile by default. They can create tickets, view their own requests, and search public FAQs.
   * **Intern Accounts (`intern01`)**: Granted the **Technician** profile. Interns can toggle between employee view and Service Desk view to claim unassigned tickets, add internal follow-up notes, link assets, and progress tickets to Solved/Closed status.

---

## 8. Master Client Golden Template (`VM 110`)

To ensure standard, zero-drift student deployments, `VM 110 (CLIENT-WIN11-MASTER)` was constructed from a clean Windows 11 Pro 25H2 baseline and converted into a Proxmox template:

### 8.1 Workstation Baseline Specifications
* **VM ID / Identifier**: `110 (CLIENT-WIN11-MASTER)` (State: `Template`)
* **Operating System**: Windows 11 Pro (Build 25H2 x64)
* **Hypervisor Compute**: 4 vCPUs (CPU Type: `host`), 6144 MB RAM
* **Storage Interface**: 60 GB ZFS SCSI disk on `local-zfs` with TRIM enabled (`discard=on`)
* **Firmware & Security**: `q35` Machine Type, OVMF (UEFI) BIOS, TPM 2.0 State Drive (`tpmstate0`)
* **Network Controller**: Red Hat VirtIO Paravirtualized Ethernet Adapter bound to `vmbr1` (`10.10.10.0/24`)
* **Domain Integration**: Joined to `thinkpolaris.local` with authoritative DNS pointing to `10.10.10.10`
* **Administrative Tooling**: Pre-installed Remote Server Administration Tools (RSAT):
  * Active Directory Users & Computers (`dsa.msc`)
  * Group Policy Management Console (`gpmc.msc`)

### 8.2 Instant Student Provisioning (Turnkey Cloning)
Instructors can provision a new intern workstation in under 30 seconds:
1. In Proxmox, right-click **`110 (CLIENT-WIN11-MASTER)`** > click **Clone**.
2. Set Clone Mode to **Full Clone** (or Linked Clone), assign VM ID (e.g., `VM 111`), and enter name (e.g., `CLIENT-INTERN-01`).
3. Boot the VM. The student signs in immediately using `THINKPOLARIS\intern01` with zero post-deployment configuration required.

---

## 9. Curriculum Phasing & Completion Ledger

```
+----------------------------------------------------------------------------------------------------+
|                                    CURRICULUM LIFECYCLE ROADMAP                                    |
+----------------------------------------------------------------------------------------------------+
[X] Phase 0: Bare-Metal Proxmox & Core Infrastructure Build (P0 - P3) ................... 100% DONE
[X] Phase 1: Support Fundamentals, AD Delegation & Master Client VM (P4 - P7) .......... 100% DONE
[X] Phase 2: Network Monitoring, SIEM Operations & Vulnerability Lab (P8 - P12) ......... 100% DONE
[>] Phase 3: Advanced Administration, WSUS & Automation (P13 - P18) .................... 35% ACTIVE
    [X] P13: Enterprise Backup & Disaster Recovery (Veeam Agent Win/Linux) .............. 100% DONE
    [ ] P14: Patch Management (WSUS & GPO Update Rings) ................................. PENDING
    [ ] P15: Remote Support & Endpoint Management (MeshCentral / RustDesk) .............. PENDING
    [ ] P16: Cloud & SaaS Integration (ServiceNow Developer Instance PDI) ............... PENDING
    [ ] P17: Systems Automation (PowerShell 7 & Python Lab Scripts) ..................... PENDING
    [ ] P18: Student Local Fallback Environment (VirtualBox Documentation) .............. PENDING
[ ] Phase 4: Capstone Architecture Mapping & Troubleshooting Runbook .................... PENDING
```

---

## 10. Turnkey Incident History Highlights

All technical obstacles, quirks, and resolutions are systematically recorded in `Troubleshooting_and_Incident_Log.md` (48 total incidents logged). Recent key entries:

* **[INC-045] Hardware ECC Multi-Bit RAM Halt**: Resolved by executing iDRAC memory diagnostics, identifying faulty module at slot `DIMM_B2`, issuing an RMA request to ServerBasket, and safely operating the lab in reduced-memory mode.
* **[INC-046] Campus Subnet Migration & Zero-Friction Portability**: Migrated the physical server across campus buildings from `192.168.29.x` to `192.168.1.x`. Verified Rule 5: **Zero configuration changes were required on any internal VM or database**, as all core services are isolated on `vmbr1`.
* **[INC-047] Domain-Wide GPO Lockout Remediation**: Diagnosed accidental linkage of `Control Panel Restriction` GPO to the root domain (`DC=thinkpolaris,DC=local`) which locked out administrators. Remediated via PowerShell `Remove-GPLink` and forced client convergence via `gpupdate /force`.
* **[INC-048] Client Workstation Locator DNS Misdirection**: Identified that default gateway DHCP delegated public DNS (`1.1.1.1`), preventing Windows 11 from resolving Active Directory locator records. Reconfigured client DNS to `10.10.10.10` and completed seamless domain join.

---

## 11. Immediate Next Steps & Recommendations

1. **BookStack RBAC Scoping (Phase 1 Final Polish)**: Restrict the intern security group to read-only on master technical SOPs while allowing document creation and modification only within their personal training notebooks.
2. **Project P14 (Patch Management)**: Deploy Windows Server Update Services (WSUS) on `DC-WIN-01` or `BKP-WIN-01` and create Group Policy update rings to demonstrate bandwidth-friendly internal patch deployment.
3. **Project P15 (Remote Shadowing)**: Deploy **MeshCentral** to provide browser-based, clientless remote assistance and screen shadowing as an open-source alternative to commercial TeamViewer / ScreenConnect.
4. **Student Workbook Publishing (Layer 2)**: Author the official Markdown training workbooks containing scenario injects (simulated broken printers, password reset tickets, and network outage triages).

---
*Report generated and validated from authoritative version control repository: `https://github.com/abin-az/InternshipTrainingLab.git` (Commit: `c2542d8`).*
