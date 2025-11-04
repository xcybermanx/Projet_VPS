#!/bin/bash

cd
rm -rf /root/udp &>/dev/null
mkdir -p /root/udp &>/dev/null
wget https://raw.githubusercontent.com/xcybermanx/Projet_VPS/main/udp-custom-linux-amd64 -O /root/udp/udp-custom &>/dev/null
chmod +x /root/udp/udp-custom &>/dev/null
wget https://raw.githubusercontent.com/xcybermanx/Projet_VPS/refs/heads/main/config.json -O /root/udp/config.json &>/dev/null
chmod 64 /root/udp/config.json &>/dev/null

if [ -z "$1" ]; then
cat <<EOF > /etc/systemd/system/custom.service
[Unit]
Description=UDP Custom by ePev. Team
[Service]
User=root
Type=simple
ExecStart=/root/udp/custom-server
WorkingDirectory=/root/udp/
Restart=always
RestartSec=2
[Install]
WantedBy=default.target
EOF
else
cat <<EOF > /etc/systemd/system/custom.service
[Unit]
Description=UDP Custom by ePev. Team
[Service]
User=root
Type=simple
ExecStart=/root/udp/custom-server -exclude $1
WorkingDirectory=/root/udp/
Restart=always
RestartSec=2
[Install]
WantedBy=default.target
EOF
fi

systemctl start custom &>/dev/null
systemctl enable udp-custom &>/dev/null
