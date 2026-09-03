#!/bin/bash

configure_librewolf() {
  echo "🦊 Instalacja przeglądarki LibreWolf oraz klienta Thunderbird..." | tee -a "$LOGFILE"

  sudo apt install -y --no-install-recommends extrepo | tee -a "$LOGFILE"
  sudo extrepo enable librewolf
  sudo apt update

  sudo apt install -y --no-install-recommends \
    librewolf \
    xdg-utils \
    thunderbird \
    thunderbird-l10n-pl 2>&1 | tee -a "$LOGFILE"

  REAL_USER="${SUDO_USER:-$(logname)}"
  REAL_HOME=$(eval echo "~$REAL_USER")

  # 1. Globalne odblokowanie synchronizacji Firefox Sync
  sudo mkdir -p /etc/librewolf
  cat <<EOF | sudo tee /etc/librewolf/librewolf.overrides.cfg > /dev/null
defaultPref("identity.fxaccounts.enabled", true);
pref("identity.fxaccounts.enabled", true);
EOF

  # 2. Odblokowanie synchronizacji w katalogu konfiguracyjnym użytkownika (XDG path)
  sudo -u "$REAL_USER" bash << EOF
    mkdir -p "$REAL_HOME/.config/librewolf"
    cat <<UEOF > "$REAL_HOME/.config/librewolf/librewolf.overrides.cfg"
defaultPref("identity.fxaccounts.enabled", true);
pref("identity.fxaccounts.enabled", true);
UEOF
EOF

  # 3. Ustawienie LibreWolf jako domyślnej przeglądarki
  sudo update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/librewolf 200
  sudo update-alternatives --set x-www-browser /usr/bin/librewolf

  sudo -u "$REAL_USER" bash << EOF
    /usr/bin/xdg-mime default librewolf.desktop x-scheme-handler/http
    /usr/bin/xdg-mime default librewolf.desktop x-scheme-handler/https
    /usr/bin/xdg-mime default librewolf.desktop text/html
EOF

  echo "✅ LibreWolf i Thunderbird zostały zainstalowane (Firefox Sync włączony)." | tee -a "$LOGFILE"
}
