# Think Polaris IT Internship Training Program

## What This Is

The **Think Polaris** 3-Phase Enterprise Think Polaris IT Internship Training Program curriculum and architecture repository. It simulates a realistic enterprise IT environment (using Proxmox VE or Hetzner Bare-Metal) so Think Polaris interns can learn Level 1, 2, and 3 IT Support and Security skills without installing heavy software locally.

## Core Value

To provide a fully immersive, zero-local-install, simulated enterprise environment where interns can safely practice real-world IT troubleshooting, networking, and automation.

## Requirements

### Validated

- ✓ Interactive Management Dashboards (Kanban, Pitch HTML)
- ✓ Comprehensive 3-Phase Markdown Curriculum
- ✓ Master Runbook integration
- ✓ Infrastructure Cost Analysis and Architecture Diagrams (Hetzner Bare-Metal design)

### Active

- [ ] [To be defined by user for the upcoming phase]

### Out of Scope

- [GNS3 and legacy network simulators] — explicitly banned due to resource heaviness and complexity; all simulation is done via Proxmox/Hetzner VMs and real OS routing.

## Context

- **Infrastructure**: Targeted at Hetzner Cloud (AMD Ryzen, 64GB+ RAM, NVMe) to avoid local hardware failure risks (UPS, AC).
- **Network Security**: Uses pfSense as the core firewall and routing engine.
- **Monitoring/SIEM**: Incorporates Zabbix and Wazuh.
- **Ticketing**: Uses GLPI for realistic Helpdesk simulation.

## Constraints

- **Tech Stack**: No local student virtualization; all heavy lifting is on the server.
- **Tooling restrictions**: Banned tools include GNS3, VirtualBox (on student laptops), and legacy hypervisors.
- **UI/UX**: Any web interface must follow modern "Glassmorphism" aesthetics without relying on TailwindCSS.

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Cloud Bare-Metal over Local Server | Eliminates local UPS/AC costs, failover risks, and provides easy scaling from ₹3.5K to ₹16K/month. | — Pending |
| Virtualized pfSense | Saves ₹30,000+ on hardware firewall appliances while providing enterprise realism. | — Pending |
| Shared Responsibility Security | Hetzner manages physical security; the Instructor MUST lock down pfSense to secure the raw public IP. | — Pending |

---
*Last updated: 2026-07-12 after initialization*

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state
