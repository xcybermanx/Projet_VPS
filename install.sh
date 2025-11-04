#!/bin/bash
# ==========================================
# AUTOINSTALL SCRIPT
# Author : xcybermanx
# GitHub : https://github.com/xcybermanx/Projet_VPS
# ==========================================

# === [1] Vérifications de base ===
if [ "${EUID}" -ne 0 ]; then
  echo "❌ Please run this script as root"
  exit 1
fi

if [ "$(systemd-detect-virt)" == "openvz" ]; then
  echo "❌ OpenVZ is not supported"
  exit 1
fi

# === [2] Variables globales ===
GIT_USER="xcybermanx"
REPO="Projet_VPS"
BASE_URL="https://raw.githubusercontent.com/$GIT_USER/$REPO/main"
INSTALL_DIR="/usr/bin"
VERSION_FILE="/home/ver"
TMP_DIR="/tmp/projetvps-install"
MENU_PATH="menu"

# === [3] Nettoyage et préparation ===
rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"

# === [4] Dépendances ===
echo "🧩 Installing required packages..."
apt update -y >/dev/null 2>&1
apt install -y wget curl figlet jq unzip >/dev/null 2>&1

# === [5] Version info ===
VERSION=$(date +%Y.%m.%d)
echo "$VERSION" > "$VERSION_FILE"

# === [6] Téléchargement des fichiers MENU ===
echo "⬇️  Downloading menu scripts from $REPO..."

cd "$TMP_DIR" || exit 1

# Liste dynamique des fichiers dans le dossier menu
FILES=$(curl -s "https://api.github.com/repos/$GIT_USER/$REPO/contents/$MENU_PATH" \
  | jq -r '.[] | select(.type=="file") | .name')

if [ -z "$FILES" ]; then
  echo "❌ Unable to fetch file list from GitHub API."
  exit 1
fi

for FILE in $FILES; do
  echo "📥 Downloading: $FILE"
  wget -q "$BASE_URL/$MENU_PATH/$FILE" -O "$FILE"
  if [ ! -s "$FILE" ]; then
    echo "⚠️  Failed to download: $FILE"
  else
    install -m 755 "$FILE" "$INSTALL_DIR/$FILE"
  fi
done

# === [7] Finalisation ===
clear
figlet "INSTALL DONE"
echo ""
echo "✅ All menu scripts installed successfully!"
echo "📦 Installed version: $VERSION"
echo ""
echo "Run any script using its name, e.g.:"
echo "   menu.sh"
echo ""
echo "Repository: https://github.com/$GIT_USER/$REPO"
echo ""
