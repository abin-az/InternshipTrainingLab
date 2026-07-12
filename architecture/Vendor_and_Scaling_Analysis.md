# Think Polaris IT Internship Training Program: Vendor Selection & Scaling Analysis

This report addresses the final management queries regarding cloud provider selection, exact budget scaling, and the security responsibility model.

---

## 1. Cloud Provider Comparison (Bare-Metal vs. Cloud VM)

We evaluated three potential setups for hosting our Proxmox hypervisor. The critical requirement is **nested virtualization** and high RAM capacity to simulate an entire enterprise network (pfSense, Active Directory, GLPI, Zabbix, Wazuh, WSUS, Ubuntu/Windows Clients).

| Feature / Requirement | Hetzner Bare-Metal (Selected) | OVH Bare-Metal (Alternative) | Azure / AWS (Cloud VMs) |
|-----------------------|--------------------------------|-------------------------------|--------------------------|
| **Compute / RAM** | 128GB to 256GB RAM standard. | 128GB RAM available but pricier. | Extorbitant cost for 128GB+ RAM. |
| **Nested Virtualization** | **Fully Supported** (Type 1 Hypervisor) | **Fully Supported** (Type 1) | Requires specific costly instance types. |
| **Pricing Model** | **Flat-Rate Monthly (~₹7,500/mo)** | Flat-Rate (~₹12,000/mo) | Pay-As-You-Go (~₹60,000+/mo for equivalent). |
| **Bandwidth** | Unmetered (1Gbps) | Unmetered (500Mbps) | High egress costs for heavy traffic. |

**Decision:** **Hetzner Bare-Metal** is the undisputed winner for a lab environment. It provides massive compute resources for a predictable, flat monthly fee, whereas Azure/AWS would be financially unsustainable for running 20+ persistent virtual machines.

---

## 2. Budget Scaling Roadmap (Testing to 50 Students)

The infrastructure budget will scale linearly based on the number of concurrent students interacting with the lab. Since Proxmox allows us to snapshot and migrate VMs easily, we can upgrade the underlying physical server without rebuilding the lab.

### Phase A: Initial Setup & Testing (1-2 Users)
*Used by the Instructor/Architects to build the golden images and test the curriculum.*
- **Configuration**: Hetzner AX42 (AMD Ryzen 5 7600, 64GB DDR5 RAM, 2x 512GB NVMe).
- **Estimated Cost**: ~€46 / month (**~₹4,200 / month**)
- **Timeline**: Current setup phase.

### Phase B: First Cohort (10 Students)
*The lab is fully operational with 10 students logging in concurrently to their own client machines.*
- **Configuration**: Hetzner AX52 (AMD Ryzen 7 7700, 128GB DDR5 ECC RAM, 2x 1TB NVMe).
- **Estimated Cost**: ~€79 / month (**~₹7,200 / month**)
- **Timeline**: October / November.

### Phase C: Full Scale (30 to 50 Students)
*Massive parallel access. The environment runs 50+ Windows/Ubuntu clients simultaneously alongside the core servers.*
- **Configuration**: Hetzner AX102 (AMD Ryzen 9 7950X3D, 128GB DDR5 ECC RAM - *upgraded to 256GB if needed*, 2x 1.92TB NVMe).
- **Estimated Cost**: ~€130 to €170 / month (**~₹12,000 to ₹16,000 / month**)
- **Timeline**: Future expansion.

---

## 3. The Security "Shared Responsibility" Model

A common misconception is that a Bare-Metal Cloud provider (like Hetzner or OVH) manages software security in the same way Azure or AWS manages a PaaS database. **This is false.**

When we rent a Bare-Metal server, we are renting physical hardware. 

### What Hetzner Manages (The Physical Layer)
- Physical Data Center security (locks, cameras, guards).
- Power and cooling redundancy (UPS, AC).
- Internet Service Provider uplink and DDoS protection at the network edge.
- Hardware failure replacement (broken disks, dead RAM).

### What Think Polaris Manages (The Software & Logical Layer)
- **The Hypervisor**: We install and secure Proxmox VE.
- **The Public IP**: The server is exposed directly to the internet. **Think Polaris MUST install and properly configure a virtualized pfSense Firewall** to intercept all traffic. If we do not lock down the firewall, the lab *will* be compromised.
- **VM Patching**: All internal servers (Active Directory, GLPI, Wazuh) are our responsibility to patch and monitor.
- **Student Access**: Managing VPN or Guacamole access for students to securely reach the lab.

**Conclusion:** The environment is entirely secure *if* we configure our virtual pfSense firewall correctly. The vendor handles the physical hardware; Think Polaris handles the logical security.
