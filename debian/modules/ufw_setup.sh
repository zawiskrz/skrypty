#!/bin/bash

configure_ufw() {
  echo "🛡️ Konfiguracja zapory UFW..." | tee -a "$LOGFILE"
  sudo ufw --force reset
  sudo ufw default deny incoming
  sudo ufw default allow outgoing

  for subnet in 192.168.0.0/24 192.168.1.0/24 10.0.2.0/24; do
    for port in 22 139 445 1716; do
      sudo ufw allow from "$subnet" to any port "$port" proto tcp
    done
    for port in 137 138; do
      sudo ufw allow from "$subnet" to any port "$port" proto udp
    done
  done

  sudo ufw --force enable
  echo "✅ Zapora UFW aktywna." | tee -a "$LOGFILE"
}
