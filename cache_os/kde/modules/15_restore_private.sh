#!/bin/bash
# ==============================================================================
# Moduł 15: Odtwarzanie prywatnej kopii zapasowej tożsamości i konfiguracji
# ==============================================================================

restore_private_backup() {
    log_info "=== [RESTORE] Przywracanie prywatnej kopii zapasowej z pliku/pendrive'a ==="

    local found_backups=()

    # Wyszukiwanie kopii na podłączonych pendrive'ach
    if [[ -d "/run/media/$USER" ]]; then
        while IFS= read -r -d '' f; do
            found_backups+=("$f")
        done < <(find "/run/media/$USER" -type f -name "*cachyos_kde_private_backup*.tar.gz" -o -name "*moj_backup*.tar.gz" -print0 2>/dev/null)
    fi

    # Wyszukiwanie w katalogu domowym i bieżącym
    while IFS= read -r -d '' f; do
        found_backups+=("$f")
    done < <(find "$HOME" -maxdepth 2 -type f -name "*cachyos_kde_private_backup*.tar.gz" -o -name "*moj_backup*.tar.gz" -print0 2>/dev/null)

    local backup_file=""
    if [[ ${#found_backups[@]} -gt 0 ]]; then
        echo
        echo "🔍 Znaleziono potencjalne pliki kopii zapasowej:"
        local idx=1
        for f in "${found_backups[@]}"; do
            echo "  [$idx] $f ($(du -h "$f" | cut -f1))"
            ((idx++))
        done
        echo "  [0] Wpisz inną ścieżkę ręcznie"
        read -r -p "Wybierz numer pliku [1]: " choice
        choice="${choice:-1}"
        if [[ "$choice" -ge 1 && "$choice" -le ${#found_backups[@]} ]]; then
            backup_file="${found_backups[$((choice - 1))]}"
        fi
    fi

    if [[ -z "$backup_file" ]]; then
        read -r -p "Podaj pełną ścieżkę do pliku kopii (*.tar.gz): " backup_file
    fi

    if [[ ! -f "$backup_file" ]]; then
        log_err "Plik $backup_file nie istnieje!"
        return 1
    fi

    log_step "Weryfikacja spójności archiwum $backup_file..."
    if ! tar -tzf "$backup_file" &>/dev/null; then
        log_err "Plik $backup_file nie jest prawidłowym archiwum tar.gz!"
        return 1
    fi

    # Rozpakowanie do katalogu tymczasowego
    local temp_dir
    temp_dir=$(mktemp -d /tmp/cachyos_restore_XXXXXX)
    tar -xzf "$backup_file" -C "$temp_dir"

    local data_dir="$temp_dir/data"
    if [[ ! -d "$data_dir" ]]; then
        # Jeśli archiwum nie miało prefiksu data/
        data_dir="$temp_dir"
    fi

    # 1. Przywracanie kluczy SSH
    if [[ -d "$data_dir/.ssh" ]]; then
        log_step "Przywracanie kluczy SSH..."
        mkdir -p "$HOME/.ssh"
        cp -a "$data_dir/.ssh/." "$HOME/.ssh/"
        chmod 700 "$HOME/.ssh"
        chmod 600 "$HOME/.ssh"/id_* 2>/dev/null || true
        chmod 644 "$HOME/.ssh"/*.pub 2>/dev/null || true
        chmod 600 "$HOME/.ssh"/authorized_keys* 2>/dev/null || true
        chmod 644 "$HOME/.ssh"/known_hosts* 2>/dev/null || true
        log_info "Klucze SSH przywrócone z zachowaniem rygorystycznych uprawnień bezpieczeństwa."
    fi

    # 2. Przywracanie konfiguracji Git
    if [[ -f "$data_dir/.gitconfig" ]]; then
        log_step "Przywracanie konfiguracji Git (~/.gitconfig)..."
        cp -a "$data_dir/.gitconfig" "$HOME/.gitconfig"
    fi

    # 3. Przywracanie KWallet (portfel KDE)
    if [[ -d "$data_dir/kwalletd" ]]; then
        log_step "Przywracanie portfela haseł KDE (KWallet)..."
        mkdir -p "$HOME/.local/share/kwalletd"
        cp -a "$data_dir/kwalletd/." "$HOME/.local/share/kwalletd/"
        chmod 700 "$HOME/.local/share/kwalletd"
        chmod 600 "$HOME/.local/share/kwalletd"/* 2>/dev/null || true
    fi

    # 4. Przywracanie kont sieciowych (Google / Microsoft OAuth)
    if [[ -d "$data_dir/goa-1.0" ]]; then
        log_step "Przywracanie kont internetowych (goa-1.0)..."
        mkdir -p "$HOME/.config/goa-1.0"
        cp -a "$data_dir/goa-1.0/." "$HOME/.config/goa-1.0/"
    fi
    if [[ -d "$data_dir/libaccounts-glib" ]]; then
        log_step "Przywracanie bazy kont KDE (libaccounts-glib)..."
        mkdir -p "$HOME/.config/libaccounts-glib"
        cp -a "$data_dir/libaccounts-glib/." "$HOME/.config/libaccounts-glib/"
    fi

    # 5. Przywracanie profili Wi-Fi (wymaga sudo)
    if [[ -d "$data_dir/wifi_connections" && "$(ls -A "$data_dir/wifi_connections" 2>/dev/null)" ]]; then
        log_step "Przywracanie zapisanych połączeń Wi-Fi..."
        sudo cp -a "$data_dir/wifi_connections/." /etc/NetworkManager/system-connections/
        sudo chown -R root:root /etc/NetworkManager/system-connections/
        sudo chmod 600 /etc/NetworkManager/system-connections/* 2>/dev/null || true
        log_step "Restart usługi NetworkManager w celu wczytania sieci Wi-Fi..."
        sudo systemctl restart NetworkManager 2>&1 | tee -a "$LOGFILE" || true
        log_info "Profile Wi-Fi zostały przywrócone."
    fi

    # 6. Przywracanie sesji WebApps
    if [[ -d "$data_dir/ice_profiles" ]]; then
        log_step "Przywracanie sesji aplikacji WebApp..."
        mkdir -p "$HOME/.local/share/ice/profiles"
        cp -a "$data_dir/ice_profiles/." "$HOME/.local/share/ice/profiles/"
    fi

    # Czyszczenie katalogu tymczasowego
    rm -rf "$temp_dir"

    echo
    log_info "🎉 Wszystkie dane prywatne zostały pomyślnie przywrócone!"
    echo "=========================================================="
}

# Jeśli skrypt uruchomiono bezpośrednio
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    source "$SCRIPT_DIR/config.sh"
    restore_private_backup
fi
