#!/bin/bash

configure_nvidia() {
  echo "🎮 Sprawdzanie obecności karty NVIDIA..." | tee -a "$LOGFILE"

  if lspci | grep -i "nvidia" >/dev/null; then
    echo "✅ Wykryto kartę NVIDIA. Instaluję sterowniki..." | tee -a "$LOGFILE"

    sudo sed -i 's/main/main contrib non-free non-free-firmware/g' /etc/apt/sources.list
    sudo apt update 2>&1 | tee -a "$LOGFILE"
    sudo apt install -y nvidia-driver nvidia-settings firmware-misc-nonfree 2>&1 | tee -a "$LOGFILE"

    echo "🔁 Po instalacji sterownika zalecany jest restart systemu." | tee -a "$LOGFILE"
  else
    echo "⚠️ Nie wykryto karty NVIDIA. Pomijam instalację." | tee -a "$LOGFILE"
  fi
}
