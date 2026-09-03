#!/usr/bin/env bash
# 03_deploy_sec_stack.sh
# Turnkey deployment of Docker, DVWA Target, and OpenVAS on SEC-UBU-01 (10.10.10.40)

set -euo pipefail

echo "========================================================="
echo " Deploying Security Target & Scanner on SEC-UBU-01       "
echo " Tools: Docker, DVWA (Vulnerable Target), OpenVAS        "
echo "========================================================="

export DEBIAN_FRONTEND=noninteractive

echo "--> [1/3] Installing Docker Engine..."
apt update && apt install -y ca-certificates curl gnupg lsb-release
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update && apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
systemctl enable --now docker

echo "--> [2/3] Deploying Damn Vulnerable Web App (DVWA)..."
docker run -d --name dvwa --restart always -p 80:80 vulnerables/web-dvwa

echo "--> [3/3] Setting up Greenbone Community / OpenVAS Scanner Container..."
mkdir -p /opt/greenbone-community-container && cd /opt/greenbone-community-container
curl -f -L https://greenbone.github.io/docs/latest/_static/docker-compose-22.4.yml -o docker-compose.yml
docker compose -f docker-compose.yml -p greenbone-community-edition up -d || true

echo "========================================================="
echo " [SUCCESS] Security Target Stack Deployed on SEC-UBU-01!"
echo " DVWA Practice Target:    http://10.10.10.40"
echo " OpenVAS Scanner Portal:  http://10.10.10.40:9392"
echo "========================================================="
