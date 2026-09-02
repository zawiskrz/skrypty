#!/bin/sh

# --- MAGISTRALA D-BUS I KLUCZE SYSTEMOWE (Naprawia problem z Keyring w VS Code) ---
# Aktualizacja środowiska D-Bus dla całej sesji
dbus-update-activation-environment --systemd --all &

# Uruchomienie daemona GNOME Keyring dla obsługi haseł i tokenów OAuth (GitHub/MS Authenticator)
eval $(gnome-keyring-daemon --start --components=pkcs11,secrets,ssh) &
export SSH_AUTH_SOCK &

# --- EKRAN I SPICE (GNOME Boxes / KVM) ---
# Ustawienie rozdzielczości ekranu
xrandr --output Virtual-1 --mode 1920x1080 2>/dev/null || xrandr --output HDMI-1 --mode 1920x1080 2>/dev/null &

# Uruchomienie agenta schowka dla GNOME Boxes / SPICE (kopiowanie/wklejanie z hostem)
spice-vdagent &

# --- TAPETA I WYGLĄD ---
# Ustawienie tapety (upewnij się, że masz zainstalowany pakiet 'feh')
# feh --bg-fill /ścieżka/do/twojej/tapety.jpg &

# Uruchomienie kompozytora okien w tle (przezroczystość, cienie)
picom -b &

# --- APLETY DO ZASOBNIKA SYSTEMOWEGO (SYSTRAY) ---
# Aplet sieci (NetworkManager)
nm-applet &

# Aplet do obsługi Bluetooth
blueman-applet &

# Menedżer zasilania XFCE (zarządzanie baterią i wygaszaniem ekranu)
xfce4-power-manager &

# Aplet głośności w zasobniku (opcjonalnie, wymaga: volumeicon-alsa)
# volumeicon &

# --- POWIADOMIENIA, SCHOWEK I AUTORYZACJA ---
# Daemon powiadomień systemowych
dunst &

# Agent autoryzacji Polkit (wymagany do okien z prośbą o hasło root/sudo)
lxpolkit &

# Menedżer schowka zapamiętujący historię kopiowania (opcjonalnie, wymaga: greenclip / xclip)
# greenclip daemon &
