#!/bin/bash
# ===================================================================
# GX TUNNEL ERROR FIX & UPDATE SCRIPT
# Version: 2.0
# Use this if you encounter errors during installation
# ===================================================================

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

green() { echo -e "${GREEN}[✓]${NC} $*"; }
red() { echo -e "${RED}[✗]${NC} $*"; }
yellow() { echo -e "${YELLOW}[!]${NC} $*"; }

# Fix common issues
fix_common_issues() {
    yellow "Fixing common system issues..."
    
    # Fix dpkg
    dpkg --configure -a || true
    
    # Fix broken packages
    apt-get install -f -y || true
    
    # Clear apt cache
    apt-get clean
    apt-get update
    
    # Fix locale
    apt-get install -y locales
    locale-gen en_US.UTF-8
    update-locale LANG=en_US.UTF-8
    
    # Fix time
    apt-get install -y ntpdate
    ntpdate pool.ntp.org
    
    green "Common issues fixed"
}

# Fix service issues
fix_services() {
    yellow "Fixing service issues..."
    
    # Restart all services
    systemctl daemon-reload
    
    # SSH
    systemctl restart ssh || {
        red "SSH failed to restart"
        systemctl status ssh --no-pager
    }
    
    # Dropbear
    systemctl restart dropbear || {
        red "Dropbear failed to restart"
        apt-get install -y dropbear
        systemctl restart dropbear
    }
    
    # Stunnel
    systemctl restart stunnel4 || {
        red "Stunnel failed to restart"
        apt-get install -y stunnel4
        systemctl restart stunnel4
    }
    
    # Nginx
    systemctl restart nginx || {
        red "Nginx failed to restart"
        nginx -t
        systemctl restart nginx
    }
    
    # Fail2ban
    systemctl restart fail2ban || {
        red "Fail2ban failed to restart"
        apt-get install -y fail2ban
        systemctl restart fail2ban
    }
    
    green "Services fixed"
}

# Fix permissions
fix_permissions() {
    yellow "Fixing permissions..."
    
    # Fix user permissions
    chown -R gxtunnel:gxtunnel /home/gxtunnel 2>/dev/null || true
    
    # Fix script permissions
    chmod +x /usr/bin/menu 2>/dev/null || true
    chmod +x /usr/bin/* 2>/dev/null || true
    
    # Fix nginx permissions
    chown -R www-data:www-data /var/www/html 2>/dev/null || true
    
    green "Permissions fixed"
}

# Fix network issues
fix_network() {
    yellow "Fixing network issues..."
    
    # Reset iptables
    iptables -F
    iptables -X
    iptables -t nat -F
    iptables -t nat -X
    iptables -t mangle -F
    iptables -t mangle -X
    
    # Restore rules if exist
    [[ -f /etc/iptables.rules ]] && iptables-restore < /etc/iptables.rules
    
    # Fix ports
    netstat -tulpn | grep -E ':22|:143|:500|:40000|:51443|:58080|:200|:222|:777|:2096|:442|:80|: Allow all other traffic
-A INPUT -j ACCEPT
-A FORWARD -j ACCEPT
COMMIT

*nat
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]

COMMIT
EOF
    
    # Install iptables-persistent
    apt-get install -y iptables-persistent || warning "Failed to install iptables-persistent"
    
    # Load rules
    iptables-restore < /etc/iptables.rules || warning "Failed to load iptables rules"
    
    # Make rules persistent
    netfilter-persistent save || warning "Failed to save iptables rules"
    
    success "iptables configured"
}

# ===================================================================
# MENU INSTALLATION
# ===================================================================

install_menu() {
    blue "Installing management menu..."
    
    cd /usr/bin
    
    # Download menu scripts
    local menu_scripts=(
        "menu:menu/menu.sh"
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
        "restart:menu/restart.sh"
        "speedtest:ssh/speedtest_cli.py"
        "status:status.sh"
        "about:menu/about.sh"
        "auto-reboot:menu/auto-reboot.sh"
    )
    
    for script in "${menu_scripts[@]}"; do
        local name="${script%%:*}"
        local path="${script##*:}"
        
        wget -q -O "$name" "https://raw.githubusercontent.com/xcybermanx/Projet_VPS/main/$path" || warning "Failed to download $name"
        chmod +x "$name" || warning "Failed to chmod $name"
    done
    
    # Create symlink for menu
    ln -sf /usr/bin/menu /usr/local/bin/menu || warning "Failed to create menu symlink"
    
    success "Management menu installed"
}

# ===================================================================
# CRON JOBS
# ===================================================================

setup_cron() {
    blue "Setting up cron jobs..."
    
    # Create cron jobs
    cat > /etc/cron.d/gx_tunnel << 'EOF'
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# Auto reboot at 2 AM
0 2 * * * root /sbin/reboot

# Auto clear expired users at midnight
0 0 * * * root /usr/bin/xp

# SSL renewal check every 3 days
15 03 */3 * * root /usr/local/bin/ssl_renew.sh
EOF
    
    systemctl restart cron || warning "Failed to restart cron service"
    success "Cron jobs configured"
}

# ===================================================================
# FINAL CLEANUP
# ===================================================================

final_cleanup() {
    blue "Performing final cleanup..."
    
    # Remove unnecessary packages
    apt-get autoremove -y || true
    apt-get autoclean -y || true
    
    # Clear history
    history -c
    echo "unset HISTFILE" >> /etc/profile
    
    # Fix permissions
    chown -R www-data:www-data /var/www/html || true
    
    success "Cleanup completed"
}

# ===================================================================
# MAIN INSTALLATION
# ===================================================================

main() {
    clear
    echo -e "${BIGreen}╔══════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BIGreen}║${NC}                     ${BIWhite}GX Tunnel VPS Auto Installer${NC}                        ${BIGreen}║${NC}"
    echo -e "${BIGreen}║${NC}                           ${BIYellow}Version 2.0 - Updated${NC}                              ${BIGreen}║${NC}"
    echo -e "${BIGreen}╚══════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Validate system
    validate_system
    
    # Update system
    update_system
    
    # Install components
    install_openvpn
    install_dropbear
    install_stunnel
    install_fail2ban
    install_nginx
    install_badvpn
    install_websocket
    configure_iptables
    install_menu
    setup_cron
    
    # Final cleanup
    final_cleanup
    
    echo ""
    echo -e "${BIGreen}╔══════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BIGreen}║${NC}                    ${BIGreen}✅ Installation Completed Successfully!${NC}                    ${BIGreen}║${NC}"
    echo -e "${BIGreen}║${NC}                                                                                  ${BIGreen}║${NC}"
    echo -e "${BIGreen}║${NC} ${BIWhite}Commands:${NC}                                                                      ${BIGreen}║${NC}"
    echo -e "${BIGreen}║${NC}   • ${BIYellow}menu${NC} - Show management menu                                          ${BIGreen}║${NC}"
    echo -e "${BIGreen}║${NC}   • ${BIYellow}status${NC} - Show service status                                        ${BIGreen}║${NC}"
    echo -e "${BIGreen}║${NC}   • ${BIYellow}restart${NC} - Restart all services                                     ${BIGreen}║${NC}"
    echo -e "${BIGreen}║${NC}                                                                                  ${BIGreen}║${NC}"
    echo -e "${BIGreen}║${NC} ${BIWhite}SSH Ports:${NC} 22, 500, 40000, 51443, 58080, 200                          ${BIGreen}║${NC}"
    echo -e "${BIGreen}║${NC} ${BIWhite}Dropbear:${NC} 143, 109, 110, 69, 50000                                     ${BIGreen}║${NC}"
    echo -e "${BIGreen}║${NC} ${BIWhite}Stunnel:${NC} 222, 777, 2096, 442                                          ${BIGreen}║${NC}"
    echo -e "${BIGreen}║${NC} ${BIWhite}WebSocket:${NC} 80, 443                                                      ${BIGreen}║${NC}"
    echo -e "${BIGreen}║${NC}                                                                                  ${BIGreen}║${NC}"
    echo -e "${BIGreen}║${NC} ${BIYellow}System will reboot in 10 seconds...${NC}                                     ${BIGreen}║${NC}"
    echo -e "${BIGreen}╚══════════════════════════════════════════════════════════════════════════════════╝${NC}"
    
    sleep 10
    reboot
}

# Run main function
main "$@"
