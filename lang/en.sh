# sysgate — lang/en.sh
# English language strings

# --- Header ---
LANG_TITLE="sysgate — System Audit"
LANG_REPORT_SAVED="Report saved"
LANG_PRESS_ENTER="Press Enter to continue..."

# --- Sections ---
LANG_SECTION_SYSTEM="System"
LANG_SECTION_NETWORK="Network"
LANG_SECTION_SSH="SSH"
LANG_SECTION_FIREWALL="Firewall"
LANG_SECTION_SECURITY="Security"
LANG_SECTION_UPDATES="Updates"
LANG_SECTION_RESOURCES="Resources"
LANG_SECTION_LOGINS="Recent Logins"

# --- Summary ---
LANG_SUMMARY_TITLE="Summary"
LANG_SUMMARY_SCORE="Security score"
LANG_SUMMARY_CRITICAL="Critical issues"
LANG_SUMMARY_WARN="Warnings"
LANG_SUMMARY_FIX_FIRST="— fix these first"
LANG_SUMMARY_ALL_GOOD="All checks passed. Server is configured correctly."

# --- Fix label ---
LANG_FIX="Fix"
LANG_RISK="Risk"

# --- System checks ---
LANG_OS="OS"
LANG_KERNEL="Kernel"
LANG_UPTIME="Uptime"
LANG_HOSTNAME="Hostname"
LANG_VIRTUALIZATION="Virtualization"

# --- Resource checks ---
LANG_CPU_CORES="CPU cores"
LANG_RAM_TOTAL="RAM total"
LANG_RAM_USED="RAM used"
LANG_RAM_WARN="RAM usage above 90%"
LANG_DISK_USAGE="Disk"
LANG_DISK_WARN="Disk usage above 85%"
LANG_SWAP_ACTIVE="Swap active"
LANG_SWAP_MISSING="Swap not configured — recommended for VPS"

# --- Network checks ---
LANG_OPEN_PORTS="Open ports"
LANG_LISTENING_SERVICES="Listening services"
LANG_UNEXPECTED_PORTS="Unexpected open ports detected"

# --- SSH checks ---
LANG_SSH_STATUS="SSH status"
LANG_SSH_RUNNING="SSH is running"
LANG_SSH_NOT_RUNNING="SSH is not running"
LANG_SSH_PORT="SSH port"
LANG_SSH_PORT_DEFAULT="SSH on default port 22 — consider changing"
LANG_SSH_PORT_CUSTOM="SSH on non-default port"
LANG_SSH_ROOT_LOGIN="SSH root login"
LANG_SSH_ROOT_ALLOWED="Root login permitted — critical vulnerability"
LANG_SSH_ROOT_ALLOWED_RISK="Full server access directly via root"
LANG_SSH_ROOT_ALLOWED_FIX="sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config && systemctl restart sshd"
LANG_SSH_ROOT_DENIED="Root login denied"
LANG_SSH_PASS_AUTH="SSH password authentication"
LANG_SSH_PASS_ENABLED="Password auth enabled — key-only recommended"
LANG_SSH_PASS_ENABLED_RISK="Vulnerable to brute-force attacks"
LANG_SSH_PASS_ENABLED_FIX="sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && systemctl restart sshd"
LANG_SSH_PASS_DISABLED="Key-only — password authentication disabled"
LANG_SSH_CONFIG_NOT_FOUND="SSH configuration file not found"

# --- Firewall checks ---
LANG_UFW_STATUS="UFW status"
LANG_UFW_ACTIVE="UFW is active"
LANG_UFW_INACTIVE="UFW is inactive — server is unprotected"
LANG_UFW_INACTIVE_RISK="All ports are open without filtering"
LANG_UFW_INACTIVE_FIX="ufw allow ssh && ufw --force enable"
LANG_UFW_NOT_INSTALLED="UFW not installed"
LANG_UFW_NOT_INSTALLED_FIX="apt install ufw -y && ufw allow ssh && ufw --force enable"
LANG_IPTABLES_RULES="iptables rules"
LANG_IPTABLES_EMPTY="iptables has no rules — no filtering active"

# --- Security checks ---
LANG_FAIL2BAN_STATUS="Fail2ban status"
LANG_FAIL2BAN_ACTIVE="Fail2ban is active"
LANG_FAIL2BAN_INACTIVE="Fail2ban is inactive"
LANG_FAIL2BAN_NOT_INSTALLED="Fail2ban not installed — recommended for brute-force protection"
LANG_FAIL2BAN_NOT_INSTALLED_FIX="apt install fail2ban -y && systemctl enable fail2ban && systemctl start fail2ban"
LANG_ROOT_PASS="Root password"
LANG_ROOT_PASS_LOCKED="Root password locked (key-only access)"
LANG_ROOT_PASS_SET="Root password is set"
LANG_WORLD_WRITABLE="World-writable files"
LANG_WORLD_WRITABLE_FOUND="World-writable files found in critical directories"
LANG_WORLD_WRITABLE_RISK="Any user can modify these files"
LANG_WORLD_WRITABLE_CLEAN="Critical directories are clean"
LANG_SUDOERS="Sudoers check"
LANG_SUDOERS_OK="Sudoers file is valid"
LANG_SUDOERS_WARN="NOPASSWD entries found in sudoers"
LANG_SUDOERS_WARN_RISK="Commands run without password confirmation"

# --- Updates checks ---
LANG_UPDATES_AVAILABLE="Available updates"
LANG_UPDATES_FOUND="Package updates available"
LANG_UPDATES_FOUND_FIX="apt update && apt upgrade -y"
LANG_UPDATES_OK="System is up to date"
LANG_AUTO_UPDATES="Automatic updates"
LANG_AUTO_UPDATES_ACTIVE="Unattended security upgrades configured"
LANG_AUTO_UPDATES_INACTIVE="Automatic updates not configured"
LANG_AUTO_UPDATES_INACTIVE_FIX="apt install unattended-upgrades -y && dpkg-reconfigure -plow unattended-upgrades"

# --- Login checks ---
LANG_LAST_LOGINS="Last 5 logins"
LANG_NO_LOGINS="Login history is empty"

# --- Help ---
LANG_HELP_TITLE="sysgate — help"
LANG_HELP_DESC="Security and health audit for Linux/Windows servers."
LANG_HELP_USAGE="Usage"
LANG_HELP_OPTIONS="Options"
LANG_HELP_OPT_LANG="output language: ru or en (default: autodetect)"
LANG_HELP_OPT_OUTPUT="save report to file (default: sysgate-report-DATE.txt)"
LANG_HELP_OPT_NO_SAVE="do not save report to file"
LANG_HELP_OPT_SECTION="run only one section: system, network, ssh, firewall, security, updates"
LANG_HELP_LEGEND="Legend"
LANG_HELP_PASS="all good"
LANG_HELP_WARN="recommended to fix"
LANG_HELP_FAIL="fix immediately"
LANG_HELP_INFO="information"
LANG_HELP_EXAMPLES="Examples"
LANG_HELP_EXAMPLE_1="full audit in English"
LANG_HELP_EXAMPLE_2="SSH section only"
LANG_HELP_EXAMPLE_3="save report to file"
LANG_HELP_EXAMPLE_4="no report file"
