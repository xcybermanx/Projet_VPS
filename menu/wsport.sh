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

NOW=$(cat /etc/ws/status)
function ssh() {
mkdir /etc/ws > /dev/null 2>&1
rm /etc/ws/status
rm /etc/ws/status2
echo 'SSH ' >> /etc/ws/status
echo 'SSH' >> /etc/ws/status2
sudo sed -i "16s/.*/DEFAULT_HOST = '127.0.0.1:143'/" /usr/local/bin/ws-stunnel
sudo systemctl restart ws-stunnel
read -n 1 -s -r -p "  Press any key to back on menu"
clear
menu
}

function ovpn() {
mkdir /etc/ws > /dev/null 2>&1
rm /etc/ws/status
rm /etc/ws/status2
echo 'OVPN' >> /etc/ws/status
echo 'OVPN' >> /etc/ws/status2
sudo sed -i "16s/.*/DEFAULT_HOST = '127.0.0.1:1194'/" /usr/local/bin/ws-stunnel
sudo systemctl restart ws-stunnel
read -n 1 -s -r -p "  Press any key to back on menu"
clear
menu
}
clear
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "               ${BIWhite}${UWhite}WEBSOCKET PROTOCOL${NC} ${BIPurple}($NOW)${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "     ${BICyan}[${BIWhite}01${BICyan}] Link Websocket To SSH    "
echo -e "     ${BICyan}[${BIWhite}02${BICyan}] Link Websocket To OpenVPN      "
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e "     ${BIYellow}Press x or [ Ctrl+C ] • To-${BIWhite}Exit${NC}"
echo ""
read -p " Select menu :  "  opt
echo -e ""
case $opt in

1)
ssh
;;
2)
ovpn
;;
*)
clear
;;
esac
