#!/bin/bash

configure_nvidia() {
  echo "🎮 Sprawdzanie obecności karty NVIDIA..." | tee -a "$LOGFILE"

  if lspci | grep -i "nvidia" >/dev/null; then
    echo "✅ Wykryto kartę NVIDIA. Instaluję sterowniki..." | tee -a "$LOGFILE"

    # Upewnij się, że masz dostęp do repozytoriów non-free
    echo "📦 Dodawanie repozytoriów non-free (jeśli potrzebne)..." | tee -a "$LOGFILE"
    sudo sed -i 's/main/main contrib non-free non-free-firmware/g' /etc/apt/sources.list
    sudo apt update 2>&1 | tee -a "$LOGFILE"

    # Instalacja sterownika
    sudo apt install -y nvidia-driver nvidia-settings firmware-misc-nonfree 2>&1 | tee -a "$LOGFILE"

    echo "🔁 Restart systemu może być wymagany po instalacji sterownika." | tee -a "$LOGFILE"
  else
    echo "⚠️ Nie wykryto karty NVIDIA. Pomijam instalację sterowników." | tee -a "$LOGFILE"
  fi
}
