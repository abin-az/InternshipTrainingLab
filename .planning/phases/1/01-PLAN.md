# Phase 1: Vendor Selection & Infrastructure Analysis

**Goal**: Finalize the cloud provider choice and budget scaling model for the Think Polaris IT Internship Training Program.

## Task 1: Vendor Pricing Comparison
- **Description**: Perform a detailed analysis of Hetzner (Bare Metal) vs. OVH (Bare Metal) vs. Azure (Cloud VM).
- **Files Modified**: 
  - `architecture/Vendor_and_Scaling_Analysis.md` (NEW)
- **Constraints**: Compare based on the requirement of nested virtualization, 128GB+ RAM, and flat-rate monthly pricing.

## Task 2: Scaling Budget Mapping
- **Description**: Document exact pricing scaling across three phases in the new analysis report.
- **Details**:
  - Phase A (Setup): Minimum testing config.
  - Phase B (10 Students): ~₹7,500/month config.
  - Phase C (50 Students): Massive parallel access scale.
- **Files Modified**:
  - `architecture/Vendor_and_Scaling_Analysis.md`

## Task 3: Security & Management Analysis
- **Description**: Define the Shared Responsibility Model.
- **Details**: Explicitly clarify what Hetzner manages (Physical DC, Hardware) vs what Think Polaris manages (Proxmox, pfSense firewall, VMs). Dispels the assumption that Bare-Metal is a fully managed PaaS like Azure.
- **Files Modified**:
  - `architecture/Vendor_and_Scaling_Analysis.md`

## Verification
- Run `gsd-verify-work` to ensure the report directly answers the management queries regarding price, scaling up to 50 students, and the security model.
