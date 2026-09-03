#!/usr/bin/env bash
# 02_setup_network_bridges.sh
# Configures vmbr0 (WAN Uplink) & vmbr1 (Internal Isolated Lab LAN: 10.10.10.0/24)

set -euo pipefail

INTERFACES_FILE="/etc/network/interfaces"

echo "==> Checking if vmbr1 already exists in $INTERFACES_FILE..."
if grep -q "vmbr1" "$INTERFACES_FILE"; then
    echo "==> vmbr1 configuration already present."
else
    echo "==> Appending vmbr1 definition..."
    cat << 'EOF' >> "$INTERFACES_FILE"

auto vmbr1
iface vmbr1 inet manual
	bridge-ports none
	bridge-stp off
	bridge-fd 0
# Internal Isolated Lab LAN (10.10.10.0/24)
EOF
fi

echo "==> Reloading network configuration..."
ifreload -a

echo "==> Verifying bridge status:"
ip link show vmbr0
ip link show vmbr1

echo "==> Network bridges configured and verified."
