#!/bin/bash

configure_kde_environment() {
    log_info "=== [2/13] Środowisko KDE Plasma, integracje i konfiguracja pulpitu ==="

    # 1. Pakiety integracyjne KDE
    local kde_pkgs=(
        kdeconnect
        sshfs                    # Niezbędne do przeglądania plików telefonu w Dolphinie przez KDE Connect
        kio-gdrive               # Obsługa Dysku Google w menedżerze plików Dolphin
        kaccounts-providers      # Dostawcy kont sieciowych (Google, Microsoft)
        kdepim-addons            # Wtyczki PIM (m.in. kalendarz Google w widgecie zegara)
        merkuro                  # Aplikacja kalendarza i kontaktów KDE
        plasma-applets-weather-widget-3  # Widget pogodowy (OpenWeatherMap)
        kdenetwork-filesharing   # Udostępnianie folderów z menu podręcznego Dolphina
        plasma-firewall          # Moduł zapory ogniowej w Ustawieniach Systemowych KDE
        kio-admin                # Obsługa uprawnień roota w Dolphinie (Edytuj jako administrator)
        ffmpegthumbs             # Miniatury wideo w Dolphinie
        kdegraphics-thumbnailers # Miniatury grafik
    )
    install_pacman "${kde_pkgs[@]}"

    # 2. Konfiguracja KWin (Kafelkowanie okien, Night Color, Wirtualne pulpity)
    log_step "Konfiguracja menedżera okien KWin..."
    if command -v kwriteconfig6 &>/dev/null; then
        # 2 wirtualne pulpity
        kwriteconfig6 --file kwinrc --group Desktops --key Number 2
        kwriteconfig6 --file kwinrc --group Desktops --key Rows 1

        # Ochrona wzroku (Night Color - 3400K)
        kwriteconfig6 --file kwinrc --group NightColor --key Active true
        kwriteconfig6 --file kwinrc --group NightColor --key NightTemperature 3400

        # Skrót do edycji kafelkowania (Meta+T)
        kwriteconfig6 --file kglobalshortcutsrc --group kwin --key "Edit Tiles" "Meta+T,Meta+T,Przełącz edytora kafelków"

        # Dolphin: Ukrycie paska menu, stały rozmiar ikon w panelu miejsc (22px)
        kwriteconfig6 --file dolphinrc --group MainWindow --key MenuBar Disabled
        kwriteconfig6 --file dolphinrc --group "KFileDialog Settings" --key "Places Icons Auto-resize" false
        kwriteconfig6 --file dolphinrc --group "KFileDialog Settings" --key "Places Icons Static Size" 22
    else
        log_warn "Polecenie kwriteconfig6 nie jest dostępne. Pomijam modyfikację plików konfiguracyjnych KDE."
    fi

    # 3. Konfiguracja miejscowości w widgecie pogody (OpenWeatherMap)
    local plasma_appletsrc="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
    local weather_json="$SCRIPT_DIR/config/weather_places.json"

    if [[ -f "$plasma_appletsrc" && -f "$weather_json" ]]; then
        log_step "Konfiguracja miejscowości w widgecie pogody (Skierniewice i inne)..."
        # Sprawdzamy czy widget pogody jest już dodany do pliku konfiguracyjnego
        if grep -q "plugin=org.kde.weatherWidget-3" "$plasma_appletsrc"; then
            local places_content
            places_content=$(tr -d '\n' < "$weather_json" | sed 's/ //g')
            # Podmiana parametru places w sekcji widgetu pogody
            sed -i "/\[org.kde.weatherWidget-3\]/,/\[/ s|^places=.*|places=${places_content}|" "$plasma_appletsrc" 2>/dev/null || true
        fi
    fi

    log_info "✅ Środowisko KDE Plasma skonfigurowane."
}
