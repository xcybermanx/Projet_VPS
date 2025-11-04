apt install ncurses-utils -y
mkdir /etc/slowdns
cd /etc/slowdns

wget - O /etc/slowdns/dns-server https://github.com/xcybermanx/Projet_VPS/raw/main/slowdns/dns-server; chmod +x dns-server
apt install firewalld -y && sudo firewall-cmd --zone=public --permanent --add-port=80/tcp && sudo firewall-cmd --zone=public --permanent --add-port=8080/tcp && sudo firewall-cmd --zone=public --permanent --add-port=443/tcp && sudo firewall-cmd && sudo firewall-cmd --zone=public --permanent --add-port=53/udp && sudo firewall-cmd --zone=public --permanent --add-port=5300/udp && sudo firewall-cmd && sudo firewall-cmd --zone=public --permanent --add-port=2222/tcp && sudo firewall-cmd --reload
apt update && apt upgrade -y
apt install cron -y
apt install iptables -y
service cron reload
service cron restart
service iptables reload
service iptables restart
mv /etc/rc.local /etc/rc.local.bkp
wget -O /etc/rc.local https://github.com/khaledagn/SlowDNS/raw/main/rc.local
chmod +x /etc/rc.local
systemctl enable rc-local
systemctl start rc-local
echo -ne "\033[1;32m ENTER YOUR NS (NAMESERVER)\033[1;37m: "; read nameserver
touch /etc/slowdns/infons
echo $nameserver > infons
wget https://github.com/xcybermanx/Projet_VPS/raw/main/slowdns/startdns
chmod +x startdns
sed -i "s;1234;$nameserver;g" /etc/slowdns/startdns > /dev/null 2>&1
sed -i "s;1234;$nameserver;g" /etc/slowdns/restartdns > /dev/null 2>&1
cp startdns /bin/
cp restartdns /bin/
rm server.key server.pub
wget https://github.com/xcybermanx/Projet_VPS/raw/main/slowdns/server.key
wget https://github.com/xcybermanx/Projet_VPS/raw/main/slowdns/server.pub
cd /etc/slowdns/
iptables -I INPUT -p udp --dport 5300 -j ACCEPT
iptables -t nat -I PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 5300
./startdns
cd
