#!/bin/sh

# --- EKRAN I SPICE (GNOME Boxes / KVM) ---
# Ustawienie rozdzielczości ekranu
xrandr --output Virtual-1 --mode 1920x1080 2>/dev/null || xrandr --output HDMI-1 --mode 1920x1080 2>/dev/null &

# Uruchomienie agenta schowka dla GNOME Boxes / SPICE (kopiowanie/wklejanie z hostem)
spice-vdagent &

# --- WYGLĄD I EFEKTY ---
# Uruchomienie kompozytora okien w tle (przezroczystość, cienie)
picom -b &

# --- APLETY DO ZASOBNIKA SYSTEMOWEGO (SYSTRAY) ---
# Aplet sieci (NetworkManager z network-manager-applet)
nm-applet &

# Aplet do obsługi Bluetooth
blueman-applet &

# Menedżer zasilania XFCE (zarządzanie baterią i wygaszaniem ekranu)
xfce4-power-manager &

# --- POWIADOMIENIA I AUTORYZACJA ---
# Daemon powiadomień systemowych
dunst &

# Agent autoryzacji Polkit (wymagany do okien z prośbą o hasło root/sudo)
lxpolkit &
