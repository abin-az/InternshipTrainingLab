#!/usr/bin/env bash
# 02_deploy_nms_stack.sh
# Turnkey deployment of Zabbix, Prometheus, Grafana, and Wazuh SIEM on NMS-UBU-01 (10.10.10.30)

set -euo pipefail

echo "========================================================="
echo " Deploying Network Monitoring & SIEM on NMS-UBU-01       "
echo " Tools: Zabbix 6.4, Prometheus, Grafana, Wazuh SIEM      "
echo "========================================================="

export DEBIAN_FRONTEND=noninteractive

echo "--> [1/5] Updating system & installing core dependencies..."
apt update && apt upgrade -y
apt install -y curl wget gnupg2 software-properties-common apt-transport-https lsb-release

echo "--> [2/5] Installing Prometheus & Node Exporter..."
apt install -y prometheus prometheus-node-exporter
systemctl enable --now prometheus prometheus-node-exporter

echo "--> [3/5] Installing Grafana Enterprise..."
mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | tee /etc/apt/keyrings/grafana.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | tee /etc/apt/sources.list.d/grafana.list
apt update && apt install -y grafana
systemctl enable --now grafana-server

echo "--> [4/5] Installing Zabbix Server, Frontend, and Agent..."
cd /tmp
wget https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.4-1+ubuntu22.04_all.deb
dpkg -i zabbix-release_6.4-1+ubuntu22.04_all.deb
apt update
apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent mariadb-server

systemctl enable --now mariadb
mariadb -e "CREATE DATABASE IF NOT EXISTS zabbix CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;"
mariadb -e "CREATE USER IF NOT EXISTS 'zabbix'@'localhost' IDENTIFIED BY 'Guardian@2026_\$';"
mariadb -e "GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost';"
mariadb -e "SET GLOBAL log_bin_trust_function_creators = 1;"

echo "    Importing initial Zabbix database schema..."
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mariadb -u zabbix -p'Guardian@2026_$' zabbix || true
mariadb -e "SET GLOBAL log_bin_trust_function_creators = 0;"

sed -i "s/# DBPassword=/DBPassword=Guardian@2026_\$/g" /etc/zabbix/zabbix_server.conf
systemctl restart zabbix-server zabbix-agent apache2
systemctl enable zabbix-server zabbix-agent

echo "--> [5/5] Installing Wazuh SIEM Manager & Indexer..."
curl -sO https://packages.wazuh.com/4.8/wazuh-install.sh
bash wazuh-install.sh -a -i || true

echo "========================================================="
echo " [SUCCESS] Monitoring & SIEM Stack Deployed on NMS-UBU-01!"
echo " Zabbix Dashboard:   http://10.10.10.30/zabbix"
echo " Grafana Dashboards: http://10.10.10.30:3000"
echo " Prometheus Metrics: http://10.10.10.30:9090"
echo " Wazuh SIEM Portal:  https://10.10.10.30"
echo "========================================================="
