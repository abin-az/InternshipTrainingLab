#!/usr/bin/env bash
# ==============================================================================
# Think Polaris Cloud & DevOps Engineer 30-Day Mastery Track
# Day 01: Workstation & Toolchain Verification Script
#
# Usage:
#   chmod +x verify_environment.sh
#   ./verify_environment.sh
# ==============================================================================

set -uo pipefail

# ANSI Color Codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNINGS=0

echo -e "${BLUE}==============================================================================${NC}"
echo -e "${BOLD}${CYAN} Think Polaris Technical Training Center — Alwaye (Aluva)${NC}"
echo -e "${BOLD} Cloud & DevOps 30-Day Mastery Track: Environment Readiness Audit${NC}"
echo -e "${BLUE}==============================================================================${NC}\n"

# Helper function to check CLI command existence
check_tool() {
    local tool_name="$1"
    local command_to_check="$2"
    local version_arg="$3"
    local is_critical="${4:-true}"

    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    echo -n "Checking for ${tool_name}... "

    if command -v "${command_to_check}" >/dev/null 2>&1; then
        local raw_version
        raw_version=$("${command_to_check}" ${version_arg} 2>&1 | head -n 1 | tr -d '\r')
        echo -e "${GREEN}[PASS]${NC} (${raw_version})"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        return 0
    else
        if [ "${is_critical}" = "true" ]; then
            echo -e "${RED}[FAIL]${NC} - Missing binary '${command_to_check}'"
            FAILED_CHECKS=$((FAILED_CHECKS + 1))
            return 1
        else
            echo -e "${YELLOW}[WARN]${NC} - Optional tool '${command_to_check}' not found"
            WARNINGS=$((WARNINGS + 1))
            return 2
        fi
    fi
}

# 1. Operating System & Kernel Environment Check
echo -e "${BOLD}1. System & Architecture Detection${NC}"
if [ -f /etc/os-release ]; then
    # shellcheck disable=SC1091
    source /etc/os-release
    echo -e "   OS Distribution: ${GREEN}${NAME} ${VERSION}${NC}"
else
    echo -e "   ${YELLOW}[WARN] /etc/os-release not detected.${NC}"
fi

KERNEL_RELEASE=$(uname -r)
echo -e "   Kernel Release:  ${CYAN}${KERNEL_RELEASE}${NC}"

if grep -qi microsoft /proc/version 2>/dev/null; then
    echo -e "   Environment:     ${GREEN}WSL2 (Windows Subsystem for Linux) Verified${NC}"
else
    echo -e "   Environment:     ${CYAN}Native Linux / Proxmox VM Environment${NC}"
fi
echo ""

# 2. Essential POSIX & Networking Utilities
echo -e "${BOLD}2. Core System & Networking Utilities${NC}"
check_tool "Git" "git" "--version" true
check_tool "Curl" "curl" "--version" true
check_tool "Wget" "wget" "--version" true
check_tool "JQ (JSON Processor)" "jq" "--version" true
check_tool "Unzip" "unzip" "-v" true
check_tool "Tree" "tree" "--version" false
check_tool "Dig (DNS Utils)" "dig" "-v" true
check_tool "Net-tools / Netstat" "netstat" "--version" false
check_tool "Tcpdump" "tcpdump" "--version" true
echo ""

# 3. Cloud & DevOps Core Toolchain
echo -e "${BOLD}3. Cloud Infrastructure & Container Toolchain${NC}"
check_tool "AWS CLI" "aws" "--version" true
check_tool "HashiCorp Terraform" "terraform" "version" true
check_tool "Docker CLI" "docker" "--version" true
check_tool "Kubernetes CLI (kubectl)" "kubectl" "version --client" true
check_tool "Kind (K8s in Docker)" "kind" "--version" true
echo ""

# 4. Docker Daemon Status Check
echo -e "${BOLD}4. Docker Engine Daemon Connectivity${NC}"
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
if docker info >/dev/null 2>&1; then
    echo -e "   Docker Daemon State: ${GREEN}[PASS] Running & Accessible by current user (${USER})${NC}"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
else
    echo -e "   Docker Daemon State: ${RED}[FAIL] Docker service is stopped or current user has no permissions.${NC}"
    echo -e "   ${YELLOW}Fix: Run 'sudo service docker start' and 'sudo usermod -aG docker \$USER'${NC}"
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
fi
echo ""

# 5. AWS CLI Authentication Check (Optional on Day 1, Mandatory by Day 8)
echo -e "${BOLD}5. AWS CLI Authentication State${NC}"
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
if aws sts get-caller-identity >/dev/null 2>&1; then
    AWS_ARN=$(aws sts get-caller-identity --query "Arn" --output text 2>/dev/null)
    echo -e "   AWS Credentials:     ${GREEN}[PASS] Authenticated (${AWS_ARN})${NC}"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
else
    echo -e "   AWS Credentials:     ${YELLOW}[INFO] Not yet configured or unauthenticated.${NC}"
    echo -e "   ${CYAN}Note: Required for Phase 2 (Day 8). Follow '00_SETUP_AND_PREREQUISITES.md' to configure.${NC}"
    WARNINGS=$((WARNINGS + 1))
fi
echo ""

# Summary Table
echo -e "${BLUE}==============================================================================${NC}"
echo -e "${BOLD}AUDIT SUMMARY:${NC}"
echo -e "   Total Checks:    ${TOTAL_CHECKS}"
echo -e "   Passed Checks:   ${GREEN}${PASSED_CHECKS}${NC}"
echo -e "   Failed Checks:   ${RED}${FAILED_CHECKS}${NC}"
echo -e "   Warnings/Info:   ${YELLOW}${WARNINGS}${NC}"

if [ "${FAILED_CHECKS}" -eq 0 ]; then
    echo -e "\n${BOLD}${GREEN}✔ ALL REQUIRED SYSTEMS READY FOR DAY 1 LABS!${NC}\n"
    exit 0
else
    echo -e "\n${BOLD}${RED}✘ WORKSTATION INCOMPLETE — Remediate missing components before continuing.${NC}"
    echo -e "${YELLOW}Refer to 'cloud-devops-track/00_SETUP_AND_PREREQUISITES.md' for installation instructions.${NC}\n"
    exit 1
fi
