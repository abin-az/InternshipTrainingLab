# Requirements

## Scope
Formalize the existing IT Internship curriculum and architecture into a trackable GSD project structure, establishing a foundation for any future expansion or scaling of the cloud lab.

## User Stories
- As an Instructor, I need the curriculum structured into distinct, verifiable phases (Support, Network/Security, Automation) so I can systematically evaluate student progress.
- As a Student, I need the lab to run entirely on a remote bare-metal server (Hetzner) so my physical laptop is not bogged down by heavy virtualization.
- As a Lab Architect, I need the design documented as-code (Markdown/HTML) so I can easily version control and update the network topology without losing historical context.

## Non-Functional Requirements
- **Performance**: The server must support 10 concurrent student sessions initially, scaling up to 50 in the future.
- **Cost Efficiency**: Local physical infrastructure (UPS, heavy firewalls) must be eliminated in favor of a flat-rate Hetzner cloud server.
- **Branding**: All curriculum documents, HTML dashboards, and communications must be officially branded as "Think Polaris".

## Definition of Done
- Existing 4-phase curriculum is fully represented in the GSD planning structure.
- Infrastructure architecture is definitively locked to the Proxmox/Hetzner design pattern.
