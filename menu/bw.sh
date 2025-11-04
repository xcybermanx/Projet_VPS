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
echo -e "                    ${BIWhite}${UWhite}BANDWITH MONITOR ${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "     ${BICyan}[${BIWhite}01${BICyan}] View Total Remaining Bandwidth      "
echo -e "     ${BICyan}[${BIWhite}02${BICyan}] Usage Table Every 5 Minutes      "
echo -e "     ${BICyan}[${BIWhite}03${BICyan}] Hourly Usage Table      "
echo -e "     ${BICyan}[${BIWhite}04${BICyan}] Daily Usage Table     "
echo -e "     ${BICyan}[${BIWhite}05${BICyan}] Usage Table Every Month     "
echo -e "     ${BICyan}[${BIWhite}06${BICyan}] Annual Usage Table     "
echo -e "     ${BICyan}[${BIWhite}07${BICyan}] Highest Usage Table"
echo -e "     ${BICyan}[${BIWhite}08${BICyan}] Hourly Usage Statistics"
echo -e "     ${BICyan}[${BIWhite}09${BICyan}] View Current Active Usage"
echo -e "     ${BICyan}[${BIWhite}10${BICyan}] View Current Active Usage Traffic [5s]"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e "     ${BIYellow}Press x or [ Ctrl+C ] • To-${BIWhite}Exit${NC}"
echo ""
read -p " Select menu :  "  opt
echo -e ""
case $opt in

1)
clear 
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "                    ${BIWhite}${UWhite}BANDWITH MONITOR ${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e ""

vnstat

echo -e ""
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e ""
read -n 1 -s -r -p "Press any key to back on menu"
bw
;;

2)
clear 
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "                    ${BIWhite}${UWhite}BANDWITH MONITOR ${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e ""

vnstat -5

echo -e ""
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e ""
read -n 1 -s -r -p "Press any key to back on menu"
bw
;;

3)
clear 
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "                    ${BIWhite}${UWhite}BANDWITH MONITOR ${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e ""

vnstat -h

echo -e ""
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e ""
read -n 1 -s -r -p "Press any key to back on menu"
bw
;;

4)
clear 
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "                    ${BIWhite}${UWhite}BANDWITH MONITOR ${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e ""

vnstat -d

echo -e ""
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e ""
read -n 1 -s -r -p "Press any key to back on menu"
bw
;;

5)
clear 
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "                    ${BIWhite}${UWhite}BANDWITH MONITOR ${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e ""

vnstat -m

echo -e ""
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e ""
read -n 1 -s -r -p "Press any key to back on menu"
bw
;;

6)
clear 
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "                    ${BIWhite}${UWhite}BANDWITH MONITOR ${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e ""

vnstat -y

echo -e ""
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e ""
read -n 1 -s -r -p "Press any key to back on menu"
bw
;;

7)
clear 
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "                    ${BIWhite}${UWhite}BANDWITH MONITOR ${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e ""

vnstat -t

echo -e ""
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e ""
read -n 1 -s -r -p "Press any key to back on menu"
bw
;;

8)
clear 
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "                    ${BIWhite}${UWhite}BANDWITH MONITOR ${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e ""

vnstat -hg

echo -e ""
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e ""
read -n 1 -s -r -p "Press any key to back on menu"
bw
;;

9)
clear 
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "                    ${BIWhite}${UWhite}BANDWITH MONITOR ${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e   " Press [ Ctrl+C ] • To-Exit"
echo -e ""

vnstat -l

echo -e ""
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e ""
read -n 1 -s -r -p "Press any key to back on menu"
bw
;;

10)
clear 
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "                    ${BIWhite}${UWhite}BANDWITH MONITOR ${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e ""

vnstat -tr

echo -e ""
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e ""
read -n 1 -s -r -p "Press any key to back on menu"
bw
;;
0)
sleep 1
clear
menu
;;
x)
exit
;;
*)
echo -e ""
echo -e "Wrong choice !"
sleep 1
bw
;;
esac
