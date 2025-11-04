#!/usr/bin/env bash
# Fonctions utilitaires pour Projet_VPS

# Couleurs
RED="\033[0;31m"; GREEN="\033[0;32m"; YELLOW="\033[0;33m"; NC="\033[0m"

info() { echo -e "${GREEN}[INFO]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

# IP publique
get_ip() { curl -sS ipv4.icanhazip.com; }

# Date serveur
get_date() {
    dateFromServer=$(curl -sI --insecure https://google.com | grep -i ^Date: | sed 's/Date: //')
    date -d "$dateFromServer" +"%Y-%m-%d"
}

# Calcul jours restants
days_left() {
    local exp="$1"
    local today
    today=$(get_date)
    local d1 d2
    d1=$(date -d "$exp" +%s)
    d2=$(date -d "$today" +%s)
    echo $(( (d1 - d2)/86400 ))
}
