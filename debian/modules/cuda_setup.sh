#!/bin/bash

configure_cuda() {
  if lspci | grep -i "nvidia" >/dev/null; then
    echo "⚡ Instalacja CUDA Toolkit..." | tee -a "$LOGFILE"

    wget "$CUDA_KEYRING_URL" -O /tmp/cuda-keyring.deb 2>&1 | tee -a "$LOGFILE"
    sudo dpkg -i /tmp/cuda-keyring.deb 2>&1 | tee -a "$LOGFILE"
    rm -f /tmp/cuda-keyring.deb

    sudo apt update
    sudo apt install -y cuda 2>&1 | tee -a "$LOGFILE"

    REAL_USER="${SUDO_USER:-$(logname)}"
    BASHRC="/home/$REAL_USER/.bashrc"

    echo 'export PATH=/usr/local/cuda/bin:$PATH' >> "$BASHRC"
    echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH' >> "$BASHRC"

    echo "✅ CUDA Toolkit zainstalowany." | tee -a "$LOGFILE"
  else
    echo "⚠️ Nie wykryto karty NVIDIA. Pomijam instalację CUDA." | tee -a "$LOGFILE"
  fi
}
