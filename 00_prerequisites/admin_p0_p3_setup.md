# P0 - P3: Instructor Admin Setup

> **Note**: This setup must be completed by the instructor before the students begin Phase 1.

## P0: Planning & Lab Design
- Map out the IP schema for the `10.10.10.0/24` subnet.
- Document VM naming conventions (e.g., `APP-SRV-01`, `DC-SRV-01`).
- Define lab safety rules.

## P1: Base Virtualization Platform
- **Hardware**: Dell PowerEdge R640 (1U Rackmount, PERC H730 Mini in HBA Mode, 2x 960GB Samsung SSDs in ZFS RAID-1, Dual Redundant PSUs, iDRAC9 Enterprise).
- **Hypervisor**: Proxmox VE 9.2-1 (Host IP: `192.168.29.25/24`, Gateway: `192.168.29.1`).
- **Detailed Runbook**: See [dell_poweredge_r640_proxmox_deployment.md](file:///c:/Users/abinu/Documents/antigravity/optimistic-meitner/00_prerequisites/dell_poweredge_r640_proxmox_deployment.md) for full physical setup, iDRAC, HBA conversion, ZFS configuration, and repository tuning steps.
- **Action**: Configure `vmbr0` (Management/WAN uplink on Port 1) and `vmbr1` (Internal isolated lab LAN).

## P2: Core Lab Network
- **Tool**: pfSense
- **Action**: Deploy a pfSense VM. Connect WAN to `vmbr0` and LAN to `vmbr1`. Configure DHCP on `vmbr1` if required, but static IPs are preferred for servers. Create basic NAT rules.

## P3: Core Server Operating Systems
- **Tools**: Windows Server 2022, Ubuntu 22.04 LTS
- **Storage Pool**: `local-zfs` with SSD Discard/TRIM enabled.
- **Network Interface**: All servers connected exclusively to `vmbr1` (Internal Lab LAN `10.10.10.0/24`).

### VM 102 (`APP-UBU-01`): Core Application Server (Ubuntu 22.04 LTS)
- **Role**: GLPI ITIL Service Desk, BookStack SOP Portal, MariaDB 10.6 Database Backend (`10.10.10.20/24`).
- **Resource Allocation**: 2 vCPUs (host type), 4096 MB RAM, 40 GB ZFS Disk, VirtIO SCSI, autostart order 3.

#### Method 1: Automated Script / CLI Command
```bash
bash scripts/01_vm_provisioning/03_provision_app_ubuntu_vm102.sh
# Or direct command:
qm create 102 \
  --name APP-UBU-01 \
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

qm start 102
```

#### Method 2: Manual Proxmox Web GUI Wizard
1. Click **Create VM** button (top right).
2. **General**: Node: `thinkpolaris` | VM ID: `102` | Name: `APP-UBU-01` -> Next.
3. **OS**: Storage: `local` | ISO: `ubuntu-22.04.5-live-server-amd64.iso` | Type: `Linux` (`6.x - 2.6 Kernel`) -> Next.
4. **System**: SCSI Controller: `VirtIO SCSI single` | Qemu Agent: `[*] Enabled` -> Next.
5. **Disks**: Storage: `local-zfs` | Disk size: `40 GiB` | Check `[*] Discard` -> Next.
6. **CPU**: Cores: `2` | Type: `host` -> Next.
7. **Memory**: Memory: `4096 MiB` -> Next.
8. **Network**: Bridge: `vmbr1` | Model: `VirtIO (paravirtualized)` -> Next.
9. **Confirm**: Check `[*] Start after created` -> Finish.

---

### VM 101 (`DC-WIN-01`): Primary Domain Controller (Windows Server 2022)
- **Role**: Active Directory Domain Services (`apex.local`), DNS Master (`10.10.10.10`), DHCP Scope, WSUS Patching.
- **Resource Allocation**: 2 vCPUs, 4096 MB RAM, 60 GB ZFS Disk, VirtIO SCSI, autostart order 2.
- **Provisioning Script**: `bash scripts/01_vm_provisioning/02_provision_dc_win2022_vm101.sh`.

---

### VM 103 (`NMS-UBU-01`): Network Monitoring & SIEM (Ubuntu 22.04 LTS)
- **Role**: Zabbix Server 6.4, Prometheus, Grafana Dashboards, Wazuh SIEM Manager (`10.10.10.30/24`).
- **Resource Allocation**: 4 vCPUs, 8192 MB RAM, 60 GB ZFS Disk, autostart order 4.
- **Provisioning Script**: `bash scripts/01_vm_provisioning/04_provision_nms_ubuntu_vm103.sh`.

---

### VM 104 (`SEC-UBU-01`): Security Lab & Target (Ubuntu 22.04 LTS)
- **Role**: OpenVAS Vulnerability Scanner, DVWA Target (`10.10.10.40/24`).
- **Resource Allocation**: 2 vCPUs, 4096 MB RAM, 40 GB ZFS Disk.
- **Provisioning Script**: `bash scripts/01_vm_provisioning/05_provision_sec_ubuntu_vm104.sh`.

---

### VM 105 (`BKP-WIN-01`): Backup & Disaster Recovery (Windows Server 2022)
- **Role**: Veeam Backup & Replication 12 Community Edition, Backup Repository (`10.10.10.50/24`).
- **Resource Allocation**: 2 vCPUs, 4096 MB RAM, 80 GB ZFS Disk, autostart order 5.
- **Provisioning Script**: `bash scripts/01_vm_provisioning/06_provision_bkp_win2022_vm105.sh`.
