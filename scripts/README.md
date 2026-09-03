# Think Polaris Lab: Automation & IaC Scripts Guide

This directory contains turnkey bash automation scripts for bootstrapping and deploying the Think Polaris IT Internship Training Lab on Proxmox VE.

---

## 📁 Directory Structure

```text
scripts/
├── 00_host_setup/
│   ├── 01_setup_proxmox_repos.sh       # Disables enterprise repos, configures pve-no-subscription & updates
│   ├── 02_setup_network_bridges.sh      # Validates vmbr0 (WAN) and provisions vmbr1 (Isolated LAN: 10.10.10.0/24)
│   └── 03_download_all_isos.sh          # Downloads pfSense, Ubuntu 22.04 LTS, and VirtIO Windows ISOs
├── 01_vm_provisioning/
│   ├── 01_provision_pfsense_vm100.sh    # Provisions VM 100: FW-PFSENSE-01 (Gateway Firewall)
│   ├── 02_provision_dc_win2022_vm101.sh # Provisions VM 101: DC-WIN-01 (Active Directory & DNS)
│   ├── 03_provision_app_ubuntu_vm102.sh # Provisions VM 102: APP-UBU-01 (GLPI, BookStack, MariaDB)
│   ├── 04_provision_nms_ubuntu_vm103.sh # Provisions VM 103: NMS-UBU-01 (Zabbix, Wazuh, Grafana)
│   ├── 05_provision_sec_ubuntu_vm104.sh # Provisions VM 104: SEC-UBU-01 (OpenVAS & DVWA Target)
│   ├── 06_provision_bkp_win2022_vm105.sh# Provisions VM 105: BKP-WIN-01 (Veeam Backup & Replication)
│   └── deploy_all_vms.sh                # Master runner to provision all 6 lab VMs in order
└── 02_service_configs/                  # Configuration templates for pfSense, AD, and Ubuntu services
```

---

## 🚀 How to Run on Proxmox

From the Proxmox Node Shell (`root@thinkpolaris:~#`), you can run any individual script:

```bash
# 1. Setup Host & Repositories
bash scripts/00_host_setup/01_setup_proxmox_repos.sh
bash scripts/00_host_setup/02_setup_network_bridges.sh
bash scripts/00_host_setup/03_download_all_isos.sh

# 2. Provision All Lab VMs
bash scripts/01_vm_provisioning/deploy_all_vms.sh
```
