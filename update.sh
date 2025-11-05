#!/bin/bash
# ====================================================
# Projet_VPS - Force Update Script (No Version Check)
# ====================================================

# Color definitions
Green="\033[0;32m"
Red="\033[0;31m"
Yellow="\033[1;33m"
NC="\033[0m"

# Check privileges
if [ "$EUID" -ne 0 ]; then
  echo -e "${Red}Please run this script as root.${NC}"
  exit 1
fi

echo -e "${Yellow}Starting forced update of all components...${NC}"
sleep 1

# Directory setup
cd /usr/bin || { echo "Cannot enter /usr/bin"; exit 1; }

# Create log file
LOG_FILE="/var/log/projet_vps_update.log"
echo "" > "$LOG_FILE"
echo "=== Projet_VPS Force Update $(date) ===" >> "$LOG_FILE"

# Base repo URL
BASE_URL="https://raw.githubusercontent.com/xcybermanx/Projet_VPS/main"

# List of files to fetch
FILES=(
  "ssh/usernew.sh"
  "menu/auto-reboot.sh"
  "menu/restart.sh"
  "ssh/tendang.sh"
  "menu/clearcache.sh"
  "menu/running.sh"
  "ssh/speedtest_cli.py"
  "menu/menu-vless.sh"
  "menu/menu-vmess.sh"
  "menu/menu-trojan.sh"
  "menu/menu-ssh.sh"
  "menu/menu-backup.sh"
  "menu/menu.sh"
  "theme/menu1.sh"
  "theme/menu2.sh"
  "theme/menu3.sh"
  "theme/menu4.sh"
  "theme/menu5.sh"
  "menu/menu-webmin.sh"
  "xp.sh"
  "update.sh"
  "ssh/add-host.sh"
  "xray/certv2ray.sh"
  "menu/menu-set.sh"
  "menu/about.sh"
  "ssh/trial.sh"
  "xray/add-tr.sh"
  "xray/del-tr.sh"
  "xray/cek-tr.sh"
  "xray/trialtrojan.sh"
  "xray/renew-tr.sh"
  "xray/add-ws.sh"
  "xray/del-ws.sh"
  "xray/cek-ws.sh"
  "xray/renew-ws.sh"
  "xray/trialvmess.sh"
  "xray/add-vless.sh"
  "xray/del-vless.sh"
  "xray/cek-vless.sh"
  "xray/renew-vless.sh"
  "xray/trialvless.sh"
  "menu/menu-trial.sh"
  "theme/menu-theme.sh"
)

# Download each file
for f in "${FILES[@]}"; do
  FILE_NAME=$(basename "$f")
  DEST="/usr/bin/${FILE_NAME%.*}"
  echo -e "${Green}Downloading: ${FILE_NAME}${NC}"
  wget -q -O "$DEST" "$BASE_URL/$f" && chmod +x "$DEST"
  if [ $? -eq 0 ]; then
    echo "[OK] $FILE_NAME" >> "$LOG_FILE"
  else
    echo "[FAIL] $FILE_NAME" >> "$LOG_FILE"
  fi
done

echo ""
echo -e "${Green}All files downloaded & permissions updated.${NC}"
echo ""
echo -e "Update log saved to: ${Yellow}$LOG_FILE${NC}"

# Update version tag
NEW_VERSION=$(curl -s "$BASE_URL/version")
echo "$NEW_VERSION" > /home/ver

echo ""
echo -e "${Green}✅ Update completed successfully.${NC}"
echo -e "Version: ${Yellow}$NEW_VERSION${NC}"
echo ""
sleep 1
menu
