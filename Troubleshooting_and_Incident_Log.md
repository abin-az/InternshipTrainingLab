# Turnkey Troubleshooting & Incident Log

> **Purpose**: A granular, permanent historical ledger of every technical error, hardware quirk, software misconfiguration, minute setting tweak, and resolution encountered during the deployment of the Think Polaris IT Internship Training Lab on Dell PowerEdge R640.
> **Turnkey Guarantee**: Enables any engineer or training institute to copy-paste solutions and replicate this exact deployment without repeating past mistakes.

---

## 🛠️ Incident & Troubleshooting Ledger

### [INC-001] Storage Backplane Drive Visibility Failure
- **Component**: Dell PowerEdge R640 / 2x Samsung 960GB SSDs (MZ7LH960).
- **Symptom**: Newly installed SSDs were completely invisible in the BIOS/Lifecycle Controller and storage inventory.
- **Root Cause**: Flea power in the backplane bus prevented the controller from initiating a fresh hardware bus rescan.
- **Resolution**:
  1. Log into iDRAC9 Web Interface.
  2. Navigate to **Virtual Console > Power Control**.
  3. Execute **Power Cycle System (Cold Boot)** to force a total power drain and Lifecycle Controller bus inventory rescan.
  4. Upon reboot, drives were properly recognized.

---

### [INC-002] Legacy Hardware RAID Blocking Proxmox Native ZFS
- **Component**: PERC H730 Mini RAID Controller.
- **Symptom**: Proxmox installer detected a virtual drive instead of raw underlying SSDs, preventing software ZFS mirroring.
- **Root Cause**: Controller was operating in "RAID Mode" with leftover Windows Server virtual disks.
- **Resolution**:
  1. Open iDRAC > **Storage > Virtual Disks** and delete all existing virtual disks.
  2. Open iDRAC > **Storage > Controllers > PERC H730 Mini > Controller Properties**.
  3. Change controller mode from **RAID Mode** to **HBA Mode**.
  4. Set apply operation to **At Next Reboot** and perform a warm restart.
  5. Raw drives `/dev/sda` and `/dev/sdb` became immediately exposed to Proxmox for native ZFS RAID-1.

---

### [INC-003] Proxmox Package Extraction Failure (`binutils-common.deb`)
- **Component**: Proxmox VE 9.2-1 Virtual Media Installer.
- **Symptom**: Graphical installation crashed midway during the extraction of `binutils-common.deb`.
- **Root Cause**: Packet loss/jitter over the iDRAC virtual media stream corrupted transient deb chunks.
- **Resolution**:
  1. Stabilized physical Ethernet link on the iDRAC management port.
  2. Rebooted system and remounted the ISO via iDRAC Virtual Media.
  3. Re-ran installer; passed to 100% completion cleanly.

---

### [INC-004] Proxmox Web GUI Connection Timeout (`ERR_CONNECTION_TIMED_OUT`)
- **Component**: Proxmox Web Management Service (Port 8006).
- **Symptom**: Browser refused to load `http://192.168.29.25:8006/`.
- **Root Cause**: Proxmox enforces strict TLS/HTTPS; plain HTTP is dropped without redirect.
- **Resolution**:
  1. Explicitly prefix URL with **`https://`**: `https://192.168.29.25:8006/`.
  2. Accept self-signed certificate warning in browser.
  3. Confirmed physical Ethernet cable seated in **Port 1 (NIC0)** of Network Daughter Card.

---

### [INC-005] Proxmox Enterprise Repository Update Block
- **Component**: Debian APT package manager on Proxmox node.
- **Symptom**: `apt update` failed with 401 Unauthorized errors on `pve-enterprise.list`.
- **Root Cause**: Default installation points to paid enterprise feeds without an active subscription key.
- **Resolution**:
  ```bash
  sed -i 's/^deb/#deb/' /etc/apt/sources.list.d/pve-enterprise.list
  echo "deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription" > /etc/apt/sources.list.d/pve-no-subscription.list
  apt update && apt dist-upgrade -y
  ```

---

### [INC-006] Network Portability Protection (`vmbr1` Isolation)
- **Component**: Virtual Linux Bridges on Proxmox.
- **Symptom / Risk**: If internal VMs were bound to `vmbr0`, moving the physical server to a new ISP/office subnet would break all VM IPs, AD domain, DNS, and internal services.
- **Root Cause**: Binding internal services to WAN-coupled physical NICs.
- **Resolution**:
  1. Created isolated internal virtual bridge `vmbr1` (no physical ports, manual IP).
  2. All lab VMs are bound strictly to `vmbr1` on `10.10.10.0/24`.
  3. pfSense WAN is attached to `vmbr0` with DHCP client, making the entire physical server 100% portable with zero internal reconfiguration on migration.
