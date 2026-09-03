#!/bin/bash

configure_smb() {
  echo "📡 Instalacja i konfiguracja Samby..." | tee -a "$LOGFILE"

  sudo apt update
  sudo apt install -y samba smbclient gvfs-backends gvfs-fuse | tee -a "$LOGFILE"

  # Weryfikacja i tworzenie katalogów udostępnianych
  for folder in Muzyka Obrazy Wideo; do
    DIR_PATH="/home/$SAMBA_USER/$folder"
    if [ ! -d "$DIR_PATH" ]; then
      echo "📁 Tworzenie katalogu: $DIR_PATH" | tee -a "$LOGFILE"
      mkdir -p "$DIR_PATH"
    fi
    chmod 770 "$DIR_PATH"
    chown "$SAMBA_USER:$SAMBA_USER" "$DIR_PATH"
  done

  # Rejestracja użytkownika w Sambie
  echo -e "$SAMBA_PASS\n$SAMBA_PASS" | sudo smbpasswd -a "$SAMBA_USER"
  sudo smbpasswd -e "$SAMBA_USER"

  # Kopia zapasowa konfiguracji
  if [ -f /etc/samba/smb.conf ] && [ ! -f /etc/samba/smb.conf.bak ]; then
    sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.bak
  fi

  cat <<EOF | sudo tee -a /etc/samba/smb.conf

[Muzyka]
   path = /home/$SAMBA_USER/Muzyka
   valid users = $SAMBA_USER
   browseable = yes
   writable = yes
   create mask = 0770
   directory mask = 0770
   guest ok = no

[Obrazy]
   path = /home/$SAMBA_USER/Obrazy
   valid users = $SAMBA_USER
   browseable = yes
   writable = yes
   create mask = 0770
   directory mask = 0770
   guest ok = no

[Wideo]
   path = /home/$SAMBA_USER/Wideo
   valid users = $SAMBA_USER
   browseable = yes
   writable = yes
   create mask = 0770
   directory mask = 0770
   guest ok = no
EOF

  sudo systemctl restart smbd nmbd
  echo "✅ Samba została skonfigurowana." | tee -a "$LOGFILE"
}
