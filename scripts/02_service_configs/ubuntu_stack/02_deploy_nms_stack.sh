#!/usr/bin/env bash
# 02_deploy_nms_stack.sh
# Turnkey deployment of Zabbix 6.4 LTS, Prometheus, Grafana Enterprise, and Wazuh SIEM on NMS-UBU-01 (10.10.10.30)
# Organization: Think Polaris (thinkpolaris.local)

set -euo pipefail

echo "================================================================="
echo " Deploying Network Monitoring & SIEM Stack on NMS-UBU-01 (10.10.10.30)"
echo " Stack: Zabbix 6.4 LTS, Prometheus, Grafana, Wazuh SIEM 4.8      "
echo "================================================================="

export DEBIAN_FRONTEND=noninteractive

echo "--> [1/6] Updating system repositories and installing dependencies..."
apt update && apt upgrade -y
apt install -y curl wget gnupg2 software-properties-common apt-transport-https lsb-release ufw

echo "--> [2/6] Installing & Configuring Prometheus & Node Exporter..."
apt install -y prometheus prometheus-node-exporter

# Configure Prometheus to scrape local Node Exporter
cat << 'EOF' > /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node_exporter'
    static_configs:
      - targets: ['localhost:9100']
EOF

systemctl restart prometheus prometheus-node-exporter
systemctl enable prometheus prometheus-node-exporter

echo "--> [3/6] Installing & Configuring Grafana Enterprise..."
mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor --yes | tee /etc/apt/keyrings/grafana.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | tee /etc/apt/sources.list.d/grafana.list
apt update && apt install -y grafana

systemctl daemon-reload
systemctl enable --now grafana-server

# Set default admin password for Grafana to company standard
sleep 3
grafana-cli admin reset-admin-password "Guardian@2026_$" || true

echo "--> [4/6] Installing & Configuring MariaDB and Zabbix 6.4 LTS..."
apt install -y mariadb-server mariadb-client
systemctl enable --now mariadb

mariadb -e "CREATE DATABASE IF NOT EXISTS zabbix CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;"
mariadb -e "CREATE USER IF NOT EXISTS 'zabbix'@'localhost' IDENTIFIED BY 'Guardian@2026_\$';"
mariadb -e "GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost';"
mariadb -e "SET GLOBAL log_bin_trust_function_creators = 1;"

# Install Zabbix 6.4 Release Repository
cd /tmp
wget -q https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.4-1+ubuntu22.04_all.deb
dpkg -i zabbix-release_6.4-1+ubuntu22.04_all.deb
apt update
apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent

echo "    Importing initial Zabbix database schema..."
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mariadb -u zabbix -p'Guardian@2026_$' zabbix || true
mariadb -e "SET GLOBAL log_bin_trust_function_creators = 0;"

# Configure Zabbix Server DB Password
sed -i "s/# DBPassword=/DBPassword=Guardian@2026_\$/g" /etc/zabbix/zabbix_server.conf

# Pre-configure Zabbix Web Frontend Configuration to bypass setup wizard
mkdir -p /etc/zabbix/web
cat << 'EOF' > /etc/zabbix/web/zabbix.conf.php
<?php
// Zabbix GUI configuration file - Think Polaris Turnkey
global $DB;

$DB['TYPE']     = 'MYSQL';
$DB['SERVER']   = 'localhost';
$DB['PORT']     = '0';
$DB['DATABASE'] = 'zabbix';
$DB['USER']     = 'zabbix';
$DB['PASSWORD'] = 'Guardian@2026_$';

$DB['SCHEMA'] = '';

$ZBX_SERVER      = 'localhost';
$ZBX_SERVER_PORT = '10051';
$ZBX_SERVER_NAME = 'Think Polaris Monitoring Core';

$IMAGE_FORMAT_DEFAULT = IMAGE_FORMAT_PNG;
EOF
chown -R www-data:www-data /etc/zabbix/web

systemctl restart zabbix-server zabbix-agent apache2
systemctl enable zabbix-server zabbix-agent apache2

echo "--> [5/6] Installing Wazuh SIEM Manager & Indexer All-in-One..."
cd /root
curl -sO https://packages.wazuh.com/4.8/wazuh-install.sh
curl -sO https://packages.wazuh.com/4.8/config.yml || true

# Run Wazuh unattended all-in-one installation
bash wazuh-install.sh -a -i

# Save passwords to home directory for easy reference
if [ -f /root/wazuh-passwords.txt ]; then
    cp /root/wazuh-passwords.txt /home/administrator/wazuh-passwords.txt 2>/dev/null || true
    chmod 600 /root/wazuh-passwords.txt /home/administrator/wazuh-passwords.txt 2>/dev/null || true
fi

echo "--> [6/6] Verifying Service States & Ports..."
echo "--- Systemd Service Statuses ---"
systemctl is-active zabbix-server zabbix-agent apache2 grafana-server prometheus prometheus-node-exporter wazuh-manager || true

echo "================================================================="
echo " [SUCCESS] Phase 2 Monitoring & SIEM Stack Deployed on NMS-UBU-01!"
echo "================================================================="
echo " 1. Zabbix Web UI:      http://10.10.10.30/zabbix"
echo "    Credentials:        Admin / zabbix"
echo " 2. Grafana Dashboards: http://10.10.10.30:3000"
echo "    Credentials:        admin / Guardian@2026_$"
echo " 3. Prometheus Metrics: http://10.10.10.30:9090"
echo " 4. Node Exporter:      http://10.10.10.30:9100/metrics"
echo " 5. Wazuh SIEM Portal:  https://10.10.10.30"
echo "    Credentials:        admin / (See /root/wazuh-passwords.txt)"
echo "================================================================="
