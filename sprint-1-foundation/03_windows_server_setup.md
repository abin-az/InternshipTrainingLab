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
