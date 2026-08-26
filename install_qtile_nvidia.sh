#!/bin/bash

# Kolory dla lepszej czytelności tekstu w terminalu
RED='\033;31m'
GREEN='\033;32m'
BLUE='\033;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Skrypt automatycznej instalacji sterowników i Qtile (Wersja SNAP-UV) ===${NC}\n"

# 1. Sprawdzenie czy skrypt jest uruchomiony jako root / przez sudo
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}[BŁĄD] Uruchom ten skrypt za pomocą sudo:${NC}"
  echo "sudo $0"
  exit 1
fi

# Pobranie nazwy rzeczywistego użytkownika, który wywołał sudo
REAL_USER=${SUDO_USER:-$USER}
REAL_HOME=$(eval echo "~$REAL_USER")

# 2. Aktualizacja systemu
echo -e "\n${BLUE}[1/7] Aktualizacja listy pakietów i systemu...${NC}"
apt update && apt upgrade -y

# 3. Instalacja oficjalnych sterowników NVIDIA
echo -e "\n${BLUE}[2/7] Wykrywanie i instalacja rekomendowanych sterowników NVIDIA...${NC}"
ubuntu-drivers install

# 4. Instalacja serwera X11, menedżera logowania oraz zależności
echo -e "\n${BLUE}[3/7] Instalacja serwera graficznego X11, LightDM oraz bibliotek...${NC}"
apt install -y xserver-xorg xinit lightdm lightdm-gtk-greeter python3-pip python3-full build-essential libpango1.0-dev libpangocairo-1.0-0 nvidia-prime snapd

# 5. Instalacja przydatnych programów codziennego użytku
echo -e "\n${BLUE}[4/7] Instalacja terminala (Kitty), menu (Rofi), kompozytora (Picom) i edytora...${NC}"
apt install -y kitty nitrogen picom rofi micro git

# 6. Instalacja uv przez SNAP oraz instalacja środowiska Qtile
echo -e "\n${BLUE}[5/7] Instalacja astral-uv przez Snap i środowiska Qtile dla użytkownika $REAL_USER...${NC}"
# Instalacja systemowa SNAP (wymaga roota)
snap install astral-uv --classic

# Instalacja Qtile w kontekście użytkownika za pomocą zainstalowanego astral-uv
sudo -u "$REAL_USER" bash << EOF
  astral-uv tool install --with qtile-extras qtile
EOF

# 7. Utworzenie sesji XSession dla LightDM przy użyciu polecenia 'tee'
echo -e "\n${BLUE}[6/7] Rejestracja Qtile w menedżerze logowania LightDM...${NC}"
mkdir -p /usr/share/xsessions

# Użycie tee z jawną ścieżką katalogu domowego użytkownika
sudo tee /usr/share/xsessions/qtile.desktop <<EOF
[Desktop Entry]
Name=Qtile
Comment=Qtile Window Manager
Exec=$REAL_HOME/.local/bin/qtile start
Type=Application
Keywords=wm;tiling;
EOF

# 8. Ustawienie profilu graficznego Hybrid (NVIDIA On-Demand)
echo -e "\n${BLUE}[7/7] Konfiguracja grafiki hybrydowej Intel + NVIDIA (On-Demand)...${NC}"
prime-select on-demand

echo -e "\n${GREEN}[SUKCES] Instalacja i konfiguracja zakończona pomyślnie!${NC}"
echo -e "${BLUE}[WAŻNE] Aby zastosować sterowniki NVIDIA i uruchomić środowisko graficzne, zrestartuj komputer komendą: sudo reboot${NC}"

echo -e "\n${BLUE}=== Koniec działania skryptu ===${NC}"
