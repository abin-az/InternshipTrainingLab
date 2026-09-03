#!/usr/bin/env bash
# 06_provision_bkp_win2022_vm105.sh
# Provisions VM 105: BKP-WIN-01 (Veeam Backup & Replication Server)

set -euo pipefail

VMID=105
VMNAME="BKP-WIN-01"

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
  --ostype win11 \
  --scsihw virtio-scsi-single \
  --scsi0 local-zfs:80,discard=on \
  --ide0 local:iso/virtio-win.iso,media=cdrom \
  --boot "order=scsi0;ide2;net0" \
  --net0 virtio,bridge=vmbr1,firewall=0 \
  --onboot 1 \
  --startup order=5 \
  --agent 1 \
  --description "Think Polaris Backup & DR Host (Windows Server 2022: Veeam Backup & Replication - 10.10.10.50)"

echo "==> VM $VMID ($VMNAME) created successfully."
