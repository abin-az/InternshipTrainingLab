#!/usr/bin/env bash
# 03_download_all_isos.sh
# Downloads all verified OS images and VirtIO drivers into Proxmox ISO storage

set -euo pipefail

ISO_DIR="/var/lib/vz/template/iso"
mkdir -p "$ISO_DIR"
cd "$ISO_DIR"

echo "==> [1/4] Ensuring public DNS resolution..."
if ! grep -q "1.1.1.1" /etc/resolv.conf; then
    cat << 'EOF' > /etc/resolv.conf
nameserver 1.1.1.1
nameserver 8.8.8.8
EOF
fi

echo "==> [2/4] Downloading pfSense 2.7.2 CE ISO..."
if [ ! -f "$ISO_DIR/pfSense-CE-2.7.2-RELEASE-amd64.iso" ]; then
    wget -c "https://atxfiles.netgate.com/mirror/downloads/pfSense-CE-2.7.2-RELEASE-amd64.iso.gz"
    gunzip -f "pfSense-CE-2.7.2-RELEASE-amd64.iso.gz"
else
    echo "    pfSense ISO already exists, skipping."
fi

echo "==> [3/4] Downloading VirtIO Windows Drivers ISO..."
if [ ! -f "$ISO_DIR/virtio-win.iso" ]; then
    wget -c -O "$ISO_DIR/virtio-win.iso" "https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso"
else
    echo "    virtio-win.iso already exists, skipping."
fi

echo "==> [4/4] Downloading Ubuntu Server 22.04.5 LTS ISO..."
if [ ! -f "$ISO_DIR/ubuntu-22.04.5-live-server-amd64.iso" ]; then
    wget -c "https://releases.ubuntu.com/jammy/ubuntu-22.04.5-live-server-amd64.iso"
else
    echo "    Ubuntu 22.04 ISO already exists, skipping."
fi

echo "==> ISO Catalog in $ISO_DIR:"
ls -lh "$ISO_DIR"
