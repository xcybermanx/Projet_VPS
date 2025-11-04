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
echo -e "                     ${BIWhite}${UWhite}AUTOKILL SSH ${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "     ${BICyan}[${BIWhite}01${BICyan}] AutoKill After 5 Minutes      "
echo -e "     ${BICyan}[${BIWhite}02${BICyan}] AutoKill After 10 Minutes      "
echo -e "     ${BICyan}[${BIWhite}03${BICyan}] AutoKill After 15 Minutes      "
echo -e "     ${BICyan}[${BIWhite}04${BICyan}] Turn Off AutoKill/MultiLogin     "
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"

echo -e ""
echo -e "     ${BIYellow}Press x or [ Ctrl+C ] • To-${BIWhite}Exit${NC}"
echo ""
read -p " Select menu :  "  opt
echo -e ""
case $opt in

1)
sleep 1
clear
echo > /etc/cron.d/tendang
echo "# Autokill" >/etc/cron.d/tendang
echo "*/1 * * * *  root /usr/bin/tendang $max" >>/etc/cron.d/tendang
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e ""
echo -e "      ${BIWhite}Allowed MultiLogin : $max${NC}"
echo -e "      ${BIWhite}AutoKill Every     : ${NC}${BIGreen}5 Minutes${NC}"      
echo -e ""
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
service cron restart >/dev/null 2>&1
service cron reload >/dev/null 2>&1  
;;
2)
sleep 1
clear
echo > /etc/cron.d/tendang
echo "# Autokill" >/etc/cron.d/tendang
echo "*/2 * * * *  root /usr/bin/tendang $max" >>/etc/cron.d/tendang
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e ""
echo -e "      ${BIWhite}Allowed MultiLogin : $max${NC}"
echo -e "      ${BIWhite}AutoKill Every     : ${NC}${BIGreen}10 Minutes${NC}"
echo -e ""
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
service cron restart >/dev/null 2>&1
service cron reload >/dev/null 2>&1
;;
3)
sleep 1
clear
echo > /etc/cron.d/tendang
echo "# Autokill" >/etc/cron.d/tendang
echo "*/3 * * * *  root /usr/bin/tendang $max" >>/etc/cron.d/tendang
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e ""
echo -e "      ${BIWhite}Allowed MultiLogin : $max${NC}"
echo -e "      ${BIWhite}AutoKill Every     : ${NC}${BIGreen}15 Minutes${NC}"
echo -e ""
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
service cron restart >/dev/null 2>&1
service cron reload >/dev/null 2>&1
;;
4)
clear
rm /etc/cron.d/tendang
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e ""
echo -e "      ${BIWhite}AutoKill MultiLogin Turned ${NC}${BIRed}Off${NC}  "
echo -e ""
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
service cron restart >/dev/null 2>&1
service cron reload >/dev/null 2>&1
;;
x)
clear
autokill-menu
;;
        esac
read -n 1 -s -r -p "     Press any key to back on menu"
menu
