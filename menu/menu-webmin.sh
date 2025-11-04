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
echo "Checking VPS"

clear
Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[Installed]${Font_color_suffix}"
Error="${Red_font_prefix}[Not Installed]${Font_color_suffix}"
cek=$(netstat -ntlp | grep 10000 | awk '{print $7}' | cut -d'/' -f2)
function install () {
IP=$(wget -qO- ifconfig.me/ip);
clear
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "                   ${BIWhite}${UWhite}INSTALL WEBMIN ${NC}"
echo -e "${BICyan} └─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
sleep 0.5
echo -e "${BIGreen}    Adding Repository Webmin${NC}"
sh -c 'echo "deb http://download.webmin.com/download/repository sarge contrib" > /etc/apt/sources.list.d/webmin.list'
apt install gnupg gnupg1 gnupg2 -y > /dev/null 2>&1
wget http://www.webmin.com/jcameron-key.asc > /dev/null 2>&1
apt-key add jcameron-key.asc > /dev/null 2>&1
sleep 0.5
echo -e "${BIGreen}    Start Install Webmin${NC}"
sleep 0.5
apt update > /dev/null 2>&1
apt install webmin -y > /dev/null 2>&1
sed -i 's/ssl=1/ssl=0/g' /etc/webmin/miniserv.conf
echo -e "${BIGreen}    Restart Webmin${NC}"
/etc/init.d/webmin restart > /dev/null 2>&1
rm -f /root/jcameron-key.asc > /dev/null 2>&1
sleep 0.5
echo -e "${BIGreen}    Webmin Install Successfully !${NC}"
echo ""
echo -e "${BIGreen}    $IP:10000${NC}"
echo -e "${BICyan} └─────────────────────────────────────────────────────┘${NC}"
echo ""
read -n 1 -s -r -p "       Press any key to back on menu"
menu-webmin
}
function restart () {
clear
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "                     ${BIWhite}${UWhite} RESTART WEBMIN ${NC}"
echo -e "${BICyan} └─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
sleep 0.5
echo -e "${BIGreen}    Restarting Webmin${NC}"
service webmin restart > /dev/null 2>&1
echo ""
sleep 0.5
echo -e "${BIGreen}    Webmin Start Successfully !${NC}"
echo -e "${BICyan} └─────────────────────────────────────────────────────┘${NC}"
echo ""
read -n 1 -s -r -p "       Press any key to back on menu"
menu-webmin
}
function uninstall () {
clear
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "                  ${BIWhite}${UWhite}UNINSTALL WEBMIN ${NC}"
echo -e "${BICyan} └─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
sleep 0.5
echo -e "${BIGreen}    Removing Repositori Webmin${NC}"
rm -f /etc/apt/sources.list.d/webmin.list
apt update > /dev/null 2>&1
sleep 0.5
echo -e "${BIGreen}    Start Uninstall Webmin${NC}"
apt autoremove --purge webmin -y > /dev/null 2>&1
sleep 0.5
echo -e "${BIGreen}    Webmin Uninstall Successfully !${NC}"
echo -e "${BICyan} └─────────────────────────────────────────────────────┘${NC}"
echo ""
read -n 1 -s -r -p "       Press any key to back on menu"
menu-webmin
}
if [[ "$cek" = "perl" ]]; then
sts="${Info}"
else
sts="${Error}"
fi
clear 
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "                     ${BIWhite}${UWhite}WEBMIN MENU ${NC}"
echo -e "${BICyan} └─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "     ${BICyan}[${BIWhite}01${BICyan}] Install Webmin      "
echo -e "     ${BICyan}[${BIWhite}02${BICyan}] Restart Webmin      "
echo -e "     ${BICyan}[${BIWhite}03${BICyan}] Uninstall Webmin      "
echo -e "${BICyan} └─────────────────────────────────────────────────────┘${NC}"
echo -e "     ${BIYellow}Press x or [ Ctrl+C ] • To-${BIWhite}Exit${NC}"
echo -e ""
read -p " Select menu :  "  opt
echo -e ""
case $opt in
1) clear ; install ;;
2) clear ; restart ;;
3) clear ; uninstall ;;
0) clear ; menu ;;
x) exit ;;
*) echo -e "" ; echo "Press any key to back exit" ; sleep 1 ; menu-set ;;
esac
