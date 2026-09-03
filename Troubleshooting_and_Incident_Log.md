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

---

### [INC-007] Proxmox Host DNS Resolution Failure
- **Component**: Proxmox VE Host Network / `/etc/resolv.conf`.
- **Symptom**: `wget` and `apt` failed with `Name or service not known` / `unable to resolve host address`.
- **Root Cause**: The local gateway `192.168.29.1` was not proxying upstream DNS queries properly.
- **Resolution**:
  ```bash
  cat << 'EOF' > /etc/resolv.conf
  nameserver 1.1.1.1
  nameserver 8.8.8.8
  EOF
  ```
  Verified resolution via `ping -c 2 google.com` (0% packet loss).

---

### [INC-008] pfSense Download Mirror Hostname Deprecation
- **Component**: Netgate ISO Mirror Repository.
- **Symptom**: `wget https://nyifiles.netgate.com/...` failed with `Name or service not known`.
- **Root Cause**: Netgate retired the New York mirror (`nyifiles.netgate.com`) in favor of the active Austin mirror (`atxfiles.netgate.com`).
- **Resolution**:
  Used the active official direct mirror URL:
  `https://atxfiles.netgate.com/mirror/downloads/pfSense-CE-2.7.2-RELEASE-amd64.iso.gz`

---

### [INC-009] Bash Semicolon Parsing in Proxmox `qm --boot` Parameter
- **Component**: Proxmox CLI (`qm create` / `qm set`).
- **Symptom**: Proxmox created the VM disk but bash returned `-bash: ide2: command not found`.
- **Root Cause**: The unquoted semicolon in `--boot order=scsi0;ide2;net0` was interpreted by bash as a shell command delimiter, truncating the rest of the flags.
- **Resolution**:
  Quotes are strictly required for the boot order flag: `--boot "order=ide2;scsi0"`.
  Attached the remaining network interfaces and flags using `qm set 100 ...`.

---

### [INC-010] Proxmox Reporting ~100% Memory Usage on Fresh Windows VMs
- **Component**: Proxmox VE Web GUI / QEMU Memory Reporting.
- **Symptom**: Proxmox Summary page displays `Memory usage 101.19% (4.05 GiB of 4.00 GiB)` and `IPs: Guest Agent not running`.
- **Root Cause**: Without the **QEMU Guest Agent** and **VirtIO Balloon Driver** running inside the Windows guest OS, the hypervisor cannot read inside the guest memory table. It reports the entire allocated memory block (4.00 GB) plus QEMU process runtime overhead (~50 MB) as "active".
- **Resolution**:
  1. Log into Windows Server on VM 101.
  2. Open Explorer > `CD Drive (E:) virtio-win`.
  3. Run `virtio-win-gt-x64.exe` to install the `QEMU-GA` service and `BLN` ballooning driver.
  4. Once the service starts, Proxmox receives real-time telemetry from inside the OS, memory usage display drops to true value (~30-40%), and the VM's static IP is displayed in the GUI.

---

### [INC-011] Proxmox noVNC Clipboard Limitation & GUI Alternative
- **Component**: Proxmox VE Web Console (noVNC).
- **Symptom**: Pressing `Ctrl + V` inside the browser noVNC canvas does not paste clipboard text from the host into Windows PowerShell.
- **Root Cause**: Web browser security prevents raw JavaScript clipboard injection into the virtual canvas without using the noVNC clipboard bridge or RDP/SSH.
- **Resolution**:
  - **Option 1**: Use noVNC slide-out left sidebar (`>`) clipboard tool to inject text.
  - **Option 2**: Use native Windows Server Manager GUI wizard (**Add Roles and Features > Active Directory Domain Services > Promote to Domain Controller > Add New Forest: `thinkpolaris.local`**).

---

### [INC-012] Complete Guide to Host-to-VM Clipboard & Remote Administration
- **Component**: Hypervisor Management & VM Administration.
- **Problem**: How to paste commands, scripts, and configuration blocks from a physical administrator laptop into Proxmox VMs without manual typing.
- **Solutions & Industry Standard Workflows**:

#### 1. Built-in noVNC Clipboard Bridge (Web Console)
1. In the Proxmox VM Console window, hover over the **far left edge of the screen** and click the small **`>`** pull-out tab.
2. Click the **Clipboard icon (📋)**.
3. Paste text into the noVNC clipboard text area.
4. Click inside the guest OS terminal and press **`Ctrl + V`** (or right-click).

#### 2. Native Windows Remote Desktop (RDP - `mstsc.exe`)
- **Enterprise Standard for Windows VMs**: Enable Remote Desktop in Windows Settings.
- Open `mstsc.exe` on physical laptop > connect to `10.10.10.10`.
- Native bidirectional clipboard is enabled automatically.

#### 3. Native SSH / Terminal Remoting (For Linux & Windows)
- Open PowerShell / Terminal on physical laptop:
  ```bash
  ssh administrator@10.10.10.20
  ```
- Instant copy-paste and script streaming.

#### 4. QEMU Guest Agent Remote Execution (`qm guest exec`)
- Execute scripts inside any guest VM directly from the Proxmox Node Shell:
  ```bash
  qm guest exec 101 -- powershell.exe -Command "Get-Service"
  ```

---

### [INC-013] Enabling Seamless Bidirectional Clipboard Between Host PC and Proxmox VMs
- **Problem**: Default noVNC browser console does not provide seamless desktop clipboard synchronization (copy on host -> paste in VM).
- **Turnkey Solutions**:

#### Solution 1: Remote Desktop (RDP) via pfSense Port Forward (Recommended)
1. Enable Remote Desktop on Windows VM (`DC-WIN-01`):
   - Server Manager > Local Server > Remote Desktop: **Enabled**.
2. Add a Port Forward rule in pfSense WebGUI (`https://192.168.29.47`):
   - **Firewall > NAT > Port Forward**:
     - Interface: `WAN`
     - Protocol: `TCP`
     - Destination Port: `3389`
     - Redirect Target IP: `10.10.10.10`
     - Redirect Target Port: `3389`
3. On physical laptop, open `mstsc.exe` and connect to `192.168.29.47:3389`.
4. Result: 100% native copy-paste of text, scripts, and files.

#### Solution 2: SPICE Display Engine with Virt-Viewer
1. In Proxmox GUI > VM 101 > **Hardware > Display**: Set to **`SPICE (qxl)`**.
2. Install Virt-Viewer on Windows host:
   ```powershell
   winget install RedHat.VirtViewer
   ```
3. In Proxmox GUI, click **Console > SPICE**.
4. Opens in a native desktop window with automatic bidirectional clipboard integration.

---

### [INC-014] QEMU Guest Agent Service Inactive Post-Domain Promotion
- **Component**: Windows Server 2022 Guest Services (`DC-WIN-01`).
- **Symptom**: `qm guest exec 101` returns `QEMU guest agent is not running`.
- **Root Cause**: The `QEMU Guest Agent` Windows service was either not yet installed via `virtio-win-gt-x64.exe` or was in stopped state following the root domain controller promotion reboot.
- **Resolution**:
  1. Log into Windows Server on `DC-WIN-01` (`THINKPOLARIS\Administrator`).
  2. Open Explorer > `CD Drive (E:) virtio-win` > run `virtio-win-gt-x64.exe` (or `guest-agent\qemu-ga-x86_64.msi`).
  3. Ensure the `QEMU Guest Agent` service is running in `services.msc`.
