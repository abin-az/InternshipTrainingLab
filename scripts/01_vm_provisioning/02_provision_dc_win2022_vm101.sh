#!/usr/bin/env bash
# 02_provision_dc_win2022_vm101.sh
# Provisions VM 101: DC-WIN-01 (Active Directory, DNS, DHCP, WSUS)

set -euo pipefail

VMID=101
VMNAME="DC-WIN-01"

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
  --scsi0 local-zfs:60,discard=on \
  --ide0 local:iso/virtio-win.iso,media=cdrom \
  --boot "order=scsi0;ide2;net0" \
  --net0 virtio,bridge=vmbr1,firewall=0 \
  --onboot 1 \
  --startup order=2 \
  --agent 1 \
  --description "Think Polaris Primary Domain Controller (Windows Server 2022: AD, DNS, DHCP, WSUS - 10.10.10.10)"

echo "==> VM $VMID ($VMNAME) created successfully."
