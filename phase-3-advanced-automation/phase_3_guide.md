# Phase 3: Advanced Administration & Automation

> **Objective**: Manage enterprise-scale workloads, implement disaster recovery, explore cloud computing, and automate routine tasks.

## P13: Backup and Recovery
**Tools**: Veeam Community Edition
**Scenario Lab**:
1. Log into the Veeam Backup Console on the Windows Server.
2. Create a backup job to back up the `APP01` server to a dedicated storage drive.
3. Run the backup manually. Once complete, perform a test file-level restore of a specific configuration file in `/etc/apache2`.

## P14: Patch Management
**Tools**: WSUS (Windows Server Update Services), Group Policy
**Scenario Lab**:
1. Log into the WSUS console on `DC01`.
2. Approve a critical Windows Defender definition update for deployment.
3. Create a GPO in Active Directory to configure client laptops to download updates from your internal WSUS server rather than Microsoft servers over the internet.

## P15: Remote Support and Endpoint Control
**Tools**: MeshCentral, RustDesk, Sysinternals Suite
**Scenario Lab**:
1. Launch MeshCentral and view the active endpoints.
2. An instructor will pretend to have a locked desktop. Use RustDesk to simulate a remote assistance session to unlock it for them.
3. Use Process Explorer (from the Sysinternals Suite) on a test VM to identify a hung application process and kill it safely.

## P16: Cloud and SaaS Exposure
**Tools**: Microsoft 365 Developer, Azure Free Account, ServiceNow Developer Instance
**Scenario Lab**:
1. Log into the M365 Admin Center. Understand how on-premise AD relates to Entra ID (Azure AD).
2. Create a cloud-only user account and assign them a license.
3. Log into your free ServiceNow Developer Instance. Create a mock Incident and see how it differs from your local GLPI system.

## P17: Automation and Version Control
**Tools**: VS Code, PowerShell 7, Python, Git, GitHub
**Scenario Lab**:
1. Install VS Code and Git on your laptop.
2. Write a PowerShell script that accepts a CSV file of 10 names and automatically creates Active Directory user accounts for them.
3. Commit your PowerShell script to a shared GitHub repository.
4. Write a simple Python script to ping a list of IPs and report which ones are offline.

## P18: Student Local Practice (Optional)
**Tools**: Oracle VirtualBox
**Scenario Lab**:
- If required for homework, install VirtualBox on your physical laptop and deploy a lightweight Ubuntu server to practice Linux commands locally without requiring VPN access to the main lab network.
