#!/usr/bin/env bash
# menu.sh - Version modernisée pour xcybermanx/Projet_VPS
# Auteur: xcybermanx (adapté)
# Usage: sudo bash menu.sh

set -o errexit
set -o pipefail
set -o nounset

##### Config - À personnaliser #####
GIT_USER="xcybermanx"
REPO="Projet_VPS"
REGISTER_PATH="register"   # chemin relatif dans le repo
RAW_BASE="https://raw.githubusercontent.com/$GIT_USER/$REPO/main"
REGISTER_URL="$RAW_BASE/$REGISTER_PATH"
LOGFILE="/var/log/projet_vps_menu.log"
VERSION_FILE="/opt/.ver"   # à créer/pousser dans repo si tu veux indiquer version
###################################

# Couleurs
RED="\033[0;31m"; GREEN="\033[0;32m"; YELLOW="\033[0;33m"; CYAN="\033[0;36m"; NC="\033[0m"

log() { echo -e "[$(date '+%F %T')] $*" | tee -a "$LOGFILE"; }

# Récupère la date serveur (fallback à local si échec)
get_server_date() {
  local ds
  ds=$(curl -sI --max-time 5 https://google.com/ 2>/dev/null | grep -i '^Date:' || true)
  if [ -n "$ds" ]; then
    date -d "${ds#Date: }" +%F 2>/dev/null || date +%F
  else
    date +%F
  fi
}

# Télécharge le fichier register localement et renvoie le path
fetch_register() {
  local out="/tmp/projet_register.$$"
  if curl -fsSL "$REGISTER_URL" -o "$out"; then
    echo "$out"
  else
    log "${RED}Erreur: impossible de télécharger $REGISTER_URL${NC}"
    return 1
  fi
}

# Parse register line format:
# ### name YYYY-MM-DD IP [TOKEN]
# Retourne lignes valides (name|date|ip|token)
parse_register() {
  local file="$1"
  awk '/^### / { $1=""; sub(/^ +/,""); print }' "$file" | while read -r line; do
    # split into fields
    name=$(echo "$line" | awk '{print $1}')
    date_exp=$(echo "$line" | awk '{print $2}')
    ip=$(echo "$line" | awk '{print $3}')
    token=$(echo "$line" | awk '{print $4}')
    echo "$name|$date_exp|$ip|$token"
  done
}

# Vérifie l'autorisation:
# - Si register contient une ligne avec ce VPS IP + token (si token présent) -> OK
# - Sinon fallback sur IP seul
check_permission() {
  local regfile="$1"
  local today
  today=$(get_server_date)
  local myip
  myip=$(curl -sS ipv4.icanhazip.com || true)

  # Optional local token file: /etc/projet_vps.token
  local local_token=""
  if [ -f /etc/projet_vps.token ]; then
    local_token=$(< /etc/projet_vps.token)
  fi

  local allowed=0
  while IFS='|' read -r name exp ip token; do
    # skip empty
    [ -z "${name:-}" ] && continue
    # check ip match
    if [ "$myip" = "$ip" ]; then
      # if token present in register, require local token match
      if [ -n "$token" ]; then
        if [ -n "$local_token" ] && [ "$local_token" = "$token" ]; then
          # check expiry
          if (date -d "$exp" +%s) -ge (date -d "$today" +%s); then
            echo "$name|$exp|OK_TOKEN"
            return 0
          else
            echo "$name|$exp|EXPIRED"
            return 2
          fi
        else
          echo "REQUIRED_TOKEN_MISMATCH"
          return 3
        fi
      else
        # no token required, check expiry by date
        if (date -d "$exp" +%s) -ge (date -d "$today" +%s); then
          echo "$name|$exp|OK_IP"
          return 0
        else
          echo "$name|$exp|EXPIRED"
          return 2
        fi
      fi
    fi
  done < <(parse_register "$regfile")

  # no matching ip
  return 4
}

# Affiche message permission denied
permission_denied() {
  clear
  echo -e "${RED}PERMISSION DENIED${NC}"
  echo -e "Contact admin to register your VPS."
  echo -e "Telegram: t.me/YourContact"
  echo -e "GitHub: https://github.com/$GIT_USER/$REPO"
  sleep 2
  exit 1
}

# Calcul days left
days_left() {
  local end="$1"
  local today
  today=$(get_server_date)
  echo $(( ( $(date -d "$end" +%s) - $(date -d "$today" +%s) ) / 86400 ))
}

# Status helper for services
check_service() {
  local name="$1"
  if systemctl is-active --quiet "$name"; then
    echo -e "${GREEN}ON${NC}"
  else
    echo -e "${RED}OFF${NC}"
  fi
}

# Affichage du tableau principal (menu)
show_menu() {
  clear
  local name="$1"
  local exp_date="$2"
  local expiry_days
  expiry_days=$(days_left "$exp_date" 2>/dev/null || echo "?")

  # minimal system info
  local ip
  ip=$(curl -sS ipv4.icanhazip.com || echo "N/A")
  local osname
  osname=$(awk -F= '/PRETTY_NAME/{gsub(/"/,"",$2); print $2}' /etc/os-release 2>/dev/null || uname -srv)

  # counts (safe checks)
  local ssh_count
  ssh_count="$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd 2>/dev/null | wc -l || echo 0)"
  local v2r_count
  v2r_count="$(grep -c -E '^### ' /etc/xray/config.json 2>/dev/null || echo 0)"
  # show header
  cat <<-EOF

  ┌────────────────────────────────────────────┐
  │               PROJET_VPS MENU              │
  ├────────────────────────────────────────────┤
  │ User: ${CYAN}$name${NC}   Expire in: ${YELLOW}$expiry_days days${NC} │
  │ IP: ${CYAN}$ip${NC}                             OS: ${YELLOW}$osname${NC} │
  └────────────────────────────────────────────┘

  Services: SSH $(check_service ssh)  NGINX $(check_service nginx)  XRAY $(check_service xray)
  Counts: SSH-users: ${ssh_count}  XRAY-entries: ${v2r_count}

  1) SSH management
  2) VMESS menu
  3) VLESS menu
  4) TROJAN menu
  5) Settings
  6) Trial accounts
  7) Backup
  8) Add Host
  9) Running services
  10) WS port status
  11) Install bot
  12) Bandwidth
  13) Menu theme
  14) Update script
  0) Back to top / Exit

EOF

  read -rp "Select menu: " opt
  case "$opt" in
    1) menu-ssh ;;
    2) menu-vmess ;;
    3) menu-vless ;;
    4) menu-trojan ;;
    5) menu-set ;;
    6) menu-trial ;;
    7) menu-backup ;;
    8) add-host ;;
    9) running ;;
    10) wsport ;;
    11) xolpanel ;;
    12) bw ;;
    13) menu-theme ;;
    14) update ;;
    0) exit 0 ;;
    x|X) exit 0 ;;
    *) echo "Wrong choice"; sleep 1; show_menu "$name" "$exp_date" ;;
  esac
}

######### Main flow #########
# require root
if [ "$(id -u)" -ne 0 ]; then
  echo -e "${RED}Please run as root${NC}"
  exit 1
fi

log "Starting menu.sh"

# fetch register
regfile=$(fetch_register) || { log "Failed fetching register"; permission_denied; }

# check permission
perm_out=""
if perm_out=$(check_permission "$regfile"); then
  # perm_out format: name|exp|OK_*
  IFS='|' read -r NAME EXP STATUS <<< "$perm_out"
  log "Permission OK for $NAME, expiry $EXP (status $STATUS)"
  show_menu "$NAME" "$EXP"
else
  code=$?
  case $code in
    2) log "License expired"; echo -e "${RED}License expired${NC}"; exit 1 ;;
    3) log "Token mismatch"; echo -e "${RED}Token required or mismatch${NC}"; exit 1 ;;
    4) log "No permission for this IP"; permission_denied ;;
    *) log "Unknown permission error ($code)"; permission_denied ;;
  esac
fi
