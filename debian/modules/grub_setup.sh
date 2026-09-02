#!/bin/bash

configure_silent_boot(){
  echo "🔧 Konfiguracja cichego startu systemu (GRUB + logi)..." | tee -a "$LOGFILE"

  # Edycja pliku GRUB
  echo "📝 Modyfikacja /etc/default/grub..." | tee -a "$LOGFILE"
  sudo sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' /etc/default/grub
  sudo sed -i 's/^GRUB_TIMEOUT_STYLE=.*/GRUB_TIMEOUT_STYLE=hidden/' /etc/default/grub

  # Dodanie lub aktualizacja parametrów GRUB_CMDLINE_LINUX_DEFAULT
  sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash loglevel=3 rd.systemd.show_status=auto rd.udev.log-priority=3 vt.global_cursor_default=0"/' /etc/default/grub

  # Aktualizacja konfiguracji GRUB
  echo "🔄 Aktualizacja GRUB..." | tee -a "$LOGFILE"
  sudo update-grub | tee -a "$LOGFILE"

  # Instalacja Plymouth (jeśli nie jest zainstalowany)
  echo "🎨 Instalacja Plymouth i ustawienie motywu..." | tee -a "$LOGFILE"
  sudo apt install -y plymouth plymouth-themes | tee -a "$LOGFILE"
  sudo plymouth-set-default-theme -R spinner | tee -a "$LOGFILE"

  # Aktualizacja initramfs
  echo "📦 Aktualizacja initramfs..." | tee -a "$LOGFILE"
  sudo update-initramfs -u | tee -a "$LOGFILE"

  echo "✅ Konfiguracja zakończona. System powinien uruchamiać się w trybie cichym." | tee -a "$LOGFILE"
}
