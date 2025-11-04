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
IP=$(wget -qO- ipinfo.io/ip);
date=$(date +"%Y-%m-%d");
Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[ON]${Font_color_suffix}"
Error="${Red_font_prefix}[OFF]${Font_color_suffix}"
cek=$(grep -c -E "^# BEGIN_Backup" /etc/crontab)
if [[ "$cek" = "1" ]]; then
sts="${Info}"
else
sts="${Error}"
fi
function start() {
email=$(cat /home/email)
if [[ "$email" = "" ]]; then
echo -e "     ${BIGreen} Please enter your email${NC}"
read -rp "      Email : " -e email
cat <<EOF>>/home/email
$email
EOF
fi
cat << EOF >> /etc/crontab
# BEGIN_Backup
5 0 * * * root backup
# END_Backup
EOF
service cron restart
sleep 1
echo -e "     ${BIGreen} Please Wait${NC}"
clear
echo " "
echo -e "     ${BIGreen} Data Will Be Backed Up Automatically at 00:05 GMT${NC}"
autobackup
}
function stop() {
email=$(cat /home/email)
sed -i "/^$email/d" /home/email
sed -i "/^# BEGIN_Backup/,/^# END_Backup/d" /etc/crontab
service cron restart
sleep 1
echo -e "     ${BIGreen} Please Wait${NC}"
clear
echo -e "     ${BIGreen} Autobackup Has Been Stopped${NC}"
autobackup
}

function reciemail() {
rm -rf /home/email
echo -e "     ${BIGreen} Please enter your email${NC}"
read -rp "      Email : " -e email
cat <<EOF>>/home/email
$email
EOF
autobackup
}
function sendemail() {
echo -e "     ${BIGreen} Please enter your email${NC}"
read -rp "      Email : " -e email
echo -e "     ${BIGreen} Please enter your Password email${NC}"
read -rp "      Password : " -e email
rm -rf /etc/msmtprc
cat<<EOF>>/etc/msmtprc
defaults
tls on
tls_starttls on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
account default
host smtp.gmail.com
port 587
auth on
user $email
from $email
password $pwdd
logfile ~/.msmtp.log
EOF
autobackup
}
function testemail() {
email=$(cat /home/email)
if [[ "$email" = "" ]]; then
start
fi
email=$(cat /home/email)
echo -e "     ${BIGreen} This is the contents of an attempted email to send an email from VPS${NC}"
echo -e "
${BICyan}IP VPS :${NC} $IP
${BICyan}Date    :${NC} $date
" | mail -s "${IYellow}Email Sending Experiment${NC}" $email
autobackup
}

clear
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "                   ${BIWhite}${UWhite}AUTO-REBOOT LOG ${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e "     ${BICyan}[${BIWhite}01${BICyan}] Start Autobackup      "
echo -e "     ${BICyan}[${BIWhite}02${BICyan}] Stop Autobackup      "
echo -e "     ${BICyan}[${BIWhite}03${BICyan}] Change Recipient Email       "
echo -e "     ${BICyan}[${BIWhite}04${BICyan}] Change Sender Email       "
echo -e "     ${BICyan}[${BIWhite}05${BICyan}] Test sending an email     "
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e "     ${BIYellow}Press x or [ Ctrl+C ] • To-${BIWhite}Exit${NC}"
echo ""
read -p " Select menu :  "  opt
echo -e ""
case $opt in

1)
start
;;
2)
stop
;;
3)
reciemail
;;
4)
sendemail
;;
5)
testemail
;;
*)
clear
;;
esac
