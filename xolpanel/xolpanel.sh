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

#install
rm -rf xolpanel.sh
apt update && apt upgrade
apt install python3 python3-pip git
git clone https://github.com/Bringas-tunnel/xolpanel.git
unzip xolpanel/xolpanel.zip
pip3 install -r xolpanel/requirements.txt
pip3 install pillow
DOMAIN=$(cat /etc/xray/domain)
SLDOMAIN=$(cat /root/nsdomain)
#isi data
clear
echo ""
read -e -p "   Input your Bot Token : " bottoken
read -e -p "   Input Your Id Telegram : " admin
rm /root/xolpanel/var.txt
touch /root/xolpanel/var.txt
echo -e BOT_TOKEN='"'$bottoken'"' >> /root/xolpanel/var.txt
echo -e ADMIN='"'$admin'"' >> /root/xolpanel/var.txt
echo -e DOMAIN='"'$DOMAIN'"' >> /root/xolpanel/var.txt
echo -e SLDOMAIN='"'$SLDOMAIN'"' >> /root/xolpanel/var.txt
echo -e "     ${BIGreen} Done${NC}"
sleep 0.5
clear
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "                 ${BIWhite}${UWhite}YOUR DATA BOT ${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "      ${BICyan} Bot Token     : ${NC}$bottoken      "
echo -e "      ${BICyan} ID Telegram   :  ${NC}$admin      "
echo -e "      ${BICyan} Subdomain     :  ${NC}$DOMAIN      "
echo -e "      ${BICyan} NSdomain      : ${NC}$SLDOMAIN      "
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e "     ${BIGreen} Setting done Please wait 3s${NC}"
sleep 3
sudo rm /etc/systemd/system/xolpanel.service
cat > /etc/systemd/system/xolpanel.service << END
[Unit]
Description=Simple XolPanel - @XolPanel
After=network.target

[Service]
WorkingDirectory=/root
ExecStart=/usr/bin/python3 -m xolpanel
Restart=always

[Install]
WantedBy=multi-user.target
END

systemctl daemon-reload /dev/null 2>&1
systemctl start xolpanel > /dev/null 2>&1
systemctl enable xolpanel > /dev/null 2>&1
systemctl restart xolpanel > /dev/null 2>&1
clear
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "       ${BICyan}Installations complete, type /menu on your bot${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
read -n 1 -s -r -p "   Press any key to comeback to menu"
rm -rf xolpanel.sh
clear
menu
