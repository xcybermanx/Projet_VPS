#!/usr/bin/env bash
# Installe Projet_VPS

set -e
REPO_DIR="/opt/projet_vps"

mkdir -p "$REPO_DIR"
apt update -y && apt install -y git curl wget jq bash-completion

# Clone ou update
if [ ! -d "$REPO_DIR/.git" ]; then
    git clone https://github.com/xcybermanx/Projet_VPS.git "$REPO_DIR"
else
    cd "$REPO_DIR"
    git pull
fi

# Crée token si absent
TOKEN_FILE="/etc/projet_vps.token"
if [ ! -f "$TOKEN_FILE" ]; then
    TOKEN=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 12)
    echo "$TOKEN" > "$TOKEN_FILE"
    chmod 600 "$TOKEN_FILE"
fi

# Lien pour menu
ln -sf "$REPO_DIR/menu/menu.sh" /usr/local/bin/projet-menu
chmod +x "$REPO_DIR/menu/menu.sh"

echo "Installation terminée !"
echo "Lancer le menu : projet-menu"

