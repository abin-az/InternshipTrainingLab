# Infrastructure Cost & High Availability Analysis
**IT Internship Training Program**

> **Goal:** Compare the Total Cost of Ownership (TCO) and High Availability for running the Internship Training Lab across physical and cloud architectures. (Estimated in INR).

---

## 1. Resource Requirements
To run the full lab environment (pfSense, Windows DC, Ubuntu App, NMS, Security, Veeam) for a cohort of 10 students, we require approximately:
*   **Compute**: 16 to 20 vCPUs
*   **Memory**: 64 GB to 96 GB RAM
*   **Storage**: 1 TB to 2 TB SSD/NVMe

---

## 2. The Risk of Physical Servers (Single Point of Failure)
When considering physical hardware, **Failover and Reliability** must be addressed. 
If the organization purchases a single refurbished Dell physical server and a critical component (e.g., motherboard or power supply) dies, the entire training program is **stuck offline for days** while waiting for replacement parts. 
To achieve "Cloud-like" reliability on-premise, you must purchase **two** physical servers and configure Proxmox High Availability (HA) clustering. This immediately doubles the upfront CapEx cost to **₹1,50,000+**. 

Because of this failover risk, Cloud hosting becomes highly attractive. If cloud hardware fails, the provider automatically migrating VMs to new hardware in seconds.

---

## 3. Cloud Provider Comparison: Which is Best?

If the organization chooses cloud hosting to mitigate the physical failover risk, there are two distinct paths depending on the priority: **Convenience** vs. **Cost**.

### A. The "Most Convenient" Cloud: Microsoft Azure
*Azure is recommended if the priority is native cloud VMs with automated enterprise management.*
*   **Why it's convenient**: Azure features **Azure DevTest Labs**, explicitly designed for training environments. It can automatically shut down all student VMs at 6:00 PM daily to prevent accidental overnight billing. It also integrates seamlessly with the Microsoft 365 Developer tenant used in Phase 3.
*   **The Cost**: High. Even with auto-shutdown (On-Demand pricing of approx. 160 hours/month), Azure will cost **~₹22,000 to ₹25,000 / month** for 20 vCPUs, 64GB RAM, and Windows Server licensing.
*   **Verdict**: Best for management convenience; worst for budget.

### B. The "Cheapest Alternative" Cloud: Hetzner / OVHcloud (Bare-Metal Cloud)
*Hetzner and OVH rent dedicated physical servers in their datacenters by the month.*
*   **Why it's cheap**: Instead of paying per-hour for virtual instances, you rent a massive dedicated server in their datacenter for a flat monthly fee. You receive full root access, install Proxmox VE on it, and run the lab exactly like a local server. If a hard drive fails, their datacenter technicians replace it within hours for free.
*   **The Cost**: Incredibly cheap. A dedicated server with an AMD Ryzen CPU (12+ Cores), 64GB RAM, and 1TB NVMe costs roughly **€60 to €80/month (~₹5,500 to ₹7,500 / month)** flat rate, running 24/7.
*   **Verdict**: Best for budget. You get the cheap fixed-cost of a physical server, combined with the hardware-replacement guarantee of the cloud.

### C. Amazon Web Services (AWS)
*   **Why to avoid for this specific lab**: While AWS is the industry standard, its Windows Server licensing rules and nested virtualization (running Proxmox inside EC2) are notoriously difficult and expensive to configure compared to Azure or Hetzner. AWS Academy exists, but strict limits usually prevent running 6 heavy VMs simultaneously per student.

---

## 4. Executive Summary

| Setup Option | Upfront Cost | Monthly OpEx | Year 1 Total | Failover / Hardware Risk |
| :--- | :--- | :--- | :--- | :--- |
| **Physical Refurbished (No Failover)** | ₹75,000 | ₹2,000 | **₹99,000** | **HIGH**: Lab dies if hardware fails. |
| **Physical HA Cluster (2 Servers)** | ₹1,50,000 | ₹4,000 | **₹1,98,000**| **LOW**: Seamless failover to Server 2. |
| **Azure DevTest Labs (On-Demand)** | ₹0 | ₹25,000 | **₹3,00,000**| **ZERO**: Microsoft manages hardware. |
| **Hetzner Dedicated Bare-Metal (24/7)** | ₹0 | ₹7,500 | **₹90,000** | **LOW**: Datacenter replaces parts fast. |

---

## 5. Final Recommendation

If the organization cannot risk the downtime associated with a local physical server failing (and lacks the budget for a two-server HA cluster), **do not purchase a local refurbished server**. 

**Recommendation: Rent a Dedicated Bare-Metal Server from Hetzner (or OVH).** 
At **~₹7,500/month**, it is actually *cheaper* over a one-year period (₹90,000) than buying and powering a single local physical server. It can run 24/7 so students can practice anytime, and if the hardware dies, the datacenter staff resolves the issue at no extra cost, effectively solving the failover risk on a budget.
