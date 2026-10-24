#!/bin/bash

configure_ufw() {
  echo "🛡️ Konfiguracja zapory UFW..." | tee -a "$LOGFILE"
  sudo ufw --force reset
  sudo ufw default deny incoming
  sudo ufw default allow outgoing

  # Reguły KDE Connect (porty 1714-1764 TCP/UDP)
  sudo ufw allow 1714:1764/udp comment 'KDE Connect' 2>&1 | tee -a "$LOGFILE"
  sudo ufw allow 1714:1764/tcp comment 'KDE Connect' 2>&1 | tee -a "$LOGFILE"

  for subnet in 192.168.0.0/24 192.168.1.0/24 10.0.2.0/24; do
    # SSH oraz Samba
    for port in 22 139 445; do
      sudo ufw allow from "$subnet" to any port "$port" proto tcp 2>&1 | tee -a "$LOGFILE"
    done
    for port in 137 138; do
      sudo ufw allow from "$subnet" to any port "$port" proto udp 2>&1 | tee -a "$LOGFILE"
    done
  done

  sudo ufw --force enable 2>&1 | tee -a "$LOGFILE"
  echo "✅ Zapora UFW aktywna." | tee -a "$LOGFILE"
}
