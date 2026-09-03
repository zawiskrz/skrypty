#!/bin/bash

install_printer_support() {
  echo "🔧 Instalacja sterowników i usług CUPS dla drukarek..." | tee -a "$LOGFILE"

  sudo apt install -y cups hplip avahi-daemon firmware-iwlwifi firmware-realtek printer-driver-all 2>&1 | tee -a "$LOGFILE"

  REAL_USER="${SUDO_USER:-$(logname)}"
  sudo usermod -aG lpadmin "$REAL_USER"

  sudo systemctl enable cups
  sudo systemctl start cups

  echo "✅ CUPS zainstalowany. Konfiguracja dostępna pod: http://localhost:631" | tee -a "$LOGFILE"
}
