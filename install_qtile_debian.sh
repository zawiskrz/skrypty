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

# 2. Aktualizacja systemu
echo -e "\n${BLUE}[1/10] Aktualizacja systemu...${NC}"
apt update && apt upgrade -y

# 3. Instalacja pakietów systemowych, X11, LightDM, SPICE i bibliotek build-essential
echo -e "\n${BLUE}[2/10] Instalacja serwera X11, LightDM i narzędzi systemowych...${NC}"
apt install -y \
  xserver-xorg xinit lightdm lightdm-gtk-greeter \
  x11-xserver-utils spice-vdagent qemu-guest-agent \
  build-essential curl wget git mc htop thunar \
  libpango1.0-dev libpangocairo-1.0-0 gpg \
  python3-pip python3-full python3-venv python3-neovim

# 4. Instalacja Visual Studio Code
echo -e "\n${BLUE}[3/10] Dodawanie repozytorium i instalacja Visual Studio Code...${NC}"
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/packages.microsoft.gpg
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list
apt update && apt install -y code

# 5. Instalacja LibreWolf oraz Thunderbird
echo -e "\n${BLUE}[4/10] Instalacja przeglądarki LibreWolf i Thunderbird...${NC}"
apt install -y extrepo
extrepo enable librewolf
apt update && apt install -y librewolf xdg-utils
# Odblokowanie możliwości logowania do Konta Firefox (Firefox Sync)
mkdir -p /etc/librewolf
cat <<EOF >> /etc/librewolf/librewolf.overrides.cfg
// Odblokowanie synchronizacji z serwerami Firefox (Firefox Sync)
pref("identity.fxaccounts.enabled", true);
EOF
apt update && apt install -y --no-install-recommends thunderbird thunderbird-l10n-pl

# Ustawienie LibreWolfa jako domyślnej przeglądarki (w systemie i dla użytkownika)
echo -e "\n${BLUE}[Ustawienia] Ustawianie LibreWolf jako domyślnej przeglądarki...${NC}"
update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/librewolf 200
update-alternatives --set x-www-browser /usr/bin/librewolf

# Ustawienie dla użytkownika z podaniem pełnej ścieżki do xdg-mime
sudo -u "$REAL_USER" bash << EOF
  /usr/bin/xdg-mime default librewolf.desktop x-scheme-handler/http
  /usr/bin/xdg-mime default librewolf.desktop x-scheme-handler/https
  /usr/bin/xdg-mime default librewolf.desktop text/html
EOF

# 6. Instalacja LibreOffice PL (z Base) oraz VLC Player
echo -e "\n${BLUE}[5/10] Instalacja LibreOffice (PL + Base) oraz VLC...${NC}"
apt install -y \
  libreoffice \
  libreoffice-l10n-pl \
  libreoffice-help-pl \
  hunspell-pl \
  hyphen-pl \
  mythes-pl \
  libreoffice-base \
  libreoffice-java-common \
  default-jre \
  vlc

# 7. Instalacja pakietów Python z historii (Jupyter, Data Science)
echo -e "\n${BLUE}[6/10] Instalacja pakietów naukowych Python (Apt)...${NC}"
apt install -y \
  python3-ipython python3-ipykernel \
  python3-jupyterlab python3-jupyterlab-widgets \
  python3-pandas python3-matplotlib python3-scipy

# 8. Instalacja aplikacji okienkowych oraz narzędzi do motywów GTK
echo -e "\n${BLUE}[7/10] Instalacja Kitty, jgmenu, Picom, xbindkeys i motywów GTK...${NC}"
apt install -y kitty picom jgmenu lxappearance \
  papirus-icon-theme hicolor-icon-theme gnome-icon-theme \
  xbindkeys xdotool

# Konfiguracja domyślnego motywu ikon dla GTK3 oraz reguły xbindkeys dla użytkownika
sudo -u "$REAL_USER" bash << EOF
  mkdir -p "$REAL_HOME/.config/gtk-3.0"
  cat <<GEOF > "$REAL_HOME/.config/gtk-3.0/settings.ini"
[Settings]
gtk-icon-theme-name = Papirus
gtk-theme-name = Adwaita
gtk-font-name = Sans 10
GEOF

  cat <<'XEOF' > "$REAL_HOME/.xbindkeysrc"
# Uruchom jgmenu tylko po kliknięciu prawym przyciskiem w puste tło pulpitu
"sh -c 'if [ \$(xdotool getmouselocation --shell | grep WINDOW | cut -d= -f2) -eq \$(xdotool getactivewindow 2>/dev/null || echo 0) ]; then jgmenu_run; fi'"
  b:3 + Release
XEOF
EOF

# 9. Instalacja uv oraz Qtile w środowisku użytkownika
echo -e "\n${BLUE}[8/10] Instalacja Astral-UV oraz Qtile dla użytkownika $REAL_USER...${NC}"
sudo -u "$REAL_USER" bash << EOF
  curl -LsSf https://astral.sh/uv/install.sh | sh
  source "$REAL_HOME/.local/bin/env" 2>/dev/null || export PATH="$REAL_HOME/.local/bin:\$PATH"
  $REAL_HOME/.local/bin/uv tool install --with qtile-extras qtile
EOF

# Dowiązanie symboliczne, aby LightDM widział qtile globalnie
ln -sf "$REAL_HOME/.local/bin/qtile" /usr/local/bin/qtile

# 10. Utworzenie wpisu sesji w LightDM
echo -e "\n${BLUE}[9/10] Rejestracja Qtile w LightDM...${NC}"
mkdir -p /usr/share/xsessions

cat <<EOF > /usr/share/xsessions/qtile.desktop
[Desktop Entry]
Name=Qtile
Comment=Qtile Tiling Window Manager
Exec=qtile start
Type=Application
Keywords=wm;tiling;
EOF

# 11. Kopiowanie konfiguracji z repozytorium do ~/.config/qtile/
echo -e "\n${BLUE}[10/10] Kopiowanie plików konfiguracyjnych...${NC}"
if [ -d "$SCRIPT_DIR/config/qtile" ]; then
  sudo -u "$REAL_USER" mkdir -p "$REAL_HOME/.config/qtile"
  sudo -u "$REAL_USER" cp -r "$SCRIPT_DIR/config/qtile/"* "$REAL_HOME/.config/qtile/"
  chmod +x "$REAL_HOME/.config/qtile/autostart.sh" 2>/dev/null || true
  echo -e "${GREEN}[OK] Skopiowano pliki katalogu qtile do $REAL_HOME/.config/qtile/${NC}"
fi

if [ -d "$SCRIPT_DIR/config/jgmenu" ]; then
  sudo -u "$REAL_USER" mkdir -p "$REAL_HOME/.config/jgmenu"
  sudo -u "$REAL_USER" cp -r "$SCRIPT_DIR/config/jgmenu/"* "$REAL_HOME/.config/jgmenu/"
  echo -e "${GREEN}[OK] Skopiowano pliki katalogu jgmenu do $REAL_HOME/.config/jgmenu/${NC}"
fi

if [ -d "$SCRIPT_DIR/config/kitty" ]; then
  sudo -u "$REAL_USER" mkdir -p "$REAL_HOME/.config/kitty"
  sudo -u "$REAL_USER" cp -r "$SCRIPT_DIR/config/kitty/"* "$REAL_HOME/.config/kitty/"
  echo -e "${GREEN}[OK] Skopiowano pliki katalogu kitty do $REAL_HOME/.config/kitty/${NC}"
fi

echo -e "\n${GREEN}[SUKCES] Instalacja zakończona! Zrestartuj system i zaloguj się do Qtile.${NC}"
