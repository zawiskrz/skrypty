#!/bin/bash

configure_desktop_environment() {
  echo "🧹 Czyszczenie pozostałości po Cinnamon..." | tee -a "$LOGFILE"
  sudo apt purge -y cinnamon-desktop-data cinnamon-session nemo 2>/dev/null || true
  sudo apt autoremove --purge -y | tee -a "$LOGFILE"

  echo "🖼️ Instalacja X11, LightDM oraz narzędzi GUI i zależności Qtile..." | tee -a "$LOGFILE"
  sudo apt install -y --no-install-recommends \
    xserver-xorg xinit lightdm lightdm-gtk-greeter \
    x11-xserver-utils spice-vdagent qemu-guest-agent \
    xfc4-terminal xfce4-screenshooter picom jgmenu lxappearance \
    papirus-icon-theme hicolor-icon-theme gnome-icon-theme \
    xbindkeys xdotool dunst lxpolkit \
    network-manager network-manager-applet nm-connection-editor \
    blueman pulseaudio-utils pavucontrol \
    xfce4-power-manager xfce4-power-manager-plugins \
    xfce4-netload-plugin \
    pasystray ufw gufw openssh-server \
    arandr wget unzip \
    build-essential python3-dev libffi-dev libpangocairo-1.0-0 2>&1 | tee -a "$LOGFILE"

  REAL_USER="${SUDO_USER:-$(logname)}"
  REAL_HOME=$(eval echo "~$REAL_USER")

  # Instalacja czcionki JetBrainsMono Nerd Font
  echo "🔤 Instalacja czcionki JetBrainsMono Nerd Font..." | tee -a "$LOGFILE"
  sudo -u "$REAL_USER" bash << EOF
    mkdir -p "$REAL_HOME/.local/share/fonts"
    cd /tmp
    wget -q https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
    unzip -o -q JetBrainsMono.zip -d "$REAL_HOME/.local/share/fonts/"
    rm -f JetBrainsMono.zip
    fc-cache -f
EOF

  # Konfiguracja domyślnego motywu ikon GTK3 i xbindkeys (menu jgmenu pod prawy przycisk myszy)
  sudo -u "$REAL_USER" bash << EOF
    mkdir -p "$REAL_HOME/.config/gtk-3.0"
    cat <<GEOF > "$REAL_HOME/.config/gtk-3.0/settings.ini"
[Settings]
gtk-icon-theme-name = Papirus
gtk-theme-name = Adwaita
gtk-font-name = Sans 10
GEOF

    cat <<'XEOF' > "$REAL_HOME/.xbindkeysrc"
"sh -c 'if [ \$(xdotool getmouselocation --shell | grep WINDOW | cut -d= -f2) -eq \$(xdotool getactivewindow 2>/dev/null || echo 0) ]; then jgmenu_run; fi'"
  b:3 + Release
XEOF
EOF

  echo "✅ Środowisko graficzne i narzędzia podstawowe gotowe." | tee -a "$LOGFILE"
}
