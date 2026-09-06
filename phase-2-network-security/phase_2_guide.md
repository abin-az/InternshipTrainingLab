# Phase 2: Network Monitoring & Security

> **Objective**: Move from reactive IT support into proactive infrastructure monitoring, network telemetry analysis, and enterprise security visibility.

---

## Architecture & Service Map (VM 103 — `NMS-UBU-01`)

| Module | Service | IP / Port | Credentials | Purpose / Lab Focus |
| :--- | :--- | :--- | :--- | :--- |
| **P8** | **Zabbix 6.4 LTS** | `http://10.10.10.30/zabbix` | `Admin` / `zabbix` | Host availability, CPU/RAM thresholds, trigger alerts, service monitoring. |
| **P9** | **Grafana Enterprise** | `http://10.10.10.30:3000` | `admin` / `Guardian@2026_$` | Visual performance dashboards, Prometheus time-series exploration. |
| **P9** | **Prometheus** | `http://10.10.10.30:9090` | *(Internal)* | Multi-dimensional time-series data scraping (`up`, `node_memory_*`). |
| **P9** | **Node Exporter** | `http://10.10.10.30:9100/metrics` | *(Scrape Target)* | Linux OS & hardware performance telemetry. |
| **P11** | **Wazuh SIEM Dashboard** | `https://10.10.10.30` | `admin` / *(See `/root/wazuh-passwords.txt`)* | Centralized security incident triage, file integrity monitoring, SOC logs. |
| **P12** | **DVWA / OpenVAS** | `http://10.10.10.40` (`SEC-UBU-01`) | `admin` / `password` | Isolated vulnerability lab target and automated vulnerability scanner. |

---

## Bridge Module: Network Basics
- **Core Concepts**: OSI Model (Layers 2, 3, 4, 7), TCP vs UDP, ARP resolution, ICMP.
- **Diagnostic CLI Tools**: `ping`, `tracert` / `traceroute`, `nslookup`, `netstat` / `ss`.
- **Firewall Logic**: Rule evaluation order, 5-tuple matching (Source IP, Source Port, Destination IP, Destination Port, Protocol), Stateful vs Stateless packet filtering.

---

## P8: Basic Infrastructure Monitoring (Zabbix)
**Target Host**: `NMS-UBU-01` (`10.10.10.30`) & Central Agents on `DC-WIN-01` (`10.10.10.10`) / `APP-UBU-01` (`10.10.10.20`)

### Turnkey Administrator Setup:
1. Ensure `zabbix-server` and `mariadb` are running on `NMS-UBU-01`.
2. Install Zabbix Agent on target nodes:
   - **Ubuntu (`APP-UBU-01`)**:
     ```bash
     sudo apt install -y zabbix-agent
     sudo sed -i 's/^Server=127.0.0.1/Server=10.10.10.30/' /etc/zabbix/zabbix_agentd.conf
     sudo systemctl restart zabbix-agent
     ```
   - **Windows (`DC-WIN-01`)**:
     Install Zabbix Windows Agent MSI pointing `Server` to `10.10.10.30`.

### Student Scenario Lab:
1. Log into the Zabbix dashboard at `http://10.10.10.30/zabbix` using `Admin` / `zabbix`.
2. Navigate to **Monitoring > Hosts** and inspect live CPU, memory, and disk utilization of `DC-WIN-01` and `APP-UBU-01`.
3. **Trigger Incident Simulation**: On `DC-WIN-01`, temporarily stop the DNS Server service (`Stop-Service DNS`).
4. Watch Zabbix trigger an immediate High Severity alert on the dashboard.
5. In Zabbix, click on the active problem, add an acknowledgment note explaining the root cause, restart the DNS service on `DC-WIN-01`, and verify the alert automatically clears to **RESOLVED**.

---

## P9: Dashboards & Time-Series Metrics (Prometheus & Grafana)
**Target Host**: `NMS-UBU-01` (`10.10.10.30:3000` / `:9090`)

### Student Scenario Lab:
1. Understand the paradigm difference between **Zabbix** (trigger/threshold-based agent monitoring) and **Prometheus** (pull-based time-series metrics scraping).
2. Open Prometheus at `http://10.10.10.30:9090/targets` and verify that `prometheus` and `node_exporter` targets show state `UP`.
3. Log into Grafana at `http://10.10.10.30:3000` using `admin` / `Guardian@2026_$`.
4. Navigate to **Dashboards > Import** (Import Dashboard ID `1860` - Node Exporter Full).
5. Generate simulated CPU load on `APP-UBU-01` (`stress --cpu 2 --timeout 30s`) and watch the live Grafana panel render the real-time CPU spike.

---

## P10: Networking Lab Tools (Wireshark & Nmap)
**Tools**: Wireshark, Nmap, Cisco Packet Tracer (Physical Student Laptops)

### Student Scenario Lab:
1. **Packet Capture Analysis**:
   - Open Wireshark on your physical laptop and bind to the Ethernet adapter (`10.10.10.x`).
   - Filter by `icmp` and ping `10.10.10.10` (Windows DC). Inspect the 8-byte ICMP Echo Request and Echo Reply packets, noting the MAC addresses and IP headers.
2. **Network Service Discovery (Nmap)**:
   - Run a SYN port scan against `APP-UBU-01`:
     ```bash
     nmap -sS -p 1-1000 10.10.10.20
     ```
   - Identify open ports (`22/tcp OpenSSH`, `80/tcp Apache GLPI`, `8080/tcp BookStack`).
3. **Cisco Packet Tracer Topology**:
   - Construct a virtual topology with 2 PCs and 1 Switch to demonstrate ARP cache poisoning defense and switch MAC address table aging.

---

## P11: Security Event Monitoring & SIEM (Wazuh)
**Target Host**: `NMS-UBU-01` (`https://10.10.10.30`)

### Turnkey Administrator Setup:
- Wazuh SIEM Manager & Dashboard installed on `NMS-UBU-01`.
- Deploy Wazuh Agent on `APP-UBU-01`:
  ```bash
  wget -qO - https://packages.wazuh.com/key/GPG-KEY-WAZUH | sudo gpg --dearmor -o /usr/share/keyrings/wazuh.gpg
  echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | sudo tee /etc/apt/sources.list.d/wazuh.list
  sudo apt update && sudo WAZUH_MANAGER='10.10.10.30' apt install -y wazuh-agent
  sudo systemctl enable --now wazuh-agent
  ```

### Student Scenario Lab:
1. Log into the Wazuh SIEM dashboard at `https://10.10.10.30` (`admin` / password from `/root/wazuh-passwords.txt`).
2. Simulate a brute-force authentication attack: From your physical laptop, attempt to SSH into `administrator@10.10.10.20` with invalid passwords 5 consecutive times.
3. In the Wazuh Dashboard, navigate to **Security Events > Authentication Failure**.
4. Locate Rule ID `5710` (*sshd: Attempt to log in using a non-existent user or invalid password*), identify the attacking Source IP (student laptop), and document the incident response in GLPI.

---

## P12: Vulnerability Management Lab (DVWA & OpenVAS)
**Target Host**: `SEC-UBU-01` (`10.10.10.40`)

### Student Scenario Lab:
1. Open the Damn Vulnerable Web Application (DVWA) at `http://10.10.10.40:8080`.
2. Log into the OpenVAS / Greenbone Vulnerability Management interface at `https://10.10.40:9392`.
3. Create a **Target** (`10.10.10.40`) and launch a **Full and Fast Vulnerability Scan**.
4. Review the generated vulnerability scan report (identifying CVSS scores, missing patches, and insecure HTTP methods). Export the executive summary as a PDF.
5. **Instructor Awareness Demo**: Instructor demonstrates a controlled Nmap vulnerability script (`nmap --script vuln 10.10.10.40`) from Kali Linux to illustrate how automated threat scanners discover misconfigurations.

---

## 🏆 Phase 2 Assessment Checkpoint

Before progressing to Phase 3, interns must pass this practical evaluation:
1. **Live Demonstration**: Share screen, capture and analyze an ICMP packet in Wireshark, identifying Layer 2 MAC addresses, Layer 3 IP headers, and Layer 4 checksums.
2. **SIEM Incident Triage**: Navigate Wazuh SIEM, locate an active security event assigned by the instructor, and explain the event classification and remediation steps.

