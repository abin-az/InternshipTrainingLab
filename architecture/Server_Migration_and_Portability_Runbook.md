# Server Migration & Network Portability Runbook

> **Core Requirement**: The entire Dell PowerEdge R640 Proxmox server and its complete VM ecosystem are engineered to be 100% portable so that moving the physical server between home, office, and training center networks requires **ZERO changes to any internal VM, service, database, or Active Directory configuration**.

---

## 1. Portability Architecture Overview

The lab network is strictly separated into two domains:

```mermaid
graph TD
    subgraph External Network [Variable / Site-Specific Uplink]
        ISP[Site Router / Office Switch\n(e.g., Home: 192.168.29.1 / Office: 192.168.1.1)]
        ISP -->|Physical Cable| iDRAC[iDRAC9 Dedicated Port]
        ISP -->|Physical Cable Port 1| HostNIC[Proxmox vmbr0 Uplink]
    end

    subgraph Internal Lab Core [100% Static & Portable - NEVER TOUCHED ON MIGRATION]
        HostNIC -->|Dynamic Uplink| pfSenseWAN[pfSense WAN\n(vtnet0 on vmbr0 - DHCP Client)]
        pfSenseWAN -->|NAT / Gateway| pfSenseLAN[pfSense LAN\n(vtnet1 on vmbr1: 10.10.10.1)]
        
        pfSenseLAN --> vSwitch[Internal Virtual Bridge vmbr1\nSubnet: 10.10.10.0/24]
        
        vSwitch --> DC01[DC-WIN-01\n10.10.10.10\nActive Directory / DNS]
        vSwitch --> APP01[APP-UBU-01\n10.10.10.20\nGLPI / BookStack / MariaDB]
        vSwitch --> NMS01[NMS-UBU-01\n10.10.10.30\nZabbix / Grafana / Wazuh]
        vSwitch --> SEC01[SEC-UBU-01\n10.10.10.40\nDVWA / OpenVAS]
        vSwitch --> BKP01[BKP-WIN-01\n10.10.10.50\nVeeam Backup Server]
        vSwitch --> Students[Student Laptops\nDHCP: 10.10.10.100 - .200]
    end
```

---

## 2. Zero-Touch Internal Services Guarantee

When moving the server to any new location (e.g. from Home to Office):

| Internal Component | Internal IP / Scope | Action on Site Migration |
| :--- | :--- | :--- |
| **`DC-WIN-01`** (AD DS, DNS, DHCP) | `10.10.10.10` | **ZERO CHANGES**. Domain FQDN `thinkpolaris.local`, user accounts, Kerberos, DNS zones remain untouched. |
| **`APP-UBU-01`** (GLPI, BookStack, MariaDB) | `10.10.10.20` | **ZERO CHANGES**. Database connections, web root, LDAP sync with DC remain intact. |
| **`NMS-UBU-01`** (Zabbix, Grafana, Prometheus, Wazuh) | `10.10.10.30` | **ZERO CHANGES**. Zabbix triggers, Prometheus scrape targets, Wazuh indexer/manager keys remain active. |
| **`SEC-UBU-01`** (DVWA, OpenVAS) | `10.10.10.40` | **ZERO CHANGES**. Isolated container network and scanner targets remain untouched. |
| **`BKP-WIN-01`** (Veeam Backup & Replication) | `10.10.10.50` | **ZERO CHANGES**. Backup repositories and hypervisor hooks remain static. |
| **pfSense WAN** | Dynamic on `vmbr0` | **ZERO CHANGES**. Automatically picks up the new office DHCP lease and routes traffic outbound. |

---

## 3. Step-by-Step Home-to-Office Relocation Runbook

### Phase A: Before Leaving Home
1. Cleanly shut down all VMs from Proxmox Web GUI or Shell:
   ```bash
   qm stop 105; qm stop 104; qm stop 103; qm stop 102; qm stop 101; qm stop 100
   ```
2. Power down the Proxmox host:
   ```bash
   poweroff
   ```
3. Unplug cables and transport the Dell PowerEdge R640.

---

### Phase B: Physical Setup at the Office
1. Rack the server and plug in both redundant power supplies.
2. Plug **Port 1 (NIC0)** into the Office Network switch/router.
3. Plug the **iDRAC Dedicated Port** (wrench icon) into the Office Network switch/router.
4. Power on the server.

---

### Phase C: Update Proxmox Host Uplink IP (The ONLY Step Needed on the Server)

If the office network uses a different subnet (e.g., changing from Home `192.168.29.x` to Office `192.168.1.x`):

1. **Access Proxmox Shell** via iDRAC Virtual Console (or monitor/keyboard plugged into server).
2. Edit `/etc/network/interfaces`:
   ```bash
   nano /etc/network/interfaces
   ```
   Update the `vmbr0` section to your new office subnet:
   ```text
   auto vmbr0
   iface vmbr0 inet static
       address 192.168.1.25/24        # Set to free static IP on office network
       gateway 192.168.1.1            # Office router/gateway IP
       bridge-ports eno1              # Port 1 (NIC0)
       bridge-stp off
       bridge-fd 0
   ```
3. Update the NAT rule in `/etc/network/interfaces.d/vmbr1_permanent` to match the office subnet:
   ```bash
   sed -i 's/192.168.29.0/192.168.1.0/g' /etc/network/interfaces.d/vmbr1_permanent
   ```
4. Reload networking:
   ```bash
   ifreload -a
   ```
5. Start all VMs:
   ```bash
   qm start 100; sleep 10; qm start 101; sleep 10; qm start 102; qm start 103; qm start 104; qm start 105
   ```

---

### Phase D: Update Admin Laptops at the Office

On your physical laptop connected to the Office Wi-Fi/LAN:

1. Open **PowerShell as Administrator** on your laptop.
2. Remove the old home route and add the new office route pointing to the new Proxmox IP:
   ```powershell
   # Delete old route
   route delete 10.10.10.0
   
   # Add new persistent route pointing to new Office Proxmox IP (e.g. 192.168.1.25)
   route -p add 10.10.10.0 mask 255.255.255.0 192.168.1.25
   ```
3. Update `~/.ssh/config` on your laptop (Host `proxmox` &rarr; `192.168.1.25`).
4. **Test Connectivity**:
   - `mstsc` &rarr; `10.10.10.10` (Windows DC RDP) &rarr; **Connects immediately**.
   - Browser &rarr; `http://10.10.10.20` (GLPI) &rarr; **Connects immediately**.
   - Browser &rarr; `http://10.10.10.30/zabbix` (Zabbix) &rarr; **Connects immediately**.
   - Browser &rarr; `https://10.10.10.30` (Wazuh SIEM) &rarr; **Connects immediately**.

---

## 4. Summary of Migration Time & Effort

* **Time required to migrate**: **< 5 minutes**.
* **Configuration changes on VMs**: **0 (Zero)**.
* **Database / Active Directory changes**: **0 (Zero)**.


