# Phase 1: Support Fundamentals

> **Objective**: Learn the core components of user identity, ticketing, and documentation.

## P4: Identity and Access Foundation
**Tools**: Active Directory, DNS, DHCP
**Scenario Lab**: 
1. Log into the `DC01` server via RDP.
2. Open Active Directory Users & Computers.
3. Create a test user account. Practice resetting the password and unlocking the account.
4. Verify the DHCP scope assigns IPs correctly to client laptops.

## P5: Access Utilities
**Tools**: PuTTY, WinSCP, RDP
**Scenario Lab**:
1. Download and install PuTTY and WinSCP on your student laptop.
2. Use PuTTY to SSH into the `APP01` Ubuntu server.
3. Use WinSCP to securely transfer a text file from your Windows laptop to the Ubuntu server.

## P6: Service Desk & Knowledge Base
**Tools**: GLPI, BookStack, MariaDB
**Scenario Lab**:
1. Access the GLPI web interface at `http://APP01/glpi`.
2. A user submits a ticket: "I cannot access my email." Claim the ticket.
3. **Soft Skills Integration**: Draft a professional, polite, and grammatically correct update to the end-user explaining the issue and the resolution steps. Paste this into the ticket before resolving it.
4. Access BookStack at `http://APP01/bookstack`. Write a Standard Operating Procedure (SOP) on how to reset an AD password.

## P7: Asset and Endpoint Inventory
**Tools**: OCS Inventory (integrated with GLPI)
**Scenario Lab**:
1. Install the OCS Inventory agent on a test Windows 10 VM.
2. Verify that the asset appears in the GLPI hardware inventory dashboard.
3. Link the hardware asset to a simulated IT ticket.

---

## 🏆 Phase 1 Assessment Checkpoint
Before progressing to Phase 2, students must pass this structured evaluation:
1. **Live Demonstration**: The student must share their screen and successfully reset an Active Directory user password while an instructor observes.
2. **Documentation Review**: The instructor reviews the student's BookStack SOP and a sample GLPI ticket response for technical accuracy and soft-skill professionalism.
