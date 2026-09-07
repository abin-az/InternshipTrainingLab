# Enterprise Backup & Disaster Recovery Blueprint (3-2-1 Strategy)

> **Authoritative Technical Blueprint**  
> **Backup Host**: VM 105 (`BKP-WIN-01` — `10.10.10.50` on `vmbr1`)  
> **Primary Hypervisor**: Dell PowerEdge R640 (Proxmox VE 8.x)  
> **Core Tools**: Veeam Backup & Replication Community Edition, Proxmox VZDump, ZFS Snapshots, MariaDB Hot Backups

---

## 1. Executive Summary: The Enterprise 3-2-1 Backup Architecture

In enterprise IT and Managed Service Provider (MSP) environments, backup and disaster recovery is the final line of defense against ransomware, hardware failure, human error, and database corruption.

The **Think Polaris Training Lab** implements a multi-tier **3-2-1 Backup Standard** (3 copies of data, 2 different media types, 1 isolated copy):

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                   THE 3-TIER ENTERPRISE BACKUP ARCHITECTURE                 │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │
  ┌────────────────────────────────────┼────────────────────────────────────┐
  ▼                                    ▼                                    ▼
[Tier 1: Hypervisor Layer]     [Tier 2: Enterprise Guest]   [Tier 3: Database & App]
• Proxmox VZDump Backups       • Veeam Backup & Replication  • MariaDB Automated Dumps
• ZFS Instant Copy-on-Write    • Free Community (10 VMs)     • `/var/www/` Sync
• Nightly Cron to Local Pool   • Windows / Linux VM Agent    • GLPI & BookStack Cold Sync
  │                                    │                                    │
  └────────────────────────────────────┴────────────────────────────────────┘
```

---

## 2. Backup Tool Comparison Matrix (Spreadsheet Alignment)

Based on our enterprise tooling analysis, here is how the backup solutions compare:

| Tool | License / Cost | Strengths | Enterprise Job Relevance | Lab Role |
| :--- | :--- | :--- | :--- | :--- |
| **Veeam Community Edition** | **Free (up to 10 instances)** | Industry standard for VMware/Hyper-V/Windows/Linux. Instant VM recovery, Active Directory Explorer, granular file-level restore. | **Industry Gold Standard** (Used by 82% of Fortune 500 & MSPs) | **Primary Guest & Application Backup Engine (`BKP-WIN-01`)** |
| **Proxmox VZDump / PBS** | **Free / Built-in** | Snapshot-mode live VM image backups with ZFS de-duplication and sub-minute restore times. | Enterprise Hypervisor Admin (Proxmox / KVM) | **Primary Hypervisor Bare-Metal Disaster Recovery** |
| **UrBackup Community** | Free / Open Source | Lightweight client-server image and file backup for mixed Windows/Linux fleets. | Mid-market & open-source MSPs | **Secondary / Alternative Evaluation Module** |
| **Bacula Community** | Free / Open Source | Complex enterprise network backup engine for large data centers. | Enterprise Linux Sysadmin | **Curriculum Conceptual Reference** |

---

## 3. Tier 1: Proxmox Hypervisor Automated Image Backups

### Automated Scheduled VZDump Jobs:
Proxmox VE runs automated, non-disruptive snapshot backups of all 6 core VMs (`100`, `101`, `102`, `103`, `104`, `105`):
- **Backup Type**: `Snapshot` (zero VM downtime).
- **Compression**: `ZSTD` (high-speed multi-threaded compression).
- **Storage Target**: Local ZFS storage pool (`local` / `local-zfs`).
- **Retention Schedule**: 7 daily snapshots + 4 weekly archives.

### Hypervisor Restore Capability:
If any VM is completely destroyed by a student simulation or misconfiguration, it can be fully restored to exact working order in **under 90 seconds** using:
```bash
qmrestore /var/lib/vz/dump/vzdump-qemu-101-*.vma.zst 101 --force
```

---

## 4. Tier 2: Veeam Backup & Replication Community Edition (`BKP-WIN-01`)

### Deployment Specifications (VM 105):
- **OS**: Windows Server 2022 Datacenter Edition.
- **Static IP**: `10.10.10.50/24` (Gateway: `10.10.10.1`, DNS: `10.10.10.10`).
- **RAM**: 8 GB | **vCPU**: 4 Cores | **Disk**: 100 GB (Storage Repository).

### Configured Backup Jobs:
1. **Job 1: Active Directory Domain Controller (`DC-WIN-01` — `10.10.10.10`)**:
   - VSS-aware application-consistent backup with Active Directory transaction log truncation.
   - Enables **Veeam Explorer for Active Directory** (recovering individual deleted users, OUs, passwords, and GPOs without rolling back the entire server).
2. **Job 2: Application Stack (`APP-UBU-01` — `10.10.10.20`)**:
   - File-level and volume backup targeting `/var/www/html/glpi`, `/var/www/bookstack`, and `/etc/apache2`.

---

## 5. Intern Hands-On Disaster Recovery Scenarios (P13 Lab)

| Lab Exercise | Injected Disaster State | Student Recovery Procedure |
| :--- | :--- | :--- |
| **1. Accidental User / OU Deletion** | An intern accidentally deletes the entire `Interns` Organizational Unit containing 20 users in Active Directory. | 1. Open **Veeam Explorer for Microsoft Active Directory** on `BKP-WIN-01`.<br>2. Browse the latest restore point.<br>3. Right-click the deleted OU $\rightarrow$ select **Restore to thinkpolaris.local**.<br>4. Verify OU and user accounts reappear in Active Directory Users & Computers with passwords intact. |
| **2. Corrupted Web Configuration File** | An instructor corrupts `/etc/apache2/sites-available/glpi.conf` causing Apache to fail startup on `APP-UBU-01`. | 1. Open Veeam Backup Console $\rightarrow$ **Restore > Guest Files (Linux)**.<br>2. Navigate to `/etc/apache2/sites-available/glpi.conf`.<br>3. Restore file to original location, overwriting corrupted file.<br>4. Restart `apache2` and verify GLPI loads. |
| **3. Database Point-in-Time Rollback** | Accidental table drop in MariaDB (`glpi_tickets`). | 1. Access MariaDB automated dump directory (`/var/backups/mariadb/`).<br>2. Restore database from hourly SQL dump: `mysql -u root -p glpi < /var/backups/mariadb/glpi_latest.sql`.<br>3. Verify all tickets and SLA histories are fully restored. |
