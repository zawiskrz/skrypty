#!/bin/bash
install_user_apps() {
  echo "🎯 Instalacja dodatkowego oprogramowania użytkowego..." | tee -a "$LOGFILE"
  sudo apt install -y \
    menulibre thunderbird vlc calibre rhythmbox shotwell \
    libreoffice-l10n-pl libreoffice-help-pl \
    wxmaxima python3 python3-pip python3-venv \
    mc htop wget curl gnome-boxes \
    remmina filezilla google-chrome-stable \
    transmission 2>&1 | tee -a "$LOGFILE"
}

install_webapp_manager() {
    set -e  # Zatrzymaj skrypt przy pierwszym błędzie

    echo "🌐 Rozpoczynam instalację WebApp Managera..." | tee -a "$LOGFILE"

    # 🔽 Pobierz najnowszy pakiet z repozytorium Linux Mint
    echo "📥 Pobieranie pakietu webapp-manager_1.4.3_all.deb..." | tee -a "$LOGFILE"
    wget "$WEB_APP_MANAGER" -O webapp-manager.deb  2>&1 | tee -a "$LOGFILE"

    # 🧱 Instalacja WebApp Managera
    echo "📦 Instalacja WebApp Managera z pobranego pakietu..." | tee -a "$LOGFILE"
    sudo gdebi -n webapp-manager.deb 2>&1 | tee -a "$LOGFILE"

    # 🧹 Sprzątanie
    echo "🧹 Usuwanie pobranego pliku .deb..." | tee -a "$LOGFILE"
    rm -f webapp-manager.deb

    # 🚀 Uruchomienie testowe
    echo "🚀 Próba uruchomienia aplikacji..." | tee -a "$LOGFILE"
    if command -v webapp-manager >/dev/null; then
        echo "✅ WebApp Manager został pomyślnie zainstalowany i jest dostępny jako 'webapp-manager'." | tee -a "$LOGFILE"
    else
        echo "❌ Instalacja zakończona, ale aplikacja nie jest dostępna w PATH. Sprawdź logi." | tee -a "$LOGFILE"
    fi
}

configure_user_apps() {
  install_user_apps
  install_webapp_manager
  echo "🗂️ Kopiowanie konfiguracji rhythmbox..." | tee -a "$LOGFILE"
  install -d "/home/$(logname)/.local/share/rhythmbox"
  cp -f local/rhythmbox/* "/home/$(logname)/.local/share/rhythmbox/"
  echo "✅ Dodatkowe oprogramowanie użytkowe zostało zainstalowane i skonfigurowane." | tee -a "$LOGFILE"
}