#!/bin/bash

configure_zram() {
  echo "⚡ Instalacja i konfiguracja zRAM (zram-tools)..." | tee -a "$LOGFILE"

  # 1. Instalacja pakietu zram-tools
  sudo apt update
  sudo apt install -y --no-install-recommends zram-tools 2>&1 | tee -a "$LOGFILE"

  # 2. Wyłączenie starego zRAM przed zmianą konfiguracji
  sudo zramswap stop > /dev/null 2>&1

  # 3. Nadpisanie konfiguracji /etc/default/zramswap
  # PERCENT=200 wymusza utworzenie zRAM o wielkości podwójnego fizycznego RAM-u (ok. 3.8GB - 4GB)
  cat <<EOF | sudo tee /etc/default/zramswap > /dev/null
# Konfiguracja zram-tools
ALGORITHM=zstd
PERCENT=200
PRIORITY=100
EOF

  # 4. Optymalizacja parametrów jądra (sysctl) dla wydajnego użycia zRAM
  cat <<EOF | sudo tee /etc/sysctl.d/99-zram.conf > /dev/null
# Chętniej korzystaj ze Swapu w RAM-ie przed zwalnianiem buforów
vm.swappiness=180
# Optymalizowanie usuwania nieaktywnych stron z pamięci
vm.watermark_boost_factor=0
vm.watermark_scale_factor=125
vm.page-cluster=0
EOF

  # Zastosowanie nowych ustawień sysctl bez restartu
  sudo sysctl --system > /dev/null 2>&1

  # 5. Uruchomienie usługi zramswap
  sudo systemctl restart zramswap.service | tee a "$LOGFILE"
  sudo systemctl enable zramswap.service

  echo "✅ zRAM został skonfigurowany na 200% RAM-u (ok. 4GB ZRAM, algorytm zstd)." | tee -a "$LOGFILE"
}
