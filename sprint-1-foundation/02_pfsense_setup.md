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
