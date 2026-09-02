# Think Polaris IT Internship: Stage-Wise Infrastructure & Pricing

This report breaks down the exact infrastructure costs for the Think Polaris Internship lab across four deployment stages—from basic instructor setup to full-swing 50-student capacity.

---

## 1. Stage-Wise Pricing Analysis

We evaluated three potential setups for hosting our Proxmox hypervisor. The critical requirement is **nested virtualization** and high RAM capacity to simulate an entire enterprise network.

### Stage 1: Basic Setup & Testing (1-2 Users)
*Used by the Instructors to build the golden images, deploy pfSense, and test the curriculum before students arrive.*
- **Target Configuration**: ~64GB RAM, NVMe storage.
- **Hetzner Bare-Metal (Recommended)**: €35 to €50 / month (**~₹3,200 to ₹4,500/mo**) using the Hetzner Server Auction. (Zero setup fee).
- **OVH Bare-Metal**: ~₹5,500 / month (Eco Rise series).
- **Azure Cloud VM**: ~$560 / month (~₹46,000/mo) for a D16s_v5 instance.
- **AWS Cloud EC2**: ~$367 / month (~₹30,000/mo) for an r5.2xlarge instance.
- **Google Cloud (GCP)**: ~$380 / month (~₹31,000/mo) for an n2d-standard-16.

### Stage 2: First Cohort (10 Students)
*The lab is fully operational with 10 students logging in concurrently to their own client machines alongside the core infrastructure (AD, GLPI, Zabbix).*
- **Target Configuration**: ~128GB RAM, Modern CPU (AMD Ryzen 9 or equivalent), NVMe.
- **Hetzner Bare-Metal (Recommended)**: €257.30 / month (**~₹23,000 / month**) for an AX102-1.
- **OVH Bare-Metal**: ~$107 to $150 / month (~₹8,900 to ₹12,500/mo) on the Advance series.
- **Azure Cloud VM**: ~$735 / month (~₹61,000/mo) for an E16s_v5 instance.
- **AWS Cloud EC2**: ~$735 / month (~₹61,000/mo) for an r5.4xlarge instance.
- **Google Cloud (GCP)**: ~$750 / month (~₹62,000/mo) for an n2d-standard-32.

### Stage 3: Scaling Up (30 Students)
*Heavy parallel access. We need enough compute power so students do not experience lag while running Wazuh SIEM queries or Windows Updates.*
- **Target Configuration**: ~256GB RAM, High Core Count.
- **Hetzner Bare-Metal (Recommended)**: €547.30 / month (**~₹49,000 / month**) for an AX102-2 or dual 128GB nodes.
- **OVH Bare-Metal**: ~₹30,000 to ₹40,000/mo (High-Grade or Scale series).
- **Azure Cloud VM**: ~$1,500+ / month (~₹1,25,000/mo).
- **AWS Cloud EC2**: ~$1,471 / month (~₹1,22,000/mo) for an r5.8xlarge instance.
- **Google Cloud (GCP)**: ~$1,500+ / month (~₹1,25,000/mo).

### Stage 4: Full Swing (50 Students)
*Massive deployment. The environment runs 50+ Windows/Ubuntu clients simultaneously. Since Proxmox supports clustering, we simply rent additional bare-metal nodes and cluster them together seamlessly.*
- **Target Configuration**: 3 to 4 clustered bare-metal nodes (384GB+ Total RAM).
- **Hetzner Bare-Metal (Recommended)**: ~€800 to €1,000 / month (**~₹75,000 to ₹90,000/mo**) for a multi-node Proxmox cluster.
- **OVH Bare-Metal**: ~₹1,20,000+ / month.
- **Azure Cloud VM**: ~$3,000+ / month (~₹2,50,000+/mo).
- **AWS Cloud EC2**: ~$2,200+ / month (~₹1,83,000+/mo).
- **Google Cloud (GCP)**: ~$2,500+ / month (~₹2,07,000+/mo).

**Decision Summary:** **Hetzner Bare-Metal** provides the most reliable performance specifically tuned for heavy nested virtualization at scale. Azure/AWS costs make a persistent 24/7 lab financially unsustainable. OVH is competitive at the low end but scales poorly compared to Hetzner's multi-node cluster pricing for 50 students.

---

## 2. The Security "Shared Responsibility" Model

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

---

## 4. Cost-Cutting & Optimization Strategies

To ensure Think Polaris achieves these enterprise-grade results at the absolute minimum cost, we will implement the following technical optimizations during deployment:

### 1. Leverage Proxmox LXC (Linux Containers)
Instead of deploying heavy, full Virtual Machines (KVMs) for every server, all Linux-based tools (Ubuntu, Zabbix, GLPI, Wazuh) will be deployed as lightweight LXC containers. This reduces RAM and CPU overhead by nearly **40%**, allowing more students to fit on a single, cheaper Hetzner node.

### 2. Proxmox "Linked Clones" for Windows
For student Windows 10 clients and Active Directory servers, we will build a single "Golden Image." Every student's VM will be a "Linked Clone" of this image. This means 50 Windows VMs will share the exact same base hard drive space, drastically reducing NVMe storage requirements and preventing the need to buy expensive storage upgrades.

### 3. IPv4 NAT via pfSense (Save on IP Costs)
Hetzner charges a monthly fee for every public IPv4 address. By routing the entire lab through our virtualized pfSense firewall, the entire 50-student environment will operate behind a single, €2/month public IPv4 address using Network Address Translation (NAT) and VPN tunnels.

### 4. Hetzner Server Auction for Early Stages
For Stage 1 and early Stage 2, we can source hardware from the **Hetzner Server Auction**. These servers have **zero upfront setup fees** (saving €49 to €129 immediately) and offer discounted monthly rates on slightly older, but perfectly capable, enterprise hardware.

### 5. Elastic Off-Season Scaling
Because Hetzner operates on month-to-month contracts, we will only rent the massive Stage 3/Stage 4 cluster nodes during the exact months the 30-50 student cohorts are active. During the off-season, we will migrate the Golden Images back to a single, cheap Stage 1 server and instantly cancel the expensive cluster nodes.

**Conclusion:** The environment is entirely secure *if* we configure our virtual pfSense firewall correctly. The vendor handles the physical hardware; Think Polaris handles the logical security, and our virtualization strategies will maximize hardware efficiency.
