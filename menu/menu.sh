#!/bin/bash
# =========================================
# GxTunnel Auto Setup Fix
# =========================================
clear
echo -e "\e[32m[INFO]\e[0m Starting GxTunnel Setup Fix..."

# --- Check root ---
if [ "$(id -u)" -ne 0 ]; then
  echo -e "\e[31m[ERROR]\e[0m Please run this script as root."
  exit 1
fi

# --- Define paths ---
MENU_PATH="/usr/local/bin/menu"
MENU_SRC="/root/menu.sh"

# --- Ensure dependencies exist ---
echo -e "\e[32m[INFO]\e[0m Checking required packages..."
apt update -y > /dev/null 2>&1
apt install -y curl wget jq bash coreutils > /dev/null 2>&1

# --- Fix permissions for /root/menu.sh ---
if [ -f "$MENU_SRC" ]; then
  echo -e "\e[32m[INFO]\e[0m Fixing permissions for $MENU_SRC..."
  chmod +x "$MENU_SRC"
  chown root:root "$MENU_SRC"
else
  echo -e "\e[31m[ERROR]\e[0m menu.sh not found in /root — please copy it first!"
  exit 1
fi

# --- Create symlink for easier launch ---
if [ -f "$MENU_PATH" ]; then
  rm -f "$MENU_PATH"
fi
ln -s "$MENU_SRC" "$MENU_PATH"

chmod +x "$MENU_PATH"

# --- Add menu alias to bashrc if not exists ---
if ! grep -q "menu.sh" ~/.bashrc; then
  echo "alias menu='bash /usr/local/bin/menu'" >> ~/.bashrc
fi

# --- Final check ---
if [ -x "$MENU_PATH" ]; then
  echo -e "\e[32m[SUCCESS]\e[0m GxTunnel menu launcher installed successfully!"
  echo -e "Run it anytime using: \e[36mmenu\e[0m"
else
  echo -e "\e[31m[ERROR]\e[0m Something went wrong setting up the menu!"
  exit 1
fi
