#!/bin/bash
# ==============================================================================
# Moduł tworzenia i odtwarzania prywatnej kopii zapasowej dla Debiana
# ==============================================================================

create_private_backup() {
  echo "💾 === [BACKUP] Tworzenie prywatnej kopii zapasowej (SSH, Wi-Fi, Git, Konta) ===" | tee -a "$LOGFILE"

  local target_user="${SUDO_USER:-$USER}"
  local target_home
  target_home=$(eval echo "~$target_user")

  local default_name="debian_private_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
  local target_dir="$target_home"

  # Wykrywanie pendrive'a w /media/$target_user lub /run/media/$target_user
  local usb_mounts=()
  for p in "/media/$target_user" "/run/media/$target_user"; do
    if [ -d "$p" ]; then
      while IFS= read -r -d '' mount_point; do
        usb_mounts+=("$mount_point")
      done < <(find "$p" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null)
    fi
  done

  echo
  if [ ${#usb_mounts[@]} -gt 0 ]; then
    echo "💾 Wykryto podłączony pendrive: ${usb_mounts[0]}"
    read -r -p "Czy zapisać kopię bezpośrednio na pendrive? [T/n]: " ans_usb
    if [[ ! "$ans_usb" =~ ^[Nn]$ ]]; then
      target_dir="${usb_mounts[0]}"
    fi
  fi

  read -r -p "Podaj ścieżkę zapisu archiwum [Domyślnie: $target_dir/$default_name]: " custom_path
  local backup_file="${custom_path:-$target_dir/$default_name}"

  local temp_dir
  temp_dir=$(mktemp -d /tmp/debian_backup_XXXXXX)
  local data_dir="$temp_dir/data"
  mkdir -p "$data_dir"

  echo ":: Kopiowanie kluczy SSH..." | tee -a "$LOGFILE"
  [ -d "$target_home/.ssh" ] && cp -a "$target_home/.ssh" "$data_dir/"

  echo ":: Kopiowanie konfiguracji Git..." | tee -a "$LOGFILE"
  [ -f "$target_home/.gitconfig" ] && cp -a "$target_home/.gitconfig" "$data_dir/"

  echo ":: Kopiowanie haseł portfela / keyring..." | tee -a "$LOGFILE"
  [ -d "$target_home/.local/share/kwalletd" ] && cp -a "$target_home/.local/share/kwalletd" "$data_dir/"
  [ -d "$target_home/.local/share/keyrings" ] && cp -a "$target_home/.local/share/keyrings" "$data_dir/"

  echo ":: Kopiowanie profili połączeń Wi-Fi..." | tee -a "$LOGFILE"
  if sudo test -d "/etc/NetworkManager/system-connections"; then
    mkdir -p "$data_dir/wifi_connections"
    sudo cp -a /etc/NetworkManager/system-connections/. "$data_dir/wifi_connections/" 2>/dev/null || true
    sudo chown -R "$target_user:$target_user" "$data_dir/wifi_connections" 2>/dev/null || true
  fi

  echo ":: Kompresowanie archiwum do $backup_file..." | tee -a "$LOGFILE"
  tar -czf "$backup_file" -C "$temp_dir" data
  chmod 600 "$backup_file"
  rm -rf "$temp_dir"

  echo "🎉 Prywatna kopia zapasowa została pomyślnie utworzona w: $backup_file" | tee -a "$LOGFILE"
}

restore_private_backup() {
  echo "📥 === [RESTORE] Przywracanie prywatnej kopii zapasowej ===" | tee -a "$LOGFILE"

  local target_user="${SUDO_USER:-$USER}"
  local target_home
  target_home=$(eval echo "~$target_user")

  local found_backups=()
  for p in "/media/$target_user" "/run/media/$target_user" "$target_home"; do
    if [ -d "$p" ]; then
      while IFS= read -r -d '' f; do
        found_backups+=("$f")
      done < <(find "$p" -maxdepth 2 -type f -name "*backup*.tar.gz" -print0 2>/dev/null)
    fi
  done

  local backup_file=""
  if [ ${#found_backups[@]} -gt 0 ]; then
    echo "🔍 Znaleziono potencjalne pliki kopii zapasowej:"
    local idx=1
    for f in "${found_backups[@]}"; do
      echo "  [$idx] $f ($(du -h "$f" | cut -f1))"
      ((idx++))
    done
    echo "  [0] Wpisz inną ścieżkę ręcznie"
    read -r -p "Wybierz numer pliku [1]: " choice
    choice="${choice:-1}"
    if [ "$choice" -ge 1 ] && [ "$choice" -le ${#found_backups[@]} ]; then
      backup_file="${found_backups[$((choice - 1))]}"
    fi
  fi

  if [ -z "$backup_file" ]; then
    read -r -p "Podaj pełną ścieżkę do pliku kopii (*.tar.gz): " backup_file
  fi

  if [ ! -f "$backup_file" ]; then
    echo "❌ Plik $backup_file nie istnieje!" | tee -a "$LOGFILE"
    return 1
  fi

  local temp_dir
  temp_dir=$(mktemp -d /tmp/debian_restore_XXXXXX)
  tar -xzf "$backup_file" -C "$temp_dir"

  local data_dir="$temp_dir/data"
  [ ! -d "$data_dir" ] && data_dir="$temp_dir"

  # Przywracanie SSH
  if [ -d "$data_dir/.ssh" ]; then
    echo ":: Przywracanie kluczy SSH..." | tee -a "$LOGFILE"
    mkdir -p "$target_home/.ssh"
    cp -a "$data_dir/.ssh/." "$target_home/.ssh/"
    chmod 700 "$target_home/.ssh"
    chmod 600 "$target_home/.ssh"/id_* 2>/dev/null || true
    chmod 644 "$target_home/.ssh"/*.pub 2>/dev/null || true
    chmod 600 "$target_home/.ssh"/authorized_keys* 2>/dev/null || true
    chown -R "$target_user:$target_user" "$target_home/.ssh"
  fi

  # Przywracanie Git
  if [ -f "$data_dir/.gitconfig" ]; then
    echo ":: Przywracanie ~/.gitconfig..." | tee -a "$LOGFILE"
    cp -a "$data_dir/.gitconfig" "$target_home/.gitconfig"
    chown "$target_user:$target_user" "$target_home/.gitconfig"
  fi

  # Przywracanie Wi-Fi
  if [ -d "$data_dir/wifi_connections" ] && [ "$(ls -A "$data_dir/wifi_connections" 2>/dev/null)" ]; then
    echo ":: Przywracanie profili Wi-Fi..." | tee -a "$LOGFILE"
    sudo cp -a "$data_dir/wifi_connections/." /etc/NetworkManager/system-connections/
    sudo chown -R root:root /etc/NetworkManager/system-connections/
    sudo chmod 600 /etc/NetworkManager/system-connections/* 2>/dev/null || true
    sudo systemctl restart NetworkManager 2>/dev/null || true
  fi

  # Przywracanie portfeli
  if [ -d "$data_dir/kwalletd" ]; then
    mkdir -p "$target_home/.local/share/kwalletd"
    cp -a "$data_dir/kwalletd/." "$target_home/.local/share/kwalletd/"
    chown -R "$target_user:$target_user" "$target_home/.local/share/kwalletd"
  fi
  if [ -d "$data_dir/keyrings" ]; then
    mkdir -p "$target_home/.local/share/keyrings"
    cp -a "$data_dir/keyrings/." "$target_home/.local/share/keyrings/"
    chown -R "$target_user:$target_user" "$target_home/.local/share/keyrings"
  fi

  rm -rf "$temp_dir"
  echo "🎉 Przywracanie zakończone pomyślnie!" | tee -a "$LOGFILE"
}
