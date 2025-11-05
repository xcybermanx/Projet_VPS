#!/bin/bash
# --------------------------------------------------
# Fully Automated Bootstrap Script for Projet_VPS
# Usage: curl -sSL https://github.com/xcybermanx/Projet_VPS/raw/main/run.sh | bash
# --------------------------------------------------

# ------------------------------
# Check for root
# ------------------------------
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

# ------------------------------
# Update & install dependencies
# ------------------------------
echo "[INFO] Updating system and installing dependencies..."
DEPS="git wget curl sudo unzip iptables bc screen curl openssl"
export DEBIAN_FRONTEND=noninteractive
apt update -y && apt upgrade -y
apt install -y $DEPS

# ------------------------------
# Create dedicated user if not exists
# ------------------------------
USERNAME="gxtunnel"
if ! id -u $USERNAME >/dev/null 2>&1; then
    echo "[INFO] Creating user $USERNAME..."
    adduser --disabled-password --gecos "" $USERNAME
    usermod -aG sudo $USERNAME
fi

# ------------------------------
# Clone repo if not present
# ------------------------------
USER_HOME="/home/$USERNAME"
REPO_DIR="$USER_HOME/Projet_VPS"

if [ ! -d "$REPO_DIR" ]; then
    echo "[INFO] Cloning Projet_VPS repository..."
    sudo -u $USERNAME git clone https://github.com/xcybermanx/Projet_VPS.git $REPO_DIR
fi

# ------------------------------
# Set permissions for scripts
# ------------------------------
echo "[INFO] Setting execute permissions..."
find $REPO_DIR -type f -name "*.sh" -exec chmod +x {} \;
chown -R $USERNAME:$USERNAME $REPO_DIR

# ------------------------------
# Run setup.sh unattended
# ------------------------------
echo "[INFO] Running setup.sh in fully unattended mode..."
# Some setup scripts check for input; we feed yes to all prompts
sudo -u $USERNAME bash -c "yes | bash $REPO_DIR/setup.sh"

# ------------------------------
# Finished
# ------------------------------
echo "[INFO] Installation completed! All services should be running."
