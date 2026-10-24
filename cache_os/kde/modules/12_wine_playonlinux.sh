#!/bin/bash

configure_wine_playonlinux() {
    log_info "=== [12/13] PlayOnLinux, Wine i biblioteki 32-bit (wsparcie MS Office / Excel) ==="

    ensure_multilib

    # Biblioteki 32-bitowe niezbędne do działania aplikacji 32-bit w Wine / PlayOnLinux
    local wine32_pkgs=(
        lib32-mesa
        lib32-vulkan-intel
        lib32-opencl-mesa
        lib32-alsa-lib
        lib32-libpulse
        lib32-fontconfig
        lib32-freetype2
        lib32-lcms2
        lib32-libpng
        lib32-libxcomposite
        lib32-libxcursor
        lib32-libxi
        lib32-libxinerama
        lib32-libxrandr
        lib32-libxrender
    )
    install_pacman "${wine32_pkgs[@]}"

    # PlayOnLinux
    if pacman -Si playonlinux &>/dev/null; then
        install_pacman playonlinux
    else
        install_aur playonlinux
    fi

    # Kopiowanie skrótów menulibre dla pakietu Office (Word, Excel, PowerPoint)
    local app_dir="$HOME/.local/share/applications"
    mkdir -p "$app_dir"
    local local_apps="$SCRIPT_DIR/local/applications"

    if [[ -d "$local_apps" ]]; then
        log_step "Kopiowanie skrótów pulpitowych dla Microsoft Office..."
        for desktop_file in "$local_apps"/menulibre-microsoft-*.desktop; do
            if [[ -f "$desktop_file" ]]; then
                cp "$desktop_file" "$app_dir/"
            fi
        done
        update-desktop-database "$app_dir" 2>/dev/null || true
    fi

    log_info "✅ PlayOnLinux i biblioteki 32-bitowe skonfigurowane."
}
