#!/usr/bin/env bash
source /opt/projet_vps/scripts/utils.sh

MYIP=$(get_ip)
REGISTER_FILE="/opt/projet_vps/register"

# Vérifie si VPS autorisé
check_permission() {
    local name exp ip token line
    line=$(grep "$MYIP" "$REGISTER_FILE")
    if [[ -z "$line" ]]; then
        error "Permission denied for IP $MYIP"
        exit 1
    fi
    name=$(echo $line | awk '{print $2}')
    exp=$(echo $line | awk '{print $3}')
    token=$(echo $line | awk '{print $4}')
    local days
    days=$(days_left "$exp")
    if (( days <= 0 )); then
        error "License expired for $name"
        exit 1
    fi
    info "Permission accepted for $name ($days days left)"
}

check_permission

clear
echo -e "==== SSH / OpenVPN Menu ===="
echo "1) Create account"
echo "2) Trial account"
echo "3) Renew account"
echo "4) Delete account"
echo "0) Back to main menu"
read -rp "Select menu: " opt

case $opt in
1) echo "Créer compte SSH" ;;
2) echo "Créer compte Trial" ;;
3) echo "Renouveler compte" ;;
4) echo "Supprimer compte" ;;
0) bash /opt/projet_vps/menu/menu.sh ;;
*) echo "Invalid option" ; sleep 1 ; bash "$0" ;;
esac
