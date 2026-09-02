#!/bin/bash

# Kolory dla czytelności
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Skrypt instalacyjny Qtile & Pythona dla Debiana ===${NC}\n"

# 1. Weryfikacja roota
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}[BŁĄD] Uruchom skrypt za pomocą sudo:${NC}"
  echo "sudo $0"
  exit 1
fi

REAL_USER=${SUDO_USER:-$USER}
REAL_HOME=$(eval echo "~$REAL_USER")
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 2. Usuwanie ewentualnych pozostałości po Cinnamonie
echo -e "\n${BLUE}[1/10] Czyszczenie niechcianych pakietów...${NC}"
apt purge -y cinnamon-desktop-data cinnamon-session nemo 2>/dev/null || true
apt autoremove --purge -y

# 3. Aktualizacja systemu
echo -e "\n${BLUE}[2/10] Aktualizacja systemu...${NC}"
apt update && apt upgrade -y

# 4. Instalacja pakietów systemowych, X11, LightDM, SPICE, Flatpaka i build-essential
echo -e "\n${BLUE}[3/10] Instalacja serwera X11, LightDM, Flatpak i narzędzi systemowych...${NC}"
apt install -y --no-install-recommends \
  xserver-xorg xinit lightdm lightdm-gtk-greeter \
  x11-xserver-utils spice-vdagent qemu-guest-agent \
  build-essential curl wget git mc htop thunar \
  libpango1.0-dev libpangocairo-1.0-0 gpg flatpak \
  python3-pip python3-full python3-venv python3-neovim \
  unzip fonts-font-awesome fonts-noto-color-emoji

# Instalacja JetBrainsMono Nerd Font
echo -e "\n${BLUE}Instalacja czcionki JetBrainsMono Nerd Font...${NC}"
sudo -u "$REAL_USER" bash << EOF
  mkdir -p "$REAL_HOME/.local/share/fonts"
  cd /tmp
  wget -q https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
  unzip -o -q JetBrainsMono.zip -d "$REAL_HOME/.local/share/fonts/"
  rm JetBrainsMono.zip
  fc-cache -f
EOF

# Konfiguracja repozytorium Flathub dla Flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# 5. Instalacja Visual Studio Code
echo -e "\n${BLUE}[4/10] Dodawanie repozytorium i instalacja Visual Studio Code...${NC}"
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/packages.microsoft.gpg
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list
apt update && apt install -y code

# 6. Instalacja LibreWolf oraz Thunderbird
echo -e "\n${BLUE}[5/10] Instalacja przeglądarki LibreWolf i Thunderbird...${NC}"
apt install -y --no-install-recommends extrepo
extrepo enable librewolf
apt update && apt install -y --no-install-recommends librewolf xdg-utils thunderbird thunderbird-l10n-pl

# Odblokowanie synchronizacji Firefox Sync w LibreWolf
mkdir -p /etc/librewolf
cat <<EOF >> /etc/librewolf/librewolf.overrides.cfg
pref("identity.fxaccounts.enabled", true);
EOF

# Ustawienie LibreWolfa jako domyślnej przeglądarki
update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/librewolf 200
update-alternatives --set x-www-browser /usr/bin/librewolf

sudo -u "$REAL_USER" bash << EOF
  /usr/bin/xdg-mime default librewolf.desktop x-scheme-handler/http
  /usr/bin/xdg-mime default librewolf.desktop x-scheme-handler/https
  /usr/bin/xdg-mime default librewolf.desktop text/html
EOF

# 7. Instalacja LibreOffice, Calibre, Shotwell, Rhythmbox, VLC oraz pakietów Flatpak
echo -e "\n${BLUE}[6/10] Instalacja aplikacji (Apt + Flatpak)...${NC}"
apt install -y --no-install-recommends \
  libreoffice libreoffice-l10n-pl libreoffice-help-pl hunspell-pl hyphen-pl mythes-pl \
  libreoffice-base libreoffice-java-common default-jre libreoffice-gtk3 \
  vlc calibre shotwell rhythmbox

# Instalacja aplikacji Flatpak
flatpak install -y flathub \
  com.github.IsmaelMartinez.teams_for_linux \
  com.ktechpit.whatsie \
  app.ytmdesktop.ytmdesktop \
  com.github.unrud.VideoDownloader \
  io.github.amit9838.mousam \
  app/io.missioncenter.MissionCenter/x86_64/stable \
  app/com.playonlinux.PlayOnLinux4/x86_64/stable

# 8. Instalacja pakietów Python (Data Science)
echo -e "\n${BLUE}[7/10] Instalacja pakietów naukowych Python (Apt)...${NC}"
apt install -y --no-install-recommends \
  python3-ipython python3-ipykernel \
  python3-jupyterlab python3-jupyterlab-widgets \
  python3-pandas python3-matplotlib python3-scipy

# 9. Instalacja aplikacji okienkowych, apletów zasobnika systemowego i narzędzi XFCE/GTK
echo -e "\n${BLUE}[8/10] Instalacja Kitty, jgmenu, Picom, apletów XFCE i narzędzi GTK...${NC}"
apt install -y --no-install-recommends \
  kitty picom jgmenu lxappearance \
  papirus-icon-theme hicolor-icon-theme gnome-icon-theme \
  xbindkeys xdotool dunst lxpolkit \
  pavucontrol xfce4-pulseaudio-plugin \
  network-manager network-manager-applet nm-connection-editor \
  blueman xfce4-power-manager \
  arandr xfce4-display-settings

# Konfiguracja domyślnego motywu ikon GTK3 i xbindkeys
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

# 10. Instalacja uv oraz Qtile w środowisku użytkownika
echo -e "\n${BLUE}[9/10] Instalacja Astral-UV oraz Qtile...${NC}"
sudo -u "$REAL_USER" bash << EOF
  curl -LsSf https://astral.sh/uv/install.sh | sh
  source "$REAL_HOME/.local/bin/env" 2>/dev/null || export PATH="$REAL_HOME/.local/bin:\$PATH"
  $REAL_HOME/.local/bin/uv tool install --with qtile-extras qtile
EOF

ln -sf "$REAL_HOME/.local/bin/qtile" /usr/local/bin/qtile

# 11. Rejestracja w LightDM i Kopiowanie konfiguracji
echo -e "\n${BLUE}[10/10] Rejestracja Qtile w LightDM oraz kopiowanie plików...${NC}"
mkdir -p /usr/share/xsessions
cat <<EOF > /usr/share/xsessions/qtile.desktop
[Desktop Entry]
Name=Qtile
Comment=Qtile Tiling Window Manager
Exec=qtile start
Type=Application
Keywords=wm;tiling;
EOF

if [ -d "$SCRIPT_DIR/config/qtile" ]; then
  sudo -u "$REAL_USER" mkdir -p "$REAL_HOME/.config/qtile"
  sudo -u "$REAL_USER" cp -r "$SCRIPT_DIR/config/qtile/"* "$REAL_HOME/.config/qtile/"
  chmod +x "$REAL_HOME/.config/qtile/autostart.sh" 2>/dev/null || true
  echo -e "${GREEN}[OK] Skopiowano pliki qtile.${NC}"
fi

if [ -d "$SCRIPT_DIR/config/jgmenu" ]; then
  sudo -u "$REAL_USER" mkdir -p "$REAL_HOME/.config/jgmenu"
  sudo -u "$REAL_USER" cp -r "$SCRIPT_DIR/config/jgmenu/"* "$REAL_HOME/.config/jgmenu/"
  echo -e "${GREEN}[OK] Skopiowano pliki jgmenu.${NC}"
fi

if [ -d "$SCRIPT_DIR/config/kitty" ]; then
  sudo -u "$REAL_USER" mkdir -p "$REAL_HOME/.config/kitty"
  sudo -u "$REAL_USER" cp -r "$SCRIPT_DIR/config/kitty/"* "$REAL_HOME/.config/kitty/"
  echo -e "${GREEN}[OK] Skopiowano pliki kitty.${NC}"
fi

echo -e "\n${GREEN}[SUKCES] Instalacja zakończona! Zrestartuj system.${NC}"
