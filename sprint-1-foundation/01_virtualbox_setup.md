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
