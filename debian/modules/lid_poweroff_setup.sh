#!/bin/bash

configure_lid_poweroff() {
  echo "🔧 Konfiguracja zachowania pokrywy laptopa i monitorów..." | tee -a "$LOGFILE"

  local config_file="/etc/systemd/logind.conf"
  local backup_file="/etc/systemd/logind.conf.bak"

  sudo cp "$config_file" "$backup_file"
  sudo sed -i '/^HandleLidSwitch=/d' "$config_file"
  sudo sed -i '/^HandleLidSwitchExternalPower=/d' "$config_file"
  echo "HandleLidSwitch=ignore" | sudo tee -a "$config_file" > /dev/null
  echo "HandleLidSwitchExternalPower=ignore" | sudo tee -a "$config_file" > /dev/null

  sudo systemctl restart systemd-logind

  sudo apt install -y acpid
  sudo systemctl enable acpid
  sudo systemctl start acpid

  local script_path="/usr/local/bin/lid-monitor-switch.sh"
  local user_name="${SUDO_USER:-$(logname)}"

  sudo tee "$script_path" > /dev/null <<EOF
#!/bin/bash

export DISPLAY=:0
export XAUTHORITY="/home/$user_name/.Xauthority"

LID_STATE=\$(cat /proc/acpi/button/lid/LID*/state 2>/dev/null | awk '{print \$2}')
POWER_STATE=\$(cat /sys/class/power_supply/AC/online 2>/dev/null || echo "1")

LAPTOP=\$(xrandr --query 2>/dev/null | grep " connected" | grep -E "eDP|LVDS" | awk '{print \$1}')
EXTERNAL=\$(xrandr --query 2>/dev/null | grep " connected" | grep -vE "eDP|LVDS" | awk '{print \$1}')

if [ "\$LID_STATE" = "closed" ]; then
    if [ "\$POWER_STATE" = "0" ]; then
        systemctl poweroff
    else
        if [ -n "\$LAPTOP" ] && [ -n "\$EXTERNAL" ]; then
            xrandr --output "\$LAPTOP" --off --output "\$EXTERNAL" --auto --primary
        fi
    fi
else
    if [ -n "\$LAPTOP" ] && [ -n "\$EXTERNAL" ]; then
        xrandr --output "\$EXTERNAL" --auto --primary --output "\$LAPTOP" --auto --left-of "\$EXTERNAL"
    fi
fi
EOF

  sudo chmod +x "$script_path"

  local acpi_event_file="/etc/acpi/events/lid-monitor"
  sudo tee "$acpi_event_file" > /dev/null <<EOF
event=button/lid.*
action=su -l $user_name -c "$script_path"
EOF

  sudo systemctl restart acpid

  # Uniwersalny wpis autostartu XDG (aktywny również w Qtile)
  local autostart_dir="/home/$user_name/.config/autostart"
  mkdir -p "$autostart_dir"

  sudo tee "$autostart_dir/lid-monitor.desktop" > /dev/null <<EOF
[Desktop Entry]
Type=Application
Exec=$script_path
Hidden=false
NoDisplay=false
Name=Monitor Lid Switch
Comment=Przełącza ekrany po starcie sesji graficznej
EOF

  sudo chown -R "$user_name:$user_name" "$autostart_dir"
  echo "✅ Konfiguracja pokrywy zakończona." | tee -a "$LOGFILE"
}