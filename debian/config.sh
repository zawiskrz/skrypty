#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOGFILE="$SCRIPT_DIR/install_log.txt"
CONFIG_FILE="$HOME/.config/qtile_installer.conf"
mkdir -p "$(dirname "$CONFIG_FILE")"

CUDA_KEYRING_URL="https://developer.download.nvidia.com/compute/cuda/repos/debian12/x86_64/cuda-keyring_1.1-1_all.deb"
WEB_APP_MANAGER="https://packages.linuxmint.com/pool/main/w/webapp-manager/webapp-manager_1.4.3_all.deb"

# Aktualna lista modułów
FILES_TO_SOURCE=(
  "$SCRIPT_DIR/modules/desktop_environment_setup.sh"
  "$SCRIPT_DIR/modules/qtile_setup.sh"
  "$SCRIPT_DIR/modules/lightdm_setup.sh"
  "$SCRIPT_DIR/modules/librewolf_setup.sh"
  "$SCRIPT_DIR/modules/vscode_setup.sh"
  "$SCRIPT_DIR/modules/apps_setup.sh"
  "$SCRIPT_DIR/modules/python_setup.sh"
  "$SCRIPT_DIR/modules/ssh_setup.sh"
  "$SCRIPT_DIR/modules/smb_setup.sh"
  "$SCRIPT_DIR/modules/ufw_setup.sh"
  "$SCRIPT_DIR/modules/docker_setup.sh"
  "$SCRIPT_DIR/modules/nvidia_setup.sh"
  "$SCRIPT_DIR/modules/cuda_setup.sh"
  "$SCRIPT_DIR/modules/intel_gpu_setup.sh"
  "$SCRIPT_DIR/modules/grub_setup.sh"
  "$SCRIPT_DIR/modules/lid_poweroff_setup.sh"
  "$SCRIPT_DIR/modules/printers_setup.sh"
  "$SCRIPT_DIR/modules/bluetooth_setup.sh"
  "$SCRIPT_DIR/modules/pulse_audio_setup.sh"
  "$SCRIPT_DIR/modules/zram_setup.sh"
  "$SCRIPT_DIR/modules/backup_restore_setup.sh"
)

for file in "${FILES_TO_SOURCE[@]}"; do
  if [[ -f "$file" ]]; then
    source "$file"
  else
    echo "⚠️ Plik $file nie istnieje, pomijam." | tee -a "$LOGFILE"
  fi
done
