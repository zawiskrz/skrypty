#!/bin/bash

configure_python() {
  echo "🐍 Instalacja pakietów naukowych i deweloperskich Python..." | tee -a "$LOGFILE"

  sudo apt update
  sudo apt install -y --no-install-recommends \
    python3-pip \
    python3-full \
    python3-venv \
    python3-neovim \
    python3-ipython \
    python3-ipykernel \
    python3-jupyterlab \
    python3-jupyterlab-widgets \
    python3-pandas \
    python3-matplotlib \
    python3-scipy 2>&1 | tee -a "$LOGFILE"

  echo "✅ Środowisko Python Data Science skonfigurowane." | tee -a "$LOGFILE"
}
