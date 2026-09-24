# 🔐 Master Access & Credentials Directory
**Think Polaris IT Internship Training Lab**

This document serves as the master reference for all IP addresses, web portal links, and login credentials across the entire infrastructure.

*(Note: External IPs reflect the recent migration to the `192.168.1.x` series. Internal lab IPs remain isolated on `10.10.10.x`)*

---

## 1. Physical & Hypervisor Management
| Service | Access Link / IP | Username | Password |
| :--- | :--- | :--- | :--- |
| **Dell iDRAC (Out-of-Band)** | [https://192.168.1.50](https://192.168.1.50) | `root` | `Server@12` |
| **Proxmox VE (Hypervisor)** | [https://192.168.1.25:8006](https://192.168.1.25:8006) | `root` | `Guardian@2026_$` |

---

## 2. Core Lab Infrastructure (`vmbr1` - 10.10.10.0/24)

### 🛡️ Network & Identity Core
| VM / Service | Access Link / IP | Username | Password |
| :--- | :--- | :--- | :--- |
| **pfSense Firewall (VM 100)** | [https://10.10.10.1](https://10.10.10.1) | `admin` | `Guardian@2026_$` |
| **Active Directory DC (VM 101)** | `10.10.10.10` (RDP) | `THINKPOLARIS\Administrator` | `Guardian@2026_$` |
| **Standard AD User Account** | N/A | `student` / `user` | `PolarisPass@2026!` |

### 🛠️ Helpdesk & Documentation (VM 102 - `APP-UBU-01`)
| Service | Access Link / IP | Username | Password |
| :--- | :--- | :--- | :--- |
| **GLPI (ITSM/Ticketing)** | [http://10.10.10.20](http://10.10.10.20) | AD Synced (Use AD Admin) | `Guardian@2026_$` |
| **BookStack (Wiki/SOP)** | [http://10.10.10.20:8080](http://10.10.10.20:8080) | `admin@thinkpolaris.local` | `Guardian@2026_$` |
| **SSH / CLI Access** | `ssh administrator@10.10.10.20` | `administrator` | `Guardian@2026_$` |

### 👁️ Monitoring & Security (VM 103 - `NMS-UBU-01`)
| Service | Access Link / IP | Username | Password |
| :--- | :--- | :--- | :--- |
| **Zabbix (Infrastructure)** | [http://10.10.10.30/zabbix](http://10.10.10.30/zabbix) | `Admin` | `zabbix` |
| **Grafana (Dashboards)** | [http://10.10.10.30:3000](http://10.10.10.30:3000) | `admin` | `Guardian@2026_$` |
| **Wazuh (SIEM/Security)** | [https://10.10.10.30](https://10.10.10.30) | `admin` | `RU78SD9qcDdm.KV6bZOx6NnBZJ4M7m.S` |
| **SSH / CLI Access** | `ssh administrator@10.10.10.30` | `administrator` | `Guardian@2026_$` |

### 🎯 Vulnerability Target (VM 104 - `SEC-UBU-01`)
| Service | Access Link / IP | Username | Password |
| :--- | :--- | :--- | :--- |
| **DVWA (Damn Vulnerable Web App)**| [http://10.10.10.40](http://10.10.10.40) | `admin` | `password` |
| **SSH / CLI Access** | `ssh administrator@10.10.10.40` | `administrator` | `Guardian@2026_$` |

### 💾 Backup & Disaster Recovery (VM 105 - `BKP-WIN-01`)
| Service | Access Link / IP | Username | Password |
| :--- | :--- | :--- | :--- |
| **Windows Server BKP** | `10.10.10.50` (RDP) | `THINKPOLARIS\Administrator` | `Guardian@2026_$` |
| **Veeam SMB Backup Share** | `\\10.10.10.50\VeeamBackups` | `THINKPOLARIS\Administrator` | `Guardian@2026_$` |

---

## 3. General Connection Notes
* **VPN/Routing:** To reach the `10.10.10.x` internal lab from your laptop, ensure your persistent route is pointing to the Proxmox IP: `route add 10.10.10.0 mask 255.255.255.0 192.168.1.25 -p`.
* **Domain Name:** `thinkpolaris.local`
* **Default Windows Administrator:** `Administrator` / `Guardian@2026_$`
* **Default Ubuntu sudo User:** `administrator` / `Guardian@2026_$`
