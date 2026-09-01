#!/bin/sh

# --- EKRAM I SPICE (GNOME Boxes / KVM) ---
# Ustawienie rozdzielczości ekranu (fallback do HDMI-1)
xrandr --output Virtual-1 --mode 1920x1080 2>/dev/null || xrandr --output HDMI-1 --mode 1920x1080 2>/dev/null &

# Uruchomienie agenta schowka dla GNOME Boxes / SPICE (kopiowanie/wklejanie z hostem)
spice-vdagent &

# --- WYGLĄD I EFEKTY ---
# Uruchomienie kompozytora okien w tle (przezroczystość, cienie)
picom -b &

# --- APLETY DO ZASOBNIKA SYSTEMOWEGO (SYSTRAY) ---
# Aplet sieci (Wi-Fi / Ethernet)
nm-tray &
# Jeśli używasz klasycznego nm-applet, zamień na: nm-applet &

# Aplet sterowania głośnością (PulseAudio / PipeWire)
pasystray &

# Aplet do obsługi Bluetooth
blueman-applet &

# Menedżer zasilania (zarządzanie baterią i wygaszaniem ekranu)
xfce4-power-manager &

# --- POWIADOMIENIA I AUTORYZACJA ---
# Daemon powiadomień systemowych
dunst &

# Agent autoryzacji Polkit (wymagany do okien z prośbą o hasło root/sudo)
lxpolkit &
