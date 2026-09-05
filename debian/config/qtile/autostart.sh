#!/bin/sh

# --- MAGISTRALA D-BUS I PORTALE XDG (Wymagane dla LibreWolf / Google News) ---
dbus-update-activation-environment --systemd --all &

# Uruchomienie głównego portalu XDG oraz wtyczki GTK (musi być w tej kolejności!)
/usr/libexec/xdg-desktop-portal &
sleep 1 && /usr/libexec/xdg-desktop-portal-gtk &

# Uruchomienie daemona GNOME Keyring
eval $(gnome-keyring-daemon --start --components=pkcs11,secrets,ssh) &
export SSH_AUTH_SOCK &

# --- EKRAN I MONITORY ---
xrandr --output LVDS-1 --primary --mode 1440x900 --pos 0x0 --rotate normal \
       --output VGA-1 --mode 1920x1080 --pos 1440x0 --rotate normal &

sleep 1 && feh --bg-fill ~/.config/qtile/wallpapers/miedzyzdroje.jpg &
spice-vdagent &

# --- KOMPOZYTOR (Wyłączenie filtrowania kolorów ikon) ---
picom -b &

# --- APLETY DO ZASOBNIKA SYSTEMOWEGO (SYSTRAY) ---
nm-applet &
blueman-applet &
xfce4-power-manager &
pasystray &

# --- POWIADOMIENIA I AUTORYZACJA ---
dunst &
lxpolkit &
