#!/bin/bash

configure_silent_boot() {
  echo "🔧 Konfiguracja cichego startu systemu (GRUB)..." | tee -a "$LOGFILE"

  sudo sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' /etc/default/grub
  sudo sed -i 's/^GRUB_TIMEOUT_STYLE=.*/GRUB_TIMEOUT_STYLE=hidden/' /etc/default/grub
  sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash loglevel=3 rd.systemd.show_status=auto rd.udev.log-priority=3 vt.global_cursor_default=0"/' /etc/default/grub

  sudo update-grub | tee -a "$LOGFILE"

  sudo apt install -y plymouth plymouth-themes | tee -a "$LOGFILE"
  sudo plymouth-set-default-theme -R spinner | tee -a "$LOGFILE"
  sudo update-initramfs -u | tee -a "$LOGFILE"

  echo "✅ Cichy start GRUB skonfigurowany." | tee -a "$LOGFILE"
}
