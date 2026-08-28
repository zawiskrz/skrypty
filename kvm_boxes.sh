#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Skrypt naprawczy KVM & SPICE dla GNOME Boxes ===${NC}\n"

if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}[BŁĄD] Uruchom skrypt za pomocą sudo:${NC}"
  echo "sudo $0"
  exit 1
fi

REAL_USER=${SUDO_USER:-$USER}

echo -e "\n${BLUE}[1/4] Instalacja wymaganych pakietów KVM/libvirt oraz spice-vdagent...${NC}"
apt update && apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils cpu-checker spice-vdagent qemu-guest-agent

echo -e "\n${BLUE}[2/4] Dodawanie użytkownika '$REAL_USER' do grup kvm i libvirt...${NC}"
for group in kvm libvirt; do
  if getent group "$group" > /dev/null; then
    adduser "$REAL_USER" "$group"
    echo -e "${GREEN}[OK] Dodano użytkownika do grupy $group${NC}"
  else
    groupadd "$group" && adduser "$REAL_USER" "$group"
  fi
done

echo -e "\n${BLUE}[3/4] Konfiguracja i uruchamianie usług...${NC}"
systemctl enable --now libvirtd
systemctl restart libvirtd
systemctl start spice-vdagent 2>/dev/null || true

echo -e "\n${BLUE}[4/4] Sprawdzanie akceleracji KVM (kvm-ok)...${NC}"
if kvm-ok; then
    echo -e "\n${GREEN}[SUKCES] KVM został poprawnie skonfigurowany!${NC}"
else
    echo -e "\n${RED}[UWAGA] Sprawdź czy wirtualizacja (VT-x / AMD-V) jest włączona w BIOS/UEFI.${NC}"
fi
