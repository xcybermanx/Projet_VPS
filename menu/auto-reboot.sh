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
if [ ! -e /usr/local/bin/reboot_otomatis ]; then
echo '#!/bin/bash' > /usr/local/bin/reboot_otomatis 
echo 'tanggal=$(date +"%m-%d-%Y")' >> /usr/local/bin/reboot_otomatis 
echo 'waktu=$(date +"%T")' >> /usr/local/bin/reboot_otomatis 
echo 'echo "Server successfully rebooted on the date of $tanggal hit $waktu." >> /root/log-reboot.txt' >> /usr/local/bin/reboot_otomatis 
echo '/sbin/shutdown -r now' >> /usr/local/bin/reboot_otomatis 
chmod +x /usr/local/bin/reboot_otomatis
fi
clear
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "                   ${BIWhite}${UWhite}AUTO-REBOOT LOG ${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e "     ${BICyan}[${BIWhite}01${BICyan}] Set Auto-Reboot Every 1 Hour      "
echo -e "     ${BICyan}[${BIWhite}02${BICyan}] Set Auto-Reboot Every 6 Hours      "
echo -e "     ${BICyan}[${BIWhite}03${BICyan}] Set Auto-Reboot Every 12 Hours      "
echo -e "     ${BICyan}[${BIWhite}04${BICyan}] Set Auto-Reboot Every 1 Day     "
echo -e "     ${BICyan}[${BIWhite}05${BICyan}] Set Auto-Reboot Every 1 Week     "
echo -e "     ${BICyan}[${BIWhite}06${BICyan}] Set Auto-Reboot Every 1 Month     "
echo -e "     ${BICyan}[${BIWhite}07${BICyan}] Turn off Auto-Reboot"
echo -e "     ${BICyan}[${BIWhite}08${BICyan}] View reboot log"
echo -e "     ${BICyan}[${BIWhite}09${BICyan}] Remove reboot log"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e "     ${BIYellow}Press x or [ Ctrl+C ] • To-${BIWhite}Exit${NC}"
echo ""
read -p " Select menu :  "  opt
echo -e ""
case $opt in

1)
echo "10 * * * * root /usr/local/bin/reboot_otomatis" > /etc/cron.d/reboot_otomatis
echo -e "     ${BIGreen} Auto-Reboot has been set every an hour${NC}"
sleep 2
auto-reboot
;;

2)
echo "10 */6 * * * root /usr/local/bin/reboot_otomatis" > /etc/cron.d/reboot_otomatis
echo -e "     ${BIGreen} Auto-Reboot has been successfully set every 6 hours${NC}"
sleep 2
auto-reboot
;;

3)
echo "10 */12 * * * root /usr/local/bin/reboot_otomatis" > /etc/cron.d/reboot_otomatis
echo -e "     ${BIGreen} Auto-Reboot has been successfully set every 12 hours${NC}"
sleep 2
auto-reboot
;;

4)
echo "10 0 * * * root /usr/local/bin/reboot_otomatis" > /etc/cron.d/reboot_otomatis
echo -e "     ${BIGreen} Auto-Reboot has been successfully set once a day${NC}"
sleep 2
auto-reboot
;;

5)
echo "10 0 */7 * * root /usr/local/bin/reboot_otomatis" > /etc/cron.d/reboot_otomatis
echo -e "     ${BIGreen} Auto-Reboot has been successfully set once a week${NC}"
sleep 2
auto-reboot
;;

6)
echo "10 0 1 * * root /usr/local/bin/reboot_otomatis" > /etc/cron.d/reboot_otomatis
echo -e "     ${BIGreen} Auto-Reboot has been successfully set once a month${NC}"
sleep 2
auto-reboot
;;

7)
rm -f /etc/cron.d/reboot_otomatis
echo -e "     ${BIGreen} Auto-Reboot successfully TURNED OFF${NC}"
sleep 2
auto-reboot
;;

8)
if [ ! -e /root/log-reboot.txt ]; then
echo -e "     ${BIRed} No reboot activity found${NC}"
sleep 2
auto-reboot
else
echo -e "     ${BIGreen} Auto-Reboot has been Removed${NC}"
cat /root/log-reboot.txt
sleep 2
auto-reboot
fi
;;

9)
echo "" > /root/log-reboot.txt
echo -e "     ${BIGreen} Auto Reboot Log successfully deleted!${NC}"
sleep 2
auto-reboot
;;

0)
sleep 1
clear
menu-set
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