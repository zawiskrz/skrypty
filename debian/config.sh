#!/bin/bash

LOGFILE="install_log.txt"
CONFIG_FILE="$HOME/.config/qtile_installer.conf"
mkdir -p "$(dirname "$CONFIG_FILE")"

CUDA_KEYRING_URL="https://developer.download.nvidia.com/compute/cuda/repos/debian12/x86_64/cuda-keyring_1.1-1_all.deb"
WEB_APP_MANAGER="http://packages.linuxmint.com/pool/main/w/webapp-manager/webapp-manager_1.4.3_all.deb"

# Aktualna lista modułów zgodna z plikami w katalogu ./modules/
FILES_TO_SOURCE=(
  "./modules/desktop_environment_setup.sh"
  "./modules/qtile_setup.sh"
  "./modules/lightdm_setup.sh" # <-- Dodano plik LightDM
  "./modules/librewolf_setup.sh"
  "./modules/vscode_setup.sh"
  "./modules/apps_setup.sh"
  "./modules/python_setup.sh"
  "./modules/smb_setup.sh"
  "./modules/ufw_setup.sh"
  "./modules/docker_setup.sh"
  "./modules/nvidia_setup.sh"
  "./modules/cuda_setup.sh"
  "./modules/intel_gpu_setup.sh"
  "./modules/grub_setup.sh"
  "./modules/lid_poweroff_setup.sh"
  "./modules/printers_setup.sh"
  "./modules/bluetooth_setup.sh"
  "./modules/pulse_audio_setup.sh"
  "./modules/zram_setup.sh"
)

for file in "${FILES_TO_SOURCE[@]}"; do
  if [[ -f "$file" ]]; then
    source "$file"
  else
    echo "⚠️ Plik $file nie istnieje, pomijam." | tee -a "$LOGFILE"
  fi
done
