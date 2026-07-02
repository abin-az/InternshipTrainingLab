# IT Internship Training Program - Master Runbook

> **Note:** This is the complete offline manual for the Simulated Enterprise Operations curriculum.

## 1. Project Framework

*(See `Revised_Phase_Framework.md` for the complete high-level architectural view and sprint breakdown).*

---

## 2. Admin Build Guide (Phase 0)

> **Purpose**: This section is exclusively for Instructors. You must pre-build this entire infrastructure on the Proxmox server *before* the students begin their sprints.

### 2.1 Hardware Procurement & Network Setup
- **Server**: Procure a physical 1U/2U server (e.g., Dell R630 or HP ProLiant Gen9). Minimum 8 cores, 64GB RAM, 1TB SSD.
- **Student Endpoints**: Procure 10 refurbished laptops (e.g., i5, 8GB RAM, 256GB SSD).
- **Network**: Connect the Server and all 10 Laptops to a managed 24-port Gigabit switch. Ensure the switch has uplink to the internet.

### 2.2 Proxmox VE Installation
1. Download the Proxmox VE ISO from `https://www.proxmox.com/en/downloads`.
2. Flash to a USB drive using Rufus or BalenaEtcher.
3. Boot the physical server from USB and follow the Proxmox installer.
4. Set the management IP (e.g., `192.168.1.100` on your physical network).
5. Access the Proxmox WebGUI at `https://192.168.1.100:8006`.

### 2.3 Core Virtual Machine Deployment
Deploy the following VMs on Proxmox:

| VM Name | OS | RAM | Cores | IP | Role |
|---|---|---|---|---|---|
| **pfSense-Edge** | pfSense CE | 1 GB | 2 | 10.10.10.1 | Firewall/Gateway. Bridge `vmbr0` (WAN) and `vmbr1` (LAN). |
| **DC01** | Windows Server 2022 | 4 GB | 4 | 10.10.10.10 | Domain Controller (`apex.local`), DNS, DHCP for the 10.10.10.0/24 subnet. |
| **App-Server** | Ubuntu 22.04 | 4 GB | 4 | 10.10.10.20 | Install Apache, PHP, MariaDB, GLPI (Ticketing), BookStack. |
| **NMS-Server** | Ubuntu 22.04 | 8 GB | 4 | 10.10.10.30 | Install Zabbix Server and Wazuh Manager. |

### 2.4 Creating Student Accounts
1. Log into **DC01**.
2. Open Active Directory Users and Computers.
3. Create an OU called `Interns`.
4. Create 10 standard User accounts (e.g., `intern01` to `intern10`).
5. Ensure these users are *not* Domain Admins yet (they will earn privileges in later sprints).

---

## 3. Student Sprints (Role-Based Curriculum)

> **Purpose**: This section outlines the tasks students must complete. They will log into their laptops and connect to the network you built above.

### Sprint 1: L1 Helpdesk & Access Management
**Scenario**: You have just been hired as an L1 Support Tech at Apex Corp. Your job is to handle the daily ticket queue.

**Tasks**:
1. **Login & Orientation**: Connect your laptop to the network and log in with your assigned `apex.local` account.
2. **Access GLPI**: Navigate to `http://10.10.10.20/glpi` and log in to the ticketing system.
3. **Password Reset (Ticket #101)**: A user has forgotten their password. RDP into the Domain Controller (`10.10.10.10`), open AD Users & Computers, and reset the password for `jdoe`. Check "User must change password at next logon."
4. **Account Unlock (Ticket #102)**: A user locked their account after too many failed attempts. Find their account in AD and unlock it.
5. **Group Modification (Ticket #103)**: Add the user `asmith` to the `HR_Docs_Read` security group.

---

### Sprint 2: L2 System Administration
**Scenario**: You've been promoted to L2. You are now responsible for configuring server-wide policies and network services.

**Tasks**:
1. **DHCP Reservation**: The new network printer needs a static IP. Open DHCP Manager on DC01 and create a reservation for MAC address `00:1A:2B:3C:4D:5E` to IP `10.10.10.50`.
2. **DNS Record**: The dev team spun up a new web server. Open DNS Manager and create an A-record for `dev.apex.local` pointing to `10.10.10.60`.
3. **Group Policy (GPO)**: Create a new GPO named `Enforce_Corporate_Wallpaper`. Configure it to apply a standard desktop background and link it to the `Employees` OU. Force a group policy update (`gpupdate /force`) on a test client to verify.
4. **File Shares**: Create a folder `C:\Shares\HR_Private`. Share it, and configure NTFS permissions so *only* the `HR_Docs_Read` group has access. 

---

### Sprint 3: L2 Network & Linux Administration
**Scenario**: The company relies heavily on Linux for its web applications. You need to monitor and maintain these servers.

**Tasks**:
1. **SSH Access**: Use PuTTY to SSH into the Ubuntu App Server (`10.10.10.20`).
2. **Service Troubleshooting**: The internal wiki is down. Use `systemctl status apache2` to discover it has crashed. Restart the service and verify it is running.
3. **Monitoring Analysis**: Log into the Zabbix dashboard at `http://10.10.10.30/zabbix`. Acknowledge the alert for "High CPU Utilization on App-Server".
4. **Log Review**: Use `tail -f /var/log/apache2/error.log` to monitor real-time web server errors and document any anomalies you see.

---

### Sprint 4: L3 Security & Firewall Management
**Scenario**: You are now part of the Network Engineering team. You manage the perimeter.

**Tasks**:
1. **Firewall WebGUI**: Log into the pfSense firewall at `https://10.10.10.1`.
2. **NAT Port Forwarding**: The business needs to expose the new SFTP server. Create a NAT Port Forward rule on the WAN interface forwarding port 2222 to the internal IP `10.10.10.20` port 22.
3. **Egress Filtering**: Create a strict firewall rule on the LAN interface that blocks all traffic to the IP range `8.8.8.0/24` to prevent unauthorized DNS usage.
4. **Log Analysis**: Check the pfSense Firewall Logs (Status > System Logs > Firewall) and identify which IP is repeatedly trying to ping the router.

---

### Sprint 5: L3 Security Operations (SOC)
**Scenario**: Welcome to the Security Operations Center. Your job is threat hunting and vulnerability management.

**Tasks**:
1. **SIEM Investigation**: Log into the Wazuh dashboard at `https://10.10.10.30`. Navigate to the Security Events tab. Locate the alerts generated by a simulated brute-force SSH attack. Document the attacker's IP address.
2. **Vulnerability Scanning**: Launch OpenVAS/Greenbone. Run a full vulnerability scan against the Windows Server DC01 (`10.10.10.10`).
3. **Remediation Report**: Review the OpenVAS PDF report. Identify one High or Critical vulnerability (e.g., SMB signing disabled, missing WSUS patch) and write a 1-page remediation plan on how to fix it in a production environment without causing downtime.
