#!/bin/bash

install_user_apps() {
  echo "🎯 Instalacja oprogramowania użytkowego (APT)..." | tee -a "$LOGFILE"

  sudo apt update
  sudo apt install -y --no-install-recommends \
    flatpak thunar thunar-archive-plugin file-roller gvfs-backends \
    menulibre vlc calibre rhythmbox rhythmbox-plugins rhythmbox-plugin-alternative-toolbar shotwell \
    libreoffice libreoffice-l10n-pl libreoffice-help-pl hunspell-pl hyphen-pl mythes-pl \
    libreoffice-base libreoffice-java-common default-jre libreoffice-gtk3 \
    wxmaxima mc htop wget curl gnome-boxes mpv \
    kdeconnect sshfs \
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

  local base_dir="${SCRIPT_DIR:-.}"

  # Kopiowanie bazy danych/playlist Rhythmbox
  local rhythmbox_dir="$base_dir/local/rhythmbox"
  [ -d "$rhythmbox_dir" ] || rhythmbox_dir="local/rhythmbox"
  if [ -d "$rhythmbox_dir" ]; then
    echo "🗂️ Zamykanie Rhythmbox i kopiowanie playlist..." | tee -a "$LOGFILE"
    killall rhythmbox 2>/dev/null || true
    mkdir -p "$REAL_HOME/.local/share/rhythmbox"
    cp -rf "$rhythmbox_dir"/* "$REAL_HOME/.local/share/rhythmbox/" 2>/dev/null || true
    chown -R "$REAL_USER:$REAL_USER" "$REAL_HOME/.local/share/rhythmbox"
  fi

  # Kopiowanie ikon WebApps (ICE)
  local ice_icons_dir="$base_dir/local/ice/icons"
  [ -d "$ice_icons_dir" ] || ice_icons_dir="local/ice/icons"
  if [ -d "$ice_icons_dir" ]; then
    echo "🎨 Kopiowanie ikon WebApp do ~/.local/share/ice/icons..." | tee -a "$LOGFILE"
    mkdir -p "$REAL_HOME/.local/share/ice/icons"
    cp -rf "$ice_icons_dir"/*.png "$REAL_HOME/.local/share/ice/icons/" 2>/dev/null || true
    chown -R "$REAL_USER:$REAL_USER" "$REAL_HOME/.local/share/ice"
  fi

  # Kopiowanie i dopasowanie skrótów aplikacji użytkownika
  local apps_dir="$base_dir/local/applications"
  [ -d "$apps_dir" ] || apps_dir="local/applications"
  if [ -d "$apps_dir" ]; then
    echo "🖥️ Kopiowanie skrótów aplikacji do ~/.local/share/applications..." | tee -a "$LOGFILE"
    mkdir -p "$REAL_HOME/.local/share/applications"
    for df in "$apps_dir"/*.desktop; do
      [ -f "$df" ] || continue
      fname=$(basename "$df")
      sed "s|/home/\$USER|$REAL_HOME|g; s|\$USER|$REAL_USER|g" "$df" > "$REAL_HOME/.local/share/applications/$fname"
    done
    chown -R "$REAL_USER:$REAL_USER" "$REAL_HOME/.local/share/applications"
    update-desktop-database "$REAL_HOME/.local/share/applications" 2>/dev/null || true
  fi

  echo "✅ Wszystkie aplikacje użytkownika zostały zainstalowane i skonfigurowane." | tee -a "$LOGFILE"
}
