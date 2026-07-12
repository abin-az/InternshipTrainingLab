# Think Polaris IT Internship: Student Experience & Provisioning Plan

This document outlines exactly what each intern will receive, how they will securely access the lab, and how the Think Polaris infrastructure team will provision their environment.

---

## 1. How Students Connect to the Lab

To ensure maximum security and lowest friction for the interns (who may be using personal, low-spec laptops), we will use an **HTML5 Clientless Gateway (Apache Guacamole)**. 

### The Connection Flow
1. **No VPN Required:** Students simply open their local web browser and navigate to `lab.thinkpolaris.com`.
2. **Authentication:** They log in using their unique Think Polaris Active Directory credentials.
3. **Remote Desktop in Browser:** Guacamole instantly connects them to their dedicated Windows Client VM inside the lab. The desktop streams directly into their browser tab. 
*Note: If Guacamole is too heavy to host, we will fall back to an OpenVPN profile generated from our pfSense firewall.*

---

## 2. What Each Student Gets (The Workspace)

When a student logs in, they are not just getting a blank computer; they are entering a fully simulated corporate enterprise network. 

### A. Dedicated Client VM
- **OS**: Windows 10/11 Enterprise (Deployed via Proxmox Linked Clones to save storage).
- **Specs**: 2 vCPUs, 4GB RAM, 50GB Shared Disk.
- **Network**: Placed on the `Intern_VLAN` (isolated from destroying core infrastructure, but able to ping essential services).

### B. Enterprise Identity (Active Directory)
- A standard user account in the `THINKPOLARIS.LOCAL` domain.
- Group Policy Objects (GPOs) applied to their machine (e.g., mapped network drives, restricted control panel access, forced lock screens).

### C. Pre-Installed IT Tooling
Their golden image will come pre-loaded with standard IT Helpdesk and SysAdmin tools:
- **RSAT (Remote Server Admin Tools)**: For managing AD Users and Computers (if they are assigned admin rights for an exercise).
- **Network Tools**: PuTTY, Wireshark, Advanced IP Scanner.
- **Monitoring Agents**: Wazuh Security Agent and GLPI Inventory Agent running silently in the background.

---

## 3. How We Setup and Provision Students

Provisioning 50 students manually would take days. We will use a highly automated workflow:

### Step 1: Golden Image Creation (Instructor Task)
The instructor builds one perfect Windows 10 VM, joins it to the domain, installs all tools, and runs `Sysprep`. This becomes the "Golden Image."

### Step 2: Automated Cloning (Proxmox)
Using a simple Proxmox shell script, we instantly clone the Golden Image 50 times using "Linked Clones." This takes seconds per VM and uses almost zero additional hard drive space.

### Step 3: AD User Creation (PowerShell)
The instructor runs a PowerShell script on the Windows Server Domain Controller, feeding it a `.csv` file of the 50 student names. The script instantly creates 50 AD accounts, sets default passwords, and assigns them to the "Interns" Security Group.

### Step 4: Guacamole Mapping
The new AD users are synced to Apache Guacamole, tying Student A's account exclusively to Student A's VM. 

---

## 4. The Student's Technical Journey

Once provisioned, here is what the intern actually does inside the environment:

1. **Phase 2 (Support Fundamentals):** They log into the GLPI Helpdesk portal. They receive tickets (e.g., "User locked out of AD" or "Software needs installing"). They use their VM to execute these fixes.
2. **Phase 3 (Networking & Security):** They use their VM to trigger security events (e.g., failed logins, downloading test malware). They then log into the Wazuh SIEM dashboard to see how their VM's agent reported the attack to the security team.
3. **Phase 4 (Automation):** They use PowerShell ISE on their VM to write scripts that ping servers across the network, automatically mapping the topology. 

**Conclusion:** The student gets a zero-friction, browser-based entry into a real corporate network. They have their own dedicated machine that they can break and fix, heavily monitored by enterprise-grade SIEM and Ticketing tools.
