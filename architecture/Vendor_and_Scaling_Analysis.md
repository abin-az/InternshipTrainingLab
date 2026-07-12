# Think Polaris IT Internship Training Program: Vendor Selection & Scaling Analysis

This report addresses the final management queries regarding cloud provider selection, exact budget scaling, and the security responsibility model.

---

## 1. Cloud Provider Comparison (Bare-Metal vs. Cloud VM)

We evaluated three potential setups for hosting our Proxmox hypervisor. The critical requirement is **nested virtualization** and high RAM capacity to simulate an entire enterprise network (pfSense, Active Directory, GLPI, Zabbix, Wazuh, WSUS, Ubuntu/Windows Clients).

| Feature / Requirement | Hetzner Bare-Metal (Selected) | OVH Bare-Metal (Alternative) | Azure / AWS (Cloud VMs) |
|-----------------------|--------------------------------|-------------------------------|--------------------------|
| **Compute / RAM** | 64GB to 256GB RAM standard. | 32GB to 128GB RAM standard. | Exorbitant cost for 128GB+ RAM. |
| **Nested Virtualization** | **Fully Supported** (Type 1) | **Fully Supported** (Type 1) | Requires specific costly instance types. |
| **64GB RAM Pricing** | **€97.30 (~₹8,800 / month)** | ~₹5,500 to ₹8,900 / month | ~$560 (~₹46,000 / month) |
| **128GB RAM Pricing** | **€257.30 (~₹23,000 / month)** | ~$107+ (~₹8,900+ / month) | ~$735 (~₹61,000 / month) |

**Decision:** **Hetzner Bare-Metal** provides the most reliable AMD Ryzen performance specifically tuned for heavy nested virtualization. OVH is cheaper for entry-level (Eco range) but scales poorer for modern CPUs. Azure (e.g., E16s_v5) costs over ₹61,000/month just for compute, making it financially unsustainable for a 24/7 lab.

---

## 2. Exact Budget Scaling Roadmap (Testing to 50 Students)

The infrastructure budget will scale linearly based on the number of concurrent students interacting with the lab. Since Proxmox allows us to snapshot and migrate VMs easily, we can upgrade the underlying physical server without rebuilding the lab.

### Phase A: Initial Setup & Testing (1-2 Users)
*Used by the Instructor/Architects to build the golden images and test the curriculum.*
- **Configuration**: Hetzner AX42-1 (AMD Ryzen, 64GB RAM, NVMe).
- **Exact Cost**: **€97.30 / month (~₹8,800 / month)** + €49 Setup Fee.
- **Timeline**: Current setup phase.

### Phase B: First Cohort (10 Students)
*The lab is fully operational with 10 students logging in concurrently to their own client machines.*
- **Configuration**: Hetzner AX102-1 (AMD Ryzen 9, 128GB ECC RAM, NVMe).
- **Exact Cost**: **€257.30 / month (~₹23,000 / month)** + €129 Setup Fee.
- **Timeline**: October / November.

### Phase C: Full Scale (30 to 50 Students)
*Massive parallel access. The environment runs 50+ Windows/Ubuntu clients simultaneously alongside the core servers.*
- **Configuration**: Hetzner AX102-2 (AMD Ryzen 9, 256GB ECC RAM, larger NVMe storage) or dual AX102-1 servers.
- **Exact Cost**: **€547.30 / month (~₹49,000 / month)**.
- **Timeline**: Future expansion.

---

## 3. The Security "Shared Responsibility" Model

A common misconception is that a Bare-Metal Cloud provider (like Hetzner or OVH) manages software security in the same way Azure or AWS manages a PaaS database. **This is false.**

When we rent a Bare-Metal server, we are renting raw physical hardware. 

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
