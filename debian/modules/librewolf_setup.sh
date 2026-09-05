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

  read -r -d '' LIBREWOLF_PREFS << 'EOF'
// Synchronizacja Firefox Sync
defaultPref("identity.fxaccounts.enabled", true);
pref("identity.fxaccounts.enabled", true);

// 1. Zezwolenie na przekazywanie schematu kolorów do przeglądarki i dodatków
pref("layout.css.prefers-color-scheme.content-override", 3);

// 2. Wymagane dla Dark Readera: Wyłączenie blokady RFP dla interfejsów systemowych
pref("privacy.resistFingerprinting", false);
pref("privacy.resistFingerprinting.blockAutoRefresh", false);
EOF

  # 1. Globalna konfiguracja
  sudo mkdir -p /etc/librewolf
  echo "$LIBREWOLF_PREFS" | sudo tee /etc/librewolf/librewolf.overrides.cfg > /dev/null

  # 2. Konfiguracja użytkownika
  sudo -u "$REAL_USER" bash << EOF
    mkdir -p "$REAL_HOME/.config/librewolf"
    cat <<'UEOF' > "$REAL_HOME/.config/librewolf/librewolf.overrides.cfg"
$LIBREWOLF_PREFS
UEOF
EOF

  # 3. Ustawienie jako domyślna przeglądarka
  sudo update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/librewolf 200
  sudo update-alternatives --set x-www-browser /usr/bin/librewolf

  sudo -u "$REAL_USER" bash << EOF
    /usr/bin/xdg-mime default librewolf.desktop x-scheme-handler/http
    /usr/bin/xdg-mime default librewolf.desktop x-scheme-handler/https
    /usr/bin/xdg-mime default librewolf.desktop text/html
EOF

  echo "✅ LibreWolf skonfigurowany pod obsługę Dark Readera." | tee -a "$LOGFILE"
}
