#!/bin/bash

# 🔍 Funkcja dodająca linię, jeśli jej nie ma
add_if_missing() {
    local line="$1"
    if grep -qxF "$line" "$BASHRC"; then
        echo "⏭️ Pomijam: '$line' już istnieje." | tee -a "$LOGFILE"
    else
        echo "$line" >> "$BASHRC"
        echo "✅ Dodano: $line" | tee -a "$LOGFILE"
    fi
}


configure_intel_gpu_support(){
  echo "🎮 Konfiguracja wsparcia GPU (VAAPI, Vulkan, OpenCL)..." | tee -a "$LOGFILE"

  # 🔒 Kopia zapasowa sources.list
  echo "📦 Tworzenie kopii zapasowej sources.list..." | tee -a "$LOGFILE"
  sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak

  # 📝 Nadpisanie wpisów repozytoriów Debian Trixie
  echo "📝 Aktualizacja wpisów repozytoriów Debian Trixie..." | tee -a "$LOGFILE"
  sudo tee /etc/apt/sources.list > /dev/null <<EOF
deb http://ftp.task.gda.pl/debian/ trixie main contrib non-free non-free-firmware
deb-src http://ftp.task.gda.pl/debian/ trixie main contrib non-free non-free-firmware

deb http://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware
deb-src http://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware

deb http://ftp.task.gda.pl/debian/ trixie-updates main contrib non-free non-free-firmware
deb-src http://ftp.task.gda.pl/debian/ trixie-updates main contrib non-free non-free-firmware
EOF

  # 🔄 Aktualizacja listy pakietów
  echo "🔄 Aktualizacja listy pakietów APT..." | tee -a "$LOGFILE"
  sudo apt update | tee -a "$LOGFILE"

  # 📦 Instalacja sterowników GPU i narzędzi
  echo "📦 Instalacja: VAAPI, Vulkan, OpenCL, Mesa, narzędzia..." | tee -a "$LOGFILE"
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

  # 🧪 Weryfikacja VAAPI
  echo "🧪 Weryfikacja VAAPI:" | tee -a "$LOGFILE"
  vainfo | tee -a "$LOGFILE"

  # 🧪 Weryfikacja OpenCL
  echo "🧪 Weryfikacja OpenCL:" | tee -a "$LOGFILE"
  clinfo | tee -a "$LOGFILE"

  # 🧪 Weryfikacja Vulkan
  echo "🧪 Weryfikacja Vulkan:" | tee -a "$LOGFILE"
  vulkaninfo | tee -a "$LOGFILE"

   echo "🎛️ Dodanie wpisów do .bashrc ..." | tee -a "$LOGFILE"
  BASHRC="/home/$(logname)/.bashrc"
  # 📦 Sprawdź, czy plik .bashrc istnieje
  if [ ! -f "$BASHRC" ]; then
      echo "📄 Plik .bashrc nie istnieje. Tworzę nowy..." | tee -a "$LOGFILE"
      touch "$BASHRC"
  fi
  # 🚀 Dodaj alias i zmienne środowiskowe
  add_if_missing "alias chrome-gpu='LIBVA_DRIVER_NAME=i965 google-chrome --use-gl=desktop --enable-zero-copy --ignore-gpu-blocklist --enable-gpu-rasterization --enable-native-gpu-memory-buffers --enable-features=VaapiVideoDecoder --ozone-platform=x11'"
  add_if_missing "export MOZ_ENABLE_WAYLAND=0"
  add_if_missing "export MOZ_WEBRENDER=1"
  add_if_missing "export MOZ_ACCELERATED=1"
  add_if_missing "export LIBVA_DRIVER_NAME=i965"
  add_if_missing "export VDPAU_DRIVER=i965"
  echo "✅ Konfiguracja GPU zakończona pomyślnie." | tee -a "$LOGFILE"
}
