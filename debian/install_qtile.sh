#!/bin/bash
source "./config.sh"

echo "🔧 Aktualizacja pakietów..." | tee -a "$LOGFILE"
sudo apt update 2>&1 | tee -a "$LOGFILE"

echo "📦 Instalacja narzędzi interaktywnych..." | tee -a "$LOGFILE"
sudo apt install -y dialog 2>&1 | tee -a "$LOGFILE"

# Interaktywne menu
cmd=(dialog --separate-output --checklist "Wybierz komponenty do instalacji:" 30 76 20)
options=(
  1 "QTile" on
  2 "USER APPLICATIONS" on
  3 "[PROGRAMOWANIE] Python" off
  4 "[PROGRAMOWANIE] Visual Studio Code" off
  5 "[SYSTEM] Samba" off
  6 "[SYSTEM] Firewall" on
  7 "[SYSTEM] Docker" off
  9 "[SYSTEM] NVIDIA" off
  10 "[SYSTEM] CUDA Toolkit" off
  11 "[SYSTEM] INTEL GPU" off
  12 "[SYSTEM] SILENT GRUB" off
  13 "[SYSTEM] Ustawienie Power OFF dla pokrywy" on
  14 "[SYSTEM] Printers" on
  15 "[SYSTEM] Bluetooth" on
  16 "[SYSTEM] PulseAudio" on
  17 "Restart X11" off
)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear

# Zapis konfiguracji
echo "# Konfiguracja instalatora QTile" > "$CONFIG_FILE"
for choice in $choices; do
  case $choice in
    1) echo "QTile=true" >> "$CONFIG_FILE" ;;
    2) echo "USERAPPS=true" >> "$CONFIG_FILE" ;;
    3) echo "PYTHON=true" >> "$CONFIG_FILE" ;;
    4) echo "VSCODE=true" >> "$CONFIG_FILE" ;;
    5) echo "SAMBA=true" >> "$CONFIG_FILE" ;;
    6) echo "FIREWALL=true" >> "$CONFIG_FILE" ;;
    7) echo "DOCKER=true" >> "$CONFIG_FILE" ;;
    8) echo "NVIDIA=true" >> "$CONFIG_FILE" ;;
    9) echo "CUDA=true" >> "$CONFIG_FILE" ;;
    10) echo "INTELGPU=true" >> "$CONFIG_FILE" ;;
    11) echo "GRUB_SILENT=true" >> "$CONFIG_FILE" ;;
    12) echo "LID_POWER_OFF=true" >> "$CONFIG_FILE" ;;
    13) echo "PRINTERS=true" >> "$CONFIG_FILE" ;;
    14) echo "BLUETOOTH=true" >> "$CONFIG_FILE" ;;
    15) echo "PULSE_AUDIO=true" >> "$CONFIG_FILE" ;;
    16) echo "=LIGHTDM=true" >> "$CONFIG_FILE" ;;
  esac
done

# Wykonanie instalacji na podstawie konfiguracji
source "$CONFIG_FILE"

[[ "$QTile" == "true" ]] && configure_qtile
[[ "$USERAPPS" == "true" ]] && configure_user_apps
[[ "$PYTHON" == "true" ]] && configure_python
[[ "$VSCODE" == "true" ]] && configure_vscode
[[ "$SAMBA" == "true" ]] && configure_smb
[[ "$FIREWALL" == "true" ]] && configure_ufw
[[ "$DOCKER" == "true" ]] && configure_docker
[[ "$NVIDIA" == "true" ]] && configure_nvidia
[[ "$CUDA" == "true" ]] && configure_cuda
[[ "$INTELGPU" == "true" ]] && configure_intel_gpu_support
[[ "$GRUB_SILENT" == "true" ]] && configure_silent_boot
[[ "$LID_POWER_OFF" == "true" ]] && configure_lid_poweroff
[[ "$PRINTERS" == "true" ]] && install_printer_support
[[ "$BLUETOOTH" == "true" ]] && configure_bluetooth
[[ "$PULSE_AUDIO" == "true" ]] && configure_pulseaudio
[[ "$LIGHTDM" == "true" ]] && configure_lightdm



if [[ "$SAMBA" == "true" ]]; then
  SAMBA_USER="$(logname)"
  #Koniecznie należy podać hasło dla użytkownia
  read -s -p "🔑 Podaj hasło dla użytkownika Samba: " SAMBA_PASS
  echo
  source  "./modules/smb_setup.sh"
  configure_smb
fi

if [[ "$lIGHTDM" == "true" ]]; then
  echo "🔄 Restart LightDM..." | tee -a "$LOGFILE"
  sudo systemctl restart lightdm
fi

echo "✅ Instalacja zakończona. Wybrane komponenty zostały zainstalowane." | tee -a "$LOGFILE"
