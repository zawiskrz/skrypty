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
echo -e "\n${BLUE}[1/7] Aktualizacja systemu...${NC}"
apt update && apt upgrade -y

# 3. Instalacja pakietów systemowych, X11, LightDM, SPICE i bibliotek build-essential
echo -e "\n${BLUE}[2/7] Instalacja serwera X11, LightDM i narzędzi systemowych...${NC}"
apt install -y \
  xserver-xorg xinit lightdm lightdm-gtk-greeter \
  x11-xserver-utils spice-vdagent qemu-guest-agent \
  build-essential curl wget git mc htop thunar \
  libpango1.0-dev libpangocairo-1.0-0 \
  python3-pip python3-full python3-venv python3-neovim

# 4. Instalacja LibreWolf (Lekka przeglądarka z uBlock Origin) oraz thunderbird
echo -e "\n${BLUE}[3/10] Instalacja przeglądarki LibreWolf...${NC}"
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

# 5. Instalacja pakietów Python z historii (Jupyter, Data Science)
echo -e "\n${BLUE}[3/7] Instalacja pakietów naukowych Python (Apt)...${NC}"
apt install -y \
  python3-ipython python3-ipykernel \
  python3-jupyterlab python3-jupyterlab-widgets \
  python3-pandas python3-matplotlib python3-scipy

# 6. Instalacja aplikacji okienkowych
echo -e "\n${BLUE}[4/7] Instalacja Kitty, Rofi i Picom...${NC}"
apt install -y kitty picom rofi papirus-icon-theme

# 7. Instalacja uv oraz Qtile w środowisku użytkownika
echo -e "\n${BLUE}[5/7] Instalacja Astral-UV oraz Qtile dla użytkownika $REAL_USER...${NC}"
sudo -u "$REAL_USER" bash << EOF
  curl -LsSf https://astral.sh/uv/install.sh | sh
  source "$REAL_HOME/.local/bin/env" 2>/dev/null || export PATH="$REAL_HOME/.local/bin:\$PATH"
  $REAL_HOME/.local/bin/uv tool install --with qtile-extras qtile
EOF

# Dowiązanie symboliczne, aby LightDM widział qtile globalnie
ln -sf "$REAL_HOME/.local/bin/qtile" /usr/local/bin/qtile

# 8. Utworzenie wpisu sesji w LightDM
echo -e "\n${BLUE}[6/7] Rejestracja Qtile w LightDM...${NC}"
mkdir -p /usr/share/xsessions

cat <<EOF > /usr/share/xsessions/qtile.desktop
[Desktop Entry]
Name=Qtile
Comment=Qtile Tiling Window Manager
Exec=qtile start
Type=Application
Keywords=wm;tiling;
EOF

# 9. Kopiowanie konfiguracji z repozytorium do ~/.config/qtile/
echo -e "\n${BLUE}[7/7] Kopiowanie plików konfiguracyjnych...${NC}"
if [ -d "$SCRIPT_DIR/config/qtile" ]; then
  sudo -u "$REAL_USER" mkdir -p "$REAL_HOME/.config/qtile"
  sudo -u "$REAL_USER" cp -r "$SCRIPT_DIR/config/qtile/"* "$REAL_HOME/.config/qtile/"
  chmod +x "$REAL_HOME/.config/qtile/autostart.sh" 2>/dev/null || true
  echo -e "${GREEN}[OK] Skopiowano pliki katalagu qtile do $REAL_HOME/.config/qtile/${NC}"
fi

if [ -d "$SCRIPT_DIR/config/rofi" ]; then
  sudo -u "$REAL_USER" mkdir -p "$REAL_HOME/.config/rofi"
  sudo -u "$REAL_USER" cp -r "$SCRIPT_DIR/config/rofi/"* "$REAL_HOME/.config/rofi/"
  echo -e "${GREEN}[OK] Skopiowano pliki katalagu rofi do $REAL_HOME/.config/rofi/${NC}"
fi

if [ -d "$SCRIPT_DIR/config/kitty" ]; then
  sudo -u "$REAL_USER" mkdir -p "$REAL_HOME/.config/kitty"
  sudo -u "$REAL_USER" cp -r "$SCRIPT_DIR/config/kitty/"* "$REAL_HOME/.config/kitty/"
  echo -e "${GREEN}[OK] Skopiowano pliki katalagu kitty do $REAL_HOME/.config/kitty/${NC}"
fi
echo -e "\n${GREEN}[SUKCES] Instalacja zakończona! Zrestartuj system i zaloguj się do Qtile.${NC}"

