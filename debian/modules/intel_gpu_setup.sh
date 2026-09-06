#!/bin/bash

# Ustawienie zmiennej LOGFILE, jeśli nie została zdefiniowana wcześniej
LOGFILE="${LOGFILE:-/tmp/gpu_config.log}"

add_if_missing() {
  local line="$1"
  if grep -qxF "$line" "$BASHRC"; then
    echo "⏭️ Pomijam: '$line' już istnieje." | tee -a "$LOGFILE"
  else
    echo "$line" >> "$BASHRC"
    echo "✅ Dodano: $line" | tee -a "$LOGFILE"
  fi
}

configure_intel_gpu_support() {
  echo "🎮 Konfiguracja sterowników i bibliotek Intel GPU (Gen4 / GM965)..." | tee -a "$LOGFILE"

  # Ustalenie ścieżki pliku .bashrc przed użyciem funkcji add_if_missing
  REAL_USER="${SUDO_USER:-$(logname)}"
  USER_HOME=$(eval echo "~$REAL_USER")
  BASHRC="$USER_HOME/.bashrc"

  if [ ! -f "$BASHRC" ]; then
    touch "$BASHRC"
    chown "$REAL_USER:$REAL_USER" "$BASHRC"
  fi

  # Kopia zapasowa listy repozytoriów
  sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak

  sudo tee /etc/apt/sources.list > /dev/null <<EOF
deb http://ftp.task.gda.pl/debian/ trixie main contrib non-free non-free-firmware
deb-src http://ftp.task.gda.pl/debian/ trixie main contrib non-free non-free-firmware

deb http://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware
deb-src http://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware

deb http://ftp.task.gda.pl/debian/ trixie-updates main contrib non-free non-free-firmware
deb-src http://ftp.task.gda.pl/debian/ trixie-updates main contrib non-free non-free-firmware
EOF

  sudo apt update | tee -a "$LOGFILE"
  
  # Usunięto niekompatybilne pakiety: vulkan, opencl, i965-va-driver
  sudo apt install -y \
    libgl1-mesa-dri \
    libglx-mesa0 \
    mesa-utils \
    intel-gpu-tools | tee -a "$LOGFILE"

  # Zabezpieczenie przed błędnym uprawnieniem pliku .bashrc po użyciu sudo
  chown "$REAL_USER:$REAL_USER" "$BASHRC"

  # Wymuszenie stabilnego interfejsu 2D/3D (X11) dla Firefoksa i Chrome
  add_if_missing "export MOZ_ENABLE_WAYLAND=0"
  add_if_missing "export LIBGL_ALWAYS_SOFTWARE=0"
  
  # Bezpieczny alias dla Chrome bez wymuszania niedostępnych funkcji GPU
  add_if_missing "alias chrome-gpu='google-chrome --ignore-gpu-blocklist --enable-gpu-rasterization --ozone-platform=x11'"

  echo "✅ Podstawowa akceleracja GPU została skonfigurowana." | tee -a "$LOGFILE"
}
