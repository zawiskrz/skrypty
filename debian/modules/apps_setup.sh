#!/bin/bash

install_user_apps() {
  echo "🎯 Instalacja oprogramowania użytkowego (APT)..." | tee -a "$LOGFILE"

  sudo apt update
  sudo apt install -y --no-install-recommends \
    flatpak thunar thunar-archive-plugin file-roller gvfs-backends \
    menulibre vlc calibre rhythmbox rhythmbox-plugins rhythmbox-plugin-alternative-toolbar shotwell \
    libreoffice libreoffice-l10n-pl libreoffice-help-pl hunspell-pl hyphen-pl mythes-pl \
    libreoffice-base libreoffice-java-common default-jre libreoffice-gtk3 \
    wxmaxima mc htop wget curl gnome-boxes \
    filezilla transmission-gtk gdebi-core 2>&1 | tee -a "$LOGFILE"
}

install_webapp_manager() {
  echo "🌐 Instalacja WebApp Manager..." | tee -a "$LOGFILE"

  if [ -n "$WEB_APP_MANAGER" ]; then
    wget "$WEB_APP_MANAGER" -O /tmp/webapp-manager.deb 2>&1 | tee -a "$LOGFILE"
    sudo gdebi -n /tmp/webapp-manager.deb 2>&1 | tee -a "$LOGFILE"
    rm -f /tmp/webapp-manager.deb
    echo "✅ WebApp Manager zainstalowany." | tee -a "$LOGFILE"
  else
    echo "⚠️ Brak zmiennej WEB_APP_MANAGER w config.sh, pomijam." | tee -a "$LOGFILE"
  fi
}

install_flatpak_apps() {
  echo "📦 Dodawanie repozytorium Flathub i instalacja aplikacji..." | tee -a "$LOGFILE"

  sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo 2>&1 | tee -a "$LOGFILE"

  sudo flatpak install -y flathub \
    com.github.IsmaelMartinez.teams_for_linux \
    com.ktechpit.whatsie \
    app.ytmdesktop.ytmdesktop \
    com.github.unrud.VideoDownloader \
    io.github.amit9838.mousam \
    io.missioncenter.MissionCenter \
    com.playonlinux.PlayOnLinux4 2>&1 | tee -a "$LOGFILE"
}

configure_apps() {
  install_user_apps
  install_webapp_manager
  install_flatpak_apps

  REAL_USER="${SUDO_USER:-$(logname)}"
  REAL_HOME=$(eval echo "~$REAL_USER")

  # Kopiowanie bazy danych/playlist Rhythmbox
  if [ -d "local/rhythmbox" ]; then
    echo "🗂️ Zamykanie Rhythmbox i kopiowanie bazy oraz playlist..." | tee -a "$LOGFILE"
    killall rhythmbox 2>/dev/null || true
    
    mkdir -p "$REAL_HOME/.local/share/rhythmbox"
    cp -rf local/rhythmbox/* "$REAL_HOME/.local/share/rhythmbox/"
    chown -R "$REAL_USER:$REAL_USER" "$REAL_HOME/.local/share/rhythmbox"
  fi

  echo "✅ Wszystkie aplikacje użytkownika zostały zainstalowane i skonfigurowane." | tee -a "$LOGFILE"
}
