#!/bin/bash
# ==============================================================================
# Moduł 14: Tworzenie prywatnej kopii zapasowej tożsamości i konfiguracji
# ==============================================================================

create_private_backup() {
    log_info "=== [BACKUP] Tworzenie prywatnej kopii zapasowej (SSH, KWallet, Wi-Fi, Konta) ==="

    local default_name="cachyos_kde_private_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    local target_dir="$HOME"

    # Wykrywanie zamontowanych nośników USB (pendrive)
    local usb_mounts=()
    if [[ -d "/run/media/$USER" ]]; then
        while IFS= read -r -d '' mount_point; do
            usb_mounts+=("$mount_point")
        done < <(find "/run/media/$USER" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null)
    fi

    echo
    if [[ ${#usb_mounts[@]} -gt 0 ]]; then
        echo "💾 Wykryto podłączony pendrive: ${usb_mounts[0]}"
        read -r -p "Czy zapisać kopię bezpośrednio na pendrive? [T/n]: " ans_usb
        if [[ "$ans_usb" =~ ^[Nn]$ ]]; then
            target_dir="$HOME"
        else
            target_dir="${usb_mounts[0]}"
        fi
    else
        echo "ℹ️ Nie wykryto zamontowanego pendrive'a w /run/media/$USER."
    fi

    read -r -p "Podaj ścieżkę zapisu archiwum [Domyślnie: $target_dir/$default_name]: " custom_path
    local backup_file="${custom_path:-$target_dir/$default_name}"

    # Pytanie o profile WebApp (mogą zajmować od 500MB do 2GB ze względu na cache przeglądarki)
    local include_webapps=false
    if [[ -d "$HOME/.local/share/ice/profiles" ]]; then
        echo
        echo "Aplikacje WebApp (Netflix, Teams, Disney+ itp.) posiadają zapisane sesje logowania."
        read -r -p "Czy dołączyć sesje WebApp do kopii (zwiększy rozmiar archiwum o kilkaset MB)? [t/N]: " ans_webapps
        if [[ "$ans_webapps" =~ ^[TtYy]$ ]]; then
            include_webapps=true
        fi
    fi

    # Tworzenie tymczasowego katalogu roboczego
    local temp_dir
    temp_dir=$(mktemp -d /tmp/cachyos_backup_XXXXXX)
    local data_dir="$temp_dir/data"
    mkdir -p "$data_dir"

    log_step "Kopiowanie kluczy SSH..."
    if [[ -d "$HOME/.ssh" ]]; then
        cp -a "$HOME/.ssh" "$data_dir/"
    fi

    log_step "Kopiowanie konfiguracji Git..."
    if [[ -f "$HOME/.gitconfig" ]]; then
        cp -a "$HOME/.gitconfig" "$data_dir/"
    fi

    log_step "Kopiowanie portfela haseł KDE (KWallet)..."
    if [[ -d "$HOME/.local/share/kwalletd" ]]; then
        mkdir -p "$data_dir/kwalletd"
        cp -a "$HOME/.local/share/kwalletd/." "$data_dir/kwalletd/"
    fi

    log_step "Kopiowanie kont sieciowych (Google/Microsoft OAuth)..."
    if [[ -d "$HOME/.config/goa-1.0" ]]; then
        mkdir -p "$data_dir/goa-1.0"
        cp -a "$HOME/.config/goa-1.0/." "$data_dir/goa-1.0/"
    fi
    if [[ -d "$HOME/.config/libaccounts-glib" ]]; then
        mkdir -p "$data_dir/libaccounts-glib"
        cp -a "$HOME/.config/libaccounts-glib/." "$data_dir/libaccounts-glib/"
    fi

    log_step "Kopiowanie profili połączeń Wi-Fi..."
    if sudo test -d "/etc/NetworkManager/system-connections"; then
        mkdir -p "$data_dir/wifi_connections"
        sudo cp -a /etc/NetworkManager/system-connections/. "$data_dir/wifi_connections/" 2>/dev/null || true
        sudo chown -R "$USER:$USER" "$data_dir/wifi_connections" 2>/dev/null || true
    fi

    if [[ "$include_webapps" == "true" ]]; then
        log_step "Kopiowanie sesji WebApp..."
        mkdir -p "$data_dir/ice_profiles"
        cp -a "$HOME/.local/share/ice/profiles/." "$data_dir/ice_profiles/"
    fi

    # Pakowanie archiwum
    log_step "Kompresowanie archiwum do $backup_file..."
    tar -czf "$backup_file" -C "$temp_dir" data
    chmod 600 "$backup_file"

    # Czyszczenie katalogu tymczasowego
    rm -rf "$temp_dir"

    echo
    log_info "🎉 Prywatna kopia zapasowa została pomyślnie utworzona!"
    echo "Lokalizacja: $backup_file"
    echo "Rozmiar: $(du -h "$backup_file" | cut -f1)"
    echo "Uprawnienia pliku ustawiono na 600 (tylko do odczytu przez właściciela)."
    echo "Pamiętaj, aby bezpiecznie przechować ten plik na pendrive i NIE umieszczać go w repozytorium GitHub!"
    echo "=========================================================="
}

# Jeśli skrypt uruchomiono bezpośrednio
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    source "$SCRIPT_DIR/config.sh"
    create_private_backup
fi
