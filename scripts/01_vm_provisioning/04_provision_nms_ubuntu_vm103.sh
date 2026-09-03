#!/usr/bin/env bash
# 04_provision_nms_ubuntu_vm103.sh
# Provisions VM 103: NMS-UBU-01 (Zabbix, Prometheus, Grafana, Wazuh SIEM)

set -euo pipefail

VMID=103
VMNAME="NMS-UBU-01"

if qm status "$VMID" >/dev/null 2>&1; then
    echo "==> VM $VMID ($VMNAME) already exists. Skipping creation."
    exit 0
fi

echo "==> Creating VM $VMID: $VMNAME..."
qm create "$VMID" \
  --name "$VMNAME" \
  --memory 8192 \
  --cores 4 \
  --cpu host \
  --ostype l26 \
  --scsihw virtio-scsi-single \
  --scsi0 local-zfs:60,discard=on \
  --cdrom local:iso/ubuntu-22.04.5-live-server-amd64.iso \
  --boot "order=scsi0;ide2;net0" \
  --net0 virtio,bridge=vmbr1,firewall=0 \
  --onboot 1 \
  --startup order=4 \
  --agent 1 \
  --description "Think Polaris Network Monitoring & SIEM (Ubuntu 22.04: Zabbix, Prometheus, Grafana, Wazuh - 10.10.10.30)"

echo "==> VM $VMID ($VMNAME) created successfully."
