#!/usr/bin/env bash
# Menu principal Projet_VPS

source /opt/projet_vps/scripts/utils.sh

clear
echo -e "==== Projet VPS Menu ===="
echo "1) SSH / OpenVPN"
echo "2) VMESS"
echo "3) VLESS"
echo "4) TROJAN"
echo "5) Trial"
echo "0) Exit"
read -rp "Select menu: " opt

case $opt in
1) bash /opt/projet_vps/ssh/menu-ssh.sh ;;
2) echo "Menu VMESS en construction" ;;
3) echo "Menu VLESS en construction" ;;
4) echo "Menu TROJAN en construction" ;;
5) echo "Menu Trial en construction" ;;
0) exit 0 ;;
*) echo "Invalid option" ; sleep 1 ; bash "$0" ;;
esac
