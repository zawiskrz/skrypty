#!/bin/bash

configure_samba() {
    log_info "=== [4/13] Serwer plików Samba (udziały Muzyka, Obrazy, Wideo) ==="

    local samba_pkgs=(
        samba
        cachyos-samba-settings
    )
    install_pacman "${samba_pkgs[@]}"

    local samba_user="${SAMBA_USER:-$USER}"
    local user_home
    user_home=$(eval echo "~$samba_user")

    # Tworzenie katalogów udostępnionych
    log_step "Tworzenie katalogów udostępnionych w $user_home..."
    mkdir -p "$user_home/Muzyka" "$user_home/Obrazy" "$user_home/Wideo"
    chmod 0770 "$user_home/Muzyka" "$user_home/Obrazy" "$user_home/Wideo"
    chown "$samba_user:$samba_user" "$user_home/Muzyka" "$user_home/Obrazy" "$user_home/Wideo"

    # Backup i konfiguracja /etc/samba/smb.conf
    log_step "Konfiguracja /etc/samba/smb.conf..."
    if [[ -f /etc/samba/smb.conf ]]; then
        sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.bak
    fi

    local smb_template="$SCRIPT_DIR/config/smb.conf.template"
    if [[ -f "$smb_template" ]]; then
        sed "s/__SAMBA_USER__/$samba_user/g" "$smb_template" | sudo tee /etc/samba/smb.conf > /dev/null
    else
        log_err "Brak szablonu $smb_template!"
    fi

    # Ustawienie hasła dla użytkownika Samby
    if [[ -z "$SAMBA_PASS" ]]; then
        read -s -p "🔑 Podaj hasło dla użytkownika Samba ($samba_user): " SAMBA_PASS
        echo
    fi

    if [[ -n "$SAMBA_PASS" ]]; then
        log_step "Dodawanie użytkownika $samba_user do bazy Samby..."
        echo -e "$SAMBA_PASS\n$SAMBA_PASS" | sudo smbpasswd -a -s "$samba_user" 2>&1 | tee -a "$LOGFILE"
        sudo smbpasswd -e "$samba_user" 2>&1 | tee -a "$LOGFILE"
    else
        log_warn "Pominięto ustawienie hasła Samby. Pamiętaj wykonać: sudo smbpasswd -a $samba_user"
    fi

    # Uruchomienie i włączenie usług w systemd (pod Arch/CachyOS: smb.service i nmb.service)
    log_step "Włączanie i restart usług smb.service oraz nmb.service..."
    sudo systemctl enable smb.service nmb.service 2>&1 | tee -a "$LOGFILE"
    sudo systemctl restart smb.service nmb.service 2>&1 | tee -a "$LOGFILE"

    log_info "✅ Serwer Samba skonfigurowany."
}
