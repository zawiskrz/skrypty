#!/bin/bash

configure_lightdm() {
  echo "🔧 Konfiguracja LightDM dla Qtile..." | tee -a "$LOGFILE"

  CONFIG_DIR="/etc/lightdm"
  CONF_D_DIR="$CONFIG_DIR/lightdm.conf.d"
  CONF_D_FILE="$CONF_D_DIR/01-users.conf"
  MAIN_CONF="$CONFIG_DIR/lightdm.conf"

  sudo mkdir -p "$CONF_D_DIR"

  # Konfiguracja pokazywania użytkowników na ekranie logowania
  sudo tee "$CONF_D_FILE" > /dev/null <<EOF
[Seat:*]
greeter-hide-users=false
greeter-show-manual-login=true
EOF

  # Tworzenie kopii zapasowej głównej konfiguracji
  if [ -f "$MAIN_CONF" ]; then
    sudo cp "$MAIN_CONF" "$MAIN_CONF.bak"
  fi

  # Ustawienie domyślnego greetera GTK
  sudo tee "$MAIN_CONF" > /dev/null <<EOF
[Seat:*]
greeter-session=lightdm-gtk-greeter
greeter-hide-users=false
greeter-show-manual-login=true
user-session=qtile
EOF

  echo "✅ Konfiguracja LightDM zakończona." | tee -a "$LOGFILE"
}
