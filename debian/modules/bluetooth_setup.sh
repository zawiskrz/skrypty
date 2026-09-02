#!/bin/bash
configure_bluetooth() {
  echo "🛠️ Instalacja pakietów Bluetooth..." | tee -a "$LOGFILE"
  sudo apt install -y  \
    bluez blueman pulseaudio-module-bluetooth rfkill
  echo "🔵 Konfiguracja Bluetooth..." | tee -a "$LOGFILE"
  sudo systemctl enable bluetooth
  sudo systemctl start bluetooth
  sudo rfkill unblock bluetooth
}
