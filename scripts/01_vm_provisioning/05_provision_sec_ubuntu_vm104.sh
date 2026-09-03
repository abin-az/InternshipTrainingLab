#!/usr/bin/env bash
# 05_provision_sec_ubuntu_vm104.sh
# Provisions VM 104: SEC-UBU-01 (OpenVAS Vulnerability Scanner, DVWA Target)

set -euo pipefail

VMID=104
VMNAME="SEC-UBU-01"

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
  --onboot 0 \
  --agent 1 \
  --description "Think Polaris Security Lab & Target (Ubuntu 22.04: OpenVAS, DVWA - 10.10.10.40)"

echo "==> VM $VMID ($VMNAME) created successfully."
