#!/usr/bin/env bash
# ==========================================================
# sysgate - System Security Audit
# Author: ceo714 / github.com/ceo714/sysgate
# Version: 1.0.0
# Target: Debian 11+ / Ubuntu 20.04+
# ==========================================================
#
# Usage:
#   sudo ./sysgate.sh [options]
#
# Options:
#   --lang ru|en        output language (default: autodetect)
#   --output FILE       save report to custom path
#   --no-save           do not save report
#   --section NAME      run single section only
#   --help              show help
#
# One-line run:
#   curl -sO https://raw.githubusercontent.com/ceo714/sysgate/main/linux/sysgate.sh
#   chmod +x sysgate.sh && sudo ./sysgate.sh
# ==========================================================

set -euo pipefail

SYSGATE_VERSION="1.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ==========================================================
# DEFAULTS
# ==========================================================

OPT_LANG=""
OPT_OUTPUT=""
OPT_NO_SAVE=false
OPT_SECTION=""
OPT_HELP=false

PASS_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0
INFO_COUNT=0
SCORE=100

REPORT_LINES=()
DATE_TAG=$(date +%Y-%m-%d)
TIME_TAG=$(date +"%Y-%m-%d %H:%M:%S UTC" --utc 2>/dev/null || date +"%Y-%m-%d %H:%M:%S")

# ==========================================================
# ARGUMENT PARSING
# ==========================================================

while [[ $# -gt 0 ]]; do
    case "$1" in
        --lang)    OPT_LANG="${2:-}";    shift 2 ;;
        --output)  OPT_OUTPUT="${2:-}";  shift 2 ;;
        --no-save) OPT_NO_SAVE=true;     shift   ;;
        --section) OPT_SECTION="${2:-}"; shift 2 ;;
        --help|-h) OPT_HELP=true;        shift   ;;
        *)         shift ;;
    esac
done

# ==========================================================
# LANGUAGE DETECTION
# ==========================================================

detect_lang() {
    if [[ -n "$OPT_LANG" ]]; then
        echo "$OPT_LANG"
        return
    fi
    local sys_lang="${LANG:-en}"
    if [[ "$sys_lang" == ru* ]]; then
        echo "ru"
    else
        echo "en"
    fi
}

ACTIVE_LANG=$(detect_lang)

load_lang() {
    local lang_file=""
    # Try relative to script dir first (for packaged use)
    if [[ -f "$SCRIPT_DIR/../lang/${ACTIVE_LANG}.sh" ]]; then
        lang_file="$SCRIPT_DIR/../lang/${ACTIVE_LANG}.sh"
    elif [[ -f "$SCRIPT_DIR/lang/${ACTIVE_LANG}.sh" ]]; then
        lang_file="$SCRIPT_DIR/lang/${ACTIVE_LANG}.sh"
    elif [[ -f "./lang/${ACTIVE_LANG}.sh" ]]; then
        lang_file="./lang/${ACTIVE_LANG}.sh"
    fi

    if [[ -n "$lang_file" ]]; then
        # shellcheck source=/dev/null
        source "$lang_file"
    else
        # Inline fallback English - works without lang files
        LANG_TITLE="sysgate - System Audit"
        LANG_REPORT_SAVED="Report saved"
        LANG_SECTION_SYSTEM="System"; LANG_SECTION_NETWORK="Network"
        LANG_SECTION_SSH="SSH"; LANG_SECTION_FIREWALL="Firewall"
        LANG_SECTION_SECURITY="Security"; LANG_SECTION_UPDATES="Updates"
        LANG_SECTION_RESOURCES="Resources"; LANG_SECTION_LOGINS="Recent Logins"
        LANG_SUMMARY_TITLE="Summary"; LANG_SUMMARY_SCORE="Security score"
        LANG_SUMMARY_CRITICAL="Critical issues"; LANG_SUMMARY_WARN="Warnings"
        LANG_SUMMARY_FIX_FIRST="- fix these first"
        LANG_SUMMARY_ALL_GOOD="All checks passed."
        LANG_FIX="Fix"; LANG_RISK="Risk"
        LANG_OS="OS"; LANG_KERNEL="Kernel"; LANG_UPTIME="Uptime"
        LANG_HOSTNAME="Hostname"; LANG_VIRTUALIZATION="Virtualization"
        LANG_CPU_CORES="CPU cores"; LANG_RAM_TOTAL="RAM total"
        LANG_RAM_USED="RAM used"; LANG_RAM_WARN="RAM usage above 90%"
        LANG_DISK_USAGE="Disk"; LANG_DISK_WARN="Disk above 85%"
        LANG_SWAP_ACTIVE="Swap active"; LANG_SWAP_MISSING="Swap not configured"
        LANG_OPEN_PORTS="Open ports"; LANG_LISTENING_SERVICES="Listening"
        LANG_SSH_STATUS="SSH status"; LANG_SSH_RUNNING="SSH running"
        LANG_SSH_NOT_RUNNING="SSH not running"; LANG_SSH_PORT="SSH port"
        LANG_SSH_PORT_DEFAULT="SSH on port 22 - consider changing"
        LANG_SSH_PORT_CUSTOM="SSH on custom port"
        LANG_SSH_ROOT_LOGIN="SSH root login"
        LANG_SSH_ROOT_ALLOWED="Root login permitted - critical"
        LANG_SSH_ROOT_ALLOWED_RISK="Full root access via SSH"
        LANG_SSH_ROOT_ALLOWED_FIX="sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config && systemctl restart sshd"
        LANG_SSH_ROOT_DENIED="Root login denied"
        LANG_SSH_PASS_AUTH="SSH password auth"
        LANG_SSH_PASS_ENABLED="Password auth enabled - keys recommended"
        LANG_SSH_PASS_ENABLED_RISK="Vulnerable to brute-force"
        LANG_SSH_PASS_ENABLED_FIX="sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && systemctl restart sshd"
        LANG_SSH_PASS_DISABLED="Key-only auth"
        LANG_SSH_CONFIG_NOT_FOUND="SSH config not found"
        LANG_UFW_STATUS="UFW status"; LANG_UFW_ACTIVE="UFW active"
        LANG_UFW_INACTIVE="UFW inactive - server unprotected"
        LANG_UFW_INACTIVE_RISK="All ports open without filtering"
        LANG_UFW_INACTIVE_FIX="ufw allow ssh && ufw --force enable"
        LANG_UFW_NOT_INSTALLED="UFW not installed"
        LANG_UFW_NOT_INSTALLED_FIX="apt install ufw -y && ufw allow ssh && ufw --force enable"
        LANG_IPTABLES_RULES="iptables rules"; LANG_IPTABLES_EMPTY="No iptables rules"
        LANG_FAIL2BAN_STATUS="Fail2ban"; LANG_FAIL2BAN_ACTIVE="Fail2ban active"
        LANG_FAIL2BAN_INACTIVE="Fail2ban inactive"
        LANG_FAIL2BAN_NOT_INSTALLED="Fail2ban not installed"
        LANG_FAIL2BAN_NOT_INSTALLED_FIX="apt install fail2ban -y && systemctl enable fail2ban && systemctl start fail2ban"
        LANG_ROOT_PASS="Root password"; LANG_ROOT_PASS_LOCKED="Root locked"
        LANG_ROOT_PASS_SET="Root password set"
        LANG_WORLD_WRITABLE="World-writable files"
        LANG_WORLD_WRITABLE_FOUND="World-writable files found"
        LANG_WORLD_WRITABLE_RISK="Any user can modify these files"
        LANG_WORLD_WRITABLE_CLEAN="Critical dirs clean"
        LANG_SUDOERS="Sudoers"; LANG_SUDOERS_OK="Sudoers valid"
        LANG_SUDOERS_WARN="NOPASSWD in sudoers"
        LANG_SUDOERS_WARN_RISK="Commands run without password"
        LANG_UPDATES_AVAILABLE="Updates"; LANG_UPDATES_FOUND="Updates available"
        LANG_UPDATES_FOUND_FIX="apt update && apt upgrade -y"
        LANG_UPDATES_OK="System up to date"
        LANG_AUTO_UPDATES="Auto-updates"
        LANG_AUTO_UPDATES_ACTIVE="Auto-updates configured"
        LANG_AUTO_UPDATES_INACTIVE="Auto-updates not configured"
        LANG_AUTO_UPDATES_INACTIVE_FIX="apt install unattended-upgrades -y && dpkg-reconfigure -plow unattended-upgrades"
        LANG_LAST_LOGINS="Last 5 logins"; LANG_NO_LOGINS="No login history"
        LANG_HELP_TITLE="sysgate - help"
        LANG_HELP_DESC="Security and health audit for Linux servers."
        LANG_HELP_USAGE="Usage"; LANG_HELP_OPTIONS="Options"
        LANG_HELP_OPT_LANG="language: ru or en"
        LANG_HELP_OPT_OUTPUT="save report to file"
        LANG_HELP_OPT_NO_SAVE="do not save report"
        LANG_HELP_OPT_SECTION="run single section"
        LANG_HELP_LEGEND="Legend"
        LANG_HELP_PASS="all good"; LANG_HELP_WARN="fix recommended"
        LANG_HELP_FAIL="fix immediately"; LANG_HELP_INFO="information"
        LANG_HELP_EXAMPLES="Examples"
        LANG_HELP_EXAMPLE_1="full audit"
        LANG_HELP_EXAMPLE_2="SSH section only"
        LANG_HELP_EXAMPLE_3="save to file"
        LANG_HELP_EXAMPLE_4="no report file"
    fi
}

load_lang

# ==========================================================
# COLORS
# ==========================================================

if [[ -t 1 ]]; then
    C_RESET="\033[0m"
    C_GREEN="\033[32m"
    C_YELLOW="\033[33m"
    C_RED="\033[31m"
    C_CYAN="\033[36m"
    C_WHITE="\033[37m"
    C_GRAY="\033[90m"
    C_BOLD="\033[1m"
else
    C_RESET=""; C_GREEN=""; C_YELLOW=""; C_RED=""
    C_CYAN=""; C_WHITE=""; C_GRAY=""; C_BOLD=""
fi

# ==========================================================
# OUTPUT HELPERS
# ==========================================================

print_pass() {
    local msg="$1"
    echo -e "  ${C_GREEN}[PASS]${C_RESET} $msg"
    REPORT_LINES+=("  [PASS] $msg")
    ((PASS_COUNT++)) || true
}

print_warn() {
    local msg="$1"
    local risk="${2:-}"
    local fix="${3:-}"
    echo -e "  ${C_YELLOW}[WARN]${C_RESET} $msg"
    REPORT_LINES+=("  [WARN] $msg")
    if [[ -n "$risk" ]]; then
        echo -e "  ${C_GRAY}       $LANG_RISK: $risk${C_RESET}"
        REPORT_LINES+=("         $LANG_RISK: $risk")
    fi
    if [[ -n "$fix" ]]; then
        echo -e "  ${C_GRAY}       $LANG_FIX: ${C_CYAN}$fix${C_RESET}"
        REPORT_LINES+=("         $LANG_FIX: $fix")
    fi
    ((WARN_COUNT++)) || true
    ((SCORE-=5)) || true
}

print_fail() {
    local msg="$1"
    local risk="${2:-}"
    local fix="${3:-}"
    echo -e "  ${C_RED}[FAIL]${C_RESET} $msg"
    REPORT_LINES+=("  [FAIL] $msg")
    if [[ -n "$risk" ]]; then
        echo -e "  ${C_GRAY}       $LANG_RISK: $risk${C_RESET}"
        REPORT_LINES+=("         $LANG_RISK: $risk")
    fi
    if [[ -n "$fix" ]]; then
        echo -e "  ${C_GRAY}       $LANG_FIX: ${C_CYAN}$fix${C_RESET}"
        REPORT_LINES+=("         $LANG_FIX: $fix")
    fi
    ((FAIL_COUNT++)) || true
    ((SCORE-=15)) || true
}

print_info() {
    local msg="$1"
    echo -e "  ${C_CYAN}[INFO]${C_RESET} $msg"
    REPORT_LINES+=("  [INFO] $msg")
    ((INFO_COUNT++)) || true
}

print_section() {
    local title="$1"
    echo ""
    echo -e "  ${C_BOLD}${C_WHITE}[ $title ]${C_RESET}"
    REPORT_LINES+=("")
    REPORT_LINES+=("  [ $title ]")
}

print_divider() {
    echo -e "  ${C_GRAY}==========================================${C_RESET}"
    REPORT_LINES+=("  ==========================================")
}

# ==========================================================
# HELP
# ==========================================================

show_help() {
    echo ""
    echo -e "  ${C_BOLD}${C_WHITE}========================================${C_RESET}"
    echo -e "  ${C_BOLD}${C_WHITE} $LANG_HELP_TITLE  v${SYSGATE_VERSION}${C_RESET}"
    echo -e "  ${C_BOLD}${C_WHITE}========================================${C_RESET}"
    echo ""
    echo -e "  $LANG_HELP_DESC"
    echo ""
    echo -e "  ${C_WHITE}$LANG_HELP_USAGE:${C_RESET}"
    echo -e "  ${C_CYAN}sudo ./sysgate.sh [options]${C_RESET}"
    echo ""
    echo -e "  ${C_WHITE}$LANG_HELP_OPTIONS:${C_RESET}"
    echo -e "  ${C_CYAN}--lang ru|en${C_RESET}      $LANG_HELP_OPT_LANG"
    echo -e "  ${C_CYAN}--output FILE${C_RESET}     $LANG_HELP_OPT_OUTPUT"
    echo -e "  ${C_CYAN}--no-save${C_RESET}         $LANG_HELP_OPT_NO_SAVE"
    echo -e "  ${C_CYAN}--section NAME${C_RESET}    $LANG_HELP_OPT_SECTION"
    echo -e "  ${C_CYAN}--help${C_RESET}            show this message"
    echo ""
    echo -e "  ${C_WHITE}$LANG_HELP_LEGEND:${C_RESET}"
    echo -e "  ${C_GREEN}[PASS]${C_RESET}   $LANG_HELP_PASS"
    echo -e "  ${C_YELLOW}[WARN]${C_RESET}   $LANG_HELP_WARN"
    echo -e "  ${C_RED}[FAIL]${C_RESET}   $LANG_HELP_FAIL"
    echo -e "  ${C_CYAN}[INFO]${C_RESET}   $LANG_HELP_INFO"
    echo ""
    echo -e "  ${C_WHITE}$LANG_HELP_EXAMPLES:${C_RESET}"
    echo -e "  ${C_GRAY}sudo ./sysgate.sh --lang ru${C_RESET}           # $LANG_HELP_EXAMPLE_1"
    echo -e "  ${C_GRAY}sudo ./sysgate.sh --lang en${C_RESET}           # $LANG_HELP_EXAMPLE_1 (en)"
    echo -e "  ${C_GRAY}sudo ./sysgate.sh --section ssh${C_RESET}       # $LANG_HELP_EXAMPLE_2"
    echo -e "  ${C_GRAY}sudo ./sysgate.sh --output /tmp/r.txt${C_RESET} # $LANG_HELP_EXAMPLE_3"
    echo -e "  ${C_GRAY}sudo ./sysgate.sh --no-save${C_RESET}           # $LANG_HELP_EXAMPLE_4"
    echo ""
    exit 0
}

[[ "$OPT_HELP" == true ]] && show_help

# ==========================================================
# ROOT CHECK
# ==========================================================

if [[ $EUID -ne 0 ]]; then
    echo ""
    if [[ "$ACTIVE_LANG" == "ru" ]]; then
        echo -e "  ${C_RED}[ERROR]${C_RESET} Root privileges required / Trebuyutsya prava root. Run: sudo ./sysgate.sh"
    else
        echo -e "  ${C_RED}[ERROR]${C_RESET} Root privileges required. Run: sudo ./sysgate.sh"
    fi
    echo ""
    exit 1
fi

# ==========================================================
# HEADER
# ==========================================================

print_header() {
    local os_name
    os_name=$(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"' || echo "Linux")
    local kernel
    kernel=$(uname -r)

    echo ""
    print_divider
    echo -e "  ${C_BOLD}${C_WHITE} $LANG_TITLE  v${SYSGATE_VERSION}${C_RESET}"
    echo -e "  ${C_GRAY} $os_name | kernel $kernel${C_RESET}"
    echo -e "  ${C_GRAY} $TIME_TAG${C_RESET}"
    print_divider

    REPORT_LINES+=("==========================================")
    REPORT_LINES+=(" $LANG_TITLE  v${SYSGATE_VERSION}")
    REPORT_LINES+=(" $os_name | kernel $kernel")
    REPORT_LINES+=(" $TIME_TAG")
    REPORT_LINES+=("==========================================")
}

# ==========================================================
# SECTION: SYSTEM
# ==========================================================

check_system() {
    print_section "$LANG_SECTION_SYSTEM"

    local os_name
    os_name=$(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"' || echo "Linux")
    print_info "$LANG_OS: $os_name"

    local kernel
    kernel=$(uname -r)
    print_info "$LANG_KERNEL: $kernel"

    local hostname
    hostname=$(hostname)
    print_info "$LANG_HOSTNAME: $hostname"

    local uptime_str
    uptime_str=$(uptime -p 2>/dev/null || uptime)
    print_info "$LANG_UPTIME: $uptime_str"

    # Virtualization detection
    local virt=""
    if command -v systemd-detect-virt &>/dev/null; then
        virt=$(systemd-detect-virt 2>/dev/null || echo "none")
    elif [[ -f /proc/cpuinfo ]]; then
        if grep -qi "hypervisor" /proc/cpuinfo 2>/dev/null; then
            virt="vm"
        else
            virt="none"
        fi
    fi
    [[ -n "$virt" && "$virt" != "none" ]] && print_info "$LANG_VIRTUALIZATION: $virt"
}

# ==========================================================
# SECTION: RESOURCES
# ==========================================================

check_resources() {
    print_section "$LANG_SECTION_RESOURCES"

    # CPU
    local cpu_cores
    cpu_cores=$(nproc 2>/dev/null || grep -c processor /proc/cpuinfo 2>/dev/null || echo "?")
    print_info "$LANG_CPU_CORES: $cpu_cores"

    # RAM
    local ram_total ram_used ram_pct
    ram_total=$(free -h 2>/dev/null | awk '/^Mem:/ {print $2}')
    ram_used=$(free -h 2>/dev/null | awk '/^Mem:/ {print $3}')
    ram_pct=$(free 2>/dev/null | awk '/^Mem:/ {printf "%.0f", $3/$2*100}')
    print_info "$LANG_RAM_TOTAL: $ram_total | $LANG_RAM_USED: $ram_used (${ram_pct}%)"
    if [[ "${ram_pct:-0}" -gt 90 ]]; then
        print_warn "$LANG_RAM_WARN: ${ram_pct}%"
    fi

    # Disk
    local disk_pct disk_info
    disk_pct=$(df / 2>/dev/null | awk 'NR==2 {print $5}' | tr -d '%')
    disk_info=$(df -h / 2>/dev/null | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')
    print_info "$LANG_DISK_USAGE /: $disk_info"
    if [[ "${disk_pct:-0}" -gt 85 ]]; then
        print_warn "$LANG_DISK_WARN ${disk_pct}%"
    fi

    # Swap
    local swap_total
    swap_total=$(free 2>/dev/null | awk '/^Swap:/ {print $2}')
    if [[ "${swap_total:-0}" -gt 0 ]]; then
        local swap_h
        swap_h=$(free -h 2>/dev/null | awk '/^Swap:/ {print $2}')
        print_pass "$LANG_SWAP_ACTIVE: $swap_h"
    else
        print_warn "$LANG_SWAP_MISSING"
    fi
}

# ==========================================================
# SECTION: NETWORK
# ==========================================================

check_network() {
    print_section "$LANG_SECTION_NETWORK"

    # Open ports
    local ports=""
    if command -v ss &>/dev/null; then
        ports=$(ss -tlnp 2>/dev/null | awk 'NR>1 {print $4}' | grep -oP ':\K\d+' | sort -un | tr '\n' ' ')
    elif command -v netstat &>/dev/null; then
        ports=$(netstat -tlnp 2>/dev/null | awk 'NR>2 {print $4}' | grep -oP ':\K\d+' | sort -un | tr '\n' ' ')
    fi

    if [[ -n "$ports" ]]; then
        print_info "$LANG_OPEN_PORTS: $ports"
    fi

    # Listening services
    if command -v ss &>/dev/null; then
        local services
        services=$(ss -tlnp 2>/dev/null | awk 'NR>1 {print $4, $6}' | grep -v "^$" | head -10)
        if [[ -n "$services" ]]; then
            print_info "$LANG_LISTENING_SERVICES:"
            while IFS= read -r line; do
                echo -e "  ${C_GRAY}       $line${C_RESET}"
                REPORT_LINES+=("         $line")
            done <<< "$services"
        fi
    fi
}

# ==========================================================
# SECTION: SSH
# ==========================================================

check_ssh() {
    print_section "$LANG_SECTION_SSH"

    local sshd_config="/etc/ssh/sshd_config"

    # SSH running?
    if systemctl is-active --quiet sshd 2>/dev/null || systemctl is-active --quiet ssh 2>/dev/null; then
        print_pass "$LANG_SSH_RUNNING"
    else
        print_warn "$LANG_SSH_NOT_RUNNING"
        return
    fi

    if [[ ! -f "$sshd_config" ]]; then
        print_warn "$LANG_SSH_CONFIG_NOT_FOUND"
        return
    fi

    # SSH port
    local ssh_port
    ssh_port=$(grep -E "^Port " "$sshd_config" 2>/dev/null | awk '{print $2}' || echo "22")
    ssh_port="${ssh_port:-22}"
    if [[ "$ssh_port" == "22" ]]; then
        print_warn "$LANG_SSH_PORT: $ssh_port - $LANG_SSH_PORT_DEFAULT"
    else
        print_pass "$LANG_SSH_PORT: $ssh_port - $LANG_SSH_PORT_CUSTOM"
    fi

    # Root login
    local root_login
    root_login=$(grep -E "^PermitRootLogin" "$sshd_config" 2>/dev/null | awk '{print $2}' || echo "yes")
    root_login="${root_login:-yes}"
    if [[ "$root_login" == "yes" ]]; then
        print_fail \
            "$LANG_SSH_ROOT_LOGIN: $LANG_SSH_ROOT_ALLOWED" \
            "$LANG_SSH_ROOT_ALLOWED_RISK" \
            "$LANG_SSH_ROOT_ALLOWED_FIX"
    else
        print_pass "$LANG_SSH_ROOT_LOGIN: $LANG_SSH_ROOT_DENIED"
    fi

    # Password auth
    local pass_auth
    pass_auth=$(grep -E "^PasswordAuthentication" "$sshd_config" 2>/dev/null | awk '{print $2}' || echo "yes")
    pass_auth="${pass_auth:-yes}"
    if [[ "$pass_auth" == "yes" ]]; then
        print_warn \
            "$LANG_SSH_PASS_AUTH: $LANG_SSH_PASS_ENABLED" \
            "$LANG_SSH_PASS_ENABLED_RISK" \
            "$LANG_SSH_PASS_ENABLED_FIX"
    else
        print_pass "$LANG_SSH_PASS_AUTH: $LANG_SSH_PASS_DISABLED"
    fi
}

# ==========================================================
# SECTION: FIREWALL
# ==========================================================

check_firewall() {
    print_section "$LANG_SECTION_FIREWALL"

    # UFW
    if command -v ufw &>/dev/null; then
        local ufw_status
        ufw_status=$(ufw status 2>/dev/null | head -1 | awk '{print $2}')
        if [[ "$ufw_status" == "active" ]]; then
            print_pass "$LANG_UFW_STATUS: $LANG_UFW_ACTIVE"
        else
            print_fail \
                "$LANG_UFW_STATUS: $LANG_UFW_INACTIVE" \
                "$LANG_UFW_INACTIVE_RISK" \
                "$LANG_UFW_INACTIVE_FIX"
        fi
    else
        # Check iptables as fallback
        if command -v iptables &>/dev/null; then
            local rules_count
            rules_count=$(iptables -L 2>/dev/null | grep -c "^Chain\|ACCEPT\|DROP\|REJECT" || echo "0")
            if [[ "${rules_count:-0}" -le 3 ]]; then
                print_warn \
                    "$LANG_UFW_NOT_INSTALLED" \
                    "$LANG_UFW_INACTIVE_RISK" \
                    "$LANG_UFW_NOT_INSTALLED_FIX"
            else
                print_pass "$LANG_IPTABLES_RULES: $rules_count"
            fi
        else
            print_warn \
                "$LANG_UFW_NOT_INSTALLED" \
                "$LANG_UFW_INACTIVE_RISK" \
                "$LANG_UFW_NOT_INSTALLED_FIX"
        fi
    fi
}

# ==========================================================
# SECTION: SECURITY
# ==========================================================

check_security() {
    print_section "$LANG_SECTION_SECURITY"

    # Fail2ban
    if command -v fail2ban-client &>/dev/null; then
        if systemctl is-active --quiet fail2ban 2>/dev/null; then
            print_pass "$LANG_FAIL2BAN_STATUS: $LANG_FAIL2BAN_ACTIVE"
        else
            print_warn "$LANG_FAIL2BAN_STATUS: $LANG_FAIL2BAN_INACTIVE"
        fi
    else
        print_warn \
            "$LANG_FAIL2BAN_STATUS: $LANG_FAIL2BAN_NOT_INSTALLED" \
            "" \
            "$LANG_FAIL2BAN_NOT_INSTALLED_FIX"
    fi

    # Root password
    local root_pass_status
    root_pass_status=$(passwd -S root 2>/dev/null | awk '{print $2}' || echo "P")
    if [[ "$root_pass_status" == "L" || "$root_pass_status" == "LK" ]]; then
        print_pass "$LANG_ROOT_PASS: $LANG_ROOT_PASS_LOCKED"
    else
        print_info "$LANG_ROOT_PASS: $LANG_ROOT_PASS_SET"
    fi

    # World-writable files in critical dirs
    local ww_files
    ww_files=$(find /etc /root /home -maxdepth 3 -perm -o+w -not -type l 2>/dev/null | head -5)
    if [[ -n "$ww_files" ]]; then
        print_fail \
            "$LANG_WORLD_WRITABLE: $LANG_WORLD_WRITABLE_FOUND" \
            "$LANG_WORLD_WRITABLE_RISK"
        while IFS= read -r f; do
            echo -e "  ${C_GRAY}       $f${C_RESET}"
            REPORT_LINES+=("         $f")
        done <<< "$ww_files"
    else
        print_pass "$LANG_WORLD_WRITABLE: $LANG_WORLD_WRITABLE_CLEAN"
    fi

    # Sudoers NOPASSWD
    if command -v visudo &>/dev/null || [[ -f /etc/sudoers ]]; then
        local nopasswd_count
        nopasswd_count=$(grep -r "NOPASSWD" /etc/sudoers /etc/sudoers.d/ 2>/dev/null | grep -v "^#" | wc -l | tr -d " \n" || echo "0")
        nopasswd_count="${nopasswd_count//[^0-9]/}"
        nopasswd_count="${nopasswd_count:-0}"
        if [[ "$nopasswd_count" -gt 0 ]]; then
            print_warn \
                "$LANG_SUDOERS: $LANG_SUDOERS_WARN" \
                "$LANG_SUDOERS_WARN_RISK"
        else
            print_pass "$LANG_SUDOERS: $LANG_SUDOERS_OK"
        fi
    fi
}

# ==========================================================
# SECTION: UPDATES
# ==========================================================

check_updates() {
    print_section "$LANG_SECTION_UPDATES"

    # Available updates
    if command -v apt &>/dev/null; then
        local updates_count
        apt-get update -qq 2>/dev/null || true
        updates_count=$(apt list --upgradable 2>/dev/null | grep -c "upgradable" || echo "0")
        if [[ "${updates_count:-0}" -gt 0 ]]; then
            print_warn \
                "$LANG_UPDATES_AVAILABLE: $updates_count $LANG_UPDATES_FOUND" \
                "" \
                "$LANG_UPDATES_FOUND_FIX"
        else
            print_pass "$LANG_UPDATES_AVAILABLE: $LANG_UPDATES_OK"
        fi

        # Unattended upgrades
        if dpkg -l unattended-upgrades 2>/dev/null | grep -q "^ii"; then
            print_pass "$LANG_AUTO_UPDATES: $LANG_AUTO_UPDATES_ACTIVE"
        else
            print_warn \
                "$LANG_AUTO_UPDATES: $LANG_AUTO_UPDATES_INACTIVE" \
                "" \
                "$LANG_AUTO_UPDATES_INACTIVE_FIX"
        fi
    fi
}

# ==========================================================
# SECTION: LAST LOGINS
# ==========================================================

check_logins() {
    print_section "$LANG_SECTION_LOGINS"

    if command -v last &>/dev/null; then
        local logins
        logins=$(last -n 5 2>/dev/null | head -5)
        if [[ -n "$logins" ]]; then
            print_info "$LANG_LAST_LOGINS:"
            while IFS= read -r line; do
                echo -e "  ${C_GRAY}       $line${C_RESET}"
                REPORT_LINES+=("         $line")
            done <<< "$logins"
        else
            print_info "$LANG_NO_LOGINS"
        fi
    fi
}

# ==========================================================
# SUMMARY
# ==========================================================

print_summary() {
    echo ""
    print_divider
    echo -e "  ${C_BOLD}${C_WHITE}$LANG_SUMMARY_TITLE${C_RESET}"
    echo ""

    # Score clamp
    [[ $SCORE -lt 0 ]] && SCORE=0

    local score_color="$C_GREEN"
    [[ $SCORE -lt 80 ]] && score_color="$C_YELLOW"
    [[ $SCORE -lt 60 ]] && score_color="$C_RED"

    echo -e "  ${C_WHITE}PASS: ${C_GREEN}$PASS_COUNT${C_RESET}   ${C_WHITE}WARN: ${C_YELLOW}$WARN_COUNT${C_RESET}   ${C_WHITE}FAIL: ${C_RED}$FAIL_COUNT${C_RESET}   ${C_WHITE}INFO: ${C_CYAN}$INFO_COUNT${C_RESET}"
    echo -e "  $LANG_SUMMARY_SCORE: ${score_color}${SCORE}/100${C_RESET}"

    if [[ $FAIL_COUNT -gt 0 ]]; then
        echo -e "  ${C_RED}$LANG_SUMMARY_CRITICAL: $FAIL_COUNT $LANG_SUMMARY_FIX_FIRST${C_RESET}"
    fi
    if [[ $FAIL_COUNT -eq 0 && $WARN_COUNT -eq 0 ]]; then
        echo -e "  ${C_GREEN}$LANG_SUMMARY_ALL_GOOD${C_RESET}"
    fi

    print_divider
    echo ""

    REPORT_LINES+=("==========================================")
    REPORT_LINES+=("$LANG_SUMMARY_TITLE")
    REPORT_LINES+=("")
    REPORT_LINES+=("PASS: $PASS_COUNT   WARN: $WARN_COUNT   FAIL: $FAIL_COUNT   INFO: $INFO_COUNT")
    REPORT_LINES+=("$LANG_SUMMARY_SCORE: ${SCORE}/100")
    REPORT_LINES+=("==========================================")
}

# ==========================================================
# SAVE REPORT
# ==========================================================

save_report() {
    if [[ "$OPT_NO_SAVE" == true ]]; then
        return
    fi

    local report_path="${OPT_OUTPUT:-sysgate-report-${DATE_TAG}.txt}"

    printf '%s\n' "${REPORT_LINES[@]}" > "$report_path"
    echo -e "  ${C_GRAY}$LANG_REPORT_SAVED: $report_path${C_RESET}"
    echo ""
}

# ==========================================================
# MAIN
# ==========================================================

main() {
    print_header

    case "${OPT_SECTION:-all}" in
        system)   check_system ;;
        resources) check_resources ;;
        network)  check_network ;;
        ssh)      check_ssh ;;
        firewall) check_firewall ;;
        security) check_security ;;
        updates)  check_updates ;;
        logins)   check_logins ;;
        all|*)
            check_system
            check_resources
            check_network
            check_ssh
            check_firewall
            check_security
            check_updates
            check_logins
            ;;
    esac

    print_summary
    save_report
}

main
