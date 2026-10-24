#!/bin/bash
# ==============================================================================
# Główny skrypt instalacyjny Qtile dla systemu Debian 13 (Trixie)
# ==============================================================================

if [[ $EUID -eq 0 ]]; then
  echo "❌ BŁĄD: Nie uruchamiaj instalatora bezpośrednio jako root (przez sudo)!"
  echo "   Uruchom go jako zwykły użytkownik: ./install_qtile.sh"
  echo "   Skrypt sam poprosi o uprawnienia administratora w momentach, gdy są one wymagane."
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# Obsługa dedykowanych flag CLI (--backup, --restore)
if [[ "$1" == "--backup" ]]; then
  create_private_backup
  exit 0
fi

if [[ "$1" == "--restore" ]]; then
  restore_private_backup
  exit 0
fi

AUTO_MODE=false
if [[ "$1" == "--all" || "$1" == "-y" ]]; then
  AUTO_MODE=true
fi

echo "🔧 Aktualizacja pakietów..." | tee -a "$LOGFILE"
sudo apt update 2>&1 | tee -a "$LOGFILE"

echo "📦 Instalacja narzędzi interaktywnych..." | tee -a "$LOGFILE"
sudo apt install -y dialog 2>&1 | tee -a "$LOGFILE"

if [[ "$AUTO_MODE" == "true" ]]; then
  echo "🚀 Uruchomiono w trybie automatycznym (--all). Wykonywanie standardowych modułów 1-20..." | tee -a "$LOGFILE"
  choices="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20"
else
  # Interaktywne menu dialogowe
  cmd=(dialog --separate-output --checklist "Wybierz komponenty do instalacji/konfiguracji:" 30 84 22)
  options=(
    1 "[ŚRODOWISKO] X11, LightDM, Fonts, GUI" on
    2 "[WM] Qtile & UV" on
    3 "[LOGIN MANAGER] Konfiguracja LightDM dla Qtile" on
    4 "[PRZEGLĄDARKA] LibreWolf & Thunderbird" on
    5 "[PROGRAMOWANIE] Visual Studio Code" off
    6 "[APLIKACJE] LibreOffice, VLC, Flatpak, WebApp, KDE Connect" on
    7 "[PROGRAMOWANIE] Python Data Science" off
    8 "[SYSTEM] Firewall UFW (reguły LAN, SSH, SMB, KDE Connect)" on
    9 "[SYSTEM] Samba (Udostępnianie plików)" off
    10 "[SYSTEM] Docker" off
    11 "[SYSTEM] Sterowniki NVIDIA" off
    12 "[SYSTEM] CUDA Toolkit" off
    13 "[SYSTEM] Intel GPU (Akceleracja Video)" off
    14 "[SYSTEM] Silent GRUB & Plymouth" off
    15 "[SYSTEM] Obsługa pokrywy laptopa" on
    16 "[SYSTEM] Drukarki (CUPS)" on
    17 "[SYSTEM] Bluetooth" on
    18 "[AUDIO] PulseAudio" on
    19 "[SYSTEM] zRAM (zram-tools)" off
    20 "[SIEĆ] Serwer OpenSSH i klucz ed25519" off
    21 "[BACKUP] Utwórz prywatną kopię (SSH, Wi-Fi, Git)" off
    22 "[RESTORE] Przywróć prywatną kopię z pendrive'a/pliku" off
    23 "Restart usługi LightDM na koniec" off
  )
  choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty) || {
    echo "Anulowano instalację."
    exit 0
  }
  clear
fi

# Zapis konfiguracji użytkownika
echo "# Konfiguracja instalatora QTile: $(date)" > "$CONFIG_FILE"
for choice in $choices; do
  case $choice in
    1) echo "DESKTOP_ENV=true" >> "$CONFIG_FILE" ;;
    2) echo "QTILE=true" >> "$CONFIG_FILE" ;;
    3) echo "LIGHTDM_CONFIG=true" >> "$CONFIG_FILE" ;;
    4) echo "LIBREWOLF=true" >> "$CONFIG_FILE" ;;
    5) echo "VSCODE=true" >> "$CONFIG_FILE" ;;
    6) echo "USER_APPS=true" >> "$CONFIG_FILE" ;;
    7) echo "PYTHON=true" >> "$CONFIG_FILE" ;;
    8) echo "FIREWALL=true" >> "$CONFIG_FILE" ;;
    9) echo "SAMBA=true" >> "$CONFIG_FILE" ;;
    10) echo "DOCKER=true" >> "$CONFIG_FILE" ;;
    11) echo "NVIDIA=true" >> "$CONFIG_FILE" ;;
    12) echo "CUDA=true" >> "$CONFIG_FILE" ;;
    13) echo "INTELGPU=true" >> "$CONFIG_FILE" ;;
    14) echo "GRUB_SILENT=true" >> "$CONFIG_FILE" ;;
    15) echo "LID_POWER_OFF=true" >> "$CONFIG_FILE" ;;
    16) echo "PRINTERS=true" >> "$CONFIG_FILE" ;;
    17) echo "BLUETOOTH=true" >> "$CONFIG_FILE" ;;
    18) echo "PULSE_AUDIO=true" >> "$CONFIG_FILE" ;;
    19) echo "ZRAM=true" >> "$CONFIG_FILE" ;;
    20) echo "SSH_SERVER=true" >> "$CONFIG_FILE" ;;
    21) echo "BACKUP_PRIVATE=true" >> "$CONFIG_FILE" ;;
    22) echo "RESTORE_PRIVATE=true" >> "$CONFIG_FILE" ;;
    23) echo "RESTART_LIGHTDM=true" >> "$CONFIG_FILE" ;;
  esac
done

# Wczytanie wybranych opcji
source "$CONFIG_FILE"

# Jeśli wybrano przywracanie kopii z pendrive'a, wykonaj je na początku
[[ "$RESTORE_PRIVATE" == "true" ]] && restore_private_backup

# Przygotowanie danych dla Samby przed uruchomieniem modułu
if [[ "$SAMBA" == "true" && -z "$SAMBA_PASS" ]]; then
  SAMBA_USER="${SUDO_USER:-$(logname)}"
  if [[ -t 0 ]]; then
    read -s -p "🔑 Podaj hasło dla użytkownika Samba ($SAMBA_USER): " SAMBA_PASS
    echo
    export SAMBA_PASS
    export SAMBA_USER
  fi
fi

# Sekwencyjne wykonywanie modułów
[[ "$DESKTOP_ENV" == "true" ]]     && configure_desktop_environment
[[ "$QTILE" == "true" ]]           && configure_qtile
[[ "$LIGHTDM_CONFIG" == "true" ]]  && configure_lightdm
[[ "$LIBREWOLF" == "true" ]]       && configure_librewolf
[[ "$VSCODE" == "true" ]]          && configure_vscode
[[ "$USER_APPS" == "true" ]]       && configure_apps
[[ "$PYTHON" == "true" ]]          && configure_python
[[ "$SSH_SERVER" == "true" ]]      && configure_ssh
[[ "$FIREWALL" == "true" ]]        && configure_ufw
[[ "$SAMBA" == "true" ]]           && configure_smb
[[ "$DOCKER" == "true" ]]          && configure_docker
[[ "$NVIDIA" == "true" ]]          && configure_nvidia
[[ "$CUDA" == "true" ]]            && configure_cuda
[[ "$INTELGPU" == "true" ]]        && configure_intel_gpu_support
[[ "$GRUB_SILENT" == "true" ]]     && configure_silent_boot
[[ "$LID_POWER_OFF" == "true" ]]   && configure_lid_poweroff
[[ "$PRINTERS" == "true" ]]        && install_printer_support
[[ "$BLUETOOTH" == "true" ]]       && configure_bluetooth
[[ "$PULSE_AUDIO" == "true" ]]     && configure_pulseaudio
[[ "$ZRAM" == "true" ]]            && configure_zram
[[ "$BACKUP_PRIVATE" == "true" ]]  && create_private_backup

if [[ "$RESTART_LIGHTDM" == "true" ]]; then
  echo "🔄 Restart LightDM..." | tee -a "$LOGFILE"
  sudo systemctl restart lightdm
fi

echo "✅ Instalacja zakończona pomyślnie!" | tee -a "$LOGFILE"
