# IT Internship Training Program - Master Runbook

> **Note:** This is the complete offline manual. It contains all project frameworks, task lists, and step-by-step guides.

## 1. Project Framework

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


## 2. Prerequisites & ISO Downloads

# ISO Download & Prerequisites Guide

> **Purpose**: Download all required installation media and prepare your storage directories before beginning the lab build.

---

## Step 1: Prepare Storage Directories

Create the following folders on your D: drive:

```powershell
mkdir D:\LabVMs
mkdir D:\LabISOs
```

- `D:\LabVMs\` — All VirtualBox VM files will be stored here
- `D:\LabISOs\` — All downloaded ISO files go here

---

## Step 2: Download Required ISOs

### 2.1 VirtualBox 7.x
- **URL**: https://www.virtualbox.org/wiki/Downloads
- **File**: `VirtualBox-7.x.x-Win.exe` (~170 MB)
- **Also download**: VirtualBox Extension Pack (same page, ~20 MB)

### 2.2 Windows Server 2022 Evaluation
- **URL**: https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2022
- **File**: ISO (~5 GB)
- **Note**: Evaluation is free for 180 days. Select "ISO" format, 64-bit.

### 2.3 Ubuntu Server 22.04 LTS
- **URL**: https://releases.ubuntu.com/22.04/
- **File**: `ubuntu-22.04.x-live-server-amd64.iso` (~1.4 GB)
- **Note**: Download the "Server" version, NOT Desktop.

### 2.4 pfSense CE
- **URL**: https://www.pfsense.org/download/
- **File**: AMD64, ISO, (~900 MB)
- **Note**: Select Architecture: AMD64, Installer: ISO, Mirror: closest to you.

### 2.5 Windows 10/11 Evaluation
- **URL**: https://www.microsoft.com/en-us/evalcenter/evaluate-windows-10-enterprise
- **File**: ISO (~5 GB)
- **Note**: 90-day evaluation. Select "ISO" format, 64-bit, English.

---

## Step 3: Verify Downloads

After downloading, verify you have these files in `D:\LabISOs\`:

```
D:\LabISOs\
├── VirtualBox-7.x.x-Win.exe
├── Oracle_VirtualBox_Extension_Pack-7.x.x.vbox-extpack
├── WindowsServer2022.iso (or similar name)
├── ubuntu-22.04.x-live-server-amd64.iso
├── pfSense-CE-x.x.x-amd64.iso
└── Windows10or11.iso
```

---

## Step 4: Check Available Disk Space

Open PowerShell and run:

```powershell
Get-PSDrive D | Select-Object Used, Free
```

You need at least **240 GB free** on D: to comfortably host all VMs:
- pfSense: 8 GB
- Windows Server: 40 GB
- Ubuntu Server: 30 GB
- Windows 10 Client: 30 GB
- Snapshots & growth: ~130 GB buffer

---

## ✅ Checklist

- [ ] Created `D:\LabVMs\` directory
- [ ] Created `D:\LabISOs\` directory
- [ ] Downloaded VirtualBox installer
- [ ] Downloaded VirtualBox Extension Pack
- [ ] Downloaded Windows Server 2022 ISO
- [ ] Downloaded Ubuntu Server 22.04 ISO
- [ ] Downloaded pfSense CE ISO
- [ ] Downloaded Windows 10/11 ISO
- [ ] Verified 240+ GB free on D: drive


## 3. Sprint 1: Foundation

### 01_virtualbox_setup.md

# Sprint 1, Guide 1: VirtualBox Setup

> **Time**: ~30 minutes | **Difficulty**: Beginner
> **Goal**: Install VirtualBox 7.x and configure it for the lab environment.

---

## Step 1: Install VirtualBox

1. Navigate to `D:\LabISOs\` and double-click `VirtualBox-7.x.x-Win.exe`.
2. Click **Next** through the installer. Accept all defaults.
3. You may see a warning about network interfaces being reset — click **Yes** to proceed.
4. Click **Install**, then **Finish**.

> ⚠️ **Note**: If Windows Defender SmartScreen blocks the installer, click "More info" → "Run anyway".

---

## Step 2: Install the Extension Pack

1. Open VirtualBox.
2. Go to **File → Tools → Extension Pack Manager** (or **File → Preferences → Extensions** in older UI).
3. Click the **+** icon and browse to `D:\LabISOs\Oracle_VirtualBox_Extension_Pack-7.x.x.vbox-extpack`.
4. Click **Install**, scroll down the license, click **I Agree**.
5. Verify it shows as "Active" in the list.

> 📝 The Extension Pack adds USB 2.0/3.0 support, VirtualBox RDP, and PXE boot — all useful for our lab.

---

## Step 3: Configure Default VM Storage Path

By default, VirtualBox stores VMs on your C: drive. We need to change this to D: to save space.

1. Go to **File → Preferences → General**.
2. Change **Default Machine Folder** to: `D:\LabVMs`
3. Click **OK**.

---

## Step 4: Create the Internal Network

All our lab VMs will communicate on a private internal network.

1. Go to **File → Tools → Network Manager**.
2. Click the **Host-Only Networks** tab.
3. Note: We will NOT use Host-Only for our lab. Instead, we will use VirtualBox's **Internal Network** feature (configured per-VM in their network adapter settings). The network name will be `intnet-lab`.

> 📝 **Network Design**:
> - **Adapter 1 (pfSense only)**: NAT — gives pfSense internet access
> - **Adapter 2 (pfSense)**: Internal Network (`intnet-lab`) — pfSense's LAN side
> - **All other VMs**: Internal Network (`intnet-lab`) — they reach the internet via pfSense

---

## Step 5: Verify Installation

1. Open VirtualBox Manager.
2. Confirm the version shows 7.x.x in the title bar.
3. Go to **File → Preferences → General** and verify the default path is `D:\LabVMs`.
4. Go to **File → Tools → Extension Pack Manager** and verify the Extension Pack is Active.

---

## ✅ Checklist

- [ ] VirtualBox 7.x installed
- [ ] Extension Pack installed and active
- [ ] Default VM folder changed to `D:\LabVMs`
- [ ] Understand the `intnet-lab` internal network concept

---

## 📸 Screenshots to Capture
1. VirtualBox Manager main window (showing version)
2. Extension Pack Manager showing "Active"
3. Preferences → General showing `D:\LabVMs`

**Next Guide**: [02_pfsense_setup.md](./02_pfsense_setup.md) — Creating and configuring the pfSense firewall VM.


---

### 02_pfsense_setup.md

# Sprint 1, Guide 2: pfSense Firewall Setup

> **Time**: ~45 minutes | **Difficulty**: Intermediate
> **Goal**: Deploy pfSense as the NAT gateway/firewall for the entire lab network.

---

## Step 1: Create the pfSense VM

1. Open VirtualBox → Click **New**.
2. Configure:
   - **Name**: `pfSense`
   - **Folder**: `D:\LabVMs` (should auto-fill)
   - **Type**: BSD
   - **Version**: FreeBSD (64-bit)
3. Click **Next**.
4. **Memory**: 512 MB
5. **Hard Disk**: Create a virtual hard disk now → VDI → Dynamically allocated → **8 GB**
6. Click **Create**.

---

## Step 2: Configure Network Adapters

This is the most critical step. pfSense needs TWO network adapters:

1. Right-click the `pfSense` VM → **Settings → Network**.

**Adapter 1 (WAN — Internet Access)**:
- ✅ Enable Network Adapter
- Attached to: **NAT**

**Adapter 2 (LAN — Internal Lab Network)**:
- Click the **Adapter 2** tab
- ✅ Enable Network Adapter
- Attached to: **Internal Network**
- Name: `intnet-lab`

2. Click **OK**.

> 📝 **Why two adapters?**
> - Adapter 1 (NAT) = pfSense's WAN port. It gets internet from your laptop.
> - Adapter 2 (Internal) = pfSense's LAN port. All other VMs connect here.
> - pfSense will route traffic from LAN → WAN, giving all VMs internet access.

---

## Step 3: Mount the ISO and Boot

1. Right-click `pfSense` VM → **Settings → Storage**.
2. Click the **Empty** CD icon under Controller: IDE.
3. Click the CD icon on the right → **Choose a disk file**.
4. Browse to `D:\LabISOs\pfSense-CE-x.x.x-amd64.iso`.
5. Click **OK**.
6. Click **Start** to boot the VM.

---

## Step 4: Install pfSense

1. Wait for the pfSense boot menu → Press **Enter** to accept defaults (or wait for auto-boot).
2. Select **Install pfSense** → Press Enter.
3. Select **Continue with default keymap**.
4. Select **Auto (ZFS)** or **Auto (UFS)** for guided disk setup.
5. Select the virtual disk → Confirm.
6. Wait for installation to complete.
7. Select **No** when asked about manual configuration.
8. Select **Reboot**.

> ⚠️ **Important**: After reboot, unmount the ISO!
> Go to **Devices → Optical Drives → Remove disk from virtual drive** while the VM is running, or it will boot from the ISO again.

---

## Step 5: Configure pfSense Interfaces

After the first boot, pfSense will auto-detect the two network interfaces:

1. It will ask: **Should VLANs be set up now?** → Type `n`, press Enter.
2. **Enter the WAN interface name**: It will show two interfaces (e.g., `em0`, `em1`). The WAN interface is typically `em0` (the NAT adapter). Type `em0`, press Enter.
3. **Enter the LAN interface name**: Type `em1`, press Enter.
4. **Do you want to proceed?** → Type `y`, press Enter.

---

## Step 6: Configure LAN IP Address

After interfaces are assigned, you'll see the pfSense menu. The WAN should auto-configure via DHCP (NAT).

Now configure the LAN:

1. From the pfSense menu, select option **2** (Set interface(s) IP address).
2. Select **2** for LAN.
3. **Enter the new LAN IPv4 address**: `10.10.10.1`
4. **Enter the new LAN subnet bit count**: `24`
5. **Enter the new LAN IPv4 upstream gateway**: Press Enter (leave blank for LAN).
6. **Enter the new LAN IPv6 address**: Press Enter (skip).
7. **Do you want to enable the DHCP server on LAN?**: Type `n` (we'll use Windows Server DHCP).
8. **Do you want to revert to HTTP?**: Type `n` (keep HTTPS).

---

## Step 7: Verify Connectivity

From the pfSense console menu:

1. Select option **7** (Ping host).
2. Ping `8.8.8.8` — This should succeed (internet via WAN).
3. Ping `10.10.10.1` — This should succeed (LAN interface).

> 📝 **pfSense Web UI**: You can access the pfSense web interface from any VM on the LAN at `https://10.10.10.1`. Default login: `admin` / `pfsense`.

---

## ✅ Checklist

- [ ] pfSense VM created (512 MB RAM, 8 GB disk)
- [ ] Adapter 1: NAT (WAN)
- [ ] Adapter 2: Internal Network `intnet-lab` (LAN)
- [ ] pfSense installed from ISO
- [ ] ISO unmounted after installation
- [ ] WAN interface assigned (em0) — gets IP via DHCP
- [ ] LAN interface configured: 10.10.10.1/24
- [ ] LAN DHCP disabled (Windows Server will handle DHCP)
- [ ] Ping 8.8.8.8 succeeds from pfSense console
- [ ] Ping 10.10.10.1 succeeds from pfSense console

---

## 📸 Screenshots to Capture
1. VM settings showing both network adapters
2. pfSense console after boot (showing WAN and LAN IPs)
3. Successful ping to 8.8.8.8

**Next Guide**: [03_windows_server_setup.md](./03_windows_server_setup.md) — Deploying Windows Server 2022 with Active Directory.


---

### 03_windows_server_setup.md

# Sprint 1, Guide 3: Windows Server 2022 + Active Directory Setup

> **Time**: ~60 minutes | **Difficulty**: Intermediate
> **Goal**: Deploy Windows Server 2022, install Active Directory Domain Services, and configure DNS + DHCP.

---

## Step 1: Create the Windows Server VM

1. Open VirtualBox → Click **New**.
2. Configure:
   - **Name**: `WinServer2022`
   - **Folder**: `D:\LabVMs`
   - **Type**: Microsoft Windows
   - **Version**: Windows 2022 (64-bit)
3. Click **Next**.
4. **Memory**: 3072 MB (3 GB)
5. **Hard Disk**: Create a virtual hard disk now → VDI → Dynamically allocated → **40 GB**
6. Click **Create**.

---

## Step 2: Configure Network Adapter

1. Right-click the `WinServer2022` VM → **Settings → Network**.
2. **Adapter 1**:
   - ✅ Enable Network Adapter
   - Attached to: **Internal Network**
   - Name: `intnet-lab`
3. Click **OK**.

> 📝 Unlike pfSense, this VM only has ONE adapter on the internal network. It reaches the internet via pfSense (10.10.10.1).

---

## Step 3: Mount ISO and Install Windows Server

1. **Settings → Storage** → Click Empty CD → Choose `D:\LabISOs\WindowsServer2022.iso`.
2. Click **Start** to boot.
3. Select language, click **Install Now**.
4. Select **Windows Server 2022 Standard Evaluation (Desktop Experience)**.
5. Accept license terms.
6. Select **Custom: Install Windows only**.
7. Select the 40 GB drive → Click **Next**.
8. Wait for installation to complete. The VM will reboot.
9. Set the **Administrator password** (e.g., `P@ssw0rd123!`).

> ⚠️ **Remember this password!** You'll need it for everything.

---

## Step 4: Set Static IP Address

After logging in as Administrator:

1. Open **Settings → Network & Internet → Ethernet → Change adapter options**.
2. Right-click the Ethernet adapter → **Properties**.
3. Select **Internet Protocol Version 4 (TCP/IPv4)** → Click **Properties**.
4. Select **Use the following IP address**:
   - **IP address**: `10.10.10.10`
   - **Subnet mask**: `255.255.255.0`
   - **Default gateway**: `10.10.10.1` (pfSense LAN)
5. Select **Use the following DNS server addresses**:
   - **Preferred DNS**: `127.0.0.1` (itself, once DNS is installed)
   - **Alternate DNS**: `10.10.10.1` (pfSense for fallback)
6. Click **OK** → **Close**.

### Verify Connectivity

Open **Command Prompt** (or PowerShell) and run:

```cmd
ping 10.10.10.1
ping 8.8.8.8
```

Both should succeed. If `8.8.8.8` fails, check that pfSense is running and the gateway is set to `10.10.10.1`.

---

## Step 5: Rename the Server

1. Open **Server Manager** (should open automatically).
2. Click **Local Server** on the left.
3. Click the computer name (e.g., `WIN-XXXXXXX`).
4. Click **Change** → Set Computer name to: `DC01`
5. Click **OK** → **Restart Now**.

---

## Step 6: Install Active Directory Domain Services

After reboot, log back in as Administrator:

1. Open **Server Manager → Dashboard**.
2. Click **Add Roles and Features**.
3. Click **Next** through the wizard until you reach **Server Roles**.
4. Check ✅ **Active Directory Domain Services**.
5. Click **Add Features** in the popup.
6. Click **Next → Next → Next → Install**.
7. Wait for installation to complete.

---

## Step 7: Promote to Domain Controller

1. In Server Manager, click the ⚠️ notification flag (top right).
2. Click **Promote this server to a domain controller**.
3. Select **Add a new forest**.
4. **Root domain name**: `apex.local`
5. Click **Next**.
6. **Forest/Domain functional level**: Windows Server 2016 (default is fine).
7. ✅ DNS Server (should be checked).
8. Set **DSRM password**: `P@ssw0rd123!`
9. Click **Next** through all remaining screens (ignore the DNS delegation warning).
10. Click **Install**.
11. The server will automatically reboot.

> 📝 After reboot, log in as: `APEX\Administrator` with your password.

---

## Step 8: Verify Active Directory

After reboot:

1. Open **Server Manager → Tools → Active Directory Users and Computers**.
2. Expand `apex.local` — you should see the default OUs (Computers, Domain Controllers, Users, etc.).
3. Open **Server Manager → Tools → DNS Manager**.
4. Expand **Forward Lookup Zones** → You should see `apex.local`.

---

## Step 9: Configure DNS Forward Lookup Zone

The zone should already exist from the AD DS promotion. Verify:

1. In **DNS Manager**, expand `DC01 → Forward Lookup Zones → apex.local`.
2. You should see:
   - `(same as parent folder)` — A record for DC01
   - `_msdcs` subfolder
   - `_sites`, `_tcp`, `_udp` subfolders

If you want to add custom records later (e.g., for GLPI), right-click `apex.local` → **New Host (A or AAAA)**:
- Name: `glpi`
- IP: `10.10.10.20`

---

## Step 10: Configure DHCP Server

1. Open **Server Manager → Add Roles and Features**.
2. Check ✅ **DHCP Server** → Add Features → Install.
3. After install, click the notification flag → **Complete DHCP configuration** → Commit.

### Create DHCP Scope

1. Open **Server Manager → Tools → DHCP**.
2. Expand `dc01.apex.local → IPv4`.
3. Right-click **IPv4** → **New Scope**.
4. **Name**: `Lab-Scope`
5. **Start IP**: `10.10.10.100`
6. **End IP**: `10.10.10.200`
7. **Subnet mask**: `255.255.255.0`
8. **Exclusions**: None needed for now.
9. **Lease duration**: 8 days (default is fine).
10. **Configure DHCP Options**: Yes
    - **Router (Default Gateway)**: `10.10.10.1`
    - **DNS Server**: `10.10.10.10`
    - **Domain Name**: `apex.local`
11. **Activate scope**: Yes
12. Click **Finish**.

---

## Step 11: Final Verification

Run these commands in PowerShell on the Windows Server:

```powershell
# Check AD DS
Get-ADDomain

# Check DNS
Resolve-DnsName apex.local

# Check DHCP scope
Get-DhcpServerv4Scope

# Check network
ipconfig /all
ping 10.10.10.1
ping 8.8.8.8
nslookup apex.local
```

All commands should return valid results.

---

## ✅ Checklist

- [ ] Windows Server VM created (3 GB RAM, 40 GB disk)
- [ ] Network adapter on Internal Network `intnet-lab`
- [ ] Windows Server 2022 installed (Desktop Experience)
- [ ] Static IP set: 10.10.10.10/24, GW: 10.10.10.1, DNS: 127.0.0.1
- [ ] Server renamed to DC01
- [ ] AD DS role installed
- [ ] Promoted to DC (apex.local)
- [ ] DNS forward lookup zone verified
- [ ] DHCP role installed
- [ ] DHCP scope configured (10.10.10.100-200)
- [ ] Can ping 10.10.10.1 (pfSense)
- [ ] Can ping 8.8.8.8 (internet)
- [ ] nslookup apex.local resolves

---

## 📸 Screenshots to Capture
1. Static IP configuration
2. AD DS promotion wizard (domain name screen)
3. Active Directory Users and Computers (showing apex.local)
4. DNS Manager (showing forward lookup zone)
5. DHCP scope properties
6. PowerShell output of `Get-ADDomain`

**🎉 Sprint 1 Complete!** You now have a working pfSense gateway, Windows Server domain controller, DNS, and DHCP. The foundation is set.


---

## 4. Sprint 2

*Guides for this sprint will be generated when the sprint begins.*

## 5. Sprint 3

*Guides for this sprint will be generated when the sprint begins.*

## 6. Sprint 4

*Guides for this sprint will be generated when the sprint begins.*

## 7. Sprint 5

*Guides for this sprint will be generated when the sprint begins.*

## 8. Sprint 6

*Guides for this sprint will be generated when the sprint begins.*

## 9. Sprint 7

*Guides for this sprint will be generated when the sprint begins.*

## 10. Sprint 8

*Guides for this sprint will be generated when the sprint begins.*

