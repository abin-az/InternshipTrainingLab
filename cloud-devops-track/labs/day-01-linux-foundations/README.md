# Day 01: Linux Foundations & Shell Mastery

> **Track**: Think Polaris Cloud & DevOps Engineer 30-Day Mastery Track  
> **Phase**: Phase 1: Systems & Networking Foundations  
> **Day**: 01 of 30  
> **Estimated Time**: 3 Hours (1 Hour Theory + 2 Hours Lab)

---

## 🎯 Objectives
By the end of Day 1, students will be able to:
1. Verify their local WSL2 or PowerEdge Proxmox VM development environment using automated scripts.
2. Navigate the Linux directory hierarchy and identify disk usage bottlenecks using `df` and `du`.
3. Process raw server logs using shell pipelines (`grep`, `awk`, `sed`, `cut`, `sort`, `uniq`).
4. Apply octal and symbolic Linux file permissions (`chmod`, `chown`) to enforce security boundaries.
5. Execute a production-grade defensive Bash script (`backup_home.sh`) with error traps, SHA-256 integrity verification, and automatic retention cleanup.

---

## 📂 Day 01 Lab Files
- [verify_environment.sh](file:///d:/optimistic-meitner/cloud-devops-track/labs/day-01-linux-foundations/verify_environment.sh): Automated audit script verifying that all required cloud, container, and networking CLI tools are installed and ready.
- [backup_home.sh](file:///d:/optimistic-meitner/cloud-devops-track/labs/day-01-linux-foundations/backup_home.sh): Defensive Bash script with `set -euo pipefail`, error trapping, space checking, tar gzip compression, SHA-256 verification, and 7-day retention purging.
- [lab_exercises.md](file:///d:/optimistic-meitner/cloud-devops-track/labs/day-01-linux-foundations/lab_exercises.md): Complete hands-on laboratory drill instructions.

---

## 🚀 Quick Start
```bash
# 1. Audit your environment
chmod +x verify_environment.sh
./verify_environment.sh

# 2. Run the exercises
cat lab_exercises.md

# 3. Execute the Day 1 backup script
chmod +x backup_home.sh
./backup_home.sh "${HOME}" /tmp/polaris_backups
```
