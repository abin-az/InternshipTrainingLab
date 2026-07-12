# Technical Concerns

**1. Context Drift in Documentation:**
Because the Master Runbook and Phase Guides share duplicated context, updating one without updating the other leads to drift. The `build_tools.py` script should ideally be used to automatically compile the Master Runbook from the Phase Guides.

**2. Hardcoded Values in HTML:**
`kanban.html` contains hardcoded JSON data for its initial state. If the curriculum phases change, this hardcoded data must be manually updated via regex or string replacement, which is brittle.

**3. Sub-optimal Build Pipeline:**
The repository currently lacks a CI/CD pipeline (e.g., GitHub Actions) to automatically validate Markdown links or syntax.
