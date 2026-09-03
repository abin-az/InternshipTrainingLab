# Complete Turnkey Deployment Changelog & Setting Ledger

> **Turnkey Blueprint**: Comprehensive record of every module, package, configuration file, and minute setting applied to the Think Polaris IT Internship Training Lab.

---

## 📋 Changelog & Setting Log

### [Module P0 - P1] Bare-Metal Proxmox Host Deployment
- **Target Node**: `thinkpolaris` (Dell PowerEdge R640).
- **Physical Specs**: 2x Samsung 960GB Enterprise SSDs, PERC H730 Mini (HBA Mode), Dual Redundant PSUs, iDRAC9 Enterprise.
- **Base OS**: Proxmox VE 9.2-1 / Debian Bookworm kernel.
- **Storage Configuration**: ZFS RAID-1 software mirror (`rpool`) across `/dev/sda` and `/dev/sdb`.
- **Management Endpoint**: `https://192.168.29.25:8006/` on `vmbr0` (Port 1).
- **APT Repositories**: Replaced enterprise repos with `pve-no-subscription` community feed. Full `apt dist-upgrade` completed.

---

### [Module P2] Core Lab Network & Virtual Bridges
- **`vmbr0` (WAN/Uplink)**: Bound to physical `nic0` (Port 1), IP `192.168.29.25/24`, Gateway `192.168.29.1`.
- **`vmbr1` (Internal Lab LAN)**: Isolated Linux Bridge, no physical ports attached, no host IP. Handles internal subnet `10.10.10.0/24`.
- **Firewall Appliance**: pfSense Community Edition (2.7.2).
- **Network Portability Guardrail**: pfSense WAN set to DHCP on `vmbr0`; all internal VMs anchored strictly to `vmbr1`.

---

### [Module P3] Core Server Operating Systems (Pending)
- `DC-WIN-01` (Windows Server 2022 - AD DS, DNS, DHCP, WSUS): `10.10.10.10/24` on `vmbr1`.
- `APP-UBU-01` (Ubuntu 22.04 - GLPI, BookStack, MariaDB): `10.10.10.20/24` on `vmbr1`.
- `NMS-UBU-01` (Ubuntu 22.04 - Zabbix, Prometheus, Grafana, Wazuh): `10.10.10.30/24` on `vmbr1`.
- `SEC-UBU-01` (Ubuntu 22.04 - OpenVAS, DVWA): `10.10.10.40/24` on `vmbr1`.
- `BKP-WIN-01` (Windows Server 2022 - Veeam Backup & Replication): `10.10.10.50/24` on `vmbr1`.
- **Bridge Verification**: `vmbr1` verified active via `ip link show vmbr1` (state `UP`/`UNKNOWN`, MAC `3e:d6:e1:36:ef:5e`).
- **pfSense 2.7.2 ISO Download**: Downloaded and verified `pfSense-CE-2.7.2-RELEASE-amd64.iso` (835MB) in `/var/lib/vz/template/iso/`.
- **VM 100 (FW-PFSENSE-01) Provisioned**: 2 Cores, 2048MB Fixed RAM, 20GB ZFS SCSI disk (`local-zfs`), `net0` on `vmbr0` (WAN uplink), `net1` on `vmbr1` (Internal Lab LAN `10.10.10.0/24`), autostart order 1.
- **pfSense Base OS Installed**: Completed ZFS filesystem formatting and FreeBSD system extraction on `da0` (SCSI 0).
- **pfSense WAN Interface Verified**: `vtnet0` received dynamic WAN DHCP lease `192.168.29.47/24` from physical router on `vmbr0`.
- **pfSense LAN & DHCP Configured**: LAN set to `10.10.10.1/24` on `vmbr1`; DHCP scope configured for `10.10.10.100 - 10.10.10.200`; WebConfigurator active on `https://10.10.10.1/`.
- **Module P2 Complete**: pfSense Core Lab Network and Firewall Router deployed and operational.
- **OmniRoute Standalone Background Service & Autostart Configured**:
  - Service Script: `scripts/windows_host/start-omniroute-service.ps1`.
  - Silent Launcher: `scripts/windows_host/launch-omniroute-silent.vbs`.
  - Windows Autostart: Installed to `C:\Users\abinu\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\Launch-OmniRoute.vbs`.
  - Verification: Listening on `0.0.0.0:20128` (PID: 11124).
- **Base Linux & VirtIO ISOs Verified**:
  - `ubuntu-22.04.5-live-server-amd64.iso` (2.0 GB) verified in `/var/lib/vz/template/iso/`.
  - `virtio-win.iso` (837 MB) verified in `/var/lib/vz/template/iso/`.
- **Windows Server 2022 ISO Download Initiated**: `Windows_Server_2022.iso` (~4.7 GB) queued in `/var/lib/vz/template/iso/`.
- **VM 102 (APP-UBU-01) Provisioned & Started**: 2 Cores, 4096MB RAM, 40GB ZFS disk (`local-zfs`), `net0` on `vmbr1` (Internal Lab LAN `10.10.10.20`), autostart order 3.
- **VM 101 (DC-WIN-01) Provisioning Prepared**: Windows Server 2022 with dual CD-ROM drives (`Windows_Server_2022.iso` + `virtio-win.iso`), 60GB ZFS disk, 4096MB RAM, 2 cores on `vmbr1`.
- **VM 102 (APP-UBU-01) OS Installation Complete**: Ubuntu 22.04.5 LTS running at `10.10.10.20/24` on `vmbr1`, OpenSSH server active, credentials `administrator` / `Guardian@2026_$`.
- **All Master ISOs Verified in Storage**:
  - `Windows_Server_2022.iso` (4.7 GB)
  - `virtio-win.iso` (837 MB)
  - `ubuntu-22.04.5-live-server-amd64.iso` (2.0 GB)
  - `pfSense-CE-2.7.2-RELEASE-amd64.iso` (835 MB)
- **VM 101 (DC-WIN-01) Provisioned & Booted**: Windows Server 2022 installer running in Proxmox console.
- **Domain Identity Standardized to Think Polaris**:
  - AD DS Domain: `thinkpolaris.local` (NetBIOS: `THINKPOLARIS`).
  - Public Domain: `thinkpolaris.com`.
  - Service FQDNs: `glpi.thinkpolaris.local`, `wiki.thinkpolaris.local`, `zabbix.thinkpolaris.local`, `grafana.thinkpolaris.local`, `wazuh.thinkpolaris.local`.
- **VM 101 (DC-WIN-01) Active Directory Domain Promoted**:
  - Forest Root Domain: `thinkpolaris.local` (NetBIOS: `THINKPOLARIS`).
  - Core Roles Installed: Active Directory Domain Services (AD DS), Authoritative DNS Server.
  - Disaster Recovery / DSRM Password: `Guardian@2026_$`.
  - Network Binding: `vmbr1` (Internal Lab LAN `10.10.10.0/24`).
- **VM 103 (NMS-UBU-01) Provisioned & Running**: 4 Cores, 8192MB RAM, 60GB ZFS disk (`local-zfs`), `net0` on `vmbr1` (Internal Lab LAN `10.10.10.30/24`), autostart order 4.
- **VM 104 (SEC-UBU-01) Provisioned & Running**: 2 Cores, 4096MB RAM, 40GB ZFS disk (`local-zfs`), `net0` on `vmbr1` (Internal Lab LAN `10.10.10.40/24`).
- **VM 105 (BKP-WIN-01) Provisioned & Running**: 2 Cores, 4096MB RAM, 80GB ZFS disk (`local-zfs`), `net0` on `vmbr1` (Internal Lab LAN `10.10.10.50/24`), autostart order 5.
- **Phase 0 (P0 - P3) Master Infrastructure Deployment Complete**: All 6 virtual machines (VMs 100 - 105) provisioned, bound to `vmbr1` (10.10.10.0/24), and active in the Proxmox cluster inventory.
- **Phase 1: Project P4 Active Directory Scripts Configured**:
  - Organizational Units & Security Groups: `scripts/02_service_configs/active_directory/01_setup_ad_structure.ps1`.
  - User Provisioning & Intern Accounts: `scripts/02_service_configs/active_directory/02_create_sample_users.ps1`.
- **Project P4 Active Directory Hierarchy & DNS Deployed**:
  - Root OU: `OU=ThinkPolaris,DC=thinkpolaris,DC=local`.
  - Department OUs: Executive, Finance, Human Resources, Information Technology, Operations.
  - Security Groups: `SG-IT-Admins`, `SG-Finance-Staff`, `SG-HR-Staff`, `SG-Interns`.
  - DNS Forwarders: Configured upstream to `1.1.1.1` and `8.8.8.8`.
  - Reverse DNS Zone: `10.10.10.0/24` subnet reverse zone created.
  - Verification: Automated guest execution returned exitcode 0.
