#!/usr/bin/env bash
# 01_provision_pfsense_vm100.sh
# Provisions VM 100: FW-PFSENSE-01 (Gateway Firewall)

set -euo pipefail

VMID=100
VMNAME="FW-PFSENSE-01"

if qm status "$VMID" >/dev/null 2>&1; then
    echo "==> VM $VMID ($VMNAME) already exists. Skipping creation."
    exit 0
fi

echo "==> Creating VM $VMID: $VMNAME..."
qm create "$VMID" \
  --name "$VMNAME" \
  --memory 2048 \
  --balloon 0 \
  --cores 2 \
  --cpu host \
  --ostype other \
  --scsihw virtio-scsi-single \
  --scsi0 local-zfs:20,discard=on \
  --cdrom local:iso/pfSense-CE-2.7.2-RELEASE-amd64.iso \
  --boot "order=ide2;scsi0" \
  --net0 virtio,bridge=vmbr0,firewall=0 \
  --net1 virtio,bridge=vmbr1,firewall=0 \
  --onboot 1 \
  --startup order=1 \
  --agent 1 \
  --description "Think Polaris Lab Gateway & Firewall (pfSense CE 2.7.2)"

echo "==> VM $VMID ($VMNAME) created successfully."
