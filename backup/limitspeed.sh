#!/bin/bash
# SL
# ==========================================
# Color
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT='\033[0;37m'
# ==========================================
# Getting
MYIP=$(wget -qO- ipinfo.io/ip);
echo "Checking VPS"
IZIN=$( curl ipinfo.io/ip | grep $MYIP )
if [ $MYIP = $MYIP ]; then
echo -e "${NC}${GREEN}Permission Accepted...${NC}"
else
echo -e "${NC}${RED}Permission Denied!${NC}";
exit 0
fi
clear
Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[ON]${Font_color_suffix}"
Error="${Red_font_prefix}[OFF]${Font_color_suffix}"
cek=$(cat /home/limit)
NIC=$(ip -o $ANU -4 route show to default | awk '{print $5}');
function start () {
echo -e "     ${BIGreen} Limit Speed All Service${NC}"
read -p "     ${BIGreen} Set maximum download rate (in Kbps):${NC} " down
read -p "     ${BIGreen} Set maximum upload rate (in Kbps):${NC} " up
if [[ -z "$down" ]] && [[ -z "$up" ]]; then
echo > /dev/null 2>&1
else
echo -e "     ${BIGreen} Start Configuration${NC}"
sleep 0.5
wondershaper -a $NIC -d $down -u $up > /dev/null 2>&1
systemctl enable --now wondershaper.service
echo "start" > /home/limit
echo -e "     ${BIGreen} Done${NC}"
echo ""
fi
}
function stop () {
wondershaper -ca $NIC
systemctl stop wondershaper.service

echo -e "     ${BIGreen} Stop Configuration${NC}"
sleep 0.5
echo > /home/limit
echo -e "     ${BIGreen} Done${NC}"
}
if [[ "$cek" = "start" ]]; then
sts="${Info}"
else
sts="${Error}"
fi
clear
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "              ${BIWhite}${UWhite}LIMIT BANDWIDTH SPEED ${NC}"

echo -e "${BICyan} └─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "     ${BICyan} START LIMIT   :${NC} $IP      "
echo -e "     ${BICyan} STOP LIMIT    :${NC} $link      "
echo -e "${BICyan} └─────────────────────────────────────────────────────┘${NC}"
read -rp "     Please Enter The Correct Number : " -e num
if [[ "$num" = "1" ]]; then
start
elif [[ "$num" = "2" ]]; then
stop
else
clear
echo " Wrong Choice !"
menu
fi

