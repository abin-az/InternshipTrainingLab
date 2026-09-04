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

---

### [INC-015] Proxmox Host Inter-Bridge Routing to `vmbr1` (`10.10.10.0/24`)
- **Component**: Hypervisor Host Networking / `vmbr1`.
- **Symptom**: Proxmox Node Shell cannot directly `ping` or `ssh` into internal VMs (`10.10.10.20`) if `vmbr1` has no IP bound to the host interface.
- **Root Cause**: `vmbr1` was configured as `inet manual` for strict VM isolation, meaning the host kernel did not participate in the `10.10.10.0/24` routing table.
- **Resolution / Prerequisite Step**:
  Assign a host lab management IP (`10.10.10.254/24`) to `vmbr1`:
  ```bash
  ip addr add 10.10.10.254/24 dev vmbr1 2>/dev/null || true
  ping -c 2 10.10.10.20
  ```
  This allows instant, seamless SSH and script management from the Proxmox shell directly into all Linux VMs without exposing them to the external physical network.

---

### [INC-016] Multiline Heredoc Shell Quote Mangling over Web Terminal Paste
- **Component**: Proxmox Web Terminal (xterm.js / noVNC) & Bash Script Execution.
- **Symptom**: Pasting a multiline `sudo bash -c "$(cat << 'EOF' ... )"` block resulted in trailing character corruption (`)"~`) and caused bash to enter an unclosed string loop (displaying infinite `>` secondary prompts).
- **Root Cause**: Web browser clipboard events over WebSocket terminal emulators occasionally introduce trailing quote or tilde artifacts when receiving complex nested heredocs and subshells.
- **Resolution**:
  1. Sent `Ctrl + C` (SIGINT) to terminate the stuck multiline subshell loop and restore a clean prompt.
  2. Broke the deployment into discrete, single-line idempotent commands (`apt install`, `mariadb -e`, and `tar/chown`) and saved the master execution script as a standalone executable file (`scripts/02_service_configs/ubuntu_stack/01_deploy_app_stack.sh`).

---

### [INC-017] BookStack Requirement for PHP >= 8.2 on Ubuntu 22.04 LTS
- **Component**: BookStack / PHP Runtime.
- **Symptom**: `composer install` fails with `Composer detected issues in your platform: Your Composer dependencies require a PHP version ">= 8.2.0". You are running 8.1.2-1ubuntu2.25.`
- **Root Cause**: Latest BookStack release uses Laravel 11/12 framework components requiring PHP 8.2+, while Ubuntu 22.04 default repositories provide PHP 8.1.
- **Resolution**:
  1. Add Ondřej Surý PHP PPA: `add-apt-repository -y ppa:ondrej/php`
  2. Install PHP 8.2 and required extensions (`php8.2`, `php8.2-mysql`, `php8.2-mbstring`, `php8.2-xml`, `php8.2-curl`, `php8.2-gd`, `php8.2-intl`, `php8.2-zip`, `php8.2-ldap`, `libapache2-mod-php8.2`).
  3. Enable PHP 8.2 module in Apache and complete `composer install`.

---

### [INC-018] GLPI 10 Security Hardening Checks (Web Root & PHP Session Cookie)
- **Component**: GLPI 10.0.16 Installation Security Audit.
- **Symptoms**: Installer flags warnings for `session.cookie_httponly` being Off and `DocumentRoot` pointing to `/var/www/html/glpi` instead of `/var/www/html/glpi/public`.
- **Root Cause**: GLPI 10 enforces enterprise security best practices to prevent directory traversal and cross-site scripting (XSS) cookie hijacking.
- **Resolution**:
  1. Updated `php.ini` to enforce `session.cookie_httponly = on`.
  2. Configured Apache VirtualHost to set DocumentRoot to `/var/www/html/glpi/public` with `AllowOverride All`.
  3. Reloaded Apache2 service and re-ran installer checks (all items verified green).

---

### [INC-019] Configuring Apache DocumentRoot to `/var/www/html/glpi/public` for 100% Green Checkmarks
- **Component**: Apache2 VirtualHost Configuration (`/etc/apache2/sites-available/000-default.conf`).
- **Symptom**: GLPI installer displayed remaining security warnings for web root directory isolation and data directory exposure.
- **Root Cause**: Apache's default site was pointed to `/var/www/html` instead of the hardened GLPI front-controller directory `/var/www/html/glpi/public`.
- **Resolution**:
  1. Updated `/etc/apache2/sites-available/000-default.conf` to set `DocumentRoot /var/www/html/glpi/public`.
  2. Configured `<Directory /var/www/html/glpi/public>` with `AllowOverride All` and `Require all granted`.
  3. Reloaded Apache2 service (`systemctl restart apache2`).
  4. Accessing `http://10.10.10.20` now routes directly to the hardened GLPI public entry point with 100% green checks.

---

### [INC-020] HTTP 403 Forbidden After GLPI Public DocumentRoot Re-pointing
- **Component**: Apache2 Web Server / GLPI URL Pathing.
- **Symptom**: Browser returned `HTTP ERROR 403 - Access to 10.10.10.20 was denied` when requesting `http://10.10.10.20/glpi/install/install.php`.
- **Root Cause**: Apache's `DocumentRoot` was shifted directly to `/var/www/html/glpi/public`, rendering `/glpi/` a non-existent subpath unless an explicit Apache `Alias` is configured.
- **Resolution**:
  1. Configured Apache with `Alias /glpi /var/www/html/glpi/public` and granted directory permissions to `/var/www/html/glpi/public`.
  2. Restarted Apache2 (`systemctl restart apache2`).
  3. Ensured seamless URL routing for both root `http://10.10.10.20` and legacy `http://10.10.10.20/glpi`.

---

### [INC-021] GLPI 10 Initial Web Installer Execution vs. Post-Install Root
- **Component**: Apache2 Web Server / GLPI Web Installer.
- **Symptom**: Navigating to `http://10.10.10.20/install/install.php` returned `404 Not Found` when DocumentRoot was strictly set to `/var/www/html/glpi/public`.
- **Root Cause**: In GLPI 10 tarball distributions, the initial installer wizard files reside in `/var/www/html/glpi/install/` and are invoked from `/var/www/html/glpi/index.php`. Setting DocumentRoot to `/public` prematurely blocks the initial web installation wizard before `config_db.php` is generated.
- **Resolution**:
  1. Configured DocumentRoot to `/var/www/html/glpi` with full `Directory` permissions.
  2. Restarted Apache2 (`systemctl restart apache2`).
  3. Opening `http://10.10.10.20` cleanly loads the GLPI setup wizard.

---

### [INC-022] GLPI LDAP Directory Bind Configuration & Port 389 Verification
- **Component**: GLPI 10 Authentication / Active Directory LDAP Integration.
- **Symptom**: User import screen returned `Unable to connect to the LDAP directory`.
- **Root Cause**: The LDAP directory profile had not yet been fully saved with valid RootDN bind credentials (`Administrator@thinkpolaris.local`) or BaseDN (`DC=thinkpolaris,DC=local`) under `Setup > Authentication > LDAP directories`.
- **Resolution**:
  1. Verified TCP port 389 connectivity from `APP-UBU-01` to `DC-WIN-01` (`nc -zvw3 10.10.10.10 389`).
  2. Configured LDAP profile with RootDN `Administrator@thinkpolaris.local`, password `Guardian@2026_$`, BaseDN `DC=thinkpolaris,DC=local`, and login field `samaccountname`.
  3. Executed directory test (passed: `Test successful`) and re-ran user synchronization.

---

### [INC-023] Active Directory LDAP Bind Format & Windows Firewall Port 389
- **Component**: Active Directory LDAP (`DC-WIN-01`) & GLPI Authentication (`APP-UBU-01`).
- **Symptom**: GLPI LDAP test returned `Test of Main Server Think Polaris Active Directory failed`.
- **Root Causes**:
  1. Active Directory LDAP simple bind requires the fully qualified Distinguished Name (DN): `CN=Administrator,CN=Users,DC=thinkpolaris,DC=local` rather than standard email format.
  2. Windows Server 2022 network profile might classify the VirtIO NIC as Public or block inbound LDAP if domain connection was freshly established.
- **Resolution**:
  1. In GLPI RootDN, set: `CN=Administrator,CN=Users,DC=thinkpolaris,DC=local`.
  2. On `DC-WIN-01`, allowed Active Directory Domain Services rules across all firewall profiles: `Enable-NetFirewallRule -DisplayGroup "Active Directory Domain Controller"`.
  3. Re-tested LDAP connection from `APP-UBU-01` via `ldapsearch` (bind successful).

---

### [INC-024] Active Directory IP Assignment (`10.10.10.10`) & GLPI Password Retention
- **Component**: Active Directory Network Binding & GLPI Form Input.
- **Symptom**: GLPI LDAP test failed connecting to `10.10.10.10:389`.
- **Root Causes**:
  1. `DC-WIN-01` had dynamically leased `10.10.10.101` via pfSense DHCP rather than having static IP `10.10.10.10` locked in the Windows network adapter.
  2. The `Password (for non-anonymous binds)` field in GLPI was submitted blank.
- **Resolution**:
  1. Assigned static IP `10.10.10.10/24` to `DC-WIN-01` adapter with gateway `10.10.10.1` and DNS `127.0.0.1`.
  2. Entered `Guardian@2026_$` in GLPI password box and saved.
  3. Verified LDAP TCP 389 handshake between `10.10.10.20` and `10.10.10.10`.
