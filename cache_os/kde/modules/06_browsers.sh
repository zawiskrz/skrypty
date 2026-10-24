#!/bin/bash

configure_browsers() {
    log_info "=== [6/13] Przeglądarki internetowe (Firefox, Chrome, Edge) ==="

    # 1. Firefox i integracja z KDE Plasma
    local repo_pkgs=(
        firefox
        firefox-i18n-pl
        plasma-browser-integration
    )
    install_pacman "${repo_pkgs[@]}"

    # 2. Google Chrome i Microsoft Edge z AUR
    local aur_pkgs=(
        google-chrome
        microsoft-edge-stable-bin
    )
    install_aur "${aur_pkgs[@]}"

    log_info "✅ Przeglądarki zainstalowane."
}
