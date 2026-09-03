#!/bin/bash

configure_vscode() {
  echo "📝 Instalacja Visual Studio Code..." | tee -a "$LOGFILE"

  sudo apt update
  sudo apt install -y wget gpg ca-certificates | tee -a "$LOGFILE"

  sudo install -m 0755 -d /etc/apt/keyrings
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /etc/apt/keyrings/packages.microsoft.gpg
  sudo chmod a+r /etc/apt/keyrings/packages.microsoft.gpg

  echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null

  sudo apt update
  sudo apt install -y \
    code \
    gnome-keyring \
    libsecret-1-0 \
    libsecret-tools \
    dbus-x11 \
    xdg-utils \
    seahorse 2>&1 | tee -a "$LOGFILE"

  echo "✅ Visual Studio Code został zainstalowany." | tee -a "$LOGFILE"
}
