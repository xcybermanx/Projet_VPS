#!/bin/bash
clear

# ───────────── Colors ─────────────
red='\e[1;31m'
green='\e[1;32m'
yell='\e[1;33m'
NC='\e[0m'
green() { echo -e "\\033[32;1m${*}\\033[0m"; }
red() { echo -e "\\033[31;1m${*}\\033[0m"; }

# ───────────── OS Detection ─────────────
if [[ -e /etc/debian_version ]]; then
    source /etc/os-release
    OS=$ID  # debian or ubuntu
elif [[ -e /etc/centos-release ]]; then
    source /etc/os-release
    OS=centos
else
    red "Unsupported OS. Exiting..."
    exit 1
fi

# ───────────── System Update ─────────────
sudo apt update -y
sudo apt dist-upgrade -y

# ───────────── Remove Conflicts ─────────────
sudo apt-get remove --purge -y ufw firewalld exim4

# ───────────── Install Dependencies ─────────────
sudo apt install -y nload screen curl jq bzip2 gzip coreutils rsyslog iftop \
htop zip unzip net-tools sed gnupg gnupg1 bc sudo apt-transport-https \
build-essential dirmngr libxml-parser-perl neofetch screenfetch git lsof \
openssl openvpn easy-rsa fail2ban tmux stunnel4 vnstat squid \
dropbear libsqlite3-dev socat cron bash-completion ntpdate xz-utils \
gnupg2 dnsutils lsb-release chrony

# ───────────── Node.js Setup ─────────────
curl -sSL https://deb.nodesource.com/setup_16.x | bash -
sudo apt install -y nodejs

# ───────────── vnStat Setup ─────────────
wget -q https://humdi.net/vnstat/vnstat-2.6.tar.gz
tar zxvf vnstat-2.6.tar.gz
cd vnstat-2.6 || exit
./configure --prefix=/usr --sysconfdir=/etc >/dev/null 2>&1
make >/dev/null 2>&1
make install >/dev/null 2>&1
cd

# Detect main network interface automatically
NET=$(ip route get 8.8.8.8 | awk '{print $5; exit}')
green "Detected network interface: $NET"

# Initialize vnStat database
vnstat -u -i "$NET"

# Update vnStat configuration
if [[ -f /etc/vnstat.conf ]]; then
    sed -i "s/Interface.*/Interface \"$NET\"/g" /etc/vnstat.conf
fi

# Set ownership and enable service
chown vnstat:vnstat /var/lib/vnstat -R
systemctl enable vnstat
systemctl restart vnstat

# Cleanup
rm -f /root/vnstat-2.6.tar.gz
rm -rf /root/vnstat-2.6

# ───────────── Additional Packages ─────────────
sudo apt install -y libnss3-dev libnspr4-dev pkg-config libpam0g-dev \
libcap-ng-dev libcap-ng-utils libselinux1-dev libcurl4-nss-dev flex bison \
make libnss3-tools libevent-dev xl2tpd pptpd

sleep 3
clear
green "✅ Setup completed successfully!"
