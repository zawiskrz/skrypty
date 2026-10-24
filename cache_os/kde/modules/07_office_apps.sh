#!/bin/bash

configure_office_apps() {
    log_info "=== [7/13] Aplikacje biurowe i czytniki dokumentów ==="

    local office_pkgs=(
        libreoffice-fresh
        libreoffice-fresh-pl     # Pakiet języka polskiego dla LibreOffice
        hunspell-pl              # Słownik języka polskiego (korekta pisowni)
        mythes-pl                # Tezaurus języka polskiego
        okular                   # Przeglądarka dokumentów PDF/ePub w KDE
        calibre                  # Zarządzanie biblioteką e-booków
        thunderbird              # Klient poczty e-mail
    )
    install_pacman "${office_pkgs[@]}"

    log_info "✅ Pakiety biurowe zainstalowane."
}
