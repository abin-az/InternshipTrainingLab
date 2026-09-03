# P0 - P3: Instructor Admin Setup & Turnkey VM Deployment Guide

> **Authoritative Blueprint**: Complete reference containing both **Automated CLI / Script Methods** and **Manual Proxmox Web GUI Wizard Steps** for every single virtual machine deployed in the Think Polaris IT Internship Training Program.

---

## 🏗️ Deployment Architecture Matrix

| VM ID | Name | Operating System | vCPU | RAM | Disk (ZFS) | Bridge / Subnet | Role & Primary Services |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **100** | `FW-PFSENSE-01` | FreeBSD / pfSense 2.7.2 | 2 | 2 GB | 20 GB | `vmbr0` (WAN) + `vmbr1` (LAN: `10.10.10.1/24`) | Boundary Firewall, NAT, SPI, Dynamic DHCP Gateway |
| **101** | `DC-WIN-01` | Windows Server 2022 | 2 | 4 GB | 60 GB | `vmbr1` (`10.10.10.10/24`) | Active Directory (AD DS `apex.local`), DNS Master, DHCP Scope, WSUS |
| **102** | `APP-UBU-01` | Ubuntu 22.04 LTS | 2 | 4 GB | 40 GB | `vmbr1` (`10.10.10.20/24`) | GLPI ITIL Ticketing, BookStack SOP Portal, MariaDB 10.6 Backend |
| **103** | `NMS-UBU-01` | Ubuntu 22.04 LTS | 4 | 8 GB | 60 GB | `vmbr1` (`10.10.10.30/24`) | Zabbix Server 6.4, Prometheus, Grafana, Wazuh SIEM Manager |
| **104** | `SEC-UBU-01` | Ubuntu 22.04 LTS | 2 | 4 GB | 40 GB | `vmbr1` (`10.10.10.40/24`) | OpenVAS Vulnerability Scanner, Docker Engine, DVWA Security Target |
| **105** | `BKP-WIN-01` | Windows Server 2022 | 2 | 4 GB | 80 GB | `vmbr1` (`10.10.10.50/24`) | Veeam Backup & Replication 12 CE, Hardened Backup Repository |

---

## 🛠️ VM 100: `FW-PFSENSE-01` (Boundary Firewall & Router)

### Method A: Automated CLI Script
```bash
bash scripts/01_vm_provisioning/01_provision_pfsense_vm100.sh
# Or direct command:
qm create 100 \
  --name FW-PFSENSE-01 \
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

qm start 100
```

### Method B: Manual Proxmox Web GUI Wizard
1. **General**: Node: `thinkpolaris` | VM ID: `100` | Name: `FW-PFSENSE-01` -> Next.
2. **OS**: Storage: `local` | ISO: `pfSense-CE-2.7.2-RELEASE-amd64.iso` | Guest OS Type: `Other` -> Next.
3. **System**: SCSI Controller: `VirtIO SCSI single` | Qemu Agent: `[*] Enabled` -> Next.
4. **Disks**: Storage: `local-zfs` | Disk size: `20 GiB` | Check `[*] Discard` -> Next.
5. **CPU**: Cores: `2` | Type: `host` -> Next.
6. **Memory**: Memory: `2048 MiB` | Uncheck Ballooning -> Next.
7. **Network**: Bridge: `vmbr0` | Model: `VirtIO (paravirtualized)` -> Next.
8. **Confirm & Post-Create**: Finish creation. Go to **VM 100 > Hardware > Add > Network Device**: Bridge: `vmbr1` | Model: `VirtIO`.

### Interactive Console Setup:
- Partitioning: `Auto (ZFS)` > `stripe` > Mark `[*] da0` with Spacebar > OK > Confirm YES.
- Reboot > Run `qm set 100 --delete ide2` in shell to eject ISO.
- Console Assignment: VLANs: `n` | WAN: `vtnet0` | LAN: `vtnet1`.
- Option `2) Set interface(s) IP address` > Select LAN (`2`) > IP: `10.10.10.1` | Mask: `24` | Gateway: None | DHCP: `y` (`10.10.10.100` to `10.10.10.200`) | HTTP: `n`.

---

## 🛠️ VM 101: `DC-WIN-01` (Windows Server 2022 Domain Controller)

### Method A: Automated CLI Script
```bash
bash scripts/01_vm_provisioning/02_provision_dc_win2022_vm101.sh
# Or direct command:
qm create 101 \
  --name DC-WIN-01 \
  --memory 4096 \
  --cores 2 \
  --cpu host \
  --ostype win11 \
  --scsihw virtio-scsi-single \
  --scsi0 local-zfs:60,discard=on \
  --cdrom local:iso/Windows_Server_2022.iso \
  --ide0 local:iso/virtio-win.iso,media=cdrom \
  --boot "order=ide2;scsi0;net0" \
  --net0 virtio,bridge=vmbr1,firewall=0 \
  --onboot 1 \
  --startup order=2 \
  --agent 1 \
  --description "Think Polaris Primary Domain Controller (Windows Server 2022: AD, DNS, DHCP, WSUS - 10.10.10.10)"

qm start 101
```

### Method B: Manual Proxmox Web GUI Wizard
1. **General**: Node: `thinkpolaris` | VM ID: `101` | Name: `DC-WIN-01` -> Next.
2. **OS**: Storage: `local` | ISO: `Windows_Server_2022.iso` | Type: `Microsoft Windows` | Version: `11/2022` -> Next.
3. **System**: SCSI Controller: `VirtIO SCSI single` | Qemu Agent: `[*] Enabled` -> Next.
4. **Disks**: Storage: `local-zfs` | Disk size: `60 GiB` | Check `[*] Discard` -> Next.
5. **CPU**: Cores: `2` | Type: `host` -> Next.
6. **Memory**: Memory: `4096 MiB` -> Next.
7. **Network**: Bridge: `vmbr1` | Model: `VirtIO (paravirtualized)` -> Next.
8. **Add VirtIO Driver CD**: After finish, go to **VM 101 > Hardware > Add > CD/DVD Drive**: Storage: `local` | ISO: `virtio-win.iso` -> Add.

### Windows OS Setup & VirtIO Driver Injection:
1. Edition: **`Windows Server 2022 Standard Evaluation (Desktop Experience)`** -> Next.
2. Type: **`Custom: Install Microsoft Server Operating System only (advanced)`**.
3. Storage Driver Injection:
   - Click **`Load driver`** > **`Browse`**.
   - Navigate: `CD Drive (E:) virtio-win` > `vioscsi` > `2k22` > `amd64` > OK.
   - Select `Red Hat VirtIO SCSI controller (vioscsi.inf)` > Next.
   - Select `Drive 0 Unallocated Space (60.0 GB)` > Next.
4. Post-Install:
   - Password: `Guardian@2026_$`
   - Open Explorer > `E:\virtio-win-gt-x64.exe` > Install all VirtIO drivers and QEMU Guest Agent.
   - Set Static IP in Windows: `10.10.10.10`, Subnet: `255.255.255.0`, Gateway: `10.10.10.1`, DNS: `127.0.0.1` (fallback `1.1.1.1`).

---

## 🛠️ VM 102: `APP-UBU-01` (GLPI, BookStack, MariaDB Backend)

### Method A: Automated CLI Script
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

### Method B: Manual Proxmox Web GUI Wizard
1. **General**: Node: `thinkpolaris` | VM ID: `102` | Name: `APP-UBU-01` -> Next.
2. **OS**: Storage: `local` | ISO: `ubuntu-22.04.5-live-server-amd64.iso` | Type: `Linux` (`6.x - 2.6 Kernel`) -> Next.
3. **System**: SCSI Controller: `VirtIO SCSI single` | Qemu Agent: `[*] Enabled` -> Next.
4. **Disks**: Storage: `local-zfs` | Disk size: `40 GiB` | Check `[*] Discard` -> Next.
5. **CPU**: Cores: `2` | Type: `host` -> Next.
6. **Memory**: Memory: `4096 MiB` -> Next.
7. **Network**: Bridge: `vmbr1` | Model: `VirtIO (paravirtualized)` -> Next.
8. **Confirm**: Check `[*] Start after created` -> Finish.

### Ubuntu OS Setup:
- Networking: Set `ens18` IPv4 to **Manual**: Subnet `10.10.10.0/24` | IP `10.10.10.20` | Gateway `10.10.10.1` | DNS `10.10.10.10,1.1.1.1` | Search `apex.local`.
- Storage: Entire disk (40 GB) -> Done.
- User Profile: `Lab Admin` | `app-ubu-01` | `administrator` | `Guardian@2026_$`.
- SSH Setup: Enable `[*] Install OpenSSH server`.

---

## 🛠️ VM 103: `NMS-UBU-01` (Zabbix, Prometheus, Grafana, Wazuh)

### Method A: Automated CLI Script
```bash
bash scripts/01_vm_provisioning/04_provision_nms_ubuntu_vm103.sh
# Or direct command:
qm create 103 \
  --name NMS-UBU-01 \
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

qm start 103
```

### Method B: Manual Proxmox Web GUI Wizard
1. **General**: VM ID: `103` | Name: `NMS-UBU-01` -> Next.
2. **OS**: ISO: `ubuntu-22.04.5-live-server-amd64.iso` | Linux Kernel -> Next.
3. **System**: VirtIO SCSI single | Qemu Agent: `Enabled` -> Next.
4. **Disks**: `60 GiB` on `local-zfs` | Discard `Enabled` -> Next.
5. **CPU**: `4` Cores | Type: `host` -> Next.
6. **Memory**: `8192 MiB` (8 GB) -> Next.
7. **Network**: Bridge `vmbr1` | VirtIO -> Finish.
8. Static IP: `10.10.10.30/24`, Gateway: `10.10.10.1`, Hostname: `nms-ubu-01`.

---

## 🛠️ VM 104: `SEC-UBU-01` (OpenVAS Vulnerability Scanner & DVWA)

### Method A: Automated CLI Script
```bash
bash scripts/01_vm_provisioning/05_provision_sec_ubuntu_vm104.sh
# Or direct command:
qm create 104 \
  --name SEC-UBU-01 \
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

qm start 104
```

### Method B: Manual Proxmox Web GUI Wizard
1. **General**: VM ID: `104` | Name: `SEC-UBU-01` -> Next.
2. **OS**: ISO: `ubuntu-22.04.5-live-server-amd64.iso` -> Next.
3. **Disks**: `40 GiB` on `local-zfs` with Discard -> Next.
4. **CPU**: `2` Cores | **Memory**: `4096 MiB` -> Next.
5. **Network**: Bridge `vmbr1` | VirtIO -> Finish.
6. Static IP: `10.10.10.40/24`, Gateway: `10.10.10.1`, Hostname: `sec-ubu-01`.

---

## 🛠️ VM 105: `BKP-WIN-01` (Veeam Backup & Replication)

### Method A: Automated CLI Script
```bash
bash scripts/01_vm_provisioning/06_provision_bkp_win2022_vm105.sh
# Or direct command:
qm create 105 \
  --name BKP-WIN-01 \
  --memory 4096 \
  --cores 2 \
  --cpu host \
  --ostype win11 \
  --scsihw virtio-scsi-single \
  --scsi0 local-zfs:80,discard=on \
  --cdrom local:iso/Windows_Server_2022.iso \
  --ide0 local:iso/virtio-win.iso,media=cdrom \
  --boot "order=ide2;scsi0;net0" \
  --net0 virtio,bridge=vmbr1,firewall=0 \
  --onboot 1 \
  --startup order=5 \
  --agent 1 \
  --description "Think Polaris Backup & DR Host (Windows Server 2022: Veeam Backup & Replication - 10.10.10.50)"

qm start 105
```

### Method B: Manual Proxmox Web GUI Wizard
1. **General**: VM ID: `105` | Name: `BKP-WIN-01` -> Next.
2. **OS**: ISO: `Windows_Server_2022.iso` | Windows 11/2022 -> Next.
3. **Disks**: `80 GiB` on `local-zfs` with Discard -> Next.
4. **CPU**: `2` Cores | **Memory**: `4096 MiB` -> Next.
5. **Network**: Bridge `vmbr1` | VirtIO -> Finish.
6. Attach `virtio-win.iso` under Hardware > Add CD/DVD Drive.
7. Static IP: `10.10.10.50/24`, Gateway: `10.10.10.1`, DNS: `10.10.10.10`.
