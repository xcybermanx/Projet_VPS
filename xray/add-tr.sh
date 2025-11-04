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
source /var/lib/SIJA/ipvps.conf  > /dev/null 2>&1
if [[ "$IP" = "" ]]; then
domain=$(cat /etc/xray/domain)
else
domain=$IP
fi
tr="$(cat ~/log-install.txt | grep -w "Trojan WS " | cut -d: -f2|sed 's/ //g')"
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${user_EXISTS} == '0' ]]; do
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "                   ${BIWhite}${UWhite}TROJAN ACCOUNT ${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"

		read -rp "   User: " -e user
		user_EXISTS=$(grep -w $user /etc/xray/config.json | wc -l)

		if [[ ${user_EXISTS} == '1' ]]; then
clear
		echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "                   ${BIWhite}${UWhite}TROJAN ACCOUNT ${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
			echo ""
			echo "   A client with the specified name was already created, please choose another name."
			echo ""
			echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
			read -n 1 -s -r -p "   Press any key to back on menu"
			menu-trojan
		fi
	done

uuid=$(cat /proc/sys/kernel/random/uuid)
read -p "   Expired ( DAYS ): " masaaktif
read -p "   Limit IP ( DEVIC ) : " limit
read -p "   Limit Bandwith ( GB ) :  " bw 
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#trojanws$/a\#! '"$user $exp"'\
},{"password": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json
sed -i '/#trojangrpc$/a\#! '"$user $exp"'\
},{"password": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json

systemctl restart xray
trojanlink1="trojan://${uuid}@${domain}:${tr}?mode=gun&security=tls&type=grpc&serviceName=trojan-grpc&sni=bug.com#${user}"
trojanlink="trojan://${uuid}@isi_bug_disini:${tr}?path=%2Ftrojan-ws&security=tls&host=${domain}&type=ws&sni=${domain}#${user}"
clear
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "                   ${BIWhite}${UWhite}TROJAN ACCOUNT ${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "  ${BICyan} Remarks      :${NC} ${BIWhite}${user}${NC}"
echo -e "  ${BICyan} Limit IP     :${NC} ${BIWhite}${limit}${NC}"
echo -e "  ${BICyan} Limit BW     :${NC} ${BIWhite}${bw}${NC}"
echo -e "  ${BICyan} Host/IP      :${NC} ${BIWhite}${domain}${NC}"
echo -e "  ${BICyan} Port         :${NC} ${BIWhite}443/80${NC}"
echo -e "  ${BICyan} Key          :${NC} ${BIWhite}${uuid}${NC}"
echo -e "  ${BICyan} Path         :${NC} ${BIWhite}/trojan-ws${NC}"
echo -e "  ${BICyan} ServiceName  :${NC} ${BIWhite}trojan-grpc${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} 
┌─────────────────────────────────────────────────────┐${NC}"
echo -e "  ${BICyan} Link WS      :${NC}"
echo -e "  ${BIWhite} ${trojanlink}${NC}"
echo ""
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "  ${BICyan} Link GRPC    :${NC}"
echo -e "  ${BIWhite} ${trojanlink1}${NC}"
echo ""
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "  ${BICyan} Expired On   :${NC} ${BIWhite}$exp${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo ""
read -n 1 -s -r -p "   Press any key to back on menu"

menu-trojan