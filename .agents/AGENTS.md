# Project Rules — IT Internship Training Program

## Git Commit Rule
- **Every file change must be followed by a `git commit`** with a clear, descriptive summary message.
- Commit messages should follow this format: `[Area] Brief description of what changed`
- Examples:
  - `[Sprint 1] Add VirtualBox setup guide`
  - `[Kanban] Update Sprint 7 tasks with Okta and Cloudflare`
  - `[Architecture] Update ecosystem map with Cloudflare Tunnel flow`
  - `[Build] Regenerate Master_Runbook.md with latest guides`
- If multiple files are changed together as part of one logical update, commit them together in a single commit.
- Never leave uncommitted changes in the working tree.

## Project Location
- All project files live at: `D:\Internship_Lab_Project\IT-Internship-Training-Program`
- VMs are stored at: `D:\LabVMs\`
- ISOs are stored at: `D:\LabISOs\`

## Build Workflow
- After updating any Markdown guide, run `python build_tools.py` to regenerate `Master_Runbook.md`.
- After updating kanban data, remind the user to click "Reset Board" in the browser to load new defaults.
- Sprint guides are generated iteratively: only create guides for the next sprint after the current one is complete.
