#!/bin/bash

configure_ssh() {
  echo "🔑 Konfiguracja serwera OpenSSH i kluczy SSH..." | tee -a "$LOGFILE"

  sudo apt update
  sudo apt install -y openssh-server 2>&1 | tee -a "$LOGFILE"

  echo "🚀 Uruchamianie i włączanie usługi ssh..." | tee -a "$LOGFILE"
  sudo systemctl enable ssh 2>&1 | tee -a "$LOGFILE"
  sudo systemctl restart ssh 2>&1 | tee -a "$LOGFILE"

  local target_user="${SUDO_USER:-$USER}"
  local target_home
  target_home=$(eval echo "~$target_user")

  mkdir -p "$target_home/.ssh"
  chmod 700 "$target_home/.ssh"
  chown "$target_user:$target_user" "$target_home/.ssh"

  # Generowanie klucza ed25519 dla GitHuba jeśli nie istnieje
  if [ ! -f "$target_home/.ssh/id_ed25519" ]; then
    echo "🔑 Generowanie klucza SSH ed25519..." | tee -a "$LOGFILE"
    sudo -u "$target_user" ssh-keygen -t ed25519 -C "$target_user@$(hostname)" -f "$target_home/.ssh/id_ed25519" -N "" 2>&1 | tee -a "$LOGFILE"
    echo "Twój publiczny klucz SSH ($target_home/.ssh/id_ed25519.pub):" | tee -a "$LOGFILE"
    cat "$target_home/.ssh/id_ed25519.pub" | tee -a "$LOGFILE"
  else
    echo "ℹ️ Klucz ~/.ssh/id_ed25519 już istnieje." | tee -a "$LOGFILE"
  fi

  echo "✅ Serwer OpenSSH skonfigurowany pomyślnie." | tee -a "$LOGFILE"
}
