# Enterprise Office Next-Gen Firewall (NGFW) & VLAN Architecture

> **Authoritative Technical Blueprint**  
> **Host Server**: Dell PowerEdge R640 Bare-Metal Server (Proxmox VE 8.x)  
> **Gateway VM**: VM 100 (`FW-PFSENSE-01`)  
> **Domain Standard**: `thinkpolaris.local` | `thinkpolaris.com`

---

## 1. Executive Summary: Why Virtualized pfSense Outperforms $3,000 Hardware Firewalls

Commercial appliances (FortiGate 60F/70F, Palo Alto Networks PA-400 Series, SonicWall TZ) typically cost **$1,500 to $4,000 upfront**, with recurring **20%–40% annual subscription fees** just to keep threat definitions, IPS signatures, and firmware updates active. Under the hood, entry-to-mid commercial firewalls run on low-power dual-core or quad-core ARM chips with 2 GB to 4 GB of RAM.

In contrast, deploying **pfSense Community Edition (VM 100)** on the Dell PowerEdge R640 bare-metal hypervisor leverages:
- **Enterprise Compute**: Intel Xeon Gold / AMD EPYC CPU cores with multi-gigabit throughput.
- **VirtIO Line-Rate Switching**: Sub-millisecond packet forwarding over virtualized 10 Gbps bus interfaces.
- **Zero Ongoing Licensing Fees**: 100% open-source packages (pfBlockerNG, Suricata, FQ-CoDel, WireGuard) without recurring subscription paywalls.
- **Dual Functionality**: Protects the physical office/institute building while simultaneously powering the isolated student training lab.

---

## 2. Physical & Virtual Cabling Topology

To position virtual pfSense directly in the physical traffic path of the office, the Dell PowerEdge physical NICs are mapped to Proxmox virtual bridges:

```
[ISP Fiber Optical Modem / ONT]
            │ (Dynamic DHCP / Static Public IP)
            ▼ Physical Port 1 (eno1)
   ┌───────────────────────────────────────────────────────────┐
   │ Dell PowerEdge R640 Hypervisor (Proxmox VE)               │
   │                                                           │
   │   vmbr0 (WAN Bridge) ──────► pfSense WAN Interface        │
   │                                                           │
   │   pfSense (VM 100) Core Router & Next-Gen Firewall        │
   │   - Suricata IDS/IPS                                      │
   │   - pfBlockerNG GeoIP + DNSBL                             │
   │   - FQ-CoDel Bandwidth Shaper                             │
   │   - 802.1Q 6-Zone Inter-VLAN Router                       │
   │                                                           │
   │   vmbr1 (VLAN-Aware LAN Bridge)                           │
   └─────────────────────────────┬─────────────────────────────┘
                                 │ Physical Port 2 (eno2 - 802.1Q Trunk)
                                 ▼
         ┌───────────────────────────────────────────────┐
         │ Managed Gigabit Switch (802.1Q VLAN Tagged)  │
         └───────┬───────────────┬───────────────┬───────┘
                 │               │               │
        [Port 1-10: V30] [Port 11-16: V40] [Port 20-24: Trunk]
         Student Laptops    Staff / Admin    Wi-Fi Access Points
         (Training Lab)     (Office PCs)    (SSID: Polaris-Guest / Staff)
```

---

## 3. The 6-Zone Enterprise VLAN Security Model

| VLAN ID | Subnet | Zone Name | Allowed Inbound Targets | Blocked Inbound Targets | Security & Operational Purpose |
| :---: | :---: | :---: | :---: | :---: | :--- |
| **VLAN 10** | `10.10.10.0/24` | **MGMT (Infrastructure)** | Proxmox Host, iDRAC, Switch Management, pfSense WebGUI | External WAN (no raw internet exposure) | Hypervisor and out-of-band hardware management. Accessible strictly by Instructor/Admin laptops. |
| **VLAN 20** | `10.10.20.0/24` | **Lab Core Servers** | Inter-VM communication, WAN package updates | Initiating connections into Staff VLAN 40 | Houses DC-WIN-01, GLPI, BookStack, Zabbix, Wazuh SIEM. Protected from client tampering. |
| **VLAN 30** | `10.10.30.0/24` | **Students / Interns** | Lab Core (VLAN 20 on ports 80, 443, 3389, 53, 88), WAN | MGMT (10), Staff (40), other student laptops (Client Isolation) | Students have internet and lab access, but cannot attack faculty PCs or hypervisor management. |
| **VLAN 40** | `10.10.40.0/24` | **Office / Staff / Faculty** | Internet, Lab Core (read-only), Office Printers | VLAN 60 (Sandbox), Hypervisor raw iDRAC | Management, payroll, admissions, and faculty workstations. Enforces high QoS bandwidth priority. |
| **VLAN 50** | `10.10.50.0/24` | **Guest Wi-Fi** | Internet (HTTP/HTTPS only) | All internal subnets (`10.10.0.0/16`) | Isolated captive portal for visitors, interns' smartphones, and personal gadgets. |
| **VLAN 60** | `10.10.60.0/24` | **Security Sandbox / Target** | Accessible ONLY from Instructor / Scanner | All internal subnets, External WAN | Strict quarantine holding DVWA and penetration test targets. Malware cannot escape. |

---

## 4. Next-Gen Firewall (NGFW) Free Enterprise Packages

### 1. `pfBlockerNG-devel` (Threat Intelligence & Content Filtering)
- **GeoIP Nation Blocking**: Drops all unsolicited inbound traffic from high-threat regions (e.g., botnets, automated brute-force scanners) at the packet layer.
- **DNSBL (DNS Blackholing)**: Feeds from StevenBlack, Abuse.ch, and FireHOL. Automatically blocks malware domains, phishing sites, cryptominers, and tracking telemetry network-wide without endpoint software.

### 2. `Suricata` (Intrusion Detection & Prevention System - IDS/IPS)
- **Deep Packet Inspection**: Runs against official Emerging Threats (ET Open) rulesets.
- **Automated Inline Dropping**: Detects and immediately drops port sweeps (Nmap), SSH/RDP brute-force attempts, SQL injections, and known CVE exploit payloads.

### 3. `FQ-CoDel` Bandwidth Shaper (Anti-Bufferbloat)
- **Dynamic Fair Queueing**: Prevents a single student downloading a large ISO, game, or video from saturating the internet uplink.
- **Low-Latency Prioritization**: Guarantees sub-10ms ping for Zoom calls, VoIP, and instructor demonstrations even under 100% link utilization.

### 4. `WireGuard` & `OpenVPN` Server (Hybrid Remote Access)
- **Zero-Trust Remote Lab Access**: Instructors and remote students connect over encrypted WireGuard tunnels directly to `10.10.30.0/24` without exposing dangerous RDP (3389) or SSH (22) ports to the public internet.

### 5. `HAProxy + ACME` (Automated SSL Termination)
- **Enterprise PKI**: Issues valid SSL certificates via Let's Encrypt / internal CA for `*.thinkpolaris.local`, eliminating browser red security warnings across GLPI, BookStack, Zabbix, Grafana, and Wazuh.

---

## 5. Proxmox Hypervisor Network Bridge Configuration

To enable 802.1Q VLAN trunking on Proxmox VE, edit `/etc/network/interfaces` on the host:

```bash
# WAN Uplink (ISP Fiber Modem)
auto vmbr0
iface vmbr0 inet manual
    bridge-ports eno1
    bridge-stp off
    bridge-fd 0

# LAN Trunk (To Physical Managed Switch & Internal VMs)
auto vmbr1
iface vmbr1 inet manual
    bridge-ports eno2
    bridge-stp off
    bridge-fd 0
    bridge-vlan-aware yes
    bridge-vids 10 20 30 40 50 60
```

---

## 6. Student Pedagogical Outcomes (Service Desk & NOC Alignment)

Working with this live enterprise firewall provides interns with direct industry experience:
1. **L1/L2 Network Diagnostic**: Diagnosing why an intern on VLAN 30 can ping `10.10.20.10` (ICMP allowed) but cannot load the GLPI portal (TCP 80/443 blocked by firewall rule).
2. **DHCP & Option Scope Administration**: Managing DHCP scopes, reservations, and options (Option 003 Router, Option 006 DNS) for 6 subnets.
3. **Firewall Rule Writing**: Creating stateful firewall rules with aliases, port groups, and schedule-based restrictions.
4. **SOC Tier-1 Triage**: Inspecting live Suricata intrusion alerts and cross-referencing them with Wazuh SIEM security logs.
