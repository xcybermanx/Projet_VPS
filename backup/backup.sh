#!/bin/bash
MYIP=$(wget -qO- ipinfo.io/ip);
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
IP=$(wget -qO- ipinfo.io/ip);
date=$(date +"%Y-%m-%d")
clear
email=$(cat /home/email)
if [[ "$email" = "" ]]; then
echo -e "     ${BIGreen} Enter Email To Receive Backup${NC}"
read -rp "     ${BIGreen} Email :${NC} " -e email
cat <<EOF>>/home/email
$email
EOF
fi
clear
echo -e "     ${BIGreen} Please Wait, Backup Process is in progress!!${NC}"
sleep 1
rm -rf /root/backup
mkdir /root/backup
cp /etc/passwd /root/backup/
cp /etc/group /root/backup/
cp /etc/shadow /root/backup/
cp /etc/gshadow /root/backup/
cp -r /etc/xray /root/backup/xray
cp -r /root/nsdomain /root/backup/nsdomain
cp -r /etc/slowdns /root/backup/slowdns
cp -r /home/vps/public_html /root/backup/public_html
cd /root
zip -r $IP-$date.zip backup > /dev/null 2>&1
rclone copy /root/$IP-$date.zip dr:backup/
url=$(rclone link dr:backup/$IP-$date.zip)
id=(`echo $url | grep '^https' | cut -d'=' -f2`)
link="https://drive.google.com/u/4/uc?id=${id}&export=download"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "                   ${BIWhite}${UWhite}DETAIL BACKUP ${NC}"

echo -e "${BICyan} └─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "     ${BICyan} IP VPS        :${NC} $IP      "
echo -e "     ${BICyan} Link Backup   :${NC} $link      "
echo -e "     ${BICyan} Date          :${NC} $date      "
echo -e "${BICyan} └─────────────────────────────────────────────────────┘${NC}"
echo -e "
" | mail -s "Backup Data" $email
rm -rf /root/backup
rm -r /root/$IP-$date.zip
clear
echo -e ""
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "                   ${BIWhite}${UWhite}DETAIL BACKUP ${NC}"

echo -e "${BICyan} └─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "     ${BICyan} IP VPS        :${NC} $IP      "
echo -e "     ${BICyan} Link Backup   :${NC} $link      "
echo -e "     ${BICyan} Date          :${NC} $date      "
echo -e "${BICyan} └─────────────────────────────────────────────────────┘${NC}"
echo "     Please check your Inbox $email"
echo
read -n 1 -s -r -p "     Press any key to back on system menu"
menu-backup