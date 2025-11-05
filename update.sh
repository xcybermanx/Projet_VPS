#!/bin/bash
# ===================================================================
# GX TUNNEL COMPLETE FIX & SETUP SCRIPT
# Version: 3.0 - Comprehensive Fix
# Author: xcybermanx
# ===================================================================

set -euo pipefail

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

green() { echo -e "${GREEN}[✓]${NC} $*"; }
red() { echo -e "${RED}[✗]${NC} $*"; }
yellow() { echo -e "${YELLOW}[!]${NC} $*"; }
blue() { echo -e "${BLUE}[i]${NC} $*"; }

# Error handling
error_exit() {
    red "ERROR: $1"
    exit 1
}

# ===================================================================
# SYSTEM VALIDATION
# ===================================================================

check_root() {
    if [[ $EUID -ne 0 ]]; then
        error_exit "This script must be run as root. Use: sudo bash fix.sh"
    fi
}

# ===================================================================
# CREATE NECESSARY DIRECTORIES
# ===================================================================

create_directories() {
    blue "Creating necessary directories..."
    
    # Create main directories
    mkdir -p /usr/bin/gx-scripts
    mkdir -p /etc/gx-tunnel
    mkdir -p /var/log/gx-tunnel
    mkdir -p /home/gxtunnel/{config,logs,backup}
    
    # Set permissions
    chown -R gxtunnel:gxtunnel /home/gxtunnel 2>/dev/null || true
    chmod 755 /usr/bin/gx-scripts
    chmod 755 /etc/gx-tunnel
    chmod 755 /var/log/gx-tunnel
    
    success "Directories created"
}

# ===================================================================
# DOWNLOAD MISSING SCRIPTS
# ===================================================================

download_scripts() {
    blue "Downloading missing management scripts..."
    
    local base_url="https://raw.githubusercontent.com/xcybermanx/Projet_VPS/main"
    
    # Essential menu scripts
    local scripts=(
        "menu:menu/menu.sh"
        "running:menu/running.sh"
        "clearcache:menu/clearcache.sh"
        "restart:menu/restart.sh"
        "status:status.sh"
        "about:menu/about.sh"
        "auto-reboot:menu/auto-reboot.sh"
        "usernew:ssh/usernew.sh"
        "trial:ssh/trial.sh"
        "renew:ssh/renew.sh"
        "hapus:ssh/hapus.sh"
        "cek:ssh/cek.sh"
        "member:ssh/member.sh"
        "delete:ssh/delete.sh"
        "autokill:ssh/autokill.sh"
        "ceklim:ssh/ceklim.sh"
        "tendang:ssh/tendang.sh"
        "speedtest:ssh/speedtest_cli.py"
        "backup:backup/backup.sh"
        "restore:backup/restore.sh"
        "xp:ssh/xp.sh"
    )
    
    cd /usr/bin
    
    for script in "${scripts[@]}"; do
        local name="${script%%:*}"
        local path="${script##*:}"
        
        if [[ ! -f "$name" ]]; then
            blue "Downloading $name..."
            wget -q -O "$name" "$base_url/$path" || {
                yellow "Warning: Failed to download $name"
                continue
            }
            chmod +x "$name" || yellow "Warning: Failed to chmod $name"
        fi
    done
    
    success "Scripts downloaded"
}

# ===================================================================
# CREATE MAIN MENU SCRIPT
# ===================================================================

create_main_menu() {
    blue "Creating main menu script..."
    
    cat > /usr/bin/menu << 'EOF'
#!/bin/bash
# ===================================================================
# GX TUNNEL MAIN MENU
# Complete Management Interface
# ===================================================================

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
NC='\033[0m'

green() { echo -e "${GREEN}[✓]${NC} $*"; }
red() { echo -e "${RED}[✗]${NC} $*"; }
yellow() { echo -e "${YELLOW}[!]${NC} $*"; }
blue() { echo -e "${BLUE}[i]${NC} $*"; }

# Get server info
get_server_info() {
    local ip=$(curl -s ipinfo.io/ip 2>/dev/null || echo "Unknown")
    local hostname=$(hostname)
    local os=$(lsb_release -d | cut -f2 2>/dev/null || echo "Unknown")
    local kernel=$(uname -r)
    local uptime=$(uptime -p 2>/dev/null || echo "Unknown")
    
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}                    ${WHITE}GX TUNNEL VPS MANAGER${NC}                    ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                    ${YELLOW}Version 2.0 - Updated${NC}                      ${CYAN}║${NC}"
    echo -e "${CYAN}╠══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC} ${WHITE}Server IP:${NC} $ip"
    echo -e "${CYAN}║${NC} ${WHITE}Hostname:${NC} $hostname"
    echo -e "${CYAN}║${NC} ${WHITE}OS:${NC} $os"
    echo -e "${CYAN}║${NC} ${WHITE}Kernel:${NC} $kernel"
    echo -e "${CYAN}║${NC} ${WHITE}Uptime:${NC} $uptime"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
}

# Main menu function
show_main_menu() {
    clear
    get_server_info
    echo ""
    echo -e "${BLUE}┌─────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│${NC}                    ${WHITE}MAIN MENU${NC}                           ${BLUE}│${NC}"
    echo -e "${BLUE}├─────────────────────────────────────────────────────────────┤${NC}"
    echo -e "${BLUE}│${NC}  ${YELLOW}1)${NC} ${WHITE}SSH & VPN Management${NC}                               ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}  ${YELLOW}2)${NC} ${WHITE}XRAY Management${NC}                                    ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}  ${YELLOW}3)${NC} ${WHITE}System Status${NC}                                      ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}  ${YELLOW}4)${NC} ${WHITE}System Tools${NC}                                       ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}  ${YELLOW}5)${NC} ${WHITE}Restart Services${NC}                                   ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}  ${YELLOW}6)${NC} ${WHITE}Backup & Restore${NC}                                   ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}  ${YELLOW}7)${NC} ${WHITE}WebSocket Management${NC}                               ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}  ${YELLOW}8)${NC} ${WHITE}Settings${NC}                                           ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}  ${YELLOW}9)${NC} ${WHITE}About${NC}                                              ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}                                                    ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}  ${RED}0)${NC} ${WHITE}Exit${NC}                                              ${BLUE}│${NC}"
    echo -e "${BLUE}└─────────────────────────────────────────────────────────────┘${NC}"
    echo ""
}

# SSH Management menu
ssh_menu() {
    clear
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}                    ${WHITE}SSH & VPN MANAGEMENT${NC}                   ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}┌─────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│${NC}  ${YELLOW}1)${NC} ${WHITE}Create New User${NC}                                    ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}  ${YELLOW}2)${NC} ${WHITE}Create Trial User${NC}                                  ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}  ${YELLOW}3)${NC} ${WHITE}Renew User${NC}                                         ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}  ${YELLOW}4)${NC} ${WHITE}Delete User${NC}                                        ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}  ${YELLOW}5)${NC} ${WHITE}Check User${NC}                                         ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}  ${YELLOW}6)${NC} ${WHITE}List All Users${NC}                                     ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}  ${YELLOW}7)${NC} ${WHITE}Delete Expired Users${NC}                               ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}  ${YELLOW}8)${NC} ${WHITE}Auto Kill Users${NC}                                    ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}  ${YELLOW}9)${NC} ${WHITE}Check User Limits${NC}                                  ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}                                                    ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}  ${RED}0)${NC} ${WHITE}Back to Main Menu${NC}                                 ${BLUE}│${NC}"
    echo -e "${BLUE}└─────────────────────────────────────────────────────────────┘${NC}"
    echo ""
    
    read -p "Select option [0-9]: " choice
    case $choice in
        1) /usr/bin/usernew ;;
        2) /usr/bin/trial ;;
        3) /usr/bin/renew ;;
        4) /usr/bin/hapus ;;
        5) /usr/bin/cek ;;
        6) /usr/bin/member ;;
        7) /usr/bin/delete ;;
        8) /usr/bin/autokill ;;
        9) /usr/bin/ceklim ;;
        0) return ;;
        *) echo "Invalid option!"; sleep 2 ;;
    esac
}

# Main menu loop
main() {
    while true; do
        show_main_menu
        read -p "Select option [0-9]: " choice
        
        case $choice in
            1) ssh_menu ;;
            2) 
                echo "XRAY Management - Coming Soon!"
                sleep 2
                ;;
            3) /usr/bin/running ;;
            4) 
                clear
                echo -e "${BLUE}System Tools Menu${NC}"
                echo -e "1) Clear Cache"
                echo -e "2) Speed Test"
                echo -e "3) Back"
                read -p "Select: " tool_choice
                case $tool_choice in
                    1) /usr/bin/clearcache ;;
                    2) /usr/bin/speedtest ;;
                    3) ;;
                esac
                ;;
            5) /usr/bin/restart ;;
            6) 
                clear
                echo -e "${BLUE}Backup & Restore Menu${NC}"
                echo -e "1) Backup"
                echo -e "2) Restore"
                echo -e "3) Back"
                read -p "Select: " backup_choice
                case $backup_choice in
                    1) /usr/bin/backup ;;
                    2) /usr/bin/restore ;;
                    3) ;;
                esac
                ;;
            7) 
                echo "WebSocket Management - Coming Soon!"
                sleep 2
                ;;
            8) 
                clear
                echo -e "${BLUE}Settings Menu${NC}"
                echo -e "1) Auto Reboot"
                echo -e "2) About"
                echo -e "3) Back"
                read -p "Select: " settings_choice
                case $settings_choice in
                    1) /usr/bin/auto-reboot ;;
                    2) /usr/bin/about ;;
                    3) ;;
                esac
                ;;
            9) /usr/bin/about ;;
            0) 
                echo "Goodbye!"
                exit 0
                ;;
            *) 
                echo "Invalid option!"
                sleep 2
                ;;
        esac
    done
}

# Run main menu
main
EOF
    
    chmod +x /usr/bin/menu
    success "Main menu created"
}

# ===================================================================
# FIX BROKEN SERVICES
# ===================================================================

fix_services() {
    blue "Fixing service configurations..."
    
    # Fix BadVPN service
    if [[ -f /etc/systemd/system/badvpn-7100-7900.service ]]; then
        systemctl daemon-reload
        systemctl enable badvpn-7100-7900.service || true
        systemctl restart badvpn-7100-7900.service || true
    fi
    
    # Fix WebSocket services
    for service in ws-dropbear ws-stunnel ws-ovpn; do
        if [[ -f /etc/systemd/system/${service}.service ]]; then
            systemctl daemon-reload
            systemctl enable ${service}.service || true
            systemctl restart ${service}.service || true
        fi
    done
    
    # Fix user permissions
    if id "gxtunnel" &>/dev/null; then
        chown -R gxtunnel:gxtunnel /home/gxtunnel || true
    fi
    
    success "Services fixed"
}

# ===================================================================
# CREATE ALIASES
# ===================================================================

create_aliases() {
    blue "Creating command aliases..."
    
    # Add aliases to bashrc
    cat >> /root/.bashrc << 'EOF'

# GX Tunnel Aliases
alias menu='bash /usr/bin/menu'
alias status='bash /usr/bin/status'
alias restart='bash /usr/bin/restart'
alias running='bash /usr/bin/running'
alias clearcache='bash /usr/bin/clearcache'

# Service aliases
alias ssh-restart='/etc/init.d/ssh restart'
alias dropbear-restart='/etc/init.d/dropbear restart'
alias stunnel-restart='/etc/init.d/stunnel4 restart'
alias nginx-restart='/etc/init.d/nginx restart'

# System aliases
alias update-apt='apt update && apt upgrade -y'
alias clear-log='truncate -s 0 /var/log/*.log'
EOF
    
    # Reload bashrc
    source /root/.bashrc || true
    
    success "Aliases created"
}

# ===================================================================
# CREATE SYSTEM STATUS CHECKER
# ===================================================================

create_status_checker() {
    blue "Creating system status checker..."
    
    cat > /usr/bin/status << 'EOF'
#!/bin/bash
# ===================================================================
# GX TUNNEL SYSTEM STATUS CHECKER
# ===================================================================

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

green() { echo -e "${GREEN}[✓]${NC} $*"; }
red() { echo -e "${RED}[✗]${NC} $*"; }
yellow() { echo -e "${YELLOW}[!]${NC} $*"; }
blue() { echo -e "${BLUE}[i]${NC} $*"; }

# Function to check service status
check_service() {
    local service_name=$1
    local service_type=$2
    
    case $service_type in
        "systemd")
            if systemctl is-active --quiet "$service_name"; then
                green "$service_name is running"
            else
                red "$service_name is not running"
            fi
            ;;
        "init")
            if /etc/init.d/"$service_name" status >/dev/null 2>&1; then
                green "$service_name is running"
            else
                red "$service_name is not running"
            fi
            ;;
    esac
}

# Main status check
clear
echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}                    ${WHITE}SYSTEM STATUS CHECK${NC}                    ${BLUE}║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check system services
blue "Checking System Services:"
check_service "ssh" "init"
check_service "dropbear" "init"
check_service "stunnel4" "init"
check_service "nginx" "init"
check_service "fail2ban" "init"
check_service "cron" "init"

# Check WebSocket services
blue "Checking WebSocket Services:"
check_service "ws-dropbear" "systemd"
check_service "ws-stunnel" "systemd"
check_service "ws-ovpn" "systemd"

# Check network
blue "Checking Network:"
if ping -c 1 8.8.8.8 &>/dev/null; then
    green "Internet connection is active"
else
    red "No internet connection"
fi

# Check ports
blue "Checking Ports:"
for port in 22 80 443 143 222 777; do
    if netstat -tulpn | grep -q ":$port "; then
        green "Port $port is listening"
    else
        yellow "Port $port is not listening"
    fi
done

echo ""
echo -e "${BLUE}Status check completed!${NC}"
EOF
    
    chmod +x /usr/bin/status
    success "Status checker created"
}

# ===================================================================
# FINAL SETUP
# ===================================================================

complete_setup() {
    green "╔══════════════════════════════════════════════════════════════╗"
    green "║${NC}                    ${WHITE}SETUP COMPLETED!${NC}                        ${GREEN}║${NC}"
    green "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    blue "Available commands:"
    echo "  • menu     - Main management menu"
    echo "  • status   - Check service status"
    echo "  • restart  - Restart services"
    echo "  • running  - Show running services"
    echo ""
    blue "Service ports:"
    echo "  • SSH: 22, 500, 40000, 51443, 58080, 200"
    echo "  • Dropbear: 143, 109, 110, 69, 50000"
    echo "  • Stunnel: 222, 777, 2096, 442"
    echo "  • HTTP/HTTPS: 80, 443"
    echo ""
    green "System is ready to use!"
}

# ===================================================================
# MAIN FIX SEQUENCE
# ===================================================================

main() {
    clear
    green "╔══════════════════════════════════════════════════════════════╗"
    green "║${NC}                ${WHITE}GX TUNNEL COMPLETE FIX${NC}                     ${GREEN}║${NC}"
    green "║${NC}                    ${YELLOW}Version 3.0${NC}                             ${GREEN}║${NC}"
    green "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    
    check_root
    create_directories
    download_scripts
    create_main_menu
    fix_services
    create_aliases
    create_status_checker
    complete_setup
    
    echo ""
    yellow "You can now use 'menu' command to access the management interface!"
}

# Run main function
main "$@"
