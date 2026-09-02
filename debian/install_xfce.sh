#!/bin/bash
source "./config.sh"

echo "🔧 Aktualizacja pakietów..." | tee -a "$LOGFILE"
sudo apt update 2>&1 | tee -a "$LOGFILE"

echo "📦 Instalacja narzędzi interaktywnych..." | tee -a "$LOGFILE"
sudo apt install -y dialog 2>&1 | tee -a "$LOGFILE"

# Interaktywne menu
cmd=(dialog --separate-output --checklist "Wybierz komponenty do instalacji:" 30 76 20)
options=(
  1 "XFCE" on
  2 "USER APPLICATIONS" on
  3 "[PROGRAMOWANIE] RStudio" off
  4 "[PROGRAMOWANIE] PyCharm" off
  5 "[PROGRAMOWANIE] Emacs" off
  6 "[SYSTEM] Samba" off
  7 "[SYSTEM] Firewall" on
  8 "[SYSTEM] Docker" off
  9 "[SYSTEM] NVIDIA" off
  10 "[SYSTEM] CUDA Toolkit" off
  11 "[SYSTEM] INTEL GPU" off
  12 "[SYSTEM] COMPIZ" off
  13 "[SYSTEM] SILENT GRUB" off
  14 "[SYSTEM] Ustawienie Power OFF dla pokrywy" on
  15 "[SYSTEM] Printers" on
  16 "[SYSTEM] Bluetooth" on
  17 "[SYSTEM] PulseAudio" on
  18 "Restart X11" off
)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear

# Zapis konfiguracji
echo "# Konfiguracja instalatora XFCE" > "$CONFIG_FILE"
for choice in $choices; do
  case $choice in
    1) echo "XFCE=true" >> "$CONFIG_FILE" ;;
    2) echo "USERAPPS=true" >> "$CONFIG_FILE" ;;
    3) echo "RSTUDIO=true" >> "$CONFIG_FILE" ;;
    4) echo "PYCHARM=true" >> "$CONFIG_FILE" ;;
    5) echo "EMACS=true" >> "$CONFIG_FILE" ;;
    6) echo "SAMBA=true" >> "$CONFIG_FILE" ;;
    7) echo "FIREWALL=true" >> "$CONFIG_FILE" ;;
    8) echo "DOCKER=true" >> "$CONFIG_FILE" ;;
    9) echo "NVIDIA=true" >> "$CONFIG_FILE" ;;
    10) echo "CUDA=true" >> "$CONFIG_FILE" ;;
    11) echo "INTELGPU=true" >> "$CONFIG_FILE" ;;
    12) echo "COMPIZ=true" >> "$CONFIG_FILE" ;;
    13) echo "GRUB_SILENT=true" >> "$CONFIG_FILE" ;;
    14) echo "LID_POWER_OFF=true" >> "$CONFIG_FILE" ;;
    15) echo "PRINTERS=true" >> "$CONFIG_FILE" ;;
    16) echo "BLUETOOTH=true" >> "$CONFIG_FILE" ;;
    17) echo "PULSE_AUDIO=true" >> "$CONFIG_FILE" ;;
    18) echo "lIGHTDM=true" >> "$CONFIG_FILE" ;;
  esac
done

# Wykonanie instalacji na podstawie konfiguracji
source "$CONFIG_FILE"

[[ "$XFCE" == "true" ]] && configure_xfce
[[ "$USERAPPS" == "true" ]] && configure_user_apps
[[ "$NVIDIA" == "true" ]] && configure_nvidia
[[ "$CUDA" == "true" ]] && configure_cuda
[[ "$INTELGPU" == "true" ]] && configure_intel_gpu_support
[[ "$BLUETOOTH" == "true" ]] && configure_bluetooth
[[ "$PULSE_AUDIO" == "true" ]] && configure_pulseaudio
[[ "$PYCHARM" == "true" ]] && configure_pycharm
[[ "$RSTUDIO" == "true" ]] && configure_rstudio
[[ "$EMACS" == "true" ]] && configure_emacs
[[ "$FIREWALL" == "true" ]] && configure_ufw
[[ "$GRUB_SILENT" == "true" ]] && configure_silent_boot
[[ "$LID_POWER_OFF" == "true" ]] && configure_lid_poweroff
[[ "$PRINTERS" == "true" ]] && install_printer_support
[[ "$COMPIZ" == "true" ]] && setup_compiz_for_xfce
[[ "$DOCKER" == "true" ]] && configure_docker

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
