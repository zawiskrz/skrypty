#!/bin/bash

configure_bluetooth() {
  echo "🛠️ Instalacja pakietów Bluetooth..." | tee -a "$LOGFILE"
  sudo apt install -y bluez blueman pulseaudio-module-bluetooth rfkill 2>&1 | tee -a "$LOGFILE"

  echo "🔵 Konfiguracja usługi Bluetooth..." | tee -a "$LOGFILE"
  sudo systemctl enable bluetooth
  sudo systemctl start bluetooth
  sudo rfkill unblock bluetooth

  echo "✅ Bluetooth skonfigurowany." | tee -a "$LOGFILE"
}
