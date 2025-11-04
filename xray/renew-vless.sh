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
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
green() { echo -e "\\033[32;1m${*}\\033[0m"; }
red() { echo -e "\\033[31;1m${*}\\033[0m"; }




clear
NUMBER_OF_CLIENTS=$(grep -c -E "^#& " "/etc/xray/config.json")
	if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
		clear
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "                 ${BIWhite}${UWhite} RENEW VLESS ACCOUNT ${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "    ${BIWhite} You Dont have any existing clients${NC} ${BIWhite}${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
read -n 1 -s -r -p "   Press any key to back on menu"
menu-vless
fi

clear
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "                 ${BIWhite}${UWhite} RENEW VLESS ACCOUNT ${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
grep -E "^#& " "/etc/xray/config.json" | cut -d ' ' -f 2-3 | column -t | sort | uniq | sed 's/^/     /'
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
read -rp "   Input Username (Press Any key To Back): " user
if [ -z $user ]; then
menu-vless
else
read -p "   Expired (days): " masaaktif
exp=$(grep -wE "^#& $user" "/etc/xray/config.json" | cut -d ' ' -f 3 | sort | uniq)
now=$(date +%Y-%m-%d)
d1=$(date -d "$exp" +%s)
d2=$(date -d "$now" +%s)
exp2=$(( (d1 - d2) / 86400 ))
exp3=$(($exp2 + $masaaktif))
exp4=`date -d "$exp3 days" +"%Y-%m-%d"`
sed -i "/#& $user/c\#& $user $exp4" /etc/xray/config.json
systemctl restart xray > /dev/null 2>&1
clear
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "                 ${BIWhite}${UWhite} RENEW VLESS ACCOUNT ${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "    ${BICyan} Account Was Successfully Renewed${NC} ${BIWhite}${NC}"
echo -e "    ${BICyan} Client Name :${NC} ${BIWhite}${user}${NC}"
echo -e "    ${BICyan} Expired On  :${NC} ${BIWhite}${exp4}${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
read -n 1 -s -r -p "   Press any key to back on menu"
menu-vless
fi
