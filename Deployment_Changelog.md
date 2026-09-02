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
