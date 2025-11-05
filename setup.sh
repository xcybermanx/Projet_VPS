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
# Variables
# ------------------------------
Username="gxtunnel"
USER_HOME="/home/$Username"
CDN="https://raw.githubusercontent.com/xcybermanx/Projet_VPS/main/ssh"
TIME=10
CHATID="chat_id_here"
URL="telegram_url_here"

# ------------------------------
# Create user and directories
# ------------------------------
userdel $Username >/dev/null 2>&1
useradd -r -d $USER_HOME -s /bin/bash -M $Username >/dev/null 2>&1
echo -e "gxtunnel123\ngxtunnel123\n" | passwd $Username >/dev/null 2>&1
usermod -aG sudo $Username >/dev/null 2>&1

mkdir -p $USER_HOME/tmp $USER_HOME/config $USER_HOME/xray $USER_HOME/v2ray $USER_HOME/domain
chown -R $Username:$Username $USER_HOME

# ------------------------------
# Profile setup
# ------------------------------
cat > $USER_HOME/.profile << 'END'
if [ "$BASH" ]; then
    if [ -f ~/.bashrc ]; then
        . ~/.bashrc
    fi
fi
mesg n || true
clear
END
chown $Username:$Username $USER_HOME/.profile
chmod 644 $USER_HOME/.profile

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

    echo $FLARE_DOMAIN >> $USER_HOME/xray/flare-domain
    echo $NS_DOMAIN >> $USER_HOME/config/nsdomain
    echo $WS_DOMAIN >> $USER_HOME/domain/domain
    echo $FLARE_DOMAIN >> /etc/xray/flare-domain
    echo $WS_DOMAIN >> /etc/xray/domain
    echo $WS_DOMAIN >> $USER_HOME/config/scdomain
    echo $WS_DOMAIN >> $USER_HOME/xray/scdomain

elif [ "$dns" -eq 2 ]; then
    apt install -y jq curl
    wget -q -O $USER_HOME/cf "${CDN}/cf" >/dev/null 2>&1
    chmod +x $USER_HOME/cf
    chown $Username:$Username $USER_HOME/cf
    su - $Username -c "$USER_HOME/cf | tee $USER_HOME/install.log"
fi

# ------------------------------
# Register IP and user
# ------------------------------
MYIP=$(curl -sS ipv4.icanhazip.com)
register="https://raw.githubusercontent.com/xcybermanx/Projet_VPS/refs/heads/main/register"

username=$(curl $register | grep $MYIP | awk '{print $2}')
exp=$(curl $register | grep $MYIP | awk '{print $3}')

echo "$username" > /usr/bin/user
echo "$exp" > /usr/bin/e

# ------------------------------
# Kernel headers check
# ------------------------------
totet=$(uname -r)
REQUIRED_PKG="linux-headers-$totet"
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG 2>/dev/null | grep "install ok installed")
if [ "" = "$PKG_OK" ]; then
    echo "[INFO] Installing $REQUIRED_PKG..."
    apt-get update -y
    apt-get --yes install $REQUIRED_PKG
fi

# ------------------------------
# Install components
# ------------------------------
green "---> Installing SSH/WS"
wget -O $USER_HOME/ssh-vpn.sh https://raw.githubusercontent.com/xcybermanx/Projet_VPS/main/ssh/ssh-vpn.sh
chmod +x $USER_HOME/ssh-vpn.sh
chown $Username:$Username $USER_HOME/ssh-vpn.sh
su - $Username -c "$USER_HOME/ssh-vpn.sh"

green "---> Installing UDP Custom"
wget -O $USER_HOME/udp-custom.sh https://raw.githubusercontent.com/FasterExE/UDP-Custom/main/udp-custom.sh
chmod +x $USER_HOME/udp-custom.sh
chown $Username:$Username $USER_HOME/udp-custom.sh
su - $Username -c "$USER_HOME/udp-custom.sh"

green "---> Installing OpenVPN"
wget -O $USER_HOME/ovpn.sh https://raw.githubusercontent.com/xcybermanx/Projet_VPS/main/ssh/ovpn.sh
chmod +x $USER_HOME/ovpn.sh
chown $Username:$Username $USER_HOME/ovpn.sh
su - $Username -c "$USER_HOME/ovpn.sh"

green "---> Installing Backup"
wget -O $USER_HOME/set-br.sh https://raw.githubusercontent.com/xcybermanx/Projet_VPS/main/backup/set-br.sh
chmod +x $USER_HOME/set-br.sh
chown $Username:$Username $USER_HOME/set-br.sh
su - $Username -c "$USER_HOME/set-br.sh"

green "---> Installing XRAY"
wget -O $USER_HOME/ins-xray.sh https://raw.githubusercontent.com/xcybermanx/Projet_VPS/main/xray/ins-xray.sh
chmod +x $USER_HOME/ins-xray.sh
chown $Username:$Username $USER_HOME/ins-xray.sh
su - $Username -c "$USER_HOME/ins-xray.sh"

wget -O $USER_HOME/insshws.sh https://raw.githubusercontent.com/xcybermanx/Projet_VPS/main/sshws/insshws.sh
chmod +x $USER_HOME/insshws.sh
chown $Username:$Username $USER_HOME/insshws.sh
su - $Username -c "$USER_HOME/insshws.sh"

green "---> Installing SLOWDNS"
wget -q -O $USER_HOME/slow.sh https://raw.githubusercontent.com/xcybermanx/Projet_VPS/main/slow.sh
chmod +x $USER_HOME/slow.sh
chown $Username:$Username $USER_HOME/slow.sh
su - $Username -c "$USER_HOME/slow.sh"

# ------------------------------
# Install tools
# ------------------------------
wget -q -O $USER_HOME/tools.sh https://raw.githubusercontent.com/xcybermanx/Projet_VPS/main/tools.sh
chmod +x $USER_HOME/tools.sh
chown $Username:$Username $USER_HOME/tools.sh
su - $Username -c "$USER_HOME/tools.sh"
rm -f $USER_HOME/tools.sh

# ------------------------------
# Clean up temporary files
# ------------------------------
rm -f $USER_HOME/ssh-vpn.sh $USER_HOME/udp-custom.sh $USER_HOME/ovpn.sh \
      $USER_HOME/set-br.sh $USER_HOME/ins-xray.sh $USER_HOME/insshws.sh $USER_HOME/slow.sh

# ------------------------------
# Ensure menu is executable
# ------------------------------
if [ -f "$USER_HOME/menu" ]; then
    chmod +x $USER_HOME/menu
    chown $Username:$Username $USER_HOME/menu
fi

# ------------------------------
# Reboot
# ------------------------------
green "Setup complete! Rebooting in 5 seconds..."
sleep 5
reboot
