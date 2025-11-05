#!/bin/bash
# ===================================================================
#  GX Tunnel VPS – Hardened Auto-Setup  (setup.sh  v3.1)
#  Repo: https://github.com/xcybermanx/Projet_VPS
#  Target: Ubuntu 22/24 LTS  –  idempotent, fail-fast, self-healing
# ===================================================================
set -Eeuo pipefail
# ------------------------------------------------------------------ colours
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; BLUE='\033[0;34m'; NC='\033[0m'
log()  { echo -e "${GREEN}[✓]${NC} $*"; }
warn() { echo -e "${YELLOW}[!]${NC} $*"; }
err()  { echo -e "${RED}[✗]${NC} $*"; exit 1; }
# ------------------------------------------------------------------ checks
[[ $EUID -eq 0 ]] || err "Run as root: sudo bash setup.sh"
command -v apt-get &>/dev/null || err "apt-get not found – Debian/Ubuntu only"
# ------------------------------------------------------------------ env
export DEBIAN_FRONTEND=noninteractive
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
CDN="https://raw.githubusercontent.com/xcybermanx/Projet_VPS/main"
USER="gxtunnel"
HOME_DIR="/home/$USER"
# ------------------------------------------------------------------ helpers
retry() { local n=0; until "$@"; do n=$((n+1)); [[ $n -ge 5 ]] && err "Failed after $n attempts: $*"; sleep 2; done; }
dl()    { retry wget -qO- "$1"; }
safe()  { "$@" || { err "Command failed: $*"; }; }
# =================================================================== 1.  system base
log "Updating system & installing core packages"
safe apt-get update
safe apt-get -y full-upgrade
safe apt-get -y install --no-install-recommends \
  software-properties-common apt-transport-https ca-certificates gnupg lsb-release \
  curl wget git unzip jq nano htop net-tools iptables iptables-persistent fail2ban \
  ufw ruby screen build-essential python3 python3-pip openssl cron tzdata
# =================================================================== 2.  kernel & network
log "Kernel headers & IPv6 disable"
KERNEL=$(uname -r)
safe apt-get -y install "linux-headers-$KERNEL" || true
cat >/etc/sysctl.d/99-disable-ipv6.conf <<'EOF'
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF
sysctl -p /etc/sysctl.d/99-disable-ipv6.conf
# =================================================================== 3.  firewall (idempotent)
log "Configuring UFW + iptables"
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
for p in 22 80 443 53 143 222 777 109 110 69 500 40000 51443 58080 200 50000 2096 442; do
  ufw allow "$p" || true
done
ufw --force enable
# =================================================================== 4.  service user
if id "$USER" &>/dev/null; then
  warn "User $USER exists – removing & recreating"
  userdel -r "$USER" 2>/dev/null || true
fi
safe useradd -m -d "$HOME_DIR" -s /bin/bash "$USER"
echo "$USER:gxtunnel123" | safe chpasswd
safe usermod -aG sudo "$USER"
safe mkdir -p "$HOME_DIR"/{tmp,config,logs,backup,xray,v2ray,domain}
safe chown -R "$USER:$USER" "$HOME_DIR"
# =================================================================== 5.  SSH multi-port + hardening
log "SSH hardening & multi-port"
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak.$(date +%F)
cat >/etc/ssh/sshd_config <<'EOF'
# GX Tunnel – multi-port
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
cat >/etc/issue.net <<'EOF'
╔════════════════════════════════════════════════════════════════╗
║                    GX TUNNEL VPS SERVER                        ║
║                 Authorized access only!                        ║
║            All activities are monitored and logged.            ║
╚════════════════════════════════════════════════════════════════╝
EOF
safe systemctl restart sshd
# =================================================================== 6.  Dropbear
log "Installing Dropbear"
safe apt-get -y install dropbear
cat >/etc/default/dropbear <<'EOF'
NO_START=0
DROPBEAR_PORT=143
DROPBEAR_EXTRA_ARGS="-p 50000 -p 109 -p 110 -p 69"
DROPBEAR_BANNER="/etc/issue.net"
EOF
echo /bin/false >>/etc/shells
echo /usr/sbin/nologin >>/etc/shells
safe systemctl restart dropbear
safe systemctl enable dropbear
# =================================================================== 7.  Stunnel
log "Stunnel + self-signed cert"
safe apt-get -y install stunnel4
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
  -keyout /etc/stunnel/stunnel.key -out /etc/stunnel/stunnel.crt \
  -subj "/C=US/ST=State/L=City/O=GX/CN=localhost" || \
  { cp /etc/ssl/certs/ssl-cert-snakeoil.pem /etc/stunnel/stunnel.crt 2>/dev/null || true; }
cat /etc/stunnel/stunnel.crt /etc/stunnel/stunnel.key >/etc/stunnel/stunnel.pem 2>/dev/null || true
chmod 600 /etc/stunnel/stunnel.pem
cat >/etc/stunnel/stunnel.conf <<'EOF'
cert = /etc/stunnel/stunnel.pem
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1
[ssh]    accept = 222    connect = 127.0.0.1:22
[dropbear] accept = 777  connect = 127.0.0.1:109
[ws-stunnel] accept = 2096 connect = 700
[openvpn] accept = 442   connect = 127.0.0.1:1194
EOF
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
safe systemctl restart stunnel4 && safe systemctl enable stunnel4
# =================================================================== 8.  Fail2ban
log "Fail2ban jail for multi-port SSH"
cat >/etc/fail2ban/jail.local <<'EOF'
[DEFAULT]
bantime  = 3600
findtime = 600
maxretry = 5
[sshd]
enabled = true
port    = ssh,500,40000,51443,58080,200
logpath = /var/log/auth.log
maxretry = 3
EOF
safe systemctl restart fail2ban && safe systemctl enable fail2ban
# =================================================================== 9.  Nginx (clean install)
log "Nginx – clean install & web root"
safe apt-get -y remove --purge nginx nginx-common nginx-full
rm -rf /etc/nginx /var/log/nginx /var/www/html
safe apt-get -y install nginx
cat >/etc/nginx/nginx.conf <<'EOF'
user www-data;
worker_processes auto;
pid /run/nginx.pid;
events { worker_connections 1024; use epoll; multi_accept on; }
http {
  sendfile on; tcp_nopush on; tcp_nodelay on; keepalive_timeout 65;
  types_hash_max_size 2048; server_tokens off;
  include /etc/nginx/mime.types; default_type application/octet-stream;
  ssl_protocols TLSv1.2 TLSv1.3; ssl_prefer_server_ciphers off;
  access_log /var/log/nginx/access.log; error_log /var/log/nginx/error.log;
  gzip on; gzip_vary on; gzip_proxied any; gzip_comp_level 6;
  include /etc/nginx/conf.d/*.conf; include /etc/nginx/sites-enabled/*;
}
EOF
mkdir -p /var/www/html && chown www-data:www-data /var/www/html
safe systemctl restart nginx && safe systemctl enable nginx
# =================================================================== 10.  BadVPN UDP
log "BadVPN UDP gateway"
dl "$CDN/badvpn/badvpn-udpgw" >/bin/badvpn-udpgw
chmod +x /bin/badvpn-udpgw
dl "$CDN/badvpn/badvpn-7100-7900.service" >/etc/systemd/system/badvpn-7100-7900.service
safe systemctl daemon-reload
safe systemctl enable --now badvpn-7100-7900.service
# =================================================================== 11.  WebSocket Python services
log "WebSocket services"
safe apt-get -y install python3 python3-pip
for svc in dropbear stunnel ovpn; do
  dl "$CDN/sshws/ws-${svc}.py" >/usr/local/bin/ws-$svc 2>/dev/null || dl "$CDN/sshws/ws-${svc}" >/usr/local/bin/ws-$svc
  chmod +x /usr/local/bin/ws-$svc
  dl "$CDN/sshws/ws-${svc}.service" >/etc/systemd/system/ws-${svc}.service
done
safe systemctl daemon-reload
for svc in ws-dropbear ws-stunnel ws-ovpn; do safe systemctl enable --now $svc; done
# =================================================================== 12.  Management scripts (retry per file)
log "Management scripts"
mkdir -p /usr/bin/gx-scripts
for f in usernew trial renew hapus cek member delete autokill ceklim tendang \
         running clearcache restart status about auto-reboot backup restore xp speedtest; do
  dl "$CDN/ssh/${f}.sh" >/usr/bin/$f 2>/dev/null || dl "$CDN/menu/${f}.sh" >/usr/bin/$f
  chmod +x /usr/bin/$f
done
# =================================================================== 13.  Menu wrapper
log "Menu wrapper"
cat >/usr/bin/menu <<'MENU'
#!/bin/bash
# GX Tunnel Master Menu
bash /usr/bin/status && echo
echo "Press Enter for main menu..."; read -r
bash /usr/bin/running
MENU
chmod +x /usr/bin/menu
ln -sf /usr/bin/menu /usr/local/bin/menu
# =================================================================== 14.  Cron & finale
log "Cron jobs"
cat >/etc/cron.d/gx-tunnel <<'EOF'
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
0 2 * * * root /sbin/reboot
0 0 * * * root /usr/bin/xp
15 03 */3 * * root /usr/local/bin/ssl_renew.sh 2>/dev/null || true
EOF
safe systemctl enable cron
# =================================================================== 15.  clean-up & reboot
log "System clean-up"
safe apt-get autoremove -y
safe apt-get autoclean -y
history -c
echo "unset HISTFILE" >>/etc/profile
log "✅ Setup complete – rebooting in 10 s"
sleep 10
safe reboot
# ===================================================================
