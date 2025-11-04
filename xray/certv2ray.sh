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


dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=`date +"%Y-%m-%d" -d "$dateFromServer"`
#########################



cekray=`cat /root/log-install.txt | grep -ow "XRAY" | sort | uniq`
if [ "$cekray" = "XRAY" ]; then
domainlama=`cat /etc/xray/domain`
else
domainlama=`cat /etc/v2ray/domain`
fi

clear
echo -e "${BICyan}[${NC} ${BIWhite}INFO${NC} ${BICyan}]${NC} ${BICyan}Start ${NC}" 
sleep 0.5
systemctl stop nginx
domain=$(cat /etc/xray/domain)
Cek=$(lsof -i:80 | cut -d' ' -f1 | awk 'NR==2 {print $1}')
if [[ ! -z "$Cek" ]]; then
sleep 1
echo -e "${BIRed}[${NC} ${red}WARNING${NC} ${BIRed}]${NC} ${BIRed}Detected port 80 used by $Cek ${NC}" 
systemctl stop $Cek
sleep 1
echo -e "${BICyan}[${NC} ${BIWhite}INFO${NC} ${BICyan}]${NC} ${BICyan}Processing to stop $Cek ${NC}" 
sleep 1
fi
echo -e "${BICyan}[${NC} ${BIWhite}INFO${NC} ${BICyan}]${NC} ${BICyan}Starting renew cert... ${NC}" 
sleep 2
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
/root/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256
~/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /etc/xray/xray.crt --keypath /etc/xray/xray.key --ecc
echo -e "${BICyan}[${NC} ${BIWhite}INFO${NC} ${BICyan}]${NC} ${BICyan}Renew cert done... ${NC}" 
sleep 2
echo -e "${BICyan}[${NC} ${BIWhite}INFO${NC} ${BICyan}]${NC} ${BICyan}Starting service ${NC}" 
sleep 2
echo $domain > /etc/xray/domain
systemctl restart $Cek
systemctl restart nginx
echo -e "${BICyan}[${NC} ${BIWhite}INFO${NC} ${BICyan}]${NC} ${BICyan}All finished...  ${NC}" 
sleep 0.5
systemctl restart $Cek > /dev/null 2>&1
echo ""
read -n 1 -s -r -p "    Press any key to back on menu"
menu-domain
