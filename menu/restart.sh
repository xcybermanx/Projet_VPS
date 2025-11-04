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
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "                    ${BIWhite}${UWhite}RESTART MENU ${NC}"

echo -e "${BICyan} └─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "     ${BICyan}[${BIWhite}01${BICyan}] Restart All Servicesr      "
echo -e "     ${BICyan}[${BIWhite}02${BICyan}] Restart OpenSSH      "
echo -e "     ${BICyan}[${BIWhite}03${BICyan}] Restart Dropbear      "
echo -e "     ${BICyan}[${BIWhite}04${BICyan}] Restart Stunnel4     "
echo -e "     ${BICyan}[${BIWhite}05${BICyan}] Restart OpenVPN     "
echo -e "     ${BICyan}[${BIWhite}06${BICyan}] Restart Squid     "
echo -e "     ${BICyan}[${BIWhite}07${BICyan}] Restart Nginx"
echo -e "     ${BICyan}[${BIWhite}08${BICyan}] Restart Badvpn"
echo -e "     ${BICyan}[${BIWhite}09${BICyan}] Restart XRAY"
echo -e "     ${BICyan}[${BIWhite}10${BICyan}] Restart WEBSOCKET"
echo -e "     ${BICyan}[${BIWhite}11${BICyan}] Restart Trojan Go"
echo -e "${BICyan} └─────────────────────────────────────────────────────┘${NC}"
echo -e "     ${BIYellow}Press x or [ Ctrl+C ] • To-${BIWhite}Exit${NC}"
echo ""
read -p " Select menu :  "  opt
echo -e ""
case $opt in

1)
                clear
                echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "                    ${BIWhite}${UWhite}RESTART MENU ${NC}"

echo -e "${BICyan} └─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
                echo -e ""
                echo -e "     ${BIGreen} Restart Begin${NC}"
                sleep 1
                /etc/init.d/ssh restart > /dev/null 2>&1
                /etc/init.d/dropbear restart > /dev/null 2>&1
                /etc/init.d/stunnel4 restart > /dev/null 2>&1
                /etc/init.d/openvpn restart > /dev/null 2>&1
                /etc/init.d/fail2ban restart > /dev/null 2>&1
                /etc/init.d/cron restart > /dev/null 2>&1
                /etc/init.d/nginx restart > /dev/null 2>&1
                /etc/init.d/squid restart > /dev/null 2>&1
                echo -e "     ${BIGreen} Restarting xray Service (via systemctl)${NC}"
                sleep 0.5
                systemctl restart xray > /dev/null 2>&1
                systemctl restart xray.service > /dev/null 2>&1
                echo -e "     ${BIGreen} Restarting badvpn Service (via systemctl)${NC}"
                sleep 0.5
                screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 500
                sleep 0.5
                echo -e "     ${BIGreen} Restarting websocket Service (via systemctl)${NC}"
                sleep 0.5
                systemctl restart sshws.service > /dev/null 2>&1
                systemctl restart ws-dropbear.service > /dev/null 2>&1
                systemctl restart ws-stunnel.service > /dev/null 2>&1
                sleep 0.5
                echo -e "     ${BIGreen} Restarting Trojan Go Service (via systemctl)${NC}"
                sleep 0.5
                systemctl restart trojan-go.service > /dev/null 2>&1
                sleep 0.5
                echo -e "     ${BIGreen} ALL Service Restarted${NC}"
                echo ""
                echo -e "${BICyan} └─────────────────────────────────────────────────────┘${NC}"
                echo ""
                read -n 1 -s -r -p "      Press any key to back on system menu"
                restart
                ;;
                2)
                clear
                echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "                    ${BIWhite}${UWhite}RESTART MENU ${NC}"

echo -e "${BICyan} └─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
                echo -e ""
                echo -e "     ${BIGreen} Restart Begin${NC}"
                sleep 1
                /etc/init.d/ssh restart > /dev/null 2>&1
                sleep 0.5
                echo -e "     ${BIGreen} SSH Service Restarted${NC}"
                echo ""
                echo -e "${BICyan} └─────────────────────────────────────────────────────┘${NC}"
                echo ""
                read -n 1 -s -r -p "      Press any key to back on system menu"
                restart
                ;;
                3)
                clear
                echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "                    ${BIWhite}${UWhite}RESTART MENU ${NC}"

echo -e "${BICyan} └─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
                echo -e ""
                echo -e "     ${BIGreen} Restart Begin${NC}"
                sleep 1
                /etc/init.d/dropbear restart > /dev/null 2>&1
                sleep 0.5
                echo -e "     ${BIGreen} Dropbear Service Restarted${NC}"
                echo ""
                echo -e "${BICyan} └─────────────────────────────────────────────────────┘${NC}"
                echo ""
                read -n 1 -s -r -p "      Press any key to back on system menu"
                restart
                ;;
                4)
                clear
                echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "                    ${BIWhite}${UWhite}RESTART MENU ${NC}"

echo -e "${BICyan} └─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
                echo -e ""
                echo -e "     ${BIGreen} Restart Begin${NC}"
                sleep 1
                /etc/init.d/stunnel4 restart > /dev/null 2>&1
                sleep 0.5
                echo -e "     ${BIGreen} Stunnel4 Service Restarted${NC}"
                echo ""
                echo -e "${BICyan} └─────────────────────────────────────────────────────┘${NC}"
                echo ""
                read -n 1 -s -r -p "      Press any key to back on system menu"
                restart
                ;;
                5)
                clear
                echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "                    ${BIWhite}${UWhite}RESTART MENU ${NC}"

echo -e "${BICyan} └─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
                echo -e ""
                echo -e "     ${BIGreen} Restart Begin${NC}"
                sleep 1
                /etc/init.d/openvpn restart > /dev/null 2>&1
                sleep 0.5
                
                echo -e "     ${BIGreen} Openvpn Service Restarted${NC}"
                echo ""
                echo -e "${BICyan} └─────────────────────────────────────────────────────┘${NC}"
                echo ""
                read -n 1 -s -r -p "      Press any key to back on system menu"
                restart
                ;;
                6)
                clear
                echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "                    ${BIWhite}${UWhite}RESTART MENU ${NC}"

echo -e "${BICyan} └─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
                echo -e ""
                echo -e "     ${BIGreen} Restart Begin${NC}"
                sleep 1
                /etc/init.d/squid restart > /dev/null 2>&1
                sleep 0.5
                echo -e "     ${BIGreen} Squid Service Restarted${NC}"
                echo ""
                echo -e "${BICyan} └─────────────────────────────────────────────────────┘${NC}"
                echo ""
                read -n 1 -s -r -p "      Press any key to back on system menu"
                restart
                ;;
                7)
                clear
                echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "                    ${BIWhite}${UWhite}RESTART MENU ${NC}"

echo -e "${BICyan} └─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
                echo -e ""
                echo -e "     ${BIGreen} Restart Begin${NC}"
                sleep 1
                /etc/init.d/nginx restart > /dev/null 2>&1
                sleep 0.5
                echo -e "     ${BIGreen} Nginx Service Restarted${NC}"
                echo ""
                echo -e "${BICyan} └─────────────────────────────────────────────────────┘${NC}"
                echo ""
                read -n 1 -s -r -p "      Press any key to back on system menu"
                restart
                ;;
                8)
                clear
                echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "                    ${BIWhite}${UWhite}RESTART MENU ${NC}"

echo -e "${BICyan} └─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
                echo -e ""
                echo -e "     ${BIGreen} Restart Begin${NC}"
                sleep 1
                echo -e "     ${BIGreen} Restarting badvpn Service (via systemctl)${NC}"
                screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 500
                sleep 0.5
                echo -e "     ${BIGreen} Badvpn Service Restarted${NC}"
                echo ""
                echo -e "${BICyan} └─────────────────────────────────────────────────────┘${NC}"
                echo ""
                read -n 1 -s -r -p "      Press any key to back on system menu"
                restart
                ;;
                9)
                clear
                echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "                    ${BIWhite}${UWhite}RESTART MENU ${NC}"

echo -e "${BICyan} └─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
                echo -e ""
                echo -e "     ${BIGreen} Restart Begin${NC}"
                sleep 1
                echo -e "     ${BIGreen} Restarting xray Service (via systemctl)${NC}"
                systemctl restart xray > /dev/null 2>&1
                systemctl restart xray.service > /dev/null 2>&1
                sleep 0.5
                echo -e "     ${BIGreen} XRAY Service Restarted${NC}"
                echo ""
                echo -e "${BICyan} └─────────────────────────────────────────────────────┘${NC}"
                echo ""
                read -n 1 -s -r -p "      Press any key to back on system menu"
                restart
                ;;
                10)
                clear
                echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "                    ${BIWhite}${UWhite}RESTART MENU ${NC}"

echo -e "${BICyan} └─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
                echo -e ""
                echo -e "     ${BIGreen} Restart Begin${NC}"
                sleep 1
                echo -e "     ${BIGreen} Restarting websocket Service (via systemctl)${NC}"
                sleep 0.5
                systemctl restart sshws.service > /dev/null 2>&1
                systemctl restart ws-dropbear.service > /dev/null 2>&1
                systemctl restart ws-stunnel.service > /dev/null 2>&1
                sleep 0.5
                echo -e "     ${BIGreen} WEBSOCKET Service Restarted${NC}"
                echo ""
                echo -e "${BICyan} └─────────────────────────────────────────────────────┘${NC}"
                echo ""
                read -n 1 -s -r -p "      Press any key to back on system menu"
                restart
                ;;
                11)
                clear
                echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "                    ${BIWhite}${UWhite}RESTART MENU ${NC}"

echo -e "${BICyan} └─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
                echo -e ""
                echo -e "     ${BIGreen} Restart Begin${NC}"
                sleep 1
                echo -e "     ${BIGreen} Restarting Trojan Go Service (via systemctl)${NC}"
                sleep 0.5
                systemctl restart trojan-go.service > /dev/null 2>&1
                sleep 0.5
                echo -e "     ${BIGreen} Trojan Go Service Restarted${NC}"
                echo ""
                echo -e "${BICyan} └─────────────────────────────────────────────────────┘${NC}"
                echo ""
                read -n 1 -s -r -p "      Press any key to back on system menu"
                restart
                ;;                                                                         
                0)
                menu-set
                exit
                ;;
                x)
                clear
                exit
                ;;
                *) echo -e "" ; echo "Wrong choice !" ; sleep 1 ; restart ;;               
        esac
