#!/bin/bash
# ===================================================================
# GX Tunnel VPS Setup - Enhanced & Error-Free Version
# Author: xcybermanx
# Version: 2.0 (Updated)
# Description: Complete VPS setup with error handling and validation
# ===================================================================

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
NC='\033[0m'

# Color functions
green() { echo -e "${GREEN}[✓]${NC} $*"; }
red() { echo -e "${RED}[✗]${NC} $*"; }
yellow() { echo -e "${YELLOW}[!]${NC} $*"; }
blue() { echo -e "${BLUE}[i]${NC} $*"; }

# Error handling
error_exit() {
    red "ERROR: $1"
    exit 1
}

# Success message
success() {
    green "$1"
    sleep 1
}

# Warning message
warning() {
    yellow "WARNING: $1"
    sleep 2
}

# ===================================================================
# SYSTEM VALIDATION & PREPARATION
# ===================================================================

check_root() {
    if [[ $EUID -ne 0 ]]; then
        error_exit "This script must be run as root. Use: sudo bash setup.sh"
    fi
}

check_os() {
    if [[ ! -f /etc/os-release ]]; then
        error_exit "Cannot detect OS. This script requires Debian/Ubuntu."
    fi
    
    source /etc/os-release
    case $ID in
        ubuntu|debian)
            blue "Detected OS: $NAME"
            ;;
        *)
            warning "Unsupported OS: $NAME. Continuing anyway..."
            ;;
    esac
}

check_internet() {
    blue "Checking internet connection..."
    if ! ping -c 1 8.8.8.8 &>/dev/null; then
        error_exit "No internet connection detected"
    fi
    success "Internet connection verified"
}

set_timezone() {
    blue "Setting timezone to Asia/Jakarta..."
    timedatectl set-timezone Asia/Jakarta || warning "Failed to set timezone"
    success "Timezone configured"
}

# ===================================================================
# SYSTEM UPDATE & ESSENTIAL PACKAGES
# ===================================================================

update_system() {
    blue "Updating system packages..."
    export DEBIAN_FRONTEND=noninteractive
    
    # Fix potential dpkg issues
    dpkg --configure -a || true
    apt-get install -f -y || true
    
    # Update package lists
    apt-get update -y || error_exit "Failed to update package lists"
    
    # Upgrade packages
    apt-get upgrade -y || warning "Some packages failed to upgrade"
    
    # Install essential packages
    blue "Installing essential packages..."
    apt-get install -y --no-install-recommends \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        gnupg \
        lsb-release \
        curl \
        wget \
        git \
        unzip \
        jq \
        nano \
        vim \
        htop \
        net-tools \
        iptables \
        iptables-persistent \
        fail2ban \
        ufw || warning "Some packages failed to install"
    
    success "System packages updated"
}

# ===================================================================
# USER MANAGEMENT
# ===================================================================

create_vpn_user() {
    local username="gxtunnel"
    local user_home="/home/$username"
    
    blue "Creating VPN user: $username"
    
    # Remove existing user if present
    if id "$username" &>/dev/null; then
        yellow "User $username exists, removing..."
        userdel -r "$username" 2>/dev/null || true
    fi
    
    # Create user
    useradd -m -d "$user_home" -s /bin/bash "$username" || error_exit "Failed to create user"
    
    # Set password
    echo "$username:gxtunnel123" | chpasswd || warning "Failed to set password"
    
    # Add to sudo group
    usermod -aG sudo "$username" || warning "Failed to add user to sudo group"
    
    # Create directory structure
    mkdir -p "$user_home"/{tmp,config,logs,backup} || warning "Failed to create directories"
    
    # Set permissions
    chown -R "$username:$username" "$user_home" || warning "Failed to set permissions"
    
    success "User $username created successfully"
}

# ===================================================================
# NETWORK CONFIGURATION
# ===================================================================

configure_network() {
    blue "Configuring network settings..."
    
    # Disable IPv6
    cat > /etc/sysctl.d/99-disable-ipv6.conf << 'EOF'
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF
    
    sysctl -p /etc/sysctl.d/99-disable-ipv6.conf || warning "Failed to disable IPv6"
    
    # Configure UFW
    ufw --force reset || true
    ufw default deny incoming
    ufw default allow outgoing
    
    # Allow essential ports
    ufw allow 22/tcp comment "SSH"
    ufw allow 80/tcp comment "HTTP"
    ufw allow 443/tcp comment "HTTPS"
    ufw allow 53 comment "DNS"
    
    success "Network configured"
}

# ===================================================================
# SSH HARDENING & MULTI-PORT
# ===================================================================

configure_ssh() {
    blue "Configuring SSH..."
    
    # Backup original config
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
    
    # Configure SSH
    cat > /etc/ssh/sshd_config << 'EOF'
# GX Tunnel SSH Configuration
Port 22
Port 500
Port 40000
Port 51443
Port 58080
Port 200

Protocol 2
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ed25519_key

PermitRootLogin yes
PasswordAuthentication yes
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys

ClientAliveInterval 60
ClientAliveCountMax 3
MaxAuthTries 6
MaxSessions 10

X11Forwarding no
PrintMotd no
TCPKeepAlive yes
Banner /etc/issue.net

AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/openssh/sftp-server
EOF
    
    # Create issue.net banner
    cat > /etc/issue.net << 'EOF'
╔════════════════════════════════════════════════════════════════╗
║                    GX TUNNEL VPS SERVER                        ║
║                 Authorized access only!                        ║
║            All activities are monitored and logged.            ║
╚════════════════════════════════════════════════════════════════╝
EOF
    
    systemctl restart sshd || error_exit "Failed to restart SSH service"
    success "SSH configured with multiple ports"
}

# ===================================================================
# DROPBEAR INSTALLATION
# ===================================================================

install_dropbear() {
    blue "Installing Dropbear..."
    
    apt-get install -y dropbear || error_exit "Failed to install Dropbear"
    
    # Configure Dropbear
    cat > /etc/default/dropbear << 'EOF'
# Disable SSH port 22 (handled by OpenSSH)
NO_START=0

# Dropbear port
DROPBEAR_PORT=143

# Additional ports
DROPBEAR_EXTRA_ARGS="-p 50000 -p 109 -p 110 -p 69"

# Banner
DROPBEAR_BANNER="/etc/issue.net"
EOF
    
    # Add shells
    echo "/bin/false" >> /etc/shells
    echo "/usr/sbin/nologin" >> /etc/shells
    
    systemctl restart dropbear || warning "Failed to restart Dropbear"
    success "Dropbear installed and configured"
}

# ===================================================================
# STUNNEL INSTALLATION
# ===================================================================

install_stunnel() {
    blue "Installing Stunnel..."
    
    apt-get install -y stunnel4 || error_exit "Failed to install Stunnel"
    
    # Generate SSL certificate
    openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
        -keyout /etc/stunnel/stunnel.key -out /etc/stunnel/stunnel.crt \
        -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost" || warning "Failed to generate SSL certificate"
    
    cat /etc/stunnel/stunnel.crt /etc/stunnel/stunnel.key > /etc/stunnel/stunnel.pem
    
    # Configure Stunnel
    cat > /etc/stunnel/stunnel.conf << 'EOF'
cert = /etc/stunnel/stunnel.pem
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[ssh]
accept = 222
connect = 127.0.0.1:22

[dropbear]
accept = 777
connect = 127.0.0.1:109

[ws-stunnel]
accept = 2096
connect = 700

[openvpn]
accept = 442
connect = 127.0.0.1:1194
EOF
    
    # Enable Stunnel
    sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
    
    systemctl restart stunnel4 || warning "Failed to restart Stunnel"
    success "Stunnel installed and configured"
}

# ===================================================================
# FAIL2BAN & SECURITY
# ===================================================================

install_fail2ban() {
    blue "Installing Fail2ban..."
    
    apt-get install -y fail2ban || error_exit "Failed to install Fail2ban"
    
    # Configure Fail2ban
    cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5

[sshd]
enabled = true
port = ssh,500,40000,51443,58080,200
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
EOF
    
    systemctl restart fail2ban || warning "Failed to restart Fail2ban"
    success "Fail2ban installed and configured"
}

# ===================================================================
# NGINX INSTALLATION
# ===================================================================

install_nginx() {
    blue "Installing Nginx..."
    
    # Remove existing nginx
    apt-get remove --purge nginx nginx-common nginx-full -y || true
    rm -rf /etc/nginx /var/log/nginx /var/www/html
    
    apt-get install -y nginx || error_exit "Failed to install Nginx"
    
    # Configure Nginx
    cat > /etc/nginx/nginx.conf << 'EOF'
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
    worker_connections 1024;
    use epoll;
    multi_accept on;
}

http {
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    server_tokens off;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers off;

    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml text/javascript application/json application/javascript application/xml+rss application/rss+xml application/atom+xml image/svg+xml;

    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}
EOF
    
    # Create web directory
    mkdir -p /var/www/html
    chown www-data:www-data /var/www/html
    
    # Create default page
    cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>GX Tunnel VPS</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .header { color: #333; }
        .info { background: #f0f0f0; padding: 20px; border-radius: 5px; }
    </style>
</head>
<body>
    <h1 class="header">GX Tunnel VPS Server</h1>
    <div class="info">
        <p>Server is running successfully!</p>
        <p>Server Time: <span id="time"></span></p>
    </div>
    <script>
        document.getElementById('time').innerHTML = new Date().toLocaleString();
    </script>
</body>
</html>
EOF
    
    systemctl restart nginx || warning "Failed to restart Nginx"
    success "Nginx installed and configured"
}

# ===================================================================
# BADVPN INSTALLATION
# ===================================================================

install_badvpn() {
    blue "Installing BadVPN UDP Gateway..."
    
    cd /tmp
    wget -q -O badvpn.sh "https://raw.githubusercontent.com/xcybermanx/Projet_VPS/main/badvpn/badvpn.sh" || error_exit "Failed to download BadVPN script"
    chmod +x badvpn.sh
    ./badvpn.sh || warning "BadVPN installation failed"
    cd ~
    
    success "BadVPN installation completed"
}

# ===================================================================
# WEBSOCKET INSTALLATION
# ===================================================================

install_websocket() {
    blue "Installing WebSocket services..."
    
    # Install Python if not present
    apt-get install -y python3 python3-pip || warning "Failed to install Python"
    
    cd /usr/local/bin
    
    # Download WebSocket scripts
    wget -q -O ws-dropbear "https://raw.githubusercontent.com/xcybermanx/Projet_VPS/main/sshws/dropbear-ws.py" || warning "Failed to download ws-dropbear"
    wget -q -O ws-stunnel "https://raw.githubusercontent.com/xcybermanx/Projet_VPS/main/sshws/ws-stunnel" || warning "Failed to download ws-stunnel"
    wget -q -O ws-ovpn "https://raw.githubusercontent.com/xcybermanx/Projet_VPS/main/sshws/ws-ovpn.py" || warning "Failed to download ws-ovpn"
    
    chmod +x ws-dropbear ws-stunnel ws-ovpn
    
    # Download systemd services
    wget -q -O /etc/systemd/system/ws-dropbear.service "https://raw.githubusercontent.com/xcybermanx/Projet_VPS/main/sshws/service-wsdropbear" || warning "Failed to download ws-dropbear service"
    wget -q -O /etc/systemd/system/ws-stunnel.service "https://raw.githubusercontent.com/xcybermanx/Projet_VPS/main/sshws/ws-stunnel.service" || warning "Failed to download ws-stunnel service"
    wget -q -O /etc/systemd/system/ws-ovpn.service "https://raw.githubusercontent.com/xcybermanx/Projet_VPS/main/sshws/ws-ovpn.service" || warning "Failed to download ws-ovpn service"
    
    chmod +x /etc/systemd/system/ws-*.service
    
    # Enable and start services
    systemctl daemon-reload
    systemctl enable ws-dropbear ws-stunnel ws-ovpn || warning "Failed to enable WebSocket services"
    systemctl start ws-dropbear ws-stunnel ws-ovpn || warning "Failed to start WebSocket services"
    
    success "WebSocket services installed"
}

# ===================================================================
# IPTABLES CONFIGURATION
# ===================================================================

configure_iptables() {
    blue "Configuring iptables..."
    
    # Create iptables rules
    cat > /etc/iptables.rules << 'EOF'
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]

# Allow loopback
-A INPUT -i lo -j ACCEPT
-A OUTPUT -o lo -j ACCEPT

# Allow established connections
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow SSH
-A INPUT -p tcp --dport 22 -j ACCEPT
-A INPUT -p tcp --dport 500 -j ACCEPT
-A INPUT -p tcp --dport 40000 -j ACCEPT
-A INPUT -p tcp --dport 51443 -j ACCEPT
-A INPUT -p tcp --dport 58080 -j ACCEPT
-A INPUT -p tcp --dport 200 -j ACCEPT

# Allow Dropbear
-A INPUT -p tcp --dport 143 -j ACCEPT
-A INPUT -p tcp --dport 50000 -j ACCEPT
-A INPUT -p tcp --dport 109 -j ACCEPT
-A INPUT -p tcp --dport 110 -j ACCEPT
-A INPUT -p tcp --dport 69 -j ACCEPT

# Allow Stunnel
-A INPUT -p tcp --dport 222 -j ACCEPT
-A INPUT -p tcp --dport 777 -j ACCEPT
-A INPUT -p tcp --dport 2096 -j ACCEPT
-A INPUT -p tcp --dport 442 -j ACCEPT

# Allow HTTP/HTTPS
-A INPUT -p tcp --dport 80 -j ACCEPT
-A INPUT -p tcp --dport 443 -j ACCEPT

# Allow DNS
-A INPUT -p udp --dport 53 -j ACCEPT
-A INPUT -p tcp --dport 53 -j ACCEPT

# Block torrent
-A FORWARD -m string --string "get_peers" --algo bm -j DROP
-A FORWARD -m string --string "announce_peer" --algo bm -j DROP
-A FORWARD -m string --string "find_node" --algo bm -j DROP
-A FORWARD -m string --algo bm --string "BitTorrent" -j DROP
-A FORWARD -m string --algo bm --string "BitTorrent protocol" -j DROP
-A FORWARD -m string --algo bm --string "peer_id=" -j DROP
-A FORWARD -m string --algo bm --string ".torrent" -j DROP
-A FORWARD -m string --algo bm --string "announce.php?passkey=" -j DROP
-A FORWARD -m string --algo bm --string "torrent" -j DROP
-A FORWARD -m string --algo bm --string "announce" -j DROP
-A FORWARD -m string --algo bm --string "info_hash" -j DROP

# Default policies
-A INPUT -j DROP
COMMIT
EOF
    
    # Make iptables rules persistent
    iptables-restore < /etc/iptables.rules
    
    # Create persistent script
    cat > /etc/network/if-pre-up.d/iptables << 'EOF'
#!/bin/sh
/sbin/iptables-restore < /etc/iptables.rules
EOF
    
    chmod +x /etc/network/if-pre-up.d/iptables
    
    success "Iptables configured"
}

# ===================================================================
# MENU SYSTEM INSTALLATION
# ===================================================================

install_menu() {
    blue "Installing menu system..."
    
    cd /usr/bin
    
    # Download main menu
    wget -q -O menu "https://raw.githubusercontent.com/xcybermanx/Projet_VPS/main/menu/menu.sh" || warning "Failed to download main menu"
    
    # Download essential scripts
    local scripts=(
        "menu-ssh:menu-ssh.sh"
        "usernew:usernew.sh"
        "trial:trial.sh"
        "renew:renew.sh"
        "hapus:hapus.sh"
        "cek:cek.sh"
        "member:member.sh"
        "delete:delete.sh"
        "autokill:autokill.sh"
        "ceklim:ceklim.sh"
        "tendang:tendang.sh"
        "running:running.sh"
        "clearcache:clearcache.sh"
        "speedtest:speedtest_cli.py"
        "restart:restart.sh"
        "status:status.sh"
        "about:about.sh"
        "auto-reboot:auto-reboot.sh"
        "backup:backup.sh"
        "restore:restore.sh"
    )
    
    for script in "${scripts[@]}"; do
        local name="${script%:*}"
        local file="${script#*:}"
        wget -q -O "$name" "https://raw.githubusercontent.com/xcybermanx/Projet_VPS/main/ssh/$file" || warning "Failed to download $name"
        chmod +x "$name" || warning "Failed to make $name executable"
    done
    
    # Make menu executable
    chmod +x menu || warning "Failed to make menu executable"
    
    success "Menu system installed"
}

# ===================================================================
# CRON JOBS CONFIGURATION
# ===================================================================

configure_cron() {
    blue "Configuring cron jobs..."
    
    # Auto reboot at 2 AM
    cat > /etc/cron.d/re_otm << 'EOF'
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
0 2 * * * root /sbin/reboot
EOF
    
    # Auto delete expired users at midnight
    cat > /etc/cron.d/xp_otm << 'EOF'
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
0 0 * * * root /usr/bin/xp
EOF
    
    # Restart services daily
    cat > /etc/cron.d/restart_services << 'EOF'
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
0 6 * * * root /usr/bin/restart
EOF
    
    # Enable cron service
    systemctl enable cron || warning "Failed to enable cron"
    systemctl restart cron || warning "Failed to restart cron"
    
    success "Cron jobs configured"
}

# ===================================================================
# SYSTEM CLEANUP
# ===================================================================

cleanup_system() {
    blue "Cleaning up system..."
    
    # Remove unnecessary packages
    apt-get remove --purge -y \
        apache2* \
        bind9* \
        sendmail* \
        exim4* \
        samba* \
        ufw || true
    
    # Clean package cache
    apt-get autoremove -y || true
    apt-get autoclean -y || true
    apt-get clean -y || true
    
    # Clear history
    history -c
    echo "unset HISTFILE" >> /etc/profile
    
    success "System cleanup completed"
}

# ===================================================================
# FINAL SYSTEM RESTART
# ===================================================================

final_restart() {
    green "============================================"
    green "GX TUNNEL VPS SETUP COMPLETED SUCCESSFULLY!"
    green "============================================"
    echo ""
    blue "Service Status:"
    systemctl is-active ssh
    systemctl is-active dropbear
    systemctl is-active stunnel4
    systemctl is-active nginx
    systemctl is-active fail2ban
    echo ""
    yellow "System will reboot in 10 seconds..."
    yellow "After reboot, use command: menu"
    echo ""
    
    # Countdown
    for i in {10..1}; do
        echo -ne "\rRebooting in $i seconds... "
        sleep 1
    done
    
    reboot
}

# ===================================================================
# MAIN INSTALLATION SEQUENCE
# ===================================================================

main() {
    clear
    echo ""
    green "╔══════════════════════════════════════════════════════════════╗"
    green "║                GX TUNNEL VPS SETUP SCRIPT                    ║"
    green "║                    Version 2.0 (Updated)                     ║"
    green "║                     Author: xcybermanx                       ║"
    green "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    
    # Validation checks
    check_root
    check_os
    check_internet
    set_timezone
    
    # Installation sequence
    update_system
    create_vpn_user
    configure_network
    configure_ssh
    install_dropbear
    install_stunnel
    install_fail2ban
    install_nginx
    install_badvpn
    install_websocket
    configure_iptables
    install_menu
    configure_cron
    cleanup_system
    
    # Final restart
    final_restart
}

# Trap errors
trap 'error_exit "Installation failed at line $LINENO"' ERR

# Run main function
main "$@"
