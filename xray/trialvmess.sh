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

domain=$(cat /etc/xray/domain)
tls="$(cat ~/log-install.txt | grep -w "Vmess TLS" | cut -d: -f2|sed 's/ //g')"
none="$(cat ~/log-install.txt | grep -w "Vmess None TLS" | cut -d: -f2|sed 's/ //g')"
user=trial`</dev/urandom tr -dc X-Z0-9 | head -c4`
uuid=$(cat /proc/sys/kernel/random/uuid)
masaaktif=1
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
bug="masukan_bug"
sed -i '/#vmess$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","alterId": '"0"',"email": "'""$user""'"' /etc/xray/config.json
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#vmessgrpc$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","alterId": '"0"',"email": "'""$user""'"' /etc/xray/config.json
acs=`cat<<EOF
      {
      "v": "2",
      "ps": "${user}",
      "add": "${domain}",
      "port": "443",
      "id": "${uuid}",
      "aid": "0",
      "net": "ws",
      "path": "/vmess",
      "type": "none",
      "host": "${bug}",
      "tls": "tls"
}
EOF`
ask=`cat<<EOF
      {
      "v": "2",
      "ps": "${user}",
      "add": "${bug}",
      "port": "80",
      "id": "${uuid}",
      "aid": "0",
      "net": "ws",
      "path": "/vmess",
      "type": "none",
      "host": "${domain}",
      "tls": "none"
}
EOF`
grpc=`cat<<EOF
      {
      "v": "2",
      "ps": "${user}",
      "add": "${domain}",
      "port": "443",
      "id": "${uuid}",
      "aid": "0",
      "net": "grpc",
      "path": "vmess-grpc",
      "type": "none",
      "host": "${bug}",
      "tls": "tls"
}
EOF`
vmess_base641=$( base64 -w 0 <<< $vmess_json1)
vmess_base642=$( base64 -w 0 <<< $vmess_json2)
vmess_base643=$( base64 -w 0 <<< $vmess_json3)
vmesslink1="vmess://$(echo $acs | base64 -w 0)"
vmesslink2="vmess://$(echo $ask | base64 -w 0)"
vmesslink3="vmess://$(echo $grpc | base64 -w 0)"
systemctl restart xray > /dev/null 2>&1
service cron restart > /dev/null 2>&1
clear
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "                 ${BIWhite}${UWhite}VMESS TRIAL ACCOUNT ${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e "   Generat user for 1 day ....."
sleep 3
clear
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "                    ${BIWhite}${UWhite}VMESS ACCOUNT ${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e "  ${BICyan} Remarks       :${NC} ${BIWhite}${user}${NC}"
echo -e "  ${BICyan} Host/IP       :${NC} ${BIWhite}${domain}${NC}"
echo -e "  ${BICyan} Port TLS      :${NC} ${BIWhite}443${NC}"
echo -e "  ${BICyan} Port None TLS :${NC} ${BIWhite}80${NC}"
echo -e "  ${BICyan} Port GRPC     :${NC} ${BIWhite}443${NC}"
echo -e "  ${BICyan} ID            :${NC} ${BIWhite}${uuid}${NC}"
echo -e "  ${BICyan} Alterid       :${NC} ${BIWhite}0${NC}"
echo -e "  ${BICyan} Security      :${NC} ${BIWhite}Auto${NC}"
echo -e "  ${BICyan} Network       :${NC} ${BIWhite}WS${NC}"
echo -e "  ${BICyan} Path          :${NC} ${BIWhite}/vmess${NC}"
echo -e "  ${BICyan} ServiceName   :${NC} ${BIWhite}vmess-grpc${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} 
┌─────────────────────────────────────────────────────┐${NC}"
echo -e "  ${BICyan} Link TLS     :${NC}"
echo -e "  ${BIWhite} ${vmesslink1}${NC}"
echo ""
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} 
┌─────────────────────────────────────────────────────┐${NC}"
echo -e "  ${BICyan} Link None TLS:${NC}"
echo -e "  ${BIWhite} ${vmesslink2}${NC}"
echo ""
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "  ${BICyan} Link GRPC    :${NC}"
echo -e "  ${BIWhite} ${vmesslink3}${NC}"
echo ""
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "  ${BICyan} Expired On   :${NC} ${BIWhite}$exp${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo ""
read -n 1 -s -r -p "   Press any key to back on menu"

menu-vmess
