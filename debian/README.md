# 🧰 Skrypt instalacyjny XFCE dla Debiana 13 (Trixie)

Ten skrypt automatyzuje instalację pełnego środowiska graficznego **XFCE** w systemie Debian 13. Zawiera najważniejsze pakiety, aplikacje użytkowe, konfigurację pulpitu oraz zapory sieciowej.

---

## 📦 Instalowane pakiety

| Pakiet | Przeznaczenie |
|--------|---------------|
| `task-xfce-desktop` | Pełne środowisko XFCE z menedżerem logowania LightDM |
| `openssh-server` | Dostęp SSH do systemu |
| `ufw` | Zapora sieciowa z prostą konfiguracją |
| `network-manager-gnome` | Aplet sieci w trayu |
| `bluez`, `blueman` | Obsługa Bluetooth |
| `pulseaudio`, `pavucontrol`, `libcanberra-pulse` | System dźwięku i kontrola głośności |
| `firefox-esr`, `thunderbird`, `vlc`, `calibre`, `rhythmbox`, `shotwell` | Aplikacje użytkowe |
| `libreoffice`, `libreoffice-l10n-pl`, `libreoffice-help-pl` | Pakiet biurowy z lokalizacją PL |
| `wxmaxima` | Obliczenia symboliczne |
| `python3`, `python3-pip`, `python3-venv` | Środowisko Pythona |
| `mc`, `htop` | Narzędzia terminalowe |
| `x11-xserver-utils` | Narzędzia X11 |
| `papirus-icon-theme` | Ikony systemowe |

---

## 🛠️ Skrypt instalacyjny

Plik: `install_xfce.sh`

```bash
#!/bin/bash

LOGFILE="install_log.txt"

echo "🔧 Aktualizacja pakietów..." | tee -a "$LOGFILE"
sudo apt update 2>&1 | tee -a "$LOGFILE"

echo "📦 Instalacja środowiska graficznego XFCE..." | tee -a "$LOGFILE"
sudo apt install -y \
task-xfce-desktop \
openssh-server ufw \
network-manager-gnome bluez blueman \
pulseaudio pulseaudio-utils pulseaudio-module-bluetooth pavucontrol libcanberra-pulse \
firefox-esr thunderbird vlc calibre rhythmbox shotwell \
libreoffice libreoffice-l10n-pl libreoffice-help-pl \
wxmaxima python3 python3-pip python3-venv \
mc htop x11-xserver-utils papirus-icon-theme 2>&1 | tee -a "$LOGFILE"

echo "🗂️ Kopiowanie konfiguracji użytkownika..." | tee -a "$LOGFILE"
install -d ~/.config/gtk-3.0 ~/.local/share/rhythmbox ~/tapety
cp -f config/gtk-3.0/* ~/.config/gtk-3.0/
cp -f local/rhythmbox/* ~/.local/share/rhythmbox/
cp -f tapety/* ~/tapety/

echo "🖼️ Ustawianie tapety pulpitu (XFCE)..." | tee -a "$LOGFILE"
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/image-path -s ~/tapety/planety.jpg
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/image-style -s 3

echo "🛡️ Konfiguracja zapory UFW..." | tee -a "$LOGFILE"
sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing

for subnet in 192.168.0.0/24 192.168.1.0/24; do
  for port in 22 139 445 1716; do
    sudo ufw allow from $subnet to any port $port proto tcp
  done
done

sudo ufw --force enable
echo "✅ Zapora UFW aktywna." | tee -a "$LOGFILE"

echo "🔄 Restart LightDM..." | tee -a "$LOGFILE"
sudo systemctl restart lightdm

echo "✅ Instalacja zakończona. Środowisko XFCE zostało skonfigurowane." | tee -a "$LOGFILE"
