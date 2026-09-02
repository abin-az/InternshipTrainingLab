# Server Migration & Network Portability Runbook

> **Core Requirement**: The entire Dell PowerEdge R640 Proxmox server and its complete VM ecosystem must be 100% portable so that moving the physical server to another office, lab, or network location requires **ZERO changes to any internal VM or service**.

---

## 1. Portability Architecture Overview

The lab network is strictly separated into two domains:

```mermaid
graph TD
    subgraph External Network [Variable / Site-Specific]
        ISP[Site Gateway / Router\n(e.g., 192.168.29.1 or 192.168.1.1)]
        ISP -->|Physical Cable| iDRAC[iDRAC9 Port]
        ISP -->|Physical Cable Port 1| HostNIC[Proxmox vmbr0]
    end

    subgraph Internal Lab Ecosystem [100% Static & Portable - NEVER CHANGES]
        HostNIC -->|Uplink (DHCP/Static)| pfSenseWAN[pfSense WAN\n(vtnet0 on vmbr0)]
        pfSenseWAN -->|NAT / Firewall| pfSenseLAN[pfSense LAN\n(vtnet1 on vmbr1: 10.10.10.1)]
        
        pfSenseLAN --> vSwitch[Internal vSwitch vmbr1\nSubnet: 10.10.10.0/24]
        
        vSwitch --> DC01[DC-WIN-01\n10.10.10.10]
        vSwitch --> APP01[APP-UBU-01\n10.10.10.20]
        vSwitch --> NMS01[NMS-UBU-01\n10.10.10.30]
        vSwitch --> SEC01[SEC-UBU-01\n10.10.10.40]
        vSwitch --> BKP01[BKP-WIN-01\n10.10.10.50]
        vSwitch --> Students[Student Laptops\nDHCP: 10.10.10.100 - .200]
    end
```

---

## 2. Portability Precautions Enforced During Setup

| Component | Portability Rule | Impact on Migration |
| :--- | :--- | :--- |
| **All Internal VMs** | Bound exclusively to `vmbr1` (Internal isolated vSwitch). | **Zero changes**. All internal IPs (`10.10.10.x`), AD domain (`apex.local`), DNS records, MariaDB databases, and services remain completely unchanged. |
| **pfSense WAN** | Configured as **DHCP Client** on `vmbr0`. | **Zero changes**. Automatically receives IP, subnet, and default gateway from whatever new router/ISP is plugged in at the new location. |
| **Domain & DNS** | Internal DNS points to `10.10.10.10` (DC-WIN-01). Upstream forwarders set to public DNS (`1.1.1.1`, `8.8.8.8`). | **Zero changes**. Internal name resolution never breaks regardless of external WAN changes. |
| **Inter-VM Traffic** | All VMs talk via internal hostname / FQDN (`*.apex.local`) and `10.10.10.x` static IPs. | **Zero changes**. Database connections (GLPI to MariaDB), monitoring probes (Zabbix/Prometheus), and SIEM logs (Wazuh) never disconnect. |

---

## 3. Migration Day Checklist (What to Change on Moving)

When the physical Dell PowerEdge R640 server is physically relocated to a new network:

### Step 1: Physical Connections at New Site
- Connect **iDRAC Port** (wrench icon) to the new network switch.
- Connect **Port 1 (NIC0)** to the new network switch / router.

### Step 2: Update Proxmox Host Management IP (`vmbr0`)
If the new site uses a different subnet (e.g. changing from `192.168.29.x` to `192.168.1.x`):
1. Connect a monitor/keyboard to the server or log in via iDRAC Virtual Console.
2. Edit `/etc/network/interfaces`:
   ```bash
   nano /etc/network/interfaces
   ```
3. Update `address` and `gateway` under `iface vmbr0 inet static` to match the new subnet (e.g., `192.168.1.25/24` and gateway `192.168.1.1`).
4. Update `/etc/hosts` with the new IP.
5. Run `ifreload -a` or `systemctl restart networking`.

### Step 3: Update iDRAC IP (Optional)
- In the Dell Lifecycle Controller (F2 at boot) or iDRAC Web UI, update the static iDRAC IP to the new subnet (or set to DHCP).

### Step 4: Verification
- Power on VMs in order: **pfSense (100) > DC-WIN-01 (101) > APP-UBU-01 (102) > NMS-UBU-01 (103) > SEC-UBU-01 / BKP-WIN-01**.
- Connect a student laptop to `vmbr1` (via physical bridge NIC or Wi-Fi AP bridged to `vmbr1`), verify it gets `10.10.10.x`, and verify internet and internal access.
