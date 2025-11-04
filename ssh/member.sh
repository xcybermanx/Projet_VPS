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

clear
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "      ${BIWhite}${UWhite}USERNAME${NC}          ${BIWhite}${UWhite}EXP DATE${NC}          ${BIWhite}${UWhite}STATUS${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
while read expired
do
USER="$(echo $expired | cut -d: -f1)"
ID="$(echo $expired | grep -v nobody | cut -d: -f3)"
exp="$(chage -l $USER | grep "Account expires" | awk -F": " '{print $2}')"
status="$(passwd -S $USER | awk '{print $2}' )"
if [[ $ID -ge 1000 ]]; then
if [[ "$status" = "L" ]]; then
echo -e "       ${BIWhite}$USER${NC}            ${BIYellow}$exp${NC}            ${BIRed}LOCKED${NC}"
else
echo -e "       ${BIWhite}$USER${NC}            ${BIYellow}$exp${NC}            ${BIGreen}UNLOCKED${NC}"
fi
fi
done < /etc/passwd
JUMLAH="$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd | wc -l)"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "                ${BIWhite}${UWhite}Account${NC} ${BIWhite}${UWhite}Number:${NC} ${BIYellow}$JUMLAH${NC} ${BIWhite}${UWhite}User${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
read -n 1 -s -r -p "    Press any key to back on menu"

menu-ssh
