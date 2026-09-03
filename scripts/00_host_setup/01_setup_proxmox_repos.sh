#!/usr/bin/env bash
# 01_setup_proxmox_repos.sh
# Configures Proxmox Community (No-Subscription) Repositories & Updates System

set -euo pipefail

echo "==> [1/3] Disabling enterprise repositories..."
sed -i 's/^deb/#deb/' /etc/apt/sources.list.d/pve-enterprise.list 2>/dev/null || true
sed -i 's/^deb/#deb/' /etc/apt/sources.list.d/ceph.list 2>/dev/null || true

echo "==> [2/3] Adding pve-no-subscription community repository..."
cat << 'EOF' > /etc/apt/sources.list.d/pve-no-subscription.list
deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription
EOF

echo "==> [3/3] Updating package index and patching node..."
apt update && apt dist-upgrade -y

echo "==> Proxmox repositories configured and node fully patched."
