#!/bin/bash

configure_multimedia() {
    log_info "=== [9/13] Multimedia, odtwarzacze, kodeki i pakiety Flatpak ==="

    local media_pkgs=(
        vlc
        vlc-plugins-all
        phonon-qt6-vlc
        libdvdcss
        haruna                   # Nowoczesny odtwarzacz wideo dla KDE (oparty o MPV)
        elisa                    # Odtwarzacz muzyki KDE
        gwenview                 # Przeglądarka obrazów KDE
        handbrake                # Transkoder wideo
        gst-libav
        gst-plugins-bad
        gst-plugins-ugly
        gst-plugin-pipewire
        gst-plugin-va
        flatpak
    )
    install_pacman "${media_pkgs[@]}"

    # Pobieracz wideo (videodownloader z repo lub AUR)
    if pacman -Si videodownloader &>/dev/null; then
        install_pacman videodownloader
    else
        install_aur videodownloader
    fi

    # Dodanie repozytorium Flathub i instalacja aplikacji Flatpak
    if command -v flatpak &>/dev/null; then
        log_step "Konfiguracja Flathub i aplikacji Flatpak..."
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo 2>&1 | tee -a "$LOGFILE" || true

        local flatpaks=(
            app.ytmdesktop.ytmdesktop       # YouTube Music Desktop
            com.ktechpit.whatsie            # WhatsApp (Whatsie)
            com.github.unrud.VideoDownloader
        )
        for fp in "${flatpaks[@]}"; do
            log_step "Instalacja Flatpak: $fp..."
            flatpak install -y flathub "$fp" 2>&1 | tee -a "$LOGFILE" || true
        done
    fi

    log_info "✅ Multimedia skonfigurowane."
}
