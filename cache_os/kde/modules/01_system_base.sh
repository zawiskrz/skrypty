#!/bin/bash

configure_system_base() {
    log_info "=== [1/13] Baza systemu, Paru i podstawowe narzędzia CLI ==="

    # 1. Sprawdzenie repozytorium multilib
    ensure_multilib

    # 2. Instalacja paru (AUR Helper)
    if ! command -v paru &>/dev/null; then
        log_step "Instalacja AUR helpera 'paru'..."
        sudo pacman -S --needed --noconfirm paru 2>&1 | tee -a "$LOGFILE"
    fi

    # 3. Podstawowe narzędzia CLI, terminalowe i monitoring
    local cli_pkgs=(
        fish
        cachyos-fish-config
        fastfetch
        btop
        htop
        micro
        mc
        ripgrep
        plocate
        duf
        rsync
        pv
        wget
        which
        diffutils
        unzip
        unrar
    )
    install_pacman "${cli_pkgs[@]}"

    # 4. Sprawdzenie powłoki domyślnej
    if [[ "$SHELL" != *"fish"* ]]; then
        log_step "Ustawianie powłoki fish dla użytkownika $USER..."
        chsh -s "$(which fish)" "$USER" 2>&1 | tee -a "$LOGFILE" || true
    fi

    log_info "✅ Baza systemu skonfigurowana."
}
