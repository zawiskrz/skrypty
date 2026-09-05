# 🧰 Skrypt instalacyjny i konfiguracja Qtile dla Debiana 13 (Trixie)

Ten zestaw konfiguracji automatyzuje instalację oraz modularną konfigurację zaawansowanego menedżera okien **Qtile** (X11) w systemie Debian 13. Zapewnia interaktywne menu oparte na narzędziu `dialog`, zoptymalizowane pod kątem wydajności, obsługi multimediów, programowania, zarządzania systemem, integracji z pakietami Flatpak oraz dynamicznej zmiany motywów (Dark/Light).

---

## 📦 Instalowane pakiety i moduły

| Pakiet / Moduł | Przeznaczenie |
|----------------|---------------|
| `qtile`, `python3-qtile` | Menedżer okien Qtile oraz menedżer pakietów Python `uv` |
| `lightdm`, `lightdm-gtk-greeter` | Menedżer logowania oraz jego interaktywna konfiguracja |
| `picom`, `rofi`, `kitty`, `dunst` | Kompozytor okien, launcher aplikacji, terminal oraz powiadomienia |
| `librewolf`, `thunderbird` | Bezpieczna przeglądarka internetowa oraz klient poczty |
| `code` | Środowisko programistyczne Visual Studio Code |
| `libreoffice-l10n-pl`, `vlc`, `calibre`, `rhythmbox`, `shotwell` | Pakiet biurowy, menedżer zdjęć oraz odtwarzacze multimedialne |
| `flatpak` | Obsługa pakietów Flatpak (Teams, WhatsApp, YTM Desktop, Video Downloader, Mousam) |
| `numpy`, `pandas`, `matplotlib`, `jupyter` | Narzędzia Data Science zarządzane przez `uv` |
| `ufw` | Zapora sieciowa z regułami dla sieci lokalnej (SSH, SMB, KDE Connect) |
| `samba`, `docker-ce` | Udostępnianie zasobów w sieci oraz środowisko konteneryzacji |
| `nvidia-driver`, `cuda-toolkit` | Własnościowe sterowniki graficzne oraz biblioteki CUDA |
| `intel-media-va-driver` | Akceleracja sprzętowa dla zintegrowanych kart Intel |
| `plymouth`, `cups`, `bluez`, `pulseaudio` | Wyciszenie rozruchu, obsługa drukarek, Bluetooth oraz dźwięku |

---

## ⌨️ Nawigacja, skróty klawiszowe i obsługa myszy w Qtile

Głównym klawiszem modyfikatora (`mod`) jest **Klawisz Super / Windows** (`Mod4`).

### 1. Zarządzanie oknami i ułożeniem (Layout)
* **`Mod + Left / Right / Down / Up`** – Przełączenie fokusu na sąsiednie okno.
* **`Mod + Space`** – Przejście fokusu na kolejne okno.
* **`Mod + Shift + Left / Right / Down / Up`** – Przesunięcie (zamiana pozycji) okna w układzie.
* **`Mod + Ctrl + Left / Right / Down / Up`** – Zmiana rozmiaru (rozciąganie/zwężanie) aktywnego okna.
* **`Mod + N`** – Przywrócenie domyślnych/równych rozmiarów okien.
* **`Mod + Tab`** – Przełączenie trybu układu okien (np. z Columns na Max).
* **`Mod + Shift + Return`** – Przełączenie dzielenia kolumn (split / unsplit).
* **`Mod + F`** – Przełączenie trybu pełnoekranowego (Fullscreen).
* **`Mod + T`** – Przełączenie okna w tryb pływający (Floating).
* **`Mod + Q`** – Zamknięcie (skasowanie) aktywnego okna.

### 2. Wielomonitorowość (Dual-Monitor)
* **`Mod + W`** – Przejście kursor/fokus na kolejny monitor.
* **`Mod + E`** – Przejście kursor/fokus na poprzedni monitor.
* **`Mod + Ctrl + Shift + Left`** – Przeniesienie aktywnego okna na 1. monitor (`LVDS-1`).
* **`Mod + Ctrl + Shift + Right`** – Przeniesienie aktywnego okna na 2. monitor (`VGA-1`).

### 3. Pulpity i wirtualne przestrzenie robocze
* **`Mod + [1..4]`** – Przełączenie na pulpit 1, 2, 3 lub 4.
* **`Mod + Shift + [1..4]`** – Przeniesienie aktywnego okna na pulpit 1, 2, 3 lub 4 wraz z przełączeniem widoku.

### 4. Szybkie uruchamianie aplikacji i skróty systemowe
* **`Mod + Return`** – Uruchomienie terminala (`xfce4-terminal`).
* **`Mod + M`** – Otwarcie menu aplikacyjnego (`jgmenu`).
* **`Mod + R`** – Otwarcie wbudowanego paska uruchamiania poleceń (Prompt).
* **`Mod + Ctrl + D`** – Pokaż / Ukryj pulpit (minimalizacja wszystkich okien).
* **`Mod + Shift + T`** – Dynamiczne przełączenie motywu (Ciemny ⇄ Jasny).
* **`Mod + Shift + C`** – Uruchomienie Visual Studio Code.
* **`Mod + Shift + O`** – Uruchomienie LibreOffice.
* **`Mod + Shift + V`** – Uruchomienie VLC Media Player.
* **`Mod + Ctrl + R`** – Przeładowanie konfiguracji Qtile bez zamykania sesji.
* **`Mod + Ctrl + Q`** – Wylogowanie z Qtile.

### 5. Obsługa Myszki
* **`Mod + Lewy Przycisk Myszy (Button1)`** – Przeciąganie i przemieszczanie okna pływającego.
* **`Mod + Prawy Przycisk Myszy (Button3)`** – Dynamiczna zmiana rozmiaru okna pływającego.
* **`Mod + Środkowy Przycisk Myszy (Button2)`** – Przeniesienie okna pływającego na sam wierzch.

### 6. Pasek zadań i klikalne ikony (Statusbar)
Pasek zadań na górze ekranu zawiera zestaw aktywnych przycisków myszy:
* **`󰍜 Menu`** – Otwiera `jgmenu`.
* **Ikony aplikacji natywnych** (`LibreWolf`, `Thunderbird`, `Thunar`, `VS Code`, `LibreOffice`, `VLC`, `Calibre`, `Shotwell`, `Rhythmbox`).
* **Ikony aplikacji Flatpak** (`Teams`, `WhatsApp`, `YTM Desktop`, `Video Downloader`, `Mousam`).
* **`󰂄` (Menedżer zasilania)** – Uruchamia ustawienia `xfce4-power-manager-settings`.
* **`󰐥` (Przycisk wyłączenia)** – Wywołuje natychmiastowe, bezpieczne zamknięcie systemu za pomocą `systemctl poweroff`.

---

## 🛠️ Skrypt instalacyjny

Plik: `install_qtile.sh`

```bash
#!/bin/bash
source "./config.sh"

# Funkcja pomocnicza do pobierania aplikacji Flatpak
configure_flatpak_apps() {
  echo "📦 Konfiguracja repozytorium Flatpak i instalacja aplikacji..." | tee -a "$LOGFILE"
  sudo apt install -y flatpak 2>&1 | tee -a "$LOGFILE"
  sudo flatpak remote-add --if-not-exists flathub [https://dl.flathub.org/repo/flathub.flatpakrepo](https://dl.flathub.org/repo/flathub.flatpakrepo) 2>&1 | tee -a "$LOGFILE"

  local flatpaks=(
    "com.github.IsmaelMartinez.teams_for_linux"
    "com.ktechpit.whatsie"
    "app.ytmdesktop.ytmdesktop"
    "com.github.unrud.VideoDownloader"
    "io.github.amit9838.mousam"
  )

  for app in "${flatpaks[@]}"; do
    echo "📥 Instalacja Flatpak: $app..." | tee -a "$LOGFILE"
    sudo flatpak install -y flathub "$app" 2>&1 | tee -a "$LOGFILE"
  done
}

# Rozszerzona funkcja instalacji aplikacji użytkowych
configure_apps_extended() {
  echo "🎨 Instalacja aplikacji użytkowych (LibreOffice, VLC, Calibre, Rhythmbox, Shotwell)..." | tee -a "$LOGFILE"
  sudo apt install -y \
    libreoffice \
    libreoffice-l10n-pl \
    vlc \
    calibre \
    rhythmbox \
    shotwell \
    thunar 2>&1 | tee -a "$LOGFILE"
}

echo "🔧 Aktualizacja pakietów..." | tee -a "$LOGFILE"
sudo apt update 2>&1 | tee -a "$LOGFILE"

echo "📦 Instalacja narzędzi interaktywnych..." | tee -a "$LOGFILE"
sudo apt install -y dialog 2>&1 | tee -a "$LOGFILE"

# Interaktywne menu dialogowe z nową pozycją dla Flatpak
cmd=(dialog --separate-output --checklist "Wybierz komponenty do instalacji:" 30 76 20)
options=(
  1 "[ŚRODOWISKO] X11, LightDM, Fonts, GUI" on
  2 "[WM] Qtile & UV" on
  3 "[LOGIN MANAGER] Konfiguracja LightDM dla Qtile" on
  4 "[PRZEGLĄDARKA] LibreWolf & Thunderbird" on
  5 "[PROGRAMOWANIE] Visual Studio Code" off
  6 "[APLIKACJE] LibreOffice, VLC, Shotwell, Calibre" on
  7 "[FLATPAK] Teams, WhatsApp, YTM, VideoDownloader, Mousam" on
  8 "[PROGRAMOWANIE] Python Data Science" off
  9 "[SYSTEM] Firewall UFW" on
  10 "[SYSTEM] Samba (Udostępnianie plików)" off
  11 "[SYSTEM] Docker" off
  12 "[SYSTEM] Sterowniki NVIDIA" off
  13 "[SYSTEM] CUDA Toolkit" off
  14 "[SYSTEM] Intel GPU (Akceleracja Video)" off
  15 "[SYSTEM] Silent GRUB & Plymouth" off
  16 "[SYSTEM] Obsługa pokrywy laptopa" on
  17 "[SYSTEM] Drukarki (CUPS)" on
  18 "[SYSTEM] Bluetooth" on
  19 "[AUDIO] PulseAudio" on
  20 "Restart usługi LightDM na koniec" off
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
    7) echo "FLATPAK_APPS=true" >> "$CONFIG_FILE" ;;
    8) echo "PYTHON=true" >> "$CONFIG_FILE" ;;
    9) echo "FIREWALL=true" >> "$CONFIG_FILE" ;;
    10) echo "SAMBA=true" >> "$CONFIG_FILE" ;;
    11) echo "DOCKER=true" >> "$CONFIG_FILE" ;;
    12) echo "NVIDIA=true" >> "$CONFIG_FILE" ;;
    13) echo "CUDA=true" >> "$CONFIG_FILE" ;;
    14) echo "INTELGPU=true" >> "$CONFIG_FILE" ;;
    15) echo "GRUB_SILENT=true" >> "$CONFIG_FILE" ;;
    16) echo "LID_POWER_OFF=true" >> "$CONFIG_FILE" ;;
    17) echo "PRINTERS=true" >> "$CONFIG_FILE" ;;
    18) echo "BLUETOOTH=true" >> "$CONFIG_FILE" ;;
    19) echo "PULSE_AUDIO=true" >> "$CONFIG_FILE" ;;
    20) echo "RESTART_LIGHTDM=true" >> "$CONFIG_FILE" ;;
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
[[ "$USER_APPS" == "true" ]]       && configure_apps_extended
[[ "$FLATPAK_APPS" == "true" ]]    && configure_flatpak_apps
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