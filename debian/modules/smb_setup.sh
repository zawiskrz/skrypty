#!/bin/bash

configure_smb() {
  echo "📡 Instalacja Samby z autoryzacją..." | tee -a "$LOGFILE"

  # Instalacja Samby
  sudo apt update
  sudo apt install -y samba smbclient gvfs-backends gvfs-fuse | tee -a "$LOGFILE"

  # Dodanie użytkownika do Samby
  echo -e "$SAMBA_PASS\n$SAMBA_PASS" | sudo smbpasswd -a "$SAMBA_USER"
  sudo smbpasswd -e "$SAMBA_USER"

#  # Tworzenie katalogów
#  mkdir -p /home/$SAMBA_USER/Obrazy /home/$SAMBA_USER/Wideo
#  chmod 770 /home/$SAMBA_USER/Obrazy /home/$SAMBA_USER/Wideo
#  chown $SAMBA_USER:$SAMBA_USER /home/$SAMBA_USER/Obrazy /home/$SAMBA_USER/Wideo

  # Backup i konfiguracja smb.conf
  sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.bak

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

  # Restart usług
  sudo systemctl restart smbd nmbd
}