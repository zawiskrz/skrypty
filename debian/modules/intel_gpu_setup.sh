#!/bin/bash

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
  echo "🎮 Konfiguracja akceleracji Intel GPU (VAAPI, Vulkan, OpenCL)..." | tee -a "$LOGFILE"

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
  sudo apt install -y \
    i965-va-driver-shaders \
    ocl-icd-libopencl1 \
    clinfo \
    mesa-vulkan-drivers \
    libgl1-mesa-dri \
    libglx-mesa0 \
    mesa-utils \
    libva-drm2 \
    libva-x11-2 \
    libva-wayland2 \
    intel-gpu-tools \
    vulkan-tools | tee -a "$LOGFILE"

  REAL_USER="${SUDO_USER:-$(logname)}"
  BASHRC="/home/$REAL_USER/.bashrc"

  if [ ! -f "$BASHRC" ]; then
    touch "$BASHRC"
    chown "$REAL_USER:$REAL_USER" "$BASHRC"
  fi

  add_if_missing "alias chrome-gpu='LIBVA_DRIVER_NAME=i965 google-chrome --use-gl=desktop --enable-zero-copy --ignore-gpu-blocklist --enable-gpu-rasterization --enable-native-gpu-memory-buffers --enable-features=VaapiVideoDecoder --ozone-platform=x11'"
  add_if_missing "export MOZ_ENABLE_WAYLAND=0"
  add_if_missing "export MOZ_WEBRENDER=1"
  add_if_missing "export MOZ_ACCELERATED=1"
  add_if_missing "export LIBVA_DRIVER_NAME=i965"
  add_if_missing "export VDPAU_DRIVER=i965"

  echo "✅ Akceleracja GPU skonfigurowana." | tee -a "$LOGFILE"
}