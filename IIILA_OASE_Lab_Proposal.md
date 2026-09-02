# IIILA OASE: IT Internship Lab Working Plan & Proposal

## 1. Executive Summary
This document outlines the working plan for establishing a training lab for college students undertaking the Think Polaris IT Internship Training Program. 

After comprehensive analysis, we strongly recommend a **Cloud-First Hybrid Model** over a traditional pure on-premises setup. This approach maximizes educational value, ensures students learn modern industry-relevant skills (as 80%+ of enterprises utilize cloud infrastructure), and significantly reduces capital expenditures and maintenance burdens for the institution.

## 2. Setup Comparison: On-Premises vs. Cloud Provider

| Factor | Pure On-Premises Setup | Cloud-Based / Hybrid Setup (Recommended) | Verdict for College Labs |
| :--- | :--- | :--- | :--- |
| **Initial Cost** | High ($4k-$8k+ for server, networking, rack) | Low-Moderate (uses educational grants/free tiers) | ✅ Cloud wins |
| **Ongoing Cost** | Continuous (power, cooling, hardware replacement) | Variable (pay-as-you-go, shutdown when idle) | ✅ Cloud wins |
| **Accessibility**| Requires physical lab access or complex VPN | Accessible from anywhere with internet | ✅ Cloud wins |
| **Maintenance** | High (faculty/IT staff manages patches, failures) | Low (cloud provider handles underlying infrastructure) | ✅ Cloud wins |
| **Scalability** | Fixed by hardware limits | Instantly scalable per student/exercise | ✅ Cloud wins |
| **Curriculum** | Excellent for Phase 0 (low-level virtualization) | Highly relevant for Phases 1-3 | ⚖️ Tie |

## 3. Recommended Approach: Cloud-First Hybrid Model

### Phase 0: Simplified Virtualization/Networking
* **Instead of physical Proxmox/pfSense:** Use cloud Virtual Private Clouds (AWS VPC, Azure VNet) to teach subnetting, routing, and security groups.
* **Firewall Practice:** Deploy lightweight firewall VMs (OPNsense, VyOS) in the cloud.

### Phases 1-3: Cloud-Adapted Tools Installation Matrix
| Original Tool / Concept | Cloud Adaptation Strategy |
| :--- | :--- |
| **AD / Domain Controller** | Azure AD Domain Services OR Windows Server VM in cloud. |
| **DNS / DHCP** | Cloud DNS (Route 53, CloudDNS) OR Windows Server VM. |
| **GLPI / BookStack** | Deploy as Docker containers in cloud VMs OR use SaaS free tiers. |
| **Zabbix / Prometheus** | Deploy as cloud VMs OR use managed services (Azure Monitor). |
| **Wazuh / Wireshark** | Deploy in isolated cloud subnet; use VPC flow logs for analysis. |
| **OpenVAS / DVWA**| Deploy in isolated cloud subnet (strict egress controls). |
| **Veeam / WSUS** | Cloud-native backup (AWS Backup) OR Veeam agents in VMs. |
| **PowerShell / Python** | Identical execution in cloud VMs (Zero curriculum change needed). |

## 4. Hardware Procurement (Minimalist On-Prem Component)
If the institution strictly requires physical hardware for accreditation, shared services, or local jump-host security, we recommend a minimal hardware footprint:

* **1x Moderate Enterprise Server (Refurbished/Used)**
  * **CPU:** 8-16 core (Xeon/AMD EPYC)
  * **RAM:** 64GB ECC
  * **Storage:** 2TB SSD RAID 1
  * **Networking:** 2x 1GbE (or 10GbE)
  * **Estimated Cost:** $1,500 - $2,500
* **Purpose:** Host shared internal services (internal GitLab, Docker registry) or act as a secure Bastion/Jump host to the cloud environments.

## 5. 3-Year Total Cost of Ownership (TCO) Estimate
*Assumptions: 30 students per section, 2 sessions/week, educational grants applied.*

### Pure On-Premises (Original Plan)
* **Initial CAPEX:** ~$5,300 (Physical Server: $4,500, Networking/Rack: $800)
* **Annual OPEX:** ~$3,120 (Power/Cooling: $420, Hardware Replacement Fund: $900, IT Staff Maintenance: $1,500, Licenses: $300)

### Cloud-First Hybrid (Recommended Plan)
* **Initial CAPEX:** $0 (or up to $2,500 if the optional shared-services server is procured).
* **Annual OPEX:** $200 (Minimal maintenance) + **$15-$40 per student/semester**.
* **Note:** By utilizing AWS Educate, Azure for Students, or GCP Education grants, the actual student cost can frequently be offset entirely ($100/student/year in free credits).

## 6. Implementation Steps
1. Apply for Institutional Cloud Educational Grants (AWS/Azure/GCP).
2. Develop Infrastructure as Code (Terraform/Bicep) templates for one-click student lab deployments.
3. Establish strict network isolation (VPCs/Subnets) for security-focused labs (OpenVAS/DVWA).
4. Shift curriculum assessment to evaluate cloud-equivalent skills (e.g., analyzing VPC flow logs instead of raw span ports).
