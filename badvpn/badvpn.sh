sudo rm /bin/badvpn-udpgw
sudo rm /etc/systemd/system/badvpn-7100-7900.service

wget -O /bin/badvpn-udpgw https://github.com/FasterExE/VIP-Autoscript/raw/main/badvpn/badvpn-udpgw
wget -O /etc/systemd/system/badvpn-7100-7900.service https://github.com/FasterExE/VIP-Autoscript/raw/main/badvpn/badvpn-7100-7900.service

chmod 777 /bin/badvpn-udpgw
chmod 777 /etc/systemd/system/badvpn-7100-7900.service

sudo systemctl daemon-reload
sudo systemctl enable badvpn-7100-7900.service
sudo systemctl start badvpn-7100-7900.service
sudo systemctl restart badvpn-7100-7900.service
sudo rm badvpn.sh
