# Repository Architecture

This is a **Documentation-as-Code** repository storing the curriculum, runbooks, and build scripts for an Enterprise IT Internship Training Lab.

## Core Architectural Components

1. **Master Runbook (`Master_Runbook.md`)**: The central source of truth containing the Phase 0 to Phase 3 curriculum, built for offline reading.
2. **Phase Guides (`phase-1-*`, `phase-2-*`, etc.)**: Individual module breakdowns containing scenario-based labs for students.
3. **Interactive Dashboards (`kanban.html`, `pitch.html`, `architecture.html`)**: Rich UI web applications serving as interactive tools for the students and management.
4. **Build Tools (`build_tools.py`)**: Utility scripts to compile or validate the curriculum.

**Design Philosophy**:
The repo enforces a strict 3-Phase learning model, starting from Support Fundamentals and scaling up to Advanced Automation, leveraging a unified Proxmox ecosystem.
