#!/bin/sh

# Ustawienie rozdzielczości ekranu dla GNOME Boxes / KVM (fallback do HDMI-1)
xrandr --output Virtual-1 --mode 1920x1080 2>/dev/null || xrandr --output HDMI-1 --mode 1920x1080 2>/dev/null &

# Uruchomienie agenta schowka dla GNOME Boxes / SPICE
spice-vdagent &

# Uruchomienie kompozytora okien w tle
picom -b &
