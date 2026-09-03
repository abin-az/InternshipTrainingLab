#!/usr/bin/env bash
# 03_provision_app_ubuntu_vm102.sh
# Provisions VM 102: APP-UBU-01 (GLPI, BookStack, MariaDB backend)

set -euo pipefail

VMID=102
VMNAME="APP-UBU-01"

if qm status "$VMID" >/dev/null 2>&1; then
    echo "==> VM $VMID ($VMNAME) already exists. Skipping creation."
    exit 0
fi

echo "==> Creating VM $VMID: $VMNAME..."
qm create "$VMID" \
  --name "$VMNAME" \
  --memory 4096 \
  --cores 2 \
  --cpu host \
  --ostype l26 \
  --scsihw virtio-scsi-single \
  --scsi0 local-zfs:40,discard=on \
  --cdrom local:iso/ubuntu-22.04.5-live-server-amd64.iso \
  --boot "order=scsi0;ide2;net0" \
  --net0 virtio,bridge=vmbr1,firewall=0 \
  --onboot 1 \
  --startup order=3 \
  --agent 1 \
  --description "Think Polaris Core Applications Server (Ubuntu 22.04: GLPI, BookStack, MariaDB - 10.10.10.20)"

echo "==> VM $VMID ($VMNAME) created successfully."
