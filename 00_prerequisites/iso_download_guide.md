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
