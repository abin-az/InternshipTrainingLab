#!/usr/bin/env bash
# deploy_all_vms.sh
# Master Automated Deployment Script for All Think Polaris Lab VMs

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================================"
echo " Think Polaris IT Internship Lab: Master VM Deployment "
echo "========================================================"

echo "--> [1/6] Deploying VM 100: FW-PFSENSE-01..."
bash "$SCRIPT_DIR/01_provision_pfsense_vm100.sh"

echo "--> [2/6] Deploying VM 101: DC-WIN-01 (Active Directory & DNS)..."
bash "$SCRIPT_DIR/02_provision_dc_win2022_vm101.sh"

echo "--> [3/6] Deploying VM 102: APP-UBU-01 (GLPI, BookStack, MariaDB)..."
bash "$SCRIPT_DIR/03_provision_app_ubuntu_vm102.sh"

echo "--> [4/6] Deploying VM 103: NMS-UBU-01 (Zabbix, Wazuh, Grafana)..."
bash "$SCRIPT_DIR/04_provision_nms_ubuntu_vm103.sh"

echo "--> [5/6] Deploying VM 104: SEC-UBU-01 (OpenVAS & DVWA Target)..."
bash "$SCRIPT_DIR/05_provision_sec_ubuntu_vm104.sh"

echo "--> [6/6] Deploying VM 105: BKP-WIN-01 (Veeam Backup & Replication)..."
bash "$SCRIPT_DIR/06_provision_bkp_win2022_vm105.sh"

echo ""
echo "==> All 6 Lab Virtual Machines have been provisioned on Proxmox!"
echo "==> Proxmox Cluster VM Inventory:"
qm list
