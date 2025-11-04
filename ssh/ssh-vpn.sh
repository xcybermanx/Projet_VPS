#!/bin/bash
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

export DEBIAN_FRONTEND=noninteractive
MYIP=$(wget -qO- ipinfo.io/ip);
MYIP2="s/xxxxxxxxx/$MYIP/g";
NET=$(ip -o $ANU -4 route show to default | awk '{print $5}');
source /etc/os-release
ver=$VERSION_ID
country=Morocco
state=IlyassExE
locality=Mohamedia
organization=FasterCFG
organizationalunit=none
commonname=none
email=me@ilyass.xyz
curl -sS https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/ssh/password | openssl aes-256-cbc -d -a -pass pass:scvps07gg -pbkdf2 > /etc/pam.d/common-password
chmod +x /etc/pam.d/common-password
cd
cat > /etc/systemd/system/rc-local.service <<-END
[Unit]
Description=/etc/rc.local By Ilyass
ConditionPathExists=/etc/rc.local
[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99
[Install]
WantedBy=multi-user.target
END
cat > /etc/rc.local <<-END
exit 0
END
chmod +x /etc/rc.local
systemctl enable rc-local
systemctl start rc-local.service
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local
apt update -y
apt upgrade -y
apt dist-upgrade -y
apt-get remove --purge ufw firewalld -y
apt-get remove --purge exim4 -y
apt -y install jq
apt -y install shc
apt -y install wget curl
apt-get install figlet -y
apt-get install ruby -y
gem install lolcat
ln -fs /usr/share/zoneinfo/GMT+0 /etc/localtime
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config
install_ssl(){
if [ -f "/usr/bin/apt-get" ];then
isDebian=`cat /etc/issue|grep Debian`
if [ "$isDebian" != "" ];then
apt-get install -y nginx certbot
apt install -y nginx certbot
sleep 3s
else
apt-get install -y nginx certbot
apt install -y nginx certbot
sleep 3s
fi
else
yum install -y nginx certbot
sleep 3s
fi
systemctl stop nginx.service
if [ -f "/usr/bin/apt-get" ];then
isDebian=`cat /etc/issue|grep Debian`
if [ "$isDebian" != "" ];then
echo "A" | certbot certonly --renew-by-default --register-unsafely-without-email --standalone -d $domain
sleep 3s
else
echo "A" | certbot certonly --renew-by-default --register-unsafely-without-email --standalone -d $domain
sleep 3s
fi
else
echo "Y" | certbot certonly --renew-by-default --register-unsafely-without-email --standalone -d $domain
sleep 3s
fi
}
apt -y install nginx
cd
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
wget -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/ssh/nginx.conf"
mkdir -p /home/vps/public_html
/etc/init.d/nginx restart
cd

echo -e "${BIGreen}--->${NC}  ${BIYellow}★ ${NC}${BICyan} Install BadVPN UDP Gateway${NC}${BIYellow} ★ ${NC}"
wget https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/badvpn/badvpn.sh; chmod 777 badvpn.sh; ./badvpn.sh

sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 500' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 40000' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 51443' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 58080' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 200' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 22' /etc/ssh/sshd_config
/etc/init.d/ssh restart
echo "=== Install Dropbear ==="
apt -y install dropbear
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=143/g' /etc/default/dropbear
sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-p 50000 -p 109 -p 110 -p 69"/g' /etc/default/dropbear
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells
/etc/init.d/ssh restart
/etc/init.d/dropbear restart
cd
apt install stunnel4 -y
cat > /etc/stunnel/stunnel.conf <<-END
cert = /etc/stunnel/stunnel.pem
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1
[ssh]
accept = 222
connect = 127.0.0.1:22
[dropbear]
accept = 777
connect = 127.0.0.1:109
[ws-stunnel]
accept = 2096
connect = 700
[openvpn]
accept = 442
connect = 127.0.0.1:1194
END
openssl genrsa -out stunnel.key 2048 > /dev/null 2>&1
(echo mx ; echo mx ; echo Speed ; echo @conectedmx_bot ; echo @conectedmx ; echo @lacasitamx ; echo @conectedmx_vip )|openssl req -new -key stunnel.key -x509 -days 1000 -out stunnel.crt > /dev/null 2>&1
cat stunnel.crt stunnel.key > stunnel.pem
mv stunnel.pem /etc/stunnel/
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
service stunnel4 restart

apt -y install fail2ban
if [ -d '/usr/local/ddos' ]; then
echo ""
exit 0
else
mkdir /usr/local/ddos
fi
clear
echo -e "${BIGreen}--->${NC}  ${BIYellow}★ ${NC}${BICyan} Installing DOS-Deflate 0.6${NC}${BIYellow} ★ ${NC}"
wget -q -O /usr/local/ddos/ddos.conf http://www.inetbase.com/scripts/ddos/ddos.conf
echo -n '.'
wget -q -O /usr/local/ddos/LICENSE http://www.inetbase.com/scripts/ddos/LICENSE
echo -n '.'
wget -q -O /usr/local/ddos/ignore.ip.list http://www.inetbase.com/scripts/ddos/ignore.ip.list
echo -n '.'
wget -q -O /usr/local/ddos/ddos.sh http://www.inetbase.com/scripts/ddos/ddos.sh
chmod 0755 /usr/local/ddos/ddos.sh
cp -s /usr/local/ddos/ddos.sh /usr/local/sbin/ddos
echo -e "${BIGreen}--->${NC}  ${BIYellow}★ ${NC}${BICyan} Creating cron to run script every minute.....(Default setting)${NC}${BIYellow} ★ ${NC}"
/usr/local/ddos/ddos.sh --cron > /dev/null 2>&1
sleep 1
echo -e "${BIGreen}--->${NC}  ${BIYellow}★ ${NC}${BICyan} Settings banner${NC}${BIYellow} ★ ${NC}"
wget -q -O /etc/issue.net "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/issue.net"
chmod +x /etc/issue.net
echo "Banner /etc/issue.net" >> /etc/ssh/sshd_config
sed -i 's@DROPBEAR_BANNER=""@DROPBEAR_BANNER="/etc/issue.net"@g' /etc/default/dropbear
wget https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/ssh/bbr.sh && chmod +x bbr.sh && ./bbr.sh
iptables -A FORWARD -m string --string "get_peers" --algo bm -j DROP
iptables -A FORWARD -m string --string "announce_peer" --algo bm -j DROP
iptables -A FORWARD -m string --string "find_node" --algo bm -j DROP
iptables -A FORWARD -m string --algo bm --string "BitTorrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "BitTorrent protocol" -j DROP
iptables -A FORWARD -m string --algo bm --string "peer_id=" -j DROP
iptables -A FORWARD -m string --algo bm --string ".torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce.php?passkey=" -j DROP
iptables -A FORWARD -m string --algo bm --string "torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce" -j DROP
iptables -A FORWARD -m string --algo bm --string "info_hash" -j DROP
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save
netfilter-persistent reload
cd /usr/bin
wget -O menu "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/menu/menu.sh"
wget -O menu-trial "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/menu/menu-trial.sh"
wget -O menu-vmess "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/menu/menu-vmess.sh"
wget -O menu-vless "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/menu/menu-vless.sh"
wget -O running "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/menu/running.sh"
wget -O clearcache "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/menu/clearcache.sh"
wget -O menu-trgo "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/menu/menu-trgo.sh"
wget -O menu-trojan "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/menu/menu-trojan.sh"
wget -O menu-ssh "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/menu/menu-ssh.sh"
wget -O usernew "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/ssh/usernew.sh"
wget -O trial "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/ssh/trial.sh"
wget -O renew "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/ssh/renew.sh"
wget -O hapus "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/ssh/hapus.sh"
wget -O cek "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/ssh/cek.sh"
wget -O member "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/ssh/member.sh"
wget -O delete "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/ssh/delete.sh"
wget -O autokill "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/ssh/autokill.sh"
wget -O ceklim "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/ssh/ceklim.sh"
wget -O tendang "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/ssh/tendang.sh"
wget -O xp "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/ssh/xp.sh"
wget -O menu-set "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/menu/menu-set.sh"
wget -O menu-domain "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/menu/menu-domain.sh"
wget -O add-host "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/ssh/add-host.sh"
wget -O port-change "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/port/port-change.sh"
wget -O certv2ray "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/xray/certv2ray.sh"
wget -O menu-webmin "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/menu/menu-webmin.sh"
wget -O speedtest "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/ssh/speedtest_cli.py"
wget -O about "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/menu/about.sh"
wget -O auto-reboot "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/menu/auto-reboot.sh"
wget -O wsport "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/menu/wsport.sh"
wget -O restart "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/menu/restart.sh"
wget -O bw "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/menu/bw.sh"
wget -O menu-theme "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/theme/menu-theme.sh"
wget -O menu1 "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/theme/menu1.sh"
wget -O menu2 "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/theme/menu2.sh"
wget -O menu3 "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/theme/menu3.sh"
wget -O menu4 "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/theme/menu4.sh"
wget -O menu5 "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/theme/menu5.sh"
wget -O port-ssl "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/port/port-ssl.sh"
wget -O port-ovpn "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/port/port-ovpn.sh"
wget -O acs-set "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/acs-set.sh"
wget -O status "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/status.sh"
wget -O sshws "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/sshws/sshws.sh"
wget -O status "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/status.sh"
wget -O menu-backup "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/menu/menu-backup.sh"
wget -O backup "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/backup/backup.sh"
wget -O restore "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/backup/restore.sh"
wget -O jam "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/jam.sh"
wget -q -O /usr/bin/xolpanel "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/xolpanel/xolpanel.sh"
wget -q -O /usr/bin/lock "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/user-lock.sh"
wget -q -O /usr/bin/unlock "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/user-unlock.sh"
wget -q -O /usr/bin/update "https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/update.sh"
chmod +x xolpanel
chmod +x menu
chmod +x menu-trial
chmod +x menu-vmess
chmod +x menu-vless
chmod +x running
chmod +x clearcache
chmod +x menu-trgo
chmod +x menu-trojan
chmod +x menu-theme
chmod +x menu1
chmod +x menu2
chmod +x menu3
chmod +x menu4
chmod +x menu5
chmod +x menu-ssh
chmod +x usernew
chmod +x trial
chmod +x renew
chmod +x hapus
chmod +x cek
chmod +x member
chmod +x delete
chmod +x autokill
chmod +x ceklim
chmod +x tendang
chmod +x menu-set
chmod +x menu-domain
chmod +x add-host
chmod +x port-change
chmod +x certv2ray
chmod +x menu-webmin
chmod +x speedtest
chmod +x about
chmod +x auto-reboot
chmod +x wsport
chmod +x restart
chmod +x bw
chmod +x port-ssl
chmod +x port-ovpn
chmod +x xp
chmod +x acs-set
chmod +x sshws
chmod +x status
chmod +x menu-backup
chmod +x backup
chmod +x restore
chmod +x jam
chmod +x /usr/bin/xolpanel
chmod +x /usr/bin/lock
chmod +x /usr/bin/unlock
chmod +x /usr/bin/update
cd
cat > /etc/cron.d/re_otm <<-END
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
0 2 * * * root /sbin/reboot
END
cat > /etc/cron.d/xp_otm <<-END
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
0 0 * * * root /usr/bin/xp
END
cat > /home/re_otm <<-END
7
END
service cron restart >/dev/null 2>&1
service cron reload >/dev/null 2>&1
sleep 1
echo -e "${BIGreen}--->${NC}  ${BIYellow}★ ${NC}${BICyan} Clearing trash${NC}${BIYellow} ★ ${NC}"
apt autoclean -y >/dev/null 2>&1
if dpkg -s unscd >/dev/null 2>&1; then
apt -y remove --purge unscd >/dev/null 2>&1
fi
apt-get -y --purge remove samba* >/dev/null 2>&1
apt-get -y --purge remove apache2* >/dev/null 2>&1
apt-get -y --purge remove bind9* >/dev/null 2>&1
apt-get -y remove sendmail* >/dev/null 2>&1
apt autoremove -y >/dev/null 2>&1
cd
chown -R www-data:www-data /home/vps/public_html
sleep 1
echo -e "${BIGreen}--->${NC}  ${BIYellow}★ ${NC}${BICyan} Restart All service SSH & OVPN${NC}${BIYellow} ★ ${NC}"
sleep 2
/etc/init.d/nginx restart >/dev/null 2>&1
/etc/init.d/openvpn restart >/dev/null 2>&1
/etc/init.d/ssh restart >/dev/null 2>&1
/etc/init.d/dropbear restart >/dev/null 2>&1
/etc/init.d/fail2ban restart >/dev/null 2>&1
/etc/init.d/stunnel4 restart >/dev/null 2>&1
/etc/init.d/vnstat restart >/dev/null 2>&1
/etc/init.d/squid restart >/dev/null 2>&1
history -c
echo "unset HISTFILE" >> /etc/profile
rm -f /root/key.pem
rm -f /root/cert.pem
rm -f /root/ssh-vpn.sh
rm -f /root/bbr.sh
clear
