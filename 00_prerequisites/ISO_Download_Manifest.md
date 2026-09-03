# Proxmox ISO Catalog & Technical Selection Rationale

> **Purpose**: Authoritative registry of all operating system installer images, hypervisor driver packages, and their technical justifications for the Think Polaris IT Internship Training Lab.

---

## 💽 ISO Registry & In-Depth Technical Justification

### 1. `virtio-win.iso` (VirtIO Paravirtualized Windows Drivers)
- **What It Is**: Red Hat / Fedora official paravirtualized driver ISO for Windows operating systems running on Linux KVM / QEMU.
- **Why We Need It**:
  1. **Storage Visibility**: Proxmox uses high-performance `VirtIO SCSI single` storage controllers with SSD TRIM/discard support. The stock Windows Server installer does NOT include native VirtIO SCSI drivers. Without this ISO attached during installation, Windows Setup displays: *"We couldn't find any drives"*.
  2. **Network Performance**: Windows standard emulated Intel `e1000` NICs have high CPU overhead and throughput limits. The VirtIO `NetKVM` driver provides 10Gbps+ near-native wire-speed throughput on `vmbr1`.
  3. **Guest Management**: Provides the **QEMU Guest Agent** (`qemu-ga-x64.msi`), allowing Proxmox to execute graceful ACPI shutdowns, freeze filesystems during snapshots/backups, and display real-time VM IP addresses in the Proxmox GUI.
- **How We Use It**:
  - Mounted as secondary CD-ROM (`ide0`) on VM 101 (`DC-WIN-01`) and VM 105 (`BKP-WIN-01`).
  - During Windows Setup partition screen, click **Load Driver** > Browse to `CD Drive (E:) virtio-win` > `amd64\2k22` to load the storage driver (`vioscsi.inf`).
  - Once Windows boots, run `E:\virtio-win-guest-tools.exe` to install all network, ballooning, and guest agent services in one click.

---

### 2. `pfSense-CE-2.7.2-RELEASE-amd64.iso` (pfSense Community Edition)
- **What It Is**: Enterprise-grade open-source FreeBSD-based firewall and routing platform.
- **Why We Need It**:
  1. **Enterprise Boundary Defense**: Students learn real-world firewall concepts: Stateful Packet Inspection (SPI), NAT, port forwarding, alias management, and network segregation.
  2. **Network Portability Guardrail**: pfSense acts as the single boundary between the outside physical world (`vmbr0`) and the lab (`vmbr1`). Its WAN interface uses dynamic DHCP, enabling the entire physical Dell R640 server to move to any new network location with zero internal reconfigurations.
- **How We Use It**:
  - Installed on VM 100 (`FW-PFSENSE-01`).
  - `vtnet0` assigned to `vmbr0` (WAN uplink).
  - `vtnet1` assigned to `vmbr1` (Internal Lab Gateway `10.10.10.1/24`).

---

### 3. `ubuntu-22.04.5-live-server-amd64.iso` (Ubuntu Server LTS)
- **What It Is**: Long-Term Support enterprise Linux server distribution backed by Canonical.
- **Why We Need It**:
  1. **Industry Standard Linux**: Over 70% of enterprise web and cloud workloads run on Debian/Ubuntu Linux. Interns must master Linux CLI navigation, systemd services, SSH key management, cron automation, and package management (`apt`).
  2. **Open-Source Software Ecosystem**: Ubuntu Server provides native, battle-tested support and upstream repositories for the lab's core open-source platforms (MariaDB, GLPI, BookStack, Zabbix, Prometheus, Grafana, Wazuh SIEM, OpenVAS).
- **How We Use It**:
  - **VM 102 (`APP-UBU-01`)**: Hosts the LAMP stack, MariaDB relational database backend, GLPI ITIL ticketing, and BookStack documentation portal (`10.10.10.20`).
  - **VM 103 (`NMS-UBU-01`)**: Dedicated Network Monitoring & SIEM host running Zabbix Server, Prometheus time-series collector, Grafana visualization dashboards, and the Wazuh security analysis manager (`10.10.10.30`).
  - **VM 104 (`SEC-UBU-01`)**: Isolated cybersecurity testing node running Greenbone/OpenVAS vulnerability scanner and the Damn Vulnerable Web App (DVWA) practice target (`10.10.10.40`).

---

### 4. `Windows_Server_2022.iso` (Windows Server 2022)
- **What It Is**: Microsoft's enterprise server operating system.
- **Why We Need It**:
  1. **Active Directory & Enterprise Identity**: Over 90% of Fortune 500 enterprises rely on Active Directory Domain Services (AD DS) for centralized identity, Kerberos authentication, and Group Policy Management (GPO).
  2. **Enterprise Infrastructure Roles**: Acts as the authoritative internal DNS server (`10.10.10.10`), Windows Server Update Services (WSUS) patch server, and file/print server.
  3. **Disaster Recovery Ecosystem**: Hosts the Veeam Backup & Replication console, which requires Windows Server for native Volume Shadow Copy Service (VSS) coordination and synthetic full backup processing.
- **How We Use It**:
  - **VM 101 (`DC-WIN-01`)**: Primary Domain Controller for `apex.local`, DNS Master, DHCP Scope Provider, and WSUS Patch Manager (`10.10.10.10`).
  - **VM 105 (`BKP-WIN-01`)**: Standalone enterprise backup server running Veeam Backup & Replication Community Edition (`10.10.10.50`).

---

## ⚡ Master Download Commands (Proxmox Shell)

```bash
cd /var/lib/vz/template/iso

# 1. Download VirtIO Windows Drivers ISO
wget -c -O virtio-win.iso "https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso"

# 2. Download Ubuntu 22.04.5 LTS Server ISO
wget -c "https://releases.ubuntu.com/jammy/ubuntu-22.04.5-live-server-amd64.iso"

# 3. Download pfSense 2.7.2 CE ISO
wget -c "https://atxfiles.netgate.com/mirror/downloads/pfSense-CE-2.7.2-RELEASE-amd64.iso.gz" && gunzip -f "pfSense-CE-2.7.2-RELEASE-amd64.iso.gz"

# List ISO Directory
ls -lh /var/lib/vz/template/iso
```
