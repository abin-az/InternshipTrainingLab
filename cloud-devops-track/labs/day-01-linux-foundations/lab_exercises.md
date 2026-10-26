# Day 01 Hands-On Lab Exercises: Linux CLI & System Plumbing

> **Duration**: 2 Hours  
> **Target Environment**: Ubuntu 22.04 LTS (WSL2 or PowerEdge Lab VM)  
> **Prerequisite**: Complete [00_SETUP_AND_PREREQUISITES.md](file:///d:/optimistic-meitner/cloud-devops-track/00_SETUP_AND_PREREQUISITES.md) and pass `verify_environment.sh`.

---

## Exercise 1: Linux Filesystem Navigation & Storage Auditing

### Context
In cloud engineering, storage exhaustion (`No space left on device`) is one of the top causes of production service crashes. You must be able to inspect mounts, identify large files, and diagnose disk usage in seconds.

### Commands to Run:
```bash
# 1. Inspect block devices and storage topology
lsblk -f

# 2. Inspect filesystem disk space in human-readable gigabytes
df -hT

# 3. Identify the top 5 largest directories in /var/log
sudo du -ah /var/log 2>/dev/null | sort -rh | head -n 5
```

### Self-Check Question:
- What is the difference between `df -h` and `du -sh`? Which one reports file system allocation from the superblock, and which one traverses the directory tree?

---

## Exercise 2: Text Processing Pipelines (`grep`, `awk`, `sed`, `cut`)

### Context
Cloud logs (Nginx, AWS CloudWatch, Kubernetes container logs) are plain text streams. Cloud engineers do not open 2GB log files in a GUI text editor; they filter them with stream processors.

### Step 1: Create a Simulated Production Web Server Log
Run this command in your terminal to generate `sample_access.log`:

```bash
cat << 'EOF' > /tmp/sample_access.log
192.168.1.10 - - [26/Oct/2026:08:14:01 +0000] "GET /index.html HTTP/1.1" 200 4523
192.168.1.15 - - [26/Oct/2026:08:14:03 +0000] "POST /api/login HTTP/1.1" 401 234
192.168.1.10 - - [26/Oct/2026:08:14:05 +0000] "GET /style.css HTTP/1.1" 200 1205
10.0.50.22   - - [26/Oct/2026:08:14:06 +0000] "GET /admin/db HTTP/1.1" 403 542
192.168.1.15 - - [26/Oct/2026:08:14:10 +0000] "POST /api/login HTTP/1.1" 401 234
172.16.0.99  - - [26/Oct/2026:08:14:12 +0000] "GET /api/checkout HTTP/1.1" 500 89
192.168.1.15 - - [26/Oct/2026:08:14:15 +0000] "POST /api/login HTTP/1.1" 200 1024
10.0.50.22   - - [26/Oct/2026:08:14:18 +0000] "GET /admin/config HTTP/1.1" 403 542
172.16.0.99  - - [26/Oct/2026:08:14:22 +0000] "GET /api/checkout HTTP/1.1" 500 89
192.168.1.50 - - [26/Oct/2026:08:14:25 +0000] "GET /products HTTP/1.1" 200 8901
EOF
```

### Step 2: Execute Stream Processing Drills

#### Drill A: Filter all HTTP 500 Internal Server Errors
```bash
grep ' 500 ' /tmp/sample_access.log
```

#### Drill B: Extract IP Addresses of Failed Login Attempts (HTTP 401)
```bash
grep ' 401 ' /tmp/sample_access.log | awk '{print $1}'
```

#### Drill C: Count Unique Access Attempts Per IP Address
```bash
awk '{print $1}' /tmp/sample_access.log | sort | uniq -c | sort -nr
```
*Expected Output: `192.168.1.15` and `192.168.1.10` show highest frequency.*

#### Drill D: Mask Internal IP Addresses with `sed` (Stream Editor)
```bash
sed -E 's/192\.168\.[0-9]+\.[0-9]+/REDACTED_IP/g' /tmp/sample_access.log
```

---

## Exercise 3: Linux Permissions & Security Boundaries

### Context
Improper permissions either break applications (e.g. Nginx returning `403 Forbidden` because it cannot read web files) or introduce massive security vulnerabilities (world-writable configuration files).

### Commands to Run:
```bash
mkdir -p /tmp/polaris_lab
cd /tmp/polaris_lab

# 1. Create three files with varying security levels
touch public_file.txt internal_conf.cfg id_rsa_mock

# 2. Set strict permissions for an SSH private key (User read/write ONLY)
chmod 600 id_rsa_mock
ls -l id_rsa_mock
# Expected: -rw-------

# 3. Set standard web file permissions (User read/write, Group/Others read only)
chmod 644 public_file.txt
ls -l public_file.txt
# Expected: -rw-r--r--

# 4. Set directory permissions for secure key storage (User read/write/execute ONLY)
chmod 700 /tmp/polaris_lab
ls -ld /tmp/polaris_lab
# Expected: drwx------
```

---

## Exercise 4: Process Management & Systemd Service Control

### Commands to Run:
```bash
# 1. View all running processes matching 'cron' or 'ssh'
ps aux | grep -E 'cron|ssh'

# 2. Inspect CPU and Memory consumption using top (Press 'q' to quit)
top -b -n 1 | head -n 15

# 3. Check the status of the cron system service
systemctl status cron --no-pager

# 4. View recent system logs for the cron daemon
journalctl -u cron -n 10 --no-pager
```

---

## Exercise 5: Run the Day 1 Production Backup Script

```bash
# Navigate to the Day 1 lab directory
cd ~/optimistic-meitner/cloud-devops-track/labs/day-01-linux-foundations/

# Make the backup script executable
chmod +x backup_home.sh

# Run the backup targeting a test directory in /tmp
./backup_home.sh "${HOME}" /tmp/polaris_backups

# Verify the generated archive and checksum
ls -lh /tmp/polaris_backups/
cat /tmp/polaris_backups/*.sha256
```

---

## Submission Output Required for Day 1

Take a screenshot or copy the terminal output of:
1. `verify_environment.sh` showing all `[PASS]` checks.
2. The one-line `awk | sort | uniq -c` command ranking IP addresses from `sample_access.log`.
3. The successful output of `./backup_home.sh` showing the SHA-256 checksum and log confirmation.
