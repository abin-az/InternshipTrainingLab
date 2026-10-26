#!/usr/bin/env bash
# ==============================================================================
# Think Polaris Cloud & DevOps Engineer 30-Day Mastery Track
# Day 01: Production-Grade Defensive Directory Backup Script
#
# Description:
#   Performs an incremental, compressed archive of a source directory (defaults
#   to user's home), computes an SHA-256 checksum for cryptographic verification,
#   logs execution details, and enforces a retention policy to delete archives
#   older than 7 days.
#
# Usage:
#   chmod +x backup_home.sh
#   ./backup_home.sh [SOURCE_DIR] [TARGET_BACKUP_DIR]
#
# Examples:
#   ./backup_home.sh
#   sudo ./backup_home.sh /home /backup
# ==============================================================================

# Defensive Shell Execution Guardrails
set -euo pipefail

# ANSI Color Codes for Terminal Output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Configuration Variables & Defaults
TIMESTAMP=$(date +"%Y-%m-%d_%H%M%S")
SOURCE_DIR="${1:-${HOME}}"
TARGET_DIR="${2:-/backup}"
RETENTION_DAYS=7
LOG_FILE="${TARGET_DIR}/backup.log"

# Cleanup & Error Trap Function
cleanup_on_error() {
    local exit_code=$?
    echo -e "\n${RED}[CRITICAL ERROR]${NC} Backup pipeline terminated unexpectedly on line ${BASH_LINENO[0]} with exit code ${exit_code}." >&2
    if [ -f "${ARCHIVE_FILE:-}" ] && [ ! -f "${CHECKSUM_FILE:-}" ]; then
        echo -e "${YELLOW}[WARN] Removing incomplete archive: ${ARCHIVE_FILE}${NC}" >&2
        rm -f "${ARCHIVE_FILE}"
    fi
    exit "${exit_code}"
}
trap cleanup_on_error ERR

# Logging Helper Function
log_msg() {
    local level="$1"
    local message="$2"
    local log_timestamp
    log_timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local formatted_entry="[${log_timestamp}] [${level}] ${message}"

    case "${level}" in
        "INFO")  echo -e "${CYAN}${formatted_entry}${NC}" ;;
        "PASS")  echo -e "${GREEN}${formatted_entry}${NC}" ;;
        "WARN")  echo -e "${YELLOW}${formatted_entry}${NC}" ;;
        "ERROR") echo -e "${RED}${formatted_entry}${NC}" >&2 ;;
    esac

    # Append to log file if directory is writable
    if [ -w "$(dirname "${LOG_FILE}")" ] || [ -w "${LOG_FILE}" ]; then
        echo "${formatted_entry}" >> "${LOG_FILE}" 2>/dev/null || true
    fi
}

# 1. Pre-Flight Validation
log_msg "INFO" "Starting Think Polaris automated backup utility..."
log_msg "INFO" "Source Directory: ${SOURCE_DIR}"
log_msg "INFO" "Target Directory: ${TARGET_DIR}"

if [ ! -d "${SOURCE_DIR}" ]; then
    log_msg "ERROR" "Specified source directory '${SOURCE_DIR}' does not exist!"
    exit 1
fi

# Ensure Target Directory Exists
if [ ! -d "${TARGET_DIR}" ]; then
    log_msg "WARN" "Target directory '${TARGET_DIR}' not found. Attempting creation..."
    mkdir -p "${TARGET_DIR}" || {
        log_msg "ERROR" "Failed to create '${TARGET_DIR}'. Run with sudo or select a writable path."
        exit 1
    }
fi

# Verify Target Directory Write Permissions
if [ ! -w "${TARGET_DIR}" ]; then
    log_msg "ERROR" "Target directory '${TARGET_DIR}' is not writable by current user (${USER})."
    exit 1
fi

# 2. Check Disk Space Availability
SOURCE_SIZE_KB=$(du -s "${SOURCE_DIR}" 2>/dev/null | awk '{print $1}')
AVAILABLE_KB=$(df -P "${TARGET_DIR}" | awk 'NR==2 {print $4}')

log_msg "INFO" "Source Payload Size: $((SOURCE_SIZE_KB / 1024)) MB"
log_msg "INFO" "Available Disk Space: $((AVAILABLE_KB / 1024)) MB"

if [ "${SOURCE_SIZE_KB}" -ge "${AVAILABLE_KB}" ]; then
    log_msg "ERROR" "Insufficient disk space! Target volume has only $((AVAILABLE_KB / 1024)) MB available."
    exit 1
fi

# 3. Create Compressed Archive
SOURCE_BASENAME=$(basename "${SOURCE_DIR}")
ARCHIVE_NAME="${SOURCE_BASENAME}_backup_${TIMESTAMP}.tar.gz"
ARCHIVE_FILE="${TARGET_DIR}/${ARCHIVE_NAME}"
CHECKSUM_FILE="${ARCHIVE_FILE}.sha256"

log_msg "INFO" "Compressing archive to: ${ARCHIVE_FILE}..."

# Exclude unneeded cache, sockets, and virtual environments to optimize backup time and space
tar --exclude='.cache' \
    --exclude='*.sock' \
    --exclude='*.tmp' \
    --exclude='node_modules' \
    --exclude='.terraform' \
    -czf "${ARCHIVE_FILE}" -C "$(dirname "${SOURCE_DIR}")" "${SOURCE_BASENAME}"

ARCHIVE_SIZE_MB=$(du -m "${ARCHIVE_FILE}" | awk '{print $1}')
log_msg "PASS" "Compression completed successfully. Archive size: ${ARCHIVE_SIZE_MB} MB."

# 4. Generate SHA-256 Checksum for Integrity Verification
log_msg "INFO" "Computing cryptographic SHA-256 integrity hash..."
sha256sum "${ARCHIVE_FILE}" > "${CHECKSUM_FILE}"
HASH_VALUE=$(awk '{print $1}' "${CHECKSUM_FILE}")
log_msg "PASS" "SHA-256: ${HASH_VALUE}"

# Verify Checksum
if sha256sum -c "${CHECKSUM_FILE}" >/dev/null 2>&1; then
    log_msg "PASS" "Archive integrity verified against SHA-256 manifest."
else
    log_msg "ERROR" "Checksum verification failed! Archive may be corrupted."
    exit 1
fi

# 5. Enforce Retention Policy (Prune archives older than RETENTION_DAYS)
log_msg "INFO" "Enforcing ${RETENTION_DAYS}-day backup retention policy in ${TARGET_DIR}..."
PRUNED_COUNT=0
while IFS= read -r old_file; do
    if [ -n "${old_file}" ]; then
        log_msg "WARN" "Purging expired archive: ${old_file}"
        rm -f "${old_file}" "${old_file}.sha256" 2>/dev/null || true
        PRUNED_COUNT=$((PRUNED_COUNT + 1))
    fi
done < <(find "${TARGET_DIR}" -name "${SOURCE_BASENAME}_backup_*.tar.gz" -type f -mtime +"${RETENTION_DAYS}")

log_msg "INFO" "Retention enforcement completed. Purged ${PRUNED_COUNT} expired archive(s)."

# 6. Completion Summary
echo -e "\n${BOLD}${GREEN}==============================================================================${NC}"
echo -e "${BOLD}${GREEN}✔ BACKUP PIPELINE COMPLETED SUCCESSFULLY${NC}"
echo -e "   Timestamp:    ${TIMESTAMP}"
echo -e "   Archive File: ${ARCHIVE_FILE}"
echo -e "   Checksum:     ${CHECKSUM_FILE}"
echo -e "   Log File:     ${LOG_FILE}"
echo -e "${BOLD}${GREEN}==============================================================================${NC}\n"

exit 0
