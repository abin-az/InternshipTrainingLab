# P0 - P3: Instructor Admin Setup

> **Note**: This setup must be completed by the instructor before the students begin Phase 1.

## P0: Planning & Lab Design
- Map out the IP schema for the `10.10.10.0/24` subnet.
- Document VM naming conventions (e.g., `APP-SRV-01`, `DC-SRV-01`).
- Define lab safety rules.

## P1: Base Virtualization Platform
- **Tool**: Proxmox VE
- **Action**: Install Proxmox on a bare-metal physical server (minimum 12 cores, 96GB RAM, 2TB NVMe). Configure `vmbr0` (Management/WAN) and `vmbr1` (Internal LAN).

## P2: Core Lab Network
- **Tool**: pfSense
- **Action**: Deploy a pfSense VM. Connect WAN to `vmbr0` and LAN to `vmbr1`. Configure DHCP on `vmbr1` if required, but static IPs are preferred for servers. Create basic NAT rules.

## P3: Core Server Operating Systems
- **Tools**: Windows Server 2022, Ubuntu 22.04 LTS
- **Action**: 
    - Deploy `DC01` (Windows Server) on `vmbr1`.
    - Deploy `APP01` (Ubuntu Server) on `vmbr1`.
    - Deploy `NMS01` (Ubuntu Server) on `vmbr1`.
