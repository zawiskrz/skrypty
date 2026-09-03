# 🧰 Skrypt instalacyjny Qtile dla Debiana 13 (Trixie)

Ten skrypt automatyzuje instalację oraz modularną konfigurację zaawansowanego menedżera okien **Qtile** (X11) w systemie Debian 13. Zapewnia interaktywne menu oparte na narzędziu `dialog`, zoptymalizowane pod kątem wydajności, obsługi multimediów, programowania oraz zarządzania systemem.

---

## 📦 Instalowane pakiety i moduły

| Pakiet / Moduł | Przeznaczenie |
|----------------|---------------|
| `qtile`, `python3-qtile` | Menedżer okien Qtile oraz menedżer pakietów Python `uv` |
| `lightdm`, `lightdm-gtk-greeter` | Menedżer logowania oraz jego interaktywna konfiguracja |
| `picom`, `rofi`, `kitty`, `dunst` | Kompozytor okien, launcher aplikacji, terminal oraz powiadomienia |
| `librewolf`, `thunderbird` | Bezpieczna przeglądarka internetowa oraz klient poczty |
| `code` | Środowisko programistyczne Visual Studio Code |
| `libreoffice-l10n-pl`, `vlc`, `calibre`, `rhythmbox` | Pakiet biurowy oraz odtwarzacze multimedialne |
| `webapp-manager`, `flatpak` | Zarządzanie aplikacjami webowymi oraz pakietami Flatpak |
| `numpy`, `pandas`, `matplotlib`, `jupyter` | Narzędzia Data Science zarządzałe przez `uv` |
| `ufw` | Zapora sieciowa z regułami dla sieci lokalnej (SSH, SMB, KDE Connect) |
| `samba`, `docker-ce` | Udostępnianie zasobów w sieci oraz środowisko kontenerazacji |
| `nvidia-driver`, `cuda-toolkit` | Własnościowe sterowniki graficzne oraz biblioteki CUDA |
| `intel-media-va-driver` | Akceleracja sprzętowa dla zintegrowanych kart Intel |
| `plymouth`, `cups`, `bluez`, `pulseaudio` | Wyciszenie rozruchu, obsługa drukarek, Bluetooth oraz dźwięku |

---

## 🛠️ Skrypt instalacyjny

Plik: `install_qtile.sh`

```bash
#!/bin/bash
source "./config.sh"

echo "🔧 Aktualizacja pakietów..." | tee -a "$LOGFILE"
sudo apt update 2>&1 | tee -a "$LOGFILE"

echo "📦 Instalacja narzędzi interaktywnych..." | tee -a "$LOGFILE"
sudo apt install -y dialog 2>&1 | tee -a "$LOGFILE"

# Interaktywne menu dialogowe
cmd=(dialog --separate-output --checklist "Wybierz komponenty do instalacji:" 30 76 20)
options=(
  1 "[ŚRODOWISKO] X11, LightDM, Fonts, GUI" on
  2 "[WM] Qtile & UV" on
  3 "[LOGIN MANAGER] Konfiguracja LightDM dla Qtile" on
  4 "[PRZEGLĄDARKA] LibreWolf & Thunderbird" on
  5 "[PROGRAMOWANIE] Visual Studio Code" off
  6 "[APLIKACJE] LibreOffice, VLC, Flatpak, WebApp" on
  7 "[PROGRAMOWANIE] Python Data Science" off
  8 "[SYSTEM] Firewall UFW" on
  9 "[SYSTEM] Samba (Udostępnianie plików)" off
  10 "[SYSTEM] Docker" off
  11 "[SYSTEM] Sterowniki NVIDIA" off
  12 "[SYSTEM] CUDA Toolkit" off
  13 "[SYSTEM] Intel GPU (Akceleracja Video)" off
  14 "[SYSTEM] Silent GRUB & Plymouth" off
  15 "[SYSTEM] Obsługa pokrywy laptopa" on
  16 "[SYSTEM] Drukarki (CUPS)" on
  17 "[SYSTEM] Bluetooth" on
  18 "[AUDIO] PulseAudio" on
  19 "Restart usługi LightDM na koniec" off
)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear

# Zapis konfiguracji użytkownika
echo "# Konfiguracja instalatora QTile" > "$CONFIG_FILE"
for choice in $choices; do
  case $choice in
    1) echo "DESKTOP_ENV=true" >> "$CONFIG_FILE" ;;
    2) echo "QTILE=true" >> "$CONFIG_FILE" ;;
    3) echo "LIGHTDM_CONFIG=true" >> "$CONFIG_FILE" ;;
    4) echo "LIBREWOLF=true" >> "$CONFIG_FILE" ;;
    5) echo "VSCODE=true" >> "$CONFIG_FILE" ;;
    6) echo "USER_APPS=true" >> "$CONFIG_FILE" ;;
    7) echo "PYTHON=true" >> "$CONFIG_FILE" ;;
    8) echo "FIREWALL=true" >> "$CONFIG_FILE" ;;
    9) echo "SAMBA=true" >> "$CONFIG_FILE" ;;
    10) echo "DOCKER=true" >> "$CONFIG_FILE" ;;
    11) echo "NVIDIA=true" >> "$CONFIG_FILE" ;;
    12) echo "CUDA=true" >> "$CONFIG_FILE" ;;
    13) echo "INTELGPU=true" >> "$CONFIG_FILE" ;;
    14) echo "GRUB_SILENT=true" >> "$CONFIG_FILE" ;;
    15) echo "LID_POWER_OFF=true" >> "$CONFIG_FILE" ;;
    16) echo "PRINTERS=true" >> "$CONFIG_FILE" ;;
    17) echo "BLUETOOTH=true" >> "$CONFIG_FILE" ;;
    18) echo "PULSE_AUDIO=true" >> "$CONFIG_FILE" ;;
    19) echo "RESTART_LIGHTDM=true" >> "$CONFIG_FILE" ;;
  esac
done

# Wczytanie wybranych opcji
source "$CONFIG_FILE"

# Przygotowanie danych dla Samby przed uruchomieniem modułu
if [[ "$SAMBA" == "true" ]]; then
  SAMBA_USER="${SUDO_USER:-$(logname)}"
  read -s -p "🔑 Podaj hasło dla użytkownika Samba ($SAMBA_USER): " SAMBA_PASS
  echo
fi

# Sekwencyjne wykonywanie modułów
[[ "$DESKTOP_ENV" == "true" ]]     && configure_desktop_environment
[[ "$QTILE" == "true" ]]           && configure_qtile
[[ "$LIGHTDM_CONFIG" == "true" ]]  && configure_lightdm
[[ "$LIBREWOLF" == "true" ]]       && configure_librewolf
[[ "$VSCODE" == "true" ]]          && configure_vscode
[[ "$USER_APPS" == "true" ]]       && configure_apps
[[ "$PYTHON" == "true" ]]          && configure_python
[[ "$FIREWALL" == "true" ]]        && configure_ufw
[[ "$SAMBA" == "true" ]]           && configure_smb
[[ "$DOCKER" == "true" ]]          && configure_docker
[[ "$NVIDIA" == "true" ]]          && configure_nvidia
[[ "$CUDA" == "true" ]]            && configure_cuda
[[ "$INTELGPU" == "true" ]]        && configure_intel_gpu_support
[[ "$GRUB_SILENT" == "true" ]]     && configure_silent_boot
[[ "$LID_POWER_OFF" == "true" ]]   && configure_lid_poweroff
[[ "$PRINTERS" == "true" ]]        && install_printer_support
[[ "$BLUETOOTH" == "true" ]]       && configure_bluetooth
[[ "$PULSE_AUDIO" == "true" ]]     && configure_pulseaudio

if [[ "$RESTART_LIGHTDM" == "true" ]]; then
  echo "🔄 Restart LightDM..." | tee -a "$LOGFILE"
  sudo systemctl restart lightdm
fi

echo "✅ Instalacja zakończona pomyślnie!" | tee -a "$LOGFILE"
