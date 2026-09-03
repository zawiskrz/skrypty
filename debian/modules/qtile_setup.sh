#!/bin/bash

configure_qtile() {
  echo "🧩 Instalacja menedżera okien Qtile (przez Astral UV)..." | tee -a "$LOGFILE"

  REAL_USER="${SUDO_USER:-$(logname)}"
  REAL_HOME=$(eval echo "~$REAL_USER")

  # 1. Instalacja narzędzia uv w kontekście użytkownika
  sudo -u "$REAL_USER" bash << EOF
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$REAL_HOME/.local/bin:\$PATH"
    "$REAL_HOME/.local/bin/uv" tool install --with qtile-extras qtile
EOF

  # 2. Utworzenie dowiązania symbolicznego dla LightDM
  sudo ln -sf "$REAL_HOME/.local/bin/qtile" /usr/local/bin/qtile

  # 3. Rejestracja sesji X11 w LightDM
  echo "🖥️ Rejestracja wpisu sesji Qtile w LightDM..." | tee -a "$LOGFILE"
  sudo mkdir -p /usr/share/xsessions
  cat <<EOF | sudo tee /usr/share/xsessions/qtile.desktop > /dev/null
[Desktop Entry]
Name=Qtile
Comment=Qtile Tiling Window Manager
Exec=qtile start
Type=Application
Keywords=wm;tiling;
EOF

  # 4. Kopiowanie konfiguracji (qtile, jgmenu, kitty)
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

  if [ -d "$SCRIPT_DIR/config/qtile" ]; then
    sudo -u "$REAL_USER" mkdir -p "$REAL_HOME/.config/qtile"
    sudo -u "$REAL_USER" cp -r "$SCRIPT_DIR/config/qtile/"* "$REAL_HOME/.config/qtile/"
    [ -f "$REAL_HOME/.config/qtile/autostart.sh" ] && chmod +x "$REAL_HOME/.config/qtile/autostart.sh"
    echo "✅ Skopiowano konfigurację Qtile." | tee -a "$LOGFILE"
  fi

  if [ -d "$SCRIPT_DIR/config/jgmenu" ]; then
    sudo -u "$REAL_USER" mkdir -p "$REAL_HOME/.config/jgmenu"
    sudo -u "$REAL_USER" cp -r "$SCRIPT_DIR/config/jgmenu/"* "$REAL_HOME/.config/jgmenu/"
    echo "✅ Skopiowano konfigurację jgmenu." | tee -a "$LOGFILE"
  fi

  if [ -d "$SCRIPT_DIR/config/kitty" ]; then
    sudo -u "$REAL_USER" mkdir -p "$REAL_HOME/.config/kitty"
    sudo -u "$REAL_USER" cp -r "$SCRIPT_DIR/config/kitty/"* "$REAL_HOME/.config/kitty/"
    echo "✅ Skopiowano konfigurację Kitty." | tee -a "$LOGFILE"
  fi

  echo "✅ Instalacja Qtile zakończona pomyślnie." | tee -a "$LOGFILE"
}
