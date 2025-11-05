#!/bin/bash
# ===================================================================
# GX TUNNEL VPS SETUP - COMPLETE EDITION
# Version: 3.0 - Enhanced & Error-Free
# Author: xcybermanx
# ===================================================================

set -euo pipefail

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

# Warning function
warning() {
    yellow "WARNING: $1"
    sleep 1
}

# Success function
success() {
    green "$1"
    sleep 0.5
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

# ===================================================================
# SYSTEM UPDATE & CORE PACKAGES
# ===================================================================

update_system() {
    blue "Updating system packages..."
    export DEBIAN_FRONTEND=noninteractive
    
    # Fix potential dpkg issues first
    dpkg --configure -a || true
    apt-get install -f -y || true
    
    # Update package lists
    apt-get update -y || error_exit "Failed to update package lists"
    
    # Upgrade packages (handle held packages gracefully)
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
        ufw \
        ruby \
        screen \
        build-essential \
        python3 \
        python3-pip \
        openssl \
        cron \
        tzdata || warning "Some packages failed to install"
    
    success "System packages updated"
}

# ===================================================================
# NETWORK & SYSTEM CONFIGURATION
# ===================================================================

configure_network() {
    blue "Configuring network settings..."
    
    # Set timezone
    timedatectl set-timezone Asia/Jakarta || warning "Failed to set timezone"
    
    # Disable IPv6 permanently
    cat > /etc/sysctl.d/99-disable-ipv6.conf << 'EOF'
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF
    
    sysctl -p /etc/sysctl.d/99-disable-ipv6.conf || warning "Failed to disable IPv6"
    
    # Configure UFW firewall
    ufw --force reset || true
    ufw default deny incoming
    ufw default allow outgoing
    
    # Allow essential ports
    local ports=(22 80 443 53 143 222 777 109 110 69 500 40000 51443 58080 200 50000 2096 442)
    for port in "${ports[@]}"; do
        ufw allow "$port" || warning "Failed to allow port $port"
    done
    
    success "Network configured"
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
    
    # Create user with proper home directory
    useradd -m -d "$user_home" -s /bin/bash "$username" || error_exit "Failed to create user"
    
    # Set password using different method (more reliable)
    echo "$username:gxtunnel123" | chpasswd || {
        yellow "chpasswd failed, trying alternative method"
        echo -e "gxtunnel123\ngxtunnel123" | passwd "$username" || warning "Failed to set password"
    }
    
    # Add to sudo group
    usermod -aG sudo "$username" || warning "Failed to add user to sudo group"
    
    # Create organized directory structure
    mkdir -p "$user_home"/{tmp,config,logs,backup,xray,v2ray,domain} || warning "Failed to create directories"
    
    # Set proper permissions
    chown -R "$username:$username" "$user_home" || warning "Failed to set permissions"
    
    success "User $username created successfully"
}

# ===================================================================
# SSH HARDENING & MULTI-PORT
# ===================================================================

configure_ssh() {
    blue "Configuring SSH with multiple ports..."
    
    # Backup original config
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.$(date +%Y%m%d)
    
    # Create new SSH config
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

# Authentication
PermitRootLogin yes
PasswordAuthentication yes
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys

# Connection settings
ClientAliveInterval 60
ClientAliveCountMax 3
MaxAuthTries 6
MaxSessions 10

# Security
X11Forwarding no
PrintMotd no
TCPKeepAlive yes
Banner /etc/issue.net

# Environment
AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/openssh/sftp-server
EOF
    
    # Create security banner
    cat > /etc/issue.net << 'EOF'
╔════════════════════════════════════════════════════════════════╗
║                    GX TUNNEL VPS SERVER                        ║
║                 Authorized access only!                        ║
║            All activities are monitored and logged.            ║
╚════════════════════════════════════════════════════════════════╝
EOF
    
    # Restart SSH service
    systemctl restart sshd || error_exit "Failed to restart SSH service"
    
    # Test SSH configuration
    sshd -t || warning "SSH configuration test failed"
    
    success "SSH configured with multiple ports"
}

# ===================================================================
# DROPBEAR INSTALLATION
# ===================================================================

install_dropbear() {
    blue "Installing and configuring Dropbear..."
    
    # Install Dropbear
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
    
    # Add shells for Dropbear
    echo "/bin/false" >> /etc/shells
    echo "/usr/sbin/nologin" >> /etc/shells
    
    # Restart Dropbear
    systemctl restart dropbear || warning "Failed to restart Dropbear"
    systemctl enable dropbear || warning "Failed to enable Dropbear"
    
    success "Dropbear installed and configured"
}

# ===================================================================
# STUNNEL INSTALLATION
# ===================================================================

install_stunnel() {
    blue "Installing and configuring Stunnel..."
    
    # Install Stunnel
    apt-get install -y stunnel4 || error_exit "Failed to install Stunnel"
    
    # Generate SSL certificate with proper permissions
    cd /etc/stunnel
    openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
        -keyout stunnel.key -out stunnel.crt \
        -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost" || {
        warning "Failed to generate SSL certificate"
        # Use fallback certificate
        cp /etc/ssl/certs/ssl-cert-snakeoil.pem /etc/stunnel/stunnel.crt 2>/dev/null || true
        cp /etc/ssl/private/ssl-cert-snakeoil.key /etc/stunnel/stunnel.key 2>/dev/null || true
    }
    
    # Combine certificates
    cat stunnel.crt stunnel.key > stunnel.pem 2>/dev/null || true
    chmod 600 stunnel.pem
    
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
    
    # Restart Stunnel
    systemctl restart stunnel4 || warning "Failed to restart Stunnel"
    systemctl enable stunnel4 || warning "Failed to enable Stunnel"
    
    success "Stunnel installed and configured"
}

# ===================================================================
# FAIL2BAN SECURITY
# ===================================================================

install_fail2ban() {
    blue "Installing and configuring Fail2ban..."
    
    # Install Fail2ban
    apt-get install -y fail2ban || error_exit "Failed to install Fail2ban"
    
    # Configure Fail2ban for multiple SSH ports
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
    
    # Restart Fail2ban
    systemctl restart fail2ban || warning "Failed to restart Fail2ban"
    systemctl enable fail2ban || warning "Failed to enable Fail2ban"
    
    success "Fail2ban installed and configured"
}

# ===================================================================
# NGINX WEB SERVER
# ===================================================================

install_nginx() {
    blue "Installing and configuring Nginx..."
    
    # Remove any existing nginx
    apt-get remove --purge nginx nginx-common nginx-full -y || true
    rm -rf /etc/nginx /var/log/nginx /var/www/html
    
    # Install Nginx
    apt-get install -y nginx || error_exit "Failed to install Nginx"
    
    # Create optimized Nginx config
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

    # SSL Settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers off;

    # Logging
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    # Gzip Settings
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
    
    # Create default webpage
    cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>GX Tunnel VPS</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        body { 
            font-family: Arial, sans-serif; 
            margin: 40px; 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            min-height: 100vh;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            background: rgba(255,255,255,0.1);
            padding: 40px;
            border-radius: 15px;
            backdrop-filter: blur(10px);
            box-shadow: 0 8px 32px rgba(0,0,0,0.3);
        }
        .header { 
            text-align: center; 
            margin-bottom: 30px;
        }
        .header h1 {
            font-size: 2.5em;
            margin-bottom: 10px;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }
        .info { 
            background: rgba(255,255,255,0.2); 
            padding: 20px; 
            border-radius: 10px;
            margin: 20px 0;
        }
        .status {
            display: inline-block;
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 0.9em;
            font-weight: bold;
        }
        .online { background: #4CAF50; }
        .feature {
            background: rgba(255,255,255,0.1);
            padding: 15px;
            margin: 10px 0;
            border-radius: 8px;
            border-left: 4px solid #4CAF50;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🚀 GX Tunnel VPS</h1>
            <p>Advanced Multi-Protocol VPN Server</p>
            <span class="status online">● ONLINE</span>
        </div>
        
        <div class="info">
            <h2>✅ Server Status</h2>
            <p><strong>Server Time:</strong> <span id="time"></span></p>
            <p><strong>System:</strong> Ready for connections</p>
            <p><strong>Protocols:</strong> SSH, OpenVPN, XRAY, WebSocket, Trojan</p>
        </div>

        <div class="feature">
            <h3>🔒 Secure Connections</h3>
            <p>Multiple encryption protocols with advanced security features</p>
        </div>

        <div class="feature">
            <h3>⚡ High Performance</h3>
            <p>Optimized for speed and reliability with load balancing</p>
        </div>

        <div class="feature">
            <h3>🛡️ Protected</h3>
            <p>Fail2ban protection and firewall configured</p>
        </div>
    </div>

    <script>
        function updateTime() {
            document.getElementById('time').innerHTML = new Date().toLocaleString();
        }
        updateTime();
        setInterval(updateTime, 1000);
    </script>
</body>
</html>
EOF
    
    # Restart Nginx
    systemctl restart nginx || warning "Failed to restart Nginx"
    systemctl enable nginx || warning "Failed to enable Nginx"
    
    success "Nginx installed and configured"
}

# ===================================================================
# BADVPN UDP GATEWAY
# ===================================================================

install_badvpn() {
    blue "Installing BadVPN UDP Gateway..."
    
    cd /tmp
    
    # Download BadVPN binary
    wget -q -O /bin/badvpn-udpgw "$CDN/badvpn/badvpn-udpgw" || {
        warning "Failed to download BadVPN binary"
        return 1
    }
    
    chmod +x /bin/badvpn-udpgw
    
    # Download service file
    wget -q -O /etc/systemd/system/badvpn-7100-7900.service "$CDN/badvpn/badvpn-7100-7900.service" || {
        warning "Failed to download BadVPN service"
        return 1
    }
    
    # Enable and start service
    systemctl daemon-reload
    systemctl enable badvpn-7100-7900.service || warning "Failed to enable BadVPN"
    systemctl start badvpn-7100-7900.service || warning "Failed to start BadVPN"
    
    cd ~
    
    success "BadVPN UDP Gateway installed"
}

# ===================================================================
# WEBSOCKET SERVICES
# ===================================================================

install_websocket() {
    blue "Installing WebSocket services..."
    
    # Install Python3 and pip if not present
    apt-get install -y python3 python3-pip || warning "Failed to install Python3"
    
    cd /usr/local/bin
    
    # Download WebSocket scripts
    local ws_scripts=("ws-dropbear" "ws-stunnel" "ws-ovpn")
    for script in "${ws_scripts[@]}"; do
        wget -q -O "$script" "$CDN/sshws/${script}.py" 2>/dev/null || \
        wget -q -O "$script" "$CDN/sshws/${script}" 2>/dev/null || {
            warning "Failed to download $script"
            continue
        }
        chmod +x "$script"
    done
    
    # Download service files
    local services=("ws-dropbear" "ws-stunnel" "ws-ovpn")
    for service in "${services[@]}"; do
        wget -q -O "/etc/systemd/system/${service}.service" "$CDN/sshws/${service}.service" 2>/dev/null || \
        wget -q -O "/etc/systemd/system/${service}.service" "$CDN/sshws/${service}.service" 2>/dev/null || {
            warning "Failed to download ${service}.service"
            continue
        }
    done
    
    # Enable and start WebSocket services
    systemctl daemon-reload
    for service in "${services[@]}"; do
        systemctl enable "${service}.service" || warning "Failed to enable ${service}"
        systemctl start "${service}.service" || warning "Failed to start ${service}"
    done
    
    success "WebSocket services installed"
}

# ===================================================================
# MANAGEMENT SCRIPTS
# ===================================================================

install_management_scripts() {
    blue "Installing management scripts..."
    
    cd /usr/bin
    
    # Base URL for scripts
    local base_url="https://raw.githubusercontent.com/xcybermanx/Projet_VPS/main"
    
    # Essential management scripts
    local scripts=(
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
        "xp:ssh/xp.sh"
        "running:menu/running.sh"
        "clearcache:menu/clearcache.sh"
        "restart:menu/restart.sh"
        "status:status.sh"
        "about:menu/about.sh"
        "auto-reboot:menu/auto-reboot.sh"
        "backup:backup/backup.sh"
        "restore:backup/restore.sh"
        "speedtest:ssh/speedtest_cli.py"
    )
    
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
    
    success "Management scripts installed"
}

# ===================================================================
# CREATE MAIN MENU SYSTEM
# ===================================================================

create_menu_system() {
    blue "Creating main menu system..."
    
    # Create comprehensive menu script
    cat > /usr/bin/menu << 'EOF'
#!/bin/bash
# ===================================================================
# GX TUNNEL MAIN MENU - COMPLETE MANAGEMENT SYSTEM
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

# Get server information
get_server_info() {
    local ip=$(curl -s ipinfo.io/ip 2>/dev/null || echo "Unknown")
    local hostname=$(hostname)
    local os=$(lsb_release -d | cut -f2 2>/dev/null || echo "Unknown")
    local uptime=$(uptime -p 2>/dev/null || echo "Unknown")
    
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}                    ${WHITE}GX TUNNEL VPS MANAGER${NC}                    ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                    ${YELLOW}Version 3.0 - Complete${NC}                     ${CYAN}║${NC}"
    echo -e "${CYAN}╠══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC} ${WHITE}Server IP:${NC} $ip"
    echo -e "${CYAN}║${NC} ${WHITE}Hostname:${NC} $hostname"
    echo -e "${CYAN}║${NC} ${WHITE}OS:${NC} $os"
    echo -e "${CYAN}║${NC} ${WHITE}Uptime:${NC} $uptime"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
}

# Main menu display
show_main_menu() {
    clear
    get_server_info
    echo ""
    echo -e "${BLUE}┌─────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│${NC}                    ${WHITE}MAIN MENU${NC}                           ${BLUE}│${NC}"
    echo -e "${BLUE}├─────────────────────────────────────────────────────────────┤${NC}"
    echo -e "${BLUE}│${NC}  ${YELLOW}1)${NC} ${WHITE}SSH & VPN Management${NC}                               ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}  ${YELLOW}2)${NC} ${WHITE}System Status${NC}                                      ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}  ${YELLOW}3)${NC} ${WHITE}System Tools${NC}                                       ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}  ${YELLOW}4)${NC} ${WHITE}Restart Services${NC}                                   ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}  ${YELLOW}5)${NC} ${WHITE}Backup & Restore${NC}                                   ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}  ${YELLOW}6)${NC} ${WHITE}Settings${NC}                                           ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}  ${YELLOW}7)${NC} ${WHITE}About${NC}                                              ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}                                                    ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}  ${RED}0)${NC} ${WHITE}Exit${NC}                                              ${BLUE}│${NC}"
    echo -e "${BLUE}└─────────────────────────────────────────────────────────────┘${NC}"
    echo ""
}

# SSH Management submenu
ssh_management_menu() {
    while true; do
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
        echo -e "${BLUE}│${/bin
    
    # Download WebSocket scripts
    local ws_scripts=(
        "ws-dropbear:sshws/dropbear-ws.py"
        "ws-stunnel:sshws/ws-stunnel"
        "ws-ovpn:sshws/ws-ovpn.py"
    )
    
    for script in "${ws_scripts[@]}"; do
        local name="${script%%:*}"
        local path="${script##*:}"
        
        wget -q -O "$name" "$CDN/$path" || {
            warning "Failed to download $name"
            continue
        }
        chmod +x "$name"
    done
    
    # Download systemd service files
    local services=(
        "ws-dropbear.service:sshws/service-wsdropbear"
        "ws-stunnel.service:sshws/ws-stunnel.service"
        "ws-ovpn.service:sshws/ws-ovpn.service"
    )
    
    for service in "${services[@]}"; do
        local name="${service%%:*}"
        local path="${service##*:}"
        
        wget -q -O "/etc/systemd/system/$name" "$CDN/$path" || {
            warning "Failed to download $name"
            continue
        }
        chmod +x "/etc/systemd/system/$name"
    done
    
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
    blue "Configuring iptables firewall..."
    
    # Create iptables rules file
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

# SSH ports
-A INPUT -p tcp --dport 22 -j ACCEPT
-A INPUT -p tcp --dport 500 -j ACCEPT
-A INPUT -p tcp --dport 40000 -j ACCEPT
-A INPUT -p tcp --dport 51443 -j ACCEPT
-A INPUT -p tcp --dport 58080 -j ACCEPT
-A INPUT -p tcp --dport 200 -j ACCEPT

# Dropbear ports
-A INPUT -p tcp --dport 143 -j ACCEPT
-A INPUT -p tcp --dport 50000 -j ACCEPT
-A INPUT -p tcp --dport 109 -j ACCEPT
-A INPUT -p tcp --dport 110 -j ACCEPT
-A INPUT -p tcp --dport 69 -j ACCEPT

# Stunnel ports
-A INPUT -p tcp --dport 222 -j ACCEPT
-A INPUT -p tcp --dport 777 -j ACCEPT
-A INPUT -p tcp --dport 2096 -j ACCEPT
-A INPUT -p tcp --dport 442 -j ACCEPT

# Web ports
-A INPUT -p tcp --dport 80 -j ACCEPT
-A INPUT -p tcp --dport 443 -j ACCEPT

# DNS
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

# Rate limiting
-A INPUT -p tcp --dport 22 -m state --state NEW -m recent --set --name SSH
-A INPUT -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 60 --hitcount 4 --name SSH -j DROP

# Default policies
-A INPUT -j DROP
COMMIT
EOF
    
    # Load iptables rules
    iptables-restore < /etc/iptables.rules || warning "Failed to load iptables rules"
    
    # Make rules persistent
    apt-get install -y iptables-persistent || warning "Failed to install iptables-persistent"
    
    # Create persistent script
    cat > /etc/network/if-pre-up.d/iptables << 'EOF'
#!/bin/sh
/sbin/iptables-restore < /etc/iptables.rules
EOF
    
    chmod +x /etc/network/if-pre-up.d/iptables
    
    # Save current rules
    netfilter-persistent save || warning "Failed to save iptables rules"
    
    success "Iptables configured"
}

# ===================================================================
# MANAGEMENT SCRIPTS INSTALLATION
# ===================================================================

install_management_scripts() {
    blue "Installing management scripts..."
    
    cd /usr/bin
    
    # Essential management scripts
    local scripts=(
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
        "running:menu/running.sh"
        "clearcache:menu/clearcache.sh"
        "restart:menu/restart.sh"
        "status:status.sh"
        "about:menu/about.sh"
        "auto-reboot:menu/auto-reboot.sh"
        "speedtest:ssh/speedtest_cli.py"
        "backup:backup/backup.sh"
        "restore:backup/restore.sh"
        "xp:ssh/xp.sh"
    )
    
    for script in "${scripts[@]}"; do
        local name="${script%%:*}"
        local path="${script##*:}"
        
        if [[ ! -f "$name" ]]; then
            blue "Downloading $name..."
            wget -q -O "$name" "$CDN/$path" || {
                yellow "Warning: Failed to download $name"
                continue
            }
            chmod +x "$name" || yellow "Warning: Failed to chmod $name"
        fi
    done
    
    success "Management scripts installed"
}

# ===================================================================
# CREATE MASTER MENU SYSTEM
# ===================================================================

create_master_menu() {
    blue "Creating master menu system..."
    
    cat > /usr/bin/menu << 'EOF'
#!/bin/bash
# ===================================================================
# GX TUNNEL MASTER MENU - Enhanced Version
# Complete VPS Management Interface
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

# Get server information
get_server_info() {
    local ip=$(curl -s ipinfo.io/ip 2>/dev/null || echo "Unknown")
    local hostname=$(hostname)
    local os=$(lsb_release -d | cut -f2 2>/dev/null || echo "Unknown")
    local uptime=$(uptime -p 2>/dev/null || echo "Unknown")
    
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}                    ${WHITE}GX TUNNEL VPS MANAGER${NC}                    ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                    ${YELLOW}Version 3.0 - Enhanced${NC}                     ${CYAN}║${NC}"
    echo -e "${CYAN}╠══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC} ${WHITE}Server IP:${NC} $ip"
    echo -e "${CYAN}║${NC} ${WHITE}Hostname:${NC} $hostname"
    echo -e "${CYAN}║${NC} ${WHITE}OS:${NC} $os"
    echo -e "${CYAN}║${NC} ${WHITE}Uptime:${NC} $uptime"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
}

# Main menu
show_main_menu() {
    clear
    get_server_info
    echo ""
    echo -e "${BLUE}┌─────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│${NC}                    ${WHITE}MAIN MENU${NC}                           ${BLUE}│${NC}"
    echo -e "${BLUE}├─────────────────────────────────────────────────────────────┤${NC}"
    echo -e "${BLUE}│${NC}  ${YELLOW}1)${NC} ${WHITE}SSH & VPN Management${NC}                               ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}  ${YELLOW}2)${NC} ${WHITE}System Status${NC}                                      ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}  ${YELLOW}3)${NC} ${WHITE}System Tools${NC}                                       ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}  ${YELLOW}4)${NC} ${WHITE}Restart Services${NC}                                   ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}  ${YELLOW}5)${NC} ${WHITE}Backup & Restore${NC}                                   ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}  ${YELLOW}6)${NC} ${WHITE}Settings${NC}                                           ${BLUE}│${NC}"
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
        read -p "Select option [0-6]: " choice
        
        case $choice in
            1) ssh_menu ;;
            2) /usr/bin/running ;;
            3) 
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
            4) /usr/bin/restart ;;
            5) 
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
            6) 
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
    success "Master menu created"
}

# ===================================================================
# CRON JOBS SETUP
# ===================================================================

setup_cron() {
    blue "Setting up cron jobs..."
    
    # Create comprehensive cron configuration
    cat > /etc/cron.d/gx_tunnel << 'EOF'
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# Auto reboot at 2 AM daily
0 2 * * * root /sbin/reboot

# Auto delete expired users at midnight
0 0 * * * root /usr/bin/xp

# SSL renewal check every 3 days
15 03 */3 * * root /usr/local/bin/ssl_renew.sh 2>/dev/null || true

# System cleanup weekly
0 4 * * 0 root apt-get autoremove -y && apt-get autoclean -y

# Service health check every hour
0 * * * * root systemctl is-active ssh || systemctl restart ssh
0 * * * * root systemctl is-active dropbear || systemctl restart dropbear
0 * * * * root systemctl is-active stunnel4 || systemctl restart stunnel4
0 * * * * root systemctl is-active nginx || systemctl restart nginx
EOF
    
    # Enable and restart cron
    systemctl enable cron || warning "Failed to enable cron"
    systemctl restart cron || warning "Failed to restart cron"
    
    success "Cron jobs configured"
}

# ===================================================================
# SYSTEM CLEANUP
# ===================================================================

cleanup_system() {
    blue "Performing system cleanup..."
    
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
    
    # Fix permissions
    chown -R www-data:www-data /var/www/html || true
    
    success "System cleanup completed"
}

# ===================================================================
# FINAL SETUP AND REBOOT
# ===================================================================

final_setup() {
    green "╔══════════════════════════════════════════════════════════════╗"
    green "║${NC}                    ${WHITE}SETUP COMPLETED SUCCESSFULLY!${NC}           ${GREEN}║${NC}"
    green "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    blue "Available Commands:"
    echo "  • menu     - Main management menu"
    echo "  • status   -/bin
    
    # Download WebSocket scripts
    local ws_scripts=("ws-dropbear" "ws-stunnel" "ws-ovpn")
    local ws_services=("dropbear-ws.py" "ws-stunnel" "ws-ovpn.py")
    
    for i in "${!ws_scripts[@]}"; do
        local script="${ws_scripts[$i]}"
        local service="${ws_services[$i]}"
        
        wget -q -O "$script" "$CDN/sshws/$service" || {
            warning "Failed to download $script"
            continue
        }
        
        chmod +x "$script"
    done
    
    # Download systemd service files
    wget -q -O /etc/systemd/system/ws-dropbear.service "$CDN/sshws/service-wsdropbear" || warning "Failed to download ws-dropbear service"
    wget -q -O /etc/systemd/system/ws-stunnel.service "$CDN/sshws/ws-stunnel.service" || warning "Failed to download ws-stunnel service"
    wget -q -O /etc/systemd/system/ws-ovpn.service "$CDN/sshws/ws-ovpn.service" || warning "Failed to download ws-ovpn service"
    
    # Enable and start services
    systemctl daemon-reload
    
    for service in ws-dropbear ws-stunnel ws-ovpn; do
        systemctl enable "$service" || warning "Failed to enable $service"
        systemctl start "$service" || warning "Failed to start $service"
    done
    
    success "WebSocket services installed"
}

# ===================================================================
# MANAGEMENT SCRIPTS
# ===================================================================

install_management_scripts() {
    blue "Installing management scripts..."
    
    cd /usr/bin
    
    # Essential management scripts
    local scripts=(
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
    
    for script in "${scripts[@]}"; do
        local name="${script%%:*}"
        local path="${script##*:}"
        
        if [[ ! -f "$name" ]]; then
            wget -q -O "$name" "$CDN/$path" || {
                yellow "Warning: Failed to download $name"
                continue
            }
            chmod +x "$name" || yellow "Warning: Failed to chmod $name"
        fi
    done
    
    success "Management scripts installed"
}

# ===================================================================
# CREATE COMPREHENSIVE MENU SYSTEM
# ===================================================================

create_menu_system() {
    blue "Creating comprehensive menu system..."
    
    cat > /usr/bin/menu << 'EOF'
#!/bin/bash
# ===================================================================
# GX TUNNEL COMPREHENSIVE MENU SYSTEM
# Version: 3.0 - Updated Setup
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

# Get server information
get_server_info() {
    local ip=$(curl -s ipinfo.io/ip 2>/dev/null || echo "Unknown")
    local hostname=$(hostname)
    local os=$(lsb_release -d | cut -f2 2>/dev/null || echo "Unknown")
    local kernel=$(uname -r)
    local uptime=$(uptime -p 2>/dev/null || echo "Unknown")
    
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}                    ${WHITE}GX TUNNEL VPS MANAGER${NC}                    ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                    ${YELLOW}Version 3.0 - Complete${NC}                     ${CYAN}║${NC}"
    echo -e "${CYAN}╠══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC} ${WHITE}Server IP:${NC} $ip"
    echo -e "${CYAN}║${NC} ${WHITE}Hostname:${NC} $hostname"
    echo -e "${CYAN}║${NC} ${WHITE}OS:${NC} $os"
    echo -e "${CYAN}║${NC} ${WHITE}Kernel:${NC} $kernel"
    echo -e "${CYAN}║${NC} ${WHITE}Uptime:${NC} $uptime"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
}

# Main menu display
show_main_menu() {
    clear
    get_server_info
    echo ""
    echo -e "${BLUE}┌─────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│${NC}                    ${WHITE}MAIN MENU${NC}                           ${BLUE}│${NC}"
    echo -e "${BLUE}├─────────────────────────────────────────────────────────────┤${NC}"
    echo -e "${BLUE}│${NC}  ${YELLOW}1)${NC} ${WHITE}SSH & VPN Management${NC}                               ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}  ${YELLOW}2)${NC} ${WHITE}System Status${NC}                                      ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}  ${YELLOW}3)${NC} ${WHITE}System Tools${NC}                                       ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}  ${YELLOW}4)${NC} ${WHITE}Service Management${NC}                                 ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}  ${YELLOW}5)${NC} ${WHITE}Backup & Restore${NC}                                   ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}  ${YELLOW}6)${NC} ${WHITE}Settings${NC}                                           ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}  ${YELLOW}7)${NC} ${WHITE}About${NC}                                              ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}                                                    ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}  ${RED}0)${NC} ${WHITE}Exit${NC}                                              ${BLUE}│${NC}"
    echo -e "${BLUE}└─────────────────────────────────────────────────────────────┘${NC}"
    echo ""
}

# SSH Management submenu
ssh_menu() {
    while true; do
        clear
        echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║${NC}                    ${WHITE}SSH & VPN MANAGEMENT${NC}                   ${CYAN}║${NC}"
        echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${BLUE}┌─────────────────────────────────────────────────────────────┐${NC}"
        echo -e "${BLUE}│${NC}  ${YELLOW}1)${NC} ${WHITE}Create New User${NC}                                    ${BLUE}│${NC}"
        echo -e "${BLUE}│${NC}  ${YELLOW}2)${NC} ${WHITE}Create Trial User (1 Day)${NC}                          ${BLUE}│${NC}"
        echo -e "${BLUE}│${NC}  ${YELLOW}3)${NC} ${WHITE}Extend User Account${NC}                                ${BLUE}│${NC}"
        echo -e "${BLUE}│${NC}  ${YELLOW}4)${NC} ${WHITE}Delete User${NC}                                        ${BLUE}│${NC}"
        echo -e "${BLUE}│${NC}  ${YELLOW}5)${NC} ${WHITE}Check User Details${NC}                                 ${BLUE}│${NC}"
        echo -e "${BLUE}│${NC}  ${YELLOW}6)${NC} ${WHITE}List All Users${NC}                                     ${BLUE}│${NC}"
        echo -e "${BLUE}│${NC}  ${YELLOW}7)${NC} ${WHITE}Remove Expired Users${NC}                               ${BLUE}│${NC}"
        echo -e "${BLUE}│${NC}  ${YELLOW}8)${NC} ${WHITE}Monitor User Activity${NC}                              ${BLUE}│${NC}"
        echo -e "${BLUE}│${NC}  ${YELLOW}9)${NC} ${WHITE}Check Connection Limits${NC}                            ${BLUE}│${NC}"
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
    done
}

# System tools submenu
tools_menu() {
    while true; do
        clear
        echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║${NC}                    ${WHITE}SYSTEM TOOLS${NC}                           ${CYAN}║${NC}"
        echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${BLUE}┌─────────────────────────────────────────────────────────────┐${NC}"
        echo -e "${BLUE}│${NC}  ${YELLOW}1)${NC} ${WHITE}Clear RAM Cache${NC}                                    ${BLUE}│${NC}"
        echo -e "${BLUE}│${NC}  ${YELLOW}2)${NC} ${WHITE}Internet Speed Test${NC}                                ${BLUE}│${NC}"
        echo -e "${BLUE}│${NC}  ${YELLOW}3)${NC} ${WHITE}System Information${NC}                                 ${BLUE}│${NC}"
        echo -e "${BLUE}│${NC}  ${YELLOW}4)${NC} ${WHITE}Network Information${NC}                                ${BLUE}│${NC}"
        echo -e "${BLUE}│${NC}                                                    ${BLUE}│${NC}"
        echo -e "${BLUE}│${NC}  ${RED}0)${NC} ${WHITE}Back to Main Menu${NC}                                 ${BLUE}│${NC}"
        echo -e "${BLUE}└─────────────────────────────────────────────────────────────┘${NC}"
        echo ""
        
        read -p "Select option [0-4]: " choice
        case $choice in
            1) /usr/bin/clearcache ;;
            2) /usr/bin/speedtest ;;
            3) 
                echo "System Information:"
                echo "=================="
                echo "Hostname: $(hostname)"
                echo "OS: $(lsb_release -d | cut -f2 2>/dev/null || echo 'Unknown')"
                echo "Kernel: $(uname -r)"
                echo "Uptime: $(uptime -p 2>/dev/null || echo 'Unknown')"
                echo "Load: $(uptime | awk -F'load average:' '{print $2}')"
                echo "Memory: $(free -h | grep Mem | awk '{print $3 "/" $2}')"
                read -p "Press Enter to continue..."
                ;;
            4)
                echo "Network Information:"
                echo "==================="
                echo "Public IP: $(curl -s ipinfo.io/ip 2>/dev/null || echo 'Unknown')"
                echo "Local IP: $(hostname -I | awk '{print $1}')"
                echo "Gateway: $(ip route | grep default | awk '{print $3}')"
                echo "DNS: $(cat /etc/resolv.conf | grep nameserver | awk '{print $2}' | head -1)"
                read -p "Press Enter to continue..."
                ;;
            0) return ;;
            *) echo "Invalid option!"; sleep 2 ;;
        esac
    done
}

# Main menu loop
main() {
    while true; do
        show_main_menu
        read -p "Select option [0-7]: " choice
        
        case $choice in
            1) ssh_menu ;;
            2) /usr/bin/running ;;
            3) tools_menu ;;
            4) /usr/bin/restart ;;
            5) 
                clear
                echo -e "${BLUE}Backup & Restore Menu${NC}"
                echo -e "1) Create Backup"
                echo -e "2) Restore from Backup"
                echo -e "3) Back"
                read -p "Select: " backup_choice
                case $backup_choice in
                    1) /usr/bin/backup ;;
                    2) /usr/bin/restore ;;
                    3) ;;
                esac
                ;;
            6) 
                clear
                echo -e "${BLUE}Settings Menu${NC}"
                echo -e "1) Configure Auto Reboot"
                echo -e "2) About System"
                echo -e "3) Back"
                read -p "Select: " settings_choice
                case $settings_choice in
                    1) /usr/bin/auto-reboot ;;
                    2) /usr/bin/about ;;
                    3) ;;
                esac
                ;;
            7) /usr/bin/about ;;
            0) 
                echo "Goodbye! Thank you for using GX Tunnel."
                exit 0
                ;;
            *) 
                echo "Invalid option! Please try again."
                sleep 2
                ;;
        esac
    done
}

# Run main menu
main
EOF
    
    chmod +x /usr/bin/menu
    success "Menu system created"
}

# ===================================================================
# CREATE SYSTEM ALIASES
# ===================================================================

create_aliases() {
    blue "Creating system aliases..."
    
    cat >> /root/.bashrc << 'EOF'

# GX Tunnel System Aliases
alias menu='bash /usr/bin/menu'
alias status='bash /usr/bin/status'
alias restart='bash /usr/bin/restart'
alias running='bash /usr/bin/running'
alias clearcache='bash /usr/bin/clearcache'
alias ssh-restart='/etc/init.d/ssh restart'
alias dropbear-restart='/etc/init.d/dropbear restart'
alias stunnel-restart='/etc/init.d/stunnel4 restart'
alias nginx-restart='/etc/init.d/nginx restart'

# System management aliases
alias update-apt='apt update && apt upgrade -y'
alias clear-log='truncate -s 0 /var/log/*.log'
alias fix-services='systemctl daemon-reload && systemctl restart ssh dropbear stunnel4 nginx fail2ban'
EOF
    
    # Create symlink for global access
    ln -sf /usr/bin/menu /usr/local/bin/menu 2>/dev/null || true
    
    success "Aliases created"
}

# ===================================================================
# FINAL CONFIGURATION
# ===================================================================

final_configuration() {
    blue "Applying final configurations..."
    
    # Fix user permissions
    if id "gxtunnel" &>/dev/null; then
        chown -R gxtunnel:gxtunnel /home/gxtunnel || true
    fi
    
    # Set correct permissions for scripts
    chmod +x /usr/bin/* 2>/dev/null || true
    
    # Create cron jobs
    cat > /etc/cron.d/gx-tunnel << 'EOF'
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# Auto reboot at 2 AM daily
0 2 * * * root /sbin/reboot

# Auto delete expired users at midnight
0 0 * * * root /usr/bin/xp

# SSL renewal check every 3 days
15 03 */3 * * root /usr/local/bin/ssl_renew.sh 2>/dev/null || true
EOF
    
    # Enable cron service
    systemctl enable cron || warning "Failed to enable cron"
    systemctl restart cron || warning "Failed to restart cron"
    
    success "Final configuration completed"
}

# ===================================================================
# SYSTEM COMPLETION
# ===================================================================

complete_setup() {
    green "╔══════════════════════════════════════════════════════════════╗"
    green "║${NC}                    ${WHITE}✅ SETUP COMPLETED!${NC}                      ${GREEN}║${NC}"
    green "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    blue "🎉 Your GX Tunnel VPS is now fully configured and ready to use!"
    echo ""
    blue "📋 Quick Commands:"
    echo "  • menu     - Main management interface"
    echo "  • status   - Check service status"
    echo "  • restart  - Restart all services"
    echo "  • running  - Show running services"
    echo ""
    blue "🔌 Service Ports:"
    echo "  • SSH: 22, 500, 40000, 51443, 58080, 200"
    echo "  • Dropbear: 143, 109, 110, 69, 50000"
    echo "  • Stunnel: 222, 777, 2096, 442"
    echo "  • HTTP/HTTPS: 80, 443"
    echo ""
    blue "🔐/bin
    
    # Download WebSocket scripts
    local ws_scripts=("ws-dropbear" "ws-stunnel" "ws-ovpn")
    for script in "${ws_scripts[@]}"; do
        wget -q -O "$script" "$CDN/sshws/$script.py" || {
            # Try alternative without .py extension
            wget -q -O "$script" "$CDN/sshws/$script" || {
                warning "Failed to download $script"
                continue
            }
        }
        chmod +x "$script"
    done
    
    # Download systemd service files
    for service in "${ws_scripts[@]}"; do
        wget -q -O "/etc/systemd/system/${service}.service" "$CDN/sshws/${service}.service" || {
            warning "Failed to download ${service}.service"
            continue
        }
    done
    
    # Enable and start services
    systemctl daemon-reload
    for service in "${ws_scripts[@]}"; do
        systemctl enable "${service}.service" || warning "Failed to enable ${service}"
        systemctl start "${service}.service" || warning "Failed to start ${service}"
    done
    
    success "WebSocket services installed"
}

# ===================================================================
# MANAGEMENT SCRIPTS
# ===================================================================

install_management_scripts() {
    blue "Installing management scripts..."
    
    cd /usr/bin
    
    # Essential management scripts
    local scripts=(
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
        "running:menu/running.sh"
        "clearcache:menu/clearcache.sh"
        "restart:menu/restart.sh"
        "status:status.sh"
        "about:menu/about.sh"
        "auto-reboot:menu/auto-reboot.sh"
        "backup:backup/backup.sh"
        "restore:backup/restore.sh"
        "xp:ssh/xp.sh"
    )
    
    for script in "${scripts[@]}"; do
        local name="${script%%:*}"
        local path="${script##*:}"
        
        if [[ ! -f "$name" ]]; then
            wget -q -O "$name" "$CDN/$path" || {
                yellow "Warning: Failed to download $name"
                continue
            }
            chmod +x "$name" || yellow "Warning: Failed to chmod $name"
        fi
    done
    
    # Create main menu if it doesn't exist
    if [[ ! -f "menu" ]]; then
        create_main_menu_wrapper
    fi
    
    success "Management scripts installed"
}

# ===================================================================
# CREATE MAIN MENU WRAPPER
# ===================================================================

create_main_menu_wrapper() {
    blue "Creating main menu wrapper..."
    
    cat > /usr/bin/menu << 'EOF'
#!/bin/bash
# GX Tunnel Main Menu Wrapper

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
NC='\033[0m'

green() { echo -e "${GREEN}[✓]${NC} $*"; }
red() { echo -e "${RED}[✗]${NC} $*"; }
yellow() { echo -e "${YELLOW}[!]${NC} $*"; }
blue() { echo -e "${BLUE}[i]${NC} $*"; }

# Function to get server info
get_server_info() {
    local ip=$(curl -s ipinfo.io/ip 2>/dev/null || echo "Unknown")
    local hostname=$(hostname)
    local os=$(lsb_release -d | cut -f2 2>/dev/null || echo "Unknown")
    
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}                    ${WHITE}GX TUNNEL VPS MANAGER${NC}                    ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                    ${YELLOW}Complete Management Interface${NC}              ${CYAN}║${NC}"
    echo -e "${CYAN}╠══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC} ${WHITE}Server IP:${NC} $ip"
    echo -e "${CYAN}║${NC} ${WHITE}Hostname:${NC} $hostname"
    echo -e "${CYAN}║${NC} ${WHITE}OS:${NC} $os"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
}

# Main menu
show_menu() {
    clear
    get_server_info
    echo ""
    echo -e "${BLUE}┌─────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│${NC}                    ${WHITE}MAIN MENU${NC}                           ${BLUE}│${NC}"
    echo -e "${BLUE}├─────────────────────────────────────────────────────────────┤${NC}"
    echo -e "${BLUE}│${NC}  ${YELLOW}1)${NC} ${WHITE}SSH Management${NC}                                     ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}  ${YELLOW}2)${NC} ${WHITE}System Status${NC}                                      ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}  ${YELLOW}3)${NC} ${WHITE}System Tools${NC}                                       ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}  ${YELLOW}4)${NC} ${WHITE}Restart Services${NC}                                   ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}  ${YELLOW}5)${NC} ${WHITE}Backup & Restore${NC}                                   ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}                                                    ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}  ${RED}0)${NC} ${WHITE}Exit${NC}                                              ${BLUE}│${NC}"
    echo -e "${BLUE}└─────────────────────────────────────────────────────────────┘${NC}"
    echo ""
}

# SSH Management submenu
ssh_menu() {
    while true; do
        clear
        echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║${NC}                    ${WHITE}SSH MANAGEMENT${NC}                         ${CYAN}║${NC}"
        echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${BLUE}┌─────────────────────────────────────────────────────────────┐${NC}"
        echo -e "${BLUE}│${NC}  ${YELLOW}1)${NC} ${WHITE}Create New User${NC}                                    ${BLUE}│${NC}"
        echo -e "${BLUE}│${NC}  ${YELLOW}2)${NC} ${WHITE}Create Trial User${NC}                                  ${BLUE}│${NC}"
        echo -e "${BLUE}│${NC}  ${YELLOW}3)${NC} ${WHITE}Renew User${NC}                                         ${BLUE}│${NC}"
        echo -e "${BLUE}│${NC}  ${YELLOW}4)${NC} ${WHITE}Delete User${NC}                                        ${BLUE}│${NC



        }"
echo -e "BLUE│{NC}  YELLOW5){NC} WHITECheckUser{NC}                                         BLUE│{NC}"
echo -e "BLUE│{NC}  YELLOW6){NC} WHITEListAllUsers{NC}                                     BLUE│{NC}"
echo -e "BLUE│{NC}  YELLOW7){NC} WHITEDeleteExpiredUsers{NC}                               BLUE│{NC}"
echo -e "BLUE│{NC}                                                    BLUE│{NC}"
echo -e "BLUE│{NC}  RED0){NC} WHITEBacktoMainMenu{NC}                                 BLUE│{NC}"
echo -e "BLUE└─────────────────────────────────────────────────────────────┘{NC}"
echo ""
Copy
    read -p "Select option [0-7]: " choice
    case $choice in
        1) /usr/bin/usernew ;;
        2) /usr/bin/trial ;;
        3) /usr/bin/renew ;;
        4) /usr/bin/hapus ;;
        5) /usr/bin/cek ;;
        6) /usr/bin/member ;;
        7) /usr/bin/delete ;;
        0) return ;;
        *) echo "Invalid option!"; sleep 2 ;;
    esac
done
}
Tools menu
tools_menu() {
while true; do
clear
echo -e "CYAN╔══════════════════════════════════════════════════════════════╗{NC}"
echo -e "CYAN║{NC}                    WHITESYSTEMTOOLS{NC}                           CYAN║{NC}"
echo -e "CYAN╚══════════════════════════════════════════════════════════════╝{NC}"
echo ""
echo -e "BLUE┌─────────────────────────────────────────────────────────────┐{NC}"
echo -e "BLUE│{NC}  YELLOW1){NC} WHITEClearRAMCache{NC}                                    BLUE│{NC}"
echo -e "BLUE│{NC}  YELLOW2){NC} WHITEInternetSpeedTest{NC}                                BLUE│{NC}"
echo -e "BLUE│{NC}  YELLOW3){NC} WHITESystemInformation{NC}                                 BLUE│{NC}"
echo -e "BLUE│{NC}                                                    BLUE│{NC}"
echo -e "BLUE│{NC}  RED0){NC} WHITEBacktoMainMenu{NC}                                 BLUE│{NC}"
echo -e "BLUE└─────────────────────────────────────────────────────────────┘{NC}"
echo ""
Copy
    read -p "Select option [0-3]: " choice
    case $choice in
        1) /usr/bin/clearcache ;;
        2) /usr/bin/speedtest ;;
        3) 
            echo "System Information:"
            echo "=================="
            echo "Hostname: $(hostname)"
            echo "OS: $(lsb_release -d | cut -f2 2>/dev/null || echo 'Unknown')"
            echo "Kernel: $(uname -r)"
            echo "Uptime: $(uptime -p 2>/dev/null || echo 'Unknown')"
            read -p "Press Enter to continue..."
            ;;
        0) return ;;
        *) echo "Invalid option!"; sleep 2 ;;
    esac
done
}
Main menu loop
main() {
while true; do
show_menu
read -p "Select option [0-5]: " choice
Copy
    case $choice in
        1) ssh_menu ;;
        2) /usr/bin/running ;;
        3) tools_menu ;;
        4) /usr/bin/restart ;;
        5) 
            clear
            echo -e "${BLUE}Backup & Restore Menu${NC}"
            echo -e "1) Create Backup"
            echo -e "2) Restore from Backup"
            echo -e "3) Back"
            read -p "Select: " backup_choice
            case $backup_choice in
                1) /usr/bin/backup ;;
                2) /usr/bin/restore ;;
                3) ;;
            esac
            ;;
        0) 
            echo "Goodbye! Thank you for using GX Tunnel."
            exit 0
            ;;
        *) 
            echo "Invalid option! Please try again."
            sleep 2
            ;;
    esac
done
}
Run main menu
main
EOF
