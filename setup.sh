#!/bin/bash
# =========================================================
#  GX Tunnel Auto Setup - Safe, Self-Healing Version
# =========================================================

green() { echo -e "\033[32;1m${*}\033[0m"; }
red() { echo -e "\033[31;1m${*}\033[0m"; }

# ------------------------------
# Root Privilege Check
# ------------------------------
if [ "$EUID" -ne 0 ]; then
  red "❌ Please run as root: sudo bash setup.sh"
  exit 1
fi

# ------------------------------
# Ensure minimal environment
# ------------------------------
export DEBIAN_FRONTEND=noninteractive
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Repair package tools if missing
if ! command -v apt-get >/dev/null 2>&1; then
  red "❌ apt-get missing — this is not a standard Ubuntu/Debian system"
  exit 1
fi

green "[+] Updating package lists and installing core tools..."
apt-get update -y
apt-get install -y --no-install-recommends \
  bash wget curl ca-certificates coreutils util-linux sudo gnupg lsb-release tzdata

# Re-source PATH after install
hash -r

# ------------------------------
# Locale & Timezone
# ------------------------------
export LANG='en_US.UTF-8'
export LANGUAGE='en_US.UTF-8'
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null 2>&1 || true
sysctl -w net.ipv6.conf.default.disable_ipv6=1 >/dev/null 2>&1 || true

# ------------------------------
# Variables
# ------------------------------
USERNAME="gxtunnel"
USER_HOME="/home/$USERNAME"
CDN="https://raw.githubusercontent.com/xcybermanx/Projet_VPS/main"
REG_URL="$CDN/register"

# ------------------------------
# Create user
# ------------------------------
if id "$USERNAME" &>/dev/null; then
  deluser --remove-home "$USERNAME" >/dev/null 2>&1 || true
fi

useradd -m -d "$USER_HOME" -s /bin/bash "$USERNAME"
echo -e "gxtunnel123\ngxtunnel123" | passwd "$USERNAME" >/dev/null 2>&1
usermod -aG sudo "$USERNAME"
mkdir -p "$USER_HOME"/{tmp,config,xray,v2ray,domain}
chown -R "$USERNAME:$USERNAME" "$USER_HOME"

# ------------------------------
# Domain selection
# ------------------------------
clear
echo "Choose domain setup:"
echo "1) Custom domain"
echo "2) Random domain (gxtunnel.my.id)"
read -rp "Select (1/2): " dns_choice

if [[ "$dns_choice" == "1" ]]; then
  read -rp "Enter your domain: " WS_DOMAIN
  echo "$WS_DOMAIN" > "$USER_HOME/domain/domain"
else
  apt-get install -y jq curl
  /usr/bin/wget -q -O "$USER_HOME/cf" "$CDN/ssh/cf"
  chmod +x "$USER_HOME/cf"
  su - "$USERNAME" -c "$USER_HOME/cf"
fi

# ------------------------------
# Register IP (logging)
# ------------------------------
MYIP=$(curl -sS ipv4.icanhazip.com)
username=$(curl -s "$REG_URL" | grep "$MYIP" | awk '{print $2}')
exp=$(curl -s "$REG_URL" | grep "$MYIP" | awk '{print $3}')
echo "$username" > /usr/bin/user
echo "$exp" > /usr/bin/e

# ------------------------------
# Kernel headers
# ------------------------------
KERNEL=$(uname -r)
apt-get install -y "linux-headers-$KERNEL" || true

# ------------------------------
# Helper: download + run script safely
# ------------------------------
install_script() {
  local NAME=$1
  local URL=$2
  local PATH="$USER_HOME/$NAME.sh"

  /usr/bin/wget -q -O "$PATH" "$URL" || {
    red "Failed to download $NAME"
    return
  }

  /bin/chmod +x "$PATH"
  /bin/chown "$USERNAME:$USERNAME" "$PATH"
  /bin/bash "$PATH"
  /bin/rm -f "$PATH"
}

# ------------------------------
# Install required base packages
# ------------------------------
green "[+] Installing essential packages..."
apt-get install -y wget curl unzip jq sudo nginx dropbear stunnel4 openvpn ufw net-tools ruby screen || true

# ------------------------------
# Install components
# ------------------------------
green "[+] Installing SSH/WS"
install_script "ssh-vpn" "$CDN/ssh/ssh-vpn.sh"

green "[+] Installing UDP Custom"
install_script "udp-custom" "https://raw.githubusercontent.com/FasterExE/UDP-Custom/main/udp-custom.sh"

green "[+] Installing OpenVPN"
install_script "ovpn" "$CDN/ssh/ovpn.sh"

green "[+] Installing Backup"
install_script "set-br" "$CDN/backup/set-br.sh"

green "[+] Installing XRAY"
install_script "ins-xray" "$CDN/xray/ins-xray.sh"

green "[+] Installing WebSocket SSH"
install_script "insshws" "$CDN/sshws/insshws.sh"

green "[+] Installing SlowDNS"
install_script "slow" "$CDN/slow.sh"

green "[+] Installing Tools"
install_script "tools" "$CDN/tools.sh"

# ------------------------------
# Fix menu
# ------------------------------
if [ -f "$USER_HOME/menu" ]; then
  chmod +x "$USER_HOME/menu"
  chown "$USERNAME:$USERNAME" "$USER_HOME/menu"
  ln -sf "$USER_HOME/menu" /usr/bin/menu
fi

# ------------------------------
# Finish
# ------------------------------
green "✅ GX Tunnel setup completed successfully!"
echo "System will reboot in 10 seconds..."
sleep 10
reboot
