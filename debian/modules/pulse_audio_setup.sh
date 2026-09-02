#!/bin/bash

configure_pulseaudio() {
  echo "🛠️ Instalacja pakietów Pulse audio..." | tee -a "$LOGFILE"
  sudo apt install -y  \
    xfce4-pulseaudio-plugin pulseaudio pulseaudio-utils pavucontrol 2>&1 | tee -a "$LOGFILE"
  echo "🔊 Autostart PulseAudio..." | tee -a "$LOGFILE"
  sudo mkdir -p /etc/xdg/autostart
  sudo tee /etc/xdg/autostart/pulseaudio.desktop > /dev/null <<EOF
[Desktop Entry]
Type=Application
Exec=pulseaudio --start
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=PulseAudio
Comment=Start PulseAudio sound server
EOF
}
