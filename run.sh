#!/bin/bash
# ===============================
# Auto installer for Projet_VPS
# ===============================

# Variables
USERNAME="gxtunnel"
REPO_URL="https://github.com/xcybermanx/Projet_VPS"
REPO_DIR="/home/$USERNAME/Projet_VPS"
LOG_FILE="/root/projet_vps_install.log"

# ------------------------------
# Ensure script is run as root
# ------------------------------
if [[ $EUID -ne 0 ]]; then
    echo "❌ This script must be run as root."
    exit 1
fi

# ------------------------------
# Update & install prerequisites
# ------------------------------
echo "[INFO] Updating packages and installing prerequisites..." | tee -a $LOG_FILE
apt update -y && apt upgrade -y | tee -a $LOG_FILE
apt install -y sudo git unzip curl wget lsof vim tmux | tee -a $LOG_FILE

# ------------------------------
# Create user if not exists
# ------------------------------
if ! id -u $USERNAME >/dev/null 2>&1; then
    echo "[INFO] Creating user $USERNAME..." | tee -a $LOG_FILE
    adduser --disabled-password --gecos "" $USERNAME | tee -a $LOG_FILE
    usermod -aG sudo $USERNAME
fi

# ------------------------------
# Clone the repository
# ------------------------------
echo "[INFO] Cloning Projet_VPS repository..." | tee -a $LOG_FILE
if [ ! -d "$REPO_DIR" ]; then
    git clone $REPO_URL $REPO_DIR | tee -a $LOG_FILE
else
    echo "[INFO] Repository already exists, pulling latest changes..." | tee -a $LOG_FILE
    cd $REPO_DIR
    git pull | tee -a $LOG_FILE
fi

# ------------------------------
# Set execute permissions
# ------------------------------
echo "[INFO] Setting execute permissions..." | tee -a $LOG_FILE
chmod -R +x $REPO_DIR/*.sh

# ------------------------------
# Run setup.sh unattended
# ------------------------------
echo "[INFO] Running setup.sh in fully unattended mode..." | tee -a $LOG_FILE
yes | bash $REPO_DIR/setup.sh 2>&1 | tee -a $LOG_FILE

# ------------------------------
# Final message
# ------------------------------
echo "[INFO] Installation completed! Check $LOG_FILE for details." | tee -a $LOG_FILE
echo "[INFO] All services should be running."
