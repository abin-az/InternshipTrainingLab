# Phase 2: Network Monitoring & Security

> **Objective**: Move from support into proactive operational thinking, packet analysis, and security visibility.

## Bridge Module: Network Basics
- Understand the OSI Model (Layers 2, 3, 4, 7).
- Practice basic commands: `ping`, `tracert`, `nslookup`.
- Understand firewall rules (Source, Destination, Port, Allow/Deny).

## P8: Basic Monitoring
**Tools**: Zabbix Server, Zabbix Agents
**Scenario Lab**:
1. Log into the Zabbix dashboard.
2. View the CPU and memory utilization of `DC01`.
3. Stop the DNS Server service on `DC01` to intentionally trigger a Zabbix alert. Acknowledge and resolve the alert.

## P9: Dashboards and Metrics
**Tools**: Prometheus, Grafana
**Scenario Lab**:
1. Explore the difference between Zabbix (classic agent monitoring) and Prometheus (time-series scraping).
2. Open Grafana and view a pre-built node-exporter dashboard showing live metrics from the Ubuntu servers.

## P10: Networking Lab Tools
**Tools**: Cisco Packet Tracer, Wireshark, Nmap
**Scenario Lab**:
1. Open Cisco Packet Tracer and build a simple topology with 2 PCs and 1 Switch to visualize ARP and MAC learning.
2. Run Wireshark on your laptop and capture ICMP packets while pinging a server.
3. Use Nmap to run a port scan against the `APP01` server to discover open services (e.g., ports 80, 22).

## P11: Security Monitoring
**Tools**: Wazuh (SIEM)
**Scenario Lab**:
1. Log into the Wazuh dashboard.
2. Attempt to SSH into `APP01` with the wrong password 5 times.
3. Locate the failed login alert in Wazuh and identify your laptop's source IP.

## P12: Vulnerability Lab
**Tools**: OpenVAS / Greenbone, DVWA, Kali Linux (Instructor Demo)
**Scenario Lab**:
1. Access the Damn Vulnerable Web App (DVWA) running in the isolated subnet.
2. Use OpenVAS to launch a vulnerability scan against the DVWA IP. Export the PDF report.
3. **Instructor Demo**: The instructor will perform a controlled demonstration using Kali Linux to scan the DVWA target, showing students how attackers map networks, for awareness purposes only.

---

## 🏆 Phase 2 Assessment Checkpoint
Before progressing to Phase 3, students must pass this structured evaluation:
1. **Live Demonstration**: The student must share their screen, successfully capture an ICMP packet in Wireshark, and identify the Source and Destination IP addresses.
2. **Log Identification**: The student must navigate the Wazuh dashboard and locate a specific simulated security alert (e.g., failed login) assigned by the instructor.
