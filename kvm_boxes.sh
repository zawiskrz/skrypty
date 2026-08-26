#!/bin/bash

# Kolory dla lepszej czytelności tekstu w terminalu
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Skrypt naprawczy KVM dla GNOME Boxes ===${NC}\n"

# 1. Sprawdzenie czy skrypt jest uruchomiony jako root / przez sudo
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}[BŁĄD] Uruchom ten skrypt za pomocą sudo:${NC}"
  echo "sudo $0"
  exit 1
fi

# Pobranie nazwy rzeczywistego użytkownika, który wywołał sudo
REAL_USER=${SUDO_USER:-$USER}

# 2. Instalacja brakujących pakietów systemowych dla wirtualizacji
echo -e "\n${BLUE}[1/4] Instalacja wymaganych pakietów QEMU/KVM i libvirt...${NC}"
apt update && apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils cpu-checker

# 3. Dodanie użytkownika do grupy kvm oraz libvirt
echo -e "\n${BLUE}[2/4] Dodawanie użytkownika '$REAL_USER' do grup wirtualizacji...${NC}"
if getent group kvm > /dev/null; then
    adduser "$REAL_USER" kvm
    echo -e "${GREEN}[OK] Dodano użytkownika do grupy kvm${NC}"
else
    echo -e "${RED}[OSTRZEŻENIE] Grupa kvm nie istnieje. Tworzenie i dodawanie...${NC}"
    groupadd kvm && adduser "$REAL_USER" kvm
fi

if getent group libvirt > /dev/null; then
    adduser "$REAL_USER" libvirt
    echo -e "${GREEN}[OK] Dodano użytkownika do grupy libvirt${NC}"
fi

# 4. Uruchomienie i włączenie usług systemowych w tle
echo -e "\n${BLUE}[3/4] Konfiguracja i uruchamianie usług systemd...${NC}"
systemctl enable --now libvirtd
systemctl restart libvirtd

# 5. Weryfikacja stanu KVM w systemie
echo -e "\n${BLUE}[4/4] Sprawdzanie stanu akceleracji sprzętowej (kvm-ok)...${NC}"
if kvm-ok; then
    echo -e "\n${GREEN}[SUKCES] KVM został poprawnie skonfigurowany i jest dostępny!${NC}"
    echo -e "${BLUE}[WAŻNE] Aby zmiany w grupach użytkownika weszły w życie, MUSISZ się wylogować i zalogować ponownie (lub zrestartować komputer).${NC}"
else
    echo -e "\n${RED}[UWAGA] Pakiet kvm-ok zgłasza brak pełnej akceleracji.${NC}"
    echo -e "Jeśli powyższy komunikat wskazuje na brak włączenia wirtualizacji w BIOS/UEFI,"
    echo -e "uruchom ponownie komputer, wejdź do BIOS i włącz opcję:"
    echo -e "  - Intel: Intel Virtualization Technology (VT-x)"
    echo -e "  - AMD: SVM Mode / AMD-V"
fi

echo -e "\n${BLUE}=== Koniec działania skryptu ===${NC}"
