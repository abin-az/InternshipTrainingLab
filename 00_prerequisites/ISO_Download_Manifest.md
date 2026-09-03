# Proxmox ISO Catalog & Download Manifest

> **Purpose**: Single authoritative registry of all operating system installer images and driver packages required for the Think Polaris Lab deployment.
> **Storage Target**: `/var/lib/vz/template/iso/` on Proxmox VE.

---

## 💽 ISO Registry Table

| ISO Name | Version / Architecture | Download URL | Approximate Size | Target Role |
| :--- | :--- | :--- | :--- | :--- |
| **`pfSense-CE-2.7.2-RELEASE-amd64.iso`** | pfSense Community Edition 2.7.2 (x86_64) | `https://atxfiles.netgate.com/mirror/downloads/pfSense-CE-2.7.2-RELEASE-amd64.iso.gz` | ~835 MB | VM 100 (`FW-PFSENSE-01`) Firewall & Gateway |
| **`virtio-win.iso`** | Latest Stable VirtIO Drivers for Windows | `https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso` | ~600 MB | VM 101 (`DC-WIN-01`) & VM 105 (`BKP-WIN-01`) |
| **`ubuntu-22.04.5-live-server-amd64.iso`** | Ubuntu Server 22.04.5 LTS (x86_64) | `https://releases.ubuntu.com/jammy/ubuntu-22.04.5-live-server-amd64.iso` | ~2.0 GB | VM 102 (`APP-UBU-01`), VM 103 (`NMS-UBU-01`), VM 104 (`SEC-UBU-01`) |
| **`Windows_Server_2022.iso`** | Windows Server 2022 Evaluation (x86_64) | Microsoft Evaluation Center (or local ISO) | ~4.7 GB | VM 101 (`DC-WIN-01`) Active Directory & VM 105 (`BKP-WIN-01`) |

---

## ⚡ Automated Download Command

To fetch and decompress all verified Linux, BSD, and Driver ISOs in one command on Proxmox:

```bash
cd /var/lib/vz/template/iso
wget -c "https://atxfiles.netgate.com/mirror/downloads/pfSense-CE-2.7.2-RELEASE-amd64.iso.gz" && gunzip -f "pfSense-CE-2.7.2-RELEASE-amd64.iso.gz"
wget -c -O virtio-win.iso "https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso"
wget -c "https://releases.ubuntu.com/jammy/ubuntu-22.04.5-live-server-amd64.iso"
ls -lh /var/lib/vz/template/iso
```
