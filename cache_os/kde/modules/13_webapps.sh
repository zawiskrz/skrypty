#!/bin/bash

configure_webapps() {
    log_info "=== [13/13] Aplikacje internetowe WebApps (WebApp-Manager i serwisy VOD/Teams) ==="

    # 1. Instalacja WebApp-Manager
    if pacman -Si webapp-manager &>/dev/null; then
        install_pacman webapp-manager
    else
        install_aur webapp-manager
    fi

    local ice_icons_dir="$HOME/.local/share/ice/icons"
    local app_dir="$HOME/.local/share/applications"

    mkdir -p "$ice_icons_dir" "$app_dir"

    # 2. Kopiowanie ikon serwisów (Canal, Disney, Max, Netflix, Teams, YouTube itp.)
    local source_icons="$SCRIPT_DIR/local/ice/icons"
    if [[ -d "$source_icons" ]]; then
        log_step "Kopiowanie ikon do $ice_icons_dir..."
        cp -f "$source_icons"/*.png "$ice_icons_dir/" 2>/dev/null || true
    fi

    # 3. Kopiowanie skrótów .desktop i dostosowanie ścieżek do bieżącego użytkownika
    local source_apps="$SCRIPT_DIR/local/applications"
    if [[ -d "$source_apps" ]]; then
        log_step "Instalacja skrótów WebApp w $app_dir..."
        for desktop_file in "$source_apps"/WebApp-*.desktop; do
            if [[ -f "$desktop_file" ]]; then
                local filename
                filename=$(basename "$desktop_file")
                # Zastępujemy placeholder __HOME__ ścieżką katalogu domowego bieżącego użytkownika
                sed -e "s|__HOME__|$HOME|g" -e "s|/home/[^/]*|$HOME|g" "$desktop_file" > "$app_dir/$filename"
                chmod +x "$app_dir/$filename"
            fi
        done
        update-desktop-database "$app_dir" 2>/dev/null || true
    fi

    log_info "✅ Aplikacje WebApps skonfigurowane."
}
