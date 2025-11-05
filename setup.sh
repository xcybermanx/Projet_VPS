#!/bin/bash

# =========================================================
#  GX Tunnel Auto Setup - Permission Fixed Version
# =========================================================

green() { echo -e "\033[32;1m${*}\033[0m"; }
red() { echo -e "\033[31;1m${*}\033[0m"; }

# ------------------------------
# Root Privilege Check
# ------------------------------
if [ "$EUID" -ne 0 ]; then
  red "❌ Please run as root (sudo su first)"
  exit 1
fi

# ------------------------------
# System Setup
# ------------------------------
export LANG='en_US.UTF-8'
export LANGUAGE='en_US.UTF-8'
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null 2>&1
sysctl -w net.ipv6.conf.default.disable_ipv6=1 >/dev/null 2>&1

# ------------------------------
# Variables
# ------------------------------
USERNAME="gxtunnel"
USER_HOME="/home/$USERNAME"
CDN="https://raw.githubusercontent.com/xcybermanx/Projet_VPS/main"
REG_URL="https://raw.githubusercontent.com/xcybermanx/Projet_VPS/main/register"

# ------------------------------
# Create System User
# ------------------------------
if id "$USERNAME" &>/dev/null; then
  deluser --remove-home "$USERNAME" >/dev/null 2>&1
fi

useradd -m -d "$USER_HOME" -s /bin/bash "$USERNAME"
echo -e "gxtunnel123\ngxtunnel123" | passwd "$USERNAME" >/dev/null 2>&1
usermod -aG sudo "$USERNAME"

mkdir -p "$USER_HOME"/{tmp,config,xray,v2ray,domain}
chown -R "$USERNAME:$USERNAME" "$USER_HOME"

# ------------------------------
# Domain Choice
# ------------------------------
clear
echo "Choose your domain setup:"
echo "1) Enter custom domain"
echo "2) Use random domain (gxtunnel.my.id)"
read -rp "Select (1 or 2): " dns_choice

if [[ "$dns_choice" == "1" ]]; then
  read -rp "Enter your domain: " WS_DOMAIN
  echo "$WS_DOMAIN" | tee "$USER_HOME/domain/domain" >/dev/null
else
  apt update -y && apt install -y jq curl
  wget -q -O "$USER_HOME/cf" "$CDN/ssh/cf"
  chmod +x "$USER_HOME/cf"
  su - "$USERNAME" -c "$USER_HOME/cf"
fi

# ------------------------------
# Register IP (Logging purpose)
# ------------------------------
MYIP=$(curl -sS ipv4.icanhazip.com)
username=$(curl -s "$REG_URL" | grep "$MYIP" | awk '{print $2}')
exp=$(curl -s "$REG_URL" | grep "$MYIP" | awk '{print $3}')
echo "$username" > /usr/bin/user
echo "$exp" > /usr/bin/e

# ------------------------------
# Kernel Headers
# ------------------------------
KERNEL=$(uname -r)
apt-get update -y
apt-get install -y "linux-headers-$KERNEL" || true

# ------------------------------
# Install Components (As root)
# ------------------------------
install_script() {
  local NAME=$1
  local URL=$2
  local PATH="$USER_HOME/$NAME.sh"
  wget -q -O "$PATH" "$URL"
  chmod +x "$PATH"
  chown "$USERNAME:$USERNAME" "$PATH"
  bash "$PATH"
  rm -f "$PATH"
}

green "[+] Installing Core Packages..."
apt install -y wget curl unzip sudo jq nginx dropbear stunnel4 openvpn screen ufw net-tools ruby

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
# Menu Fix
# ------------------------------
if [ -f "$USER_HOME/menu" ]; then
  chmod +x "$USER_HOME/menu"
  chown "$USERNAME:$USERNAME" "$USER_HOME/menu"
  ln -sf "$USER_HOME/menu" /usr/bin/menu
fi

# ------------------------------
# Clean Up & Finish
# ------------------------------
green "✅ GX Tunnel setup completed successfully!"
echo "System will reboot in 10 seconds..."
sleep 10
reboot
