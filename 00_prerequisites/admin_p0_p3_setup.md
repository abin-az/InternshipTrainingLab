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
- **Action**: 
    - Deploy `DC01` (Windows Server) on `vmbr1`.
    - Deploy `APP01` (Ubuntu Server) on `vmbr1`.
    - Deploy `NMS01` (Ubuntu Server) on `vmbr1`.
