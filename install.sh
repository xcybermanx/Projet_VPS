#!/bin/bash
# ==========================================
# AUTOINSTALL SCRIPT GX_Tunnel
# Author : cyberman
# GitHub : https://github.com/xcybermanx/Projet_VPS
# ==========================================

# 1. Vérifications de base
if [ "${EUID}" -ne 0 ]; then
  echo "❌ Please run this script as root"
  exit 1
fi

if [ "$(systemd-detect-virt)" == "openvz" ]; then
  echo "❌ OpenVZ is not supported"
  exit 1
fi

# 2. Variables globales
GIT_USER="xcybermanx"
REPO="Projet_VPS"
BASE_URL="https://raw.githubusercontent.com/$GIT_USER/$REPO/main"
INSTALL_DIR="/usr/bin"
VERSION_FILE="/home/ver"
TMP_DIR="/tmp/autoscript-install"

# 3. Nettoyage et préparation
rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"

# 4. Dépendances
echo "🧩 Installing dependencies..."
apt update -y >/dev/null 2>&1
apt install -y wget curl figlet unzip jq >/dev/null 2>&1

# 5. Téléchargement de la version
echo "📦 Fetching version info..."
VERSION=$(curl -s "$BASE_URL/version")
echo "$VERSION" > "$VERSION_FILE"

# 6. Liste des fichiers à installer
FILES=(
  "menu/menu.sh"
  "menu/menu-ssh.sh"
  "menu/menu-vmess.sh"
  "menu/menu-vless.sh"
  "xray/add-ws.sh"
  "xray/del-ws.sh"
  "ssh/usernew.sh"
  "ssh/xp.sh"
  "menu/about.sh"
)

# 7. Téléchargement des fichiers
echo "⬇️  Downloading script files..."
cd "$TMP_DIR" || exit

for FILE in "${FILES[@]}"; do
  FILE_NAME=$(basename "$FILE")
  wget -q "$BASE_URL/$FILE" -O "$FILE_NAME"
  if [ ! -s "$FILE_NAME" ]; then
    echo "⚠️  Failed to download: $FILE"
  else
    install -m 755 "$FILE_NAME" "$INSTALL_DIR/$FILE_NAME"
    echo "✅ Installed: $FILE_NAME"
  fi
done

# 8. Finalisation
echo ""
echo "🚀 Installation complete!"
echo "Version installed: $VERSION"
echo "Run 'menu' to start."
echo ""
sleep 1
figlet "INSTALL DONE"
