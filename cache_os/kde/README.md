# Skrypty konfigurujące środowisko robocze KDE dla CachyOS Linux

Zestaw modularnych skryptów instalacyjnych i konfiguracyjnych pozwalający na **odtworzenie 1:1 środowiska pracy** z tego laptopa na nowej maszynie z czystą instalacją **CachyOS Linux** (ze środowiskiem **KDE Plasma 6**).

Skrypty zostały zaprojektowane na wzór architektury z podkatalogu `debian/`, wprowadzając modułowość, pełną idempotencję, interaktywne menu `dialog` oraz bezpieczną konfigurację z wykorzystaniem natywnych narzędzi KDE (`kwriteconfig6`).

---

## 📁 Struktura katalogu `cache_os/kde`

```text
cache_os/kde/
├── config.sh                 # Funkcje pomocnicze (logowanie, instalatory pacman/AUR, multilib), ładowanie modułów
├── install_kde.sh            # Główny skrypt uruchomieniowy (menu dialog + tryb automatyczny, obsługa --backup / --restore)
├── README.md                 # Niniejsza dokumentacja
├── config/
│   ├── smb.conf.template     # Szablon konfiguracji Samby z udziałami domowymi
│   └── weather_places.json   # Lista miejscowości dla widgetu pogody (Skierniewice, Warszawa itp.)
├── local/
│   ├── applications/         # Skróty pulpitowe (.desktop) dla WebApps i pakietu Office
│   └── ice/icons/            # Ikony serwisów internetowych (Netflix, Canal+, Disney+, Teams itp.)
└── modules/
    ├── 01_system_base.sh         # [1] Repozytorium multilib, paru (AUR), narzędzia CLI, powłoka fish
    ├── 02_kde_environment.sh     # [2] KDE Connect (sshfs), Dysk Google, Kalendarz, KWin, Dolphin, pogoda
    ├── 03_firewall_ufw.sh        # [3] Zapora UFW (odblokowanie portów KDE Connect, SSH, Samba dla LAN)
    ├── 04_samba.sh               # [4] Serwer Samba (udziały Muzyka, Obrazy, Wideo, smbpasswd)
    ├── 05_ssh.sh                 # [5] Serwer OpenSSH, generowanie klucza ed25519, obsługa w fish
    ├── 06_browsers.sh            # [6] Firefox (PL), Google Chrome (AUR), Microsoft Edge (AUR)
    ├── 07_office_apps.sh         # [7] LibreOffice Fresh (PL), słowniki pisowni, Okular, Calibre, Thunderbird
    ├── 08_dev_tools.sh           # [8] VS Code, PyCharm Community, R, RStudio Desktop, Git, Meld
    ├── 09_multimedia.sh          # [9] VLC + kodeki, Haruna, Handbrake, Flatpaki (YTMDesktop, Whatsie)
    ├── 10_printers_bluetooth.sh  # [10] Serwis drukowania CUPS (Gutenprint, HP) i obsługa Bluetooth
    ├── 11_intel_gpu.sh           # [11] Sterowniki Intel GPU, akceleracja VA-API, Vulkan, OpenCL
    ├── 12_wine_playonlinux.sh    # [12] PlayOnLinux i biblioteki 32-bit (wsparcie Microsoft Office / Excel)
    ├── 13_webapps.sh             # [13] WebApp-Manager oraz aplikacje streamingowe i Teams
    ├── 14_backup_private.sh      # [14] Tworzenie prywatnej kopii zapasowej na pendrive (SSH, KWallet, Wi-Fi)
    └── 15_restore_private.sh     # [15] Przywracanie prywatnej kopii zapasowej z pendrive'a/pliku
```

---

## 🧩 Opis modułów

| Nr | Moduł | Kluczowe pakiety i działania |
| :---: | :--- | :--- |
| **01** | `01_system_base.sh` | Odblokowanie `[multilib]`, instalacja `paru`, narzędzia `fastfetch`, `btop`, `micro`, `mc`, `ripgrep`, konfiguracja powłoki `fish`. |
| **02** | `02_kde_environment.sh` | Instalacja `kdeconnect` + `sshfs` (rozwiązuje problem z przeglądaniem pamięci telefonu w Dolphinie!), `kio-gdrive`, `kdepim-addons` (Google Calendar), `plasma-applets-weather-widget-3`. Konfiguracja KWin (kafelkowanie 3-kolumnowe, ochrona wzroku Night Color 3400K, 2 pulpity). |
| **03** | `03_firewall_ufw.sh` | Instalacja i aktywacja UFW (`gufw`). Odblokowanie portów `1714:1764` (TCP/UDP) dla KDE Connect oraz portów 22 (SSH) i 139/445 (Samba) dla lokalnych podsieci LAN (`192.168.0.0/24`, `192.168.1.0/24`, `10.0.2.0/24`). |
| **04** | `04_samba.sh` | Konfiguracja serwera Samba pod Arch/CachyOS (`smb.service`, `nmb.service`). Utworzenie folderów `Muzyka`, `Obrazy`, `Wideo` z uprawnieniami `0770` i dodanie użytkownika do `smbpasswd`. |
| **05** | `05_ssh.sh` | Aktywacja `sshd.service`, wygenerowanie klucza `id_ed25519` dla GitHuba oraz automatyczne uruchamianie `ssh-agent` w powłoce Fish. |
| **06** | `06_browsers.sh` | Instalacja `firefox` + pakietu językowego `firefox-i18n-pl`, `plasma-browser-integration`, oraz z AUR: `google-chrome` i `microsoft-edge-stable-bin`. |
| **07** | `07_office_apps.sh` | `libreoffice-fresh` z polskim pakietem językowym `libreoffice-fresh-pl`, słowniki `hunspell-pl`, `mythes-pl`, `okular`, `calibre`, `thunderbird`. |
| **08** | `08_dev_tools.sh` | Środowiska deweloperskie: `code` (VS Code), `pycharm-community-edition`, `r` + `rstudio-desktop-bin` (AUR), `git`, `python`, `meld`. |
| **09** | `09_multimedia.sh` | Odtwarzacz `vlc` ze wszystkimi wtyczkami, `haruna`, `elisa`, transkoder `handbrake`, kodeki GStreamer oraz Flatpaki: `YTMDesktop`, `Whatsie`. |
| **10** | `10_printers_bluetooth.sh` | Stos drukowania CUPS (`cups`, `cups-pdf`, `hplip`, `gutenprint`) i usługi Bluetooth (`bluez`, `bluedevil`). |
| **11** | `11_intel_gpu.sh` | Akceleracja sprzętowa wideo dla układów zintegrowanych Intel (`vulkan-intel`, `opencl-mesa`, `libva-intel-driver-irql` / `intel-media-driver`). |
| **12** | `12_wine_playonlinux.sh` | Pakiety 32-bitowe (`lib32-mesa`, `lib32-libpulse`, `lib32-vulkan-intel` itd.) eliminujące błędy uruchamiania programów 32-bitowych w Wine (m.in. Microsoft Excel 2010), instalacja PlayOnLinux. |
| **13** | `13_webapps.sh` | Instalacja `webapp-manager`, wdrożenie ikon ICE oraz skrótów `.desktop` dla Netflix, Canal+, Disney+, HBO Max, Player, Prime Video, Teams, TVN GO, YouTube z automatycznym mapowaniem ścieżek do nowego użytkownika. |
| **14** | `14_backup_private.sh` | Tworzy zaszyfrowaną/bezpieczną paczkę `.tar.gz` z danymi prywatnymi: klucze SSH (`~/.ssh`), tożsamość Gita (`~/.gitconfig`), portfel KDE (`kwalletd`), konta Google/Microsoft, hasła sieci Wi-Fi oraz opcjonalnie sesje WebApps. Automatycznie wykrywa pendrive. |
| **15** | `15_restore_private.sh` | Przywraca powyższą paczkę na nowym komputerze, dbając o rygorystyczne uprawnienia bezpieczeństwa SSH (`chmod 700`, `chmod 600`) oraz przeładowanie usług sieciowych. |

---

## 🔒 Zarządzanie prywatnymi danymi (Backup & Restore na Pendrive)

Pliki prywatne (klucze SSH, hasła Wi-Fi, portfel KDE) **nie powinny trafić do repozytorium GitHub**. Do ich wygodnego i bezpiecznego przenoszenia służą dedykowane moduły 14 i 15:

### Krok A: Na starym laptopie (tworzenie kopii)
Włóż pendrive do gniazda USB i uruchom:
```bash
./install_kde.sh --backup
```
*Skrypt wykryje pendrive w `/run/media/$USER/`, zapyta czy zapisać plik bezpośrednio na nim, zapyta o dołączenie sesji WebApp i utworzy archiwum z uprawnieniami `chmod 600`.*

Możesz też zaznaczyć opcję **[14]** w interaktywnym menu `./install_kde.sh`.

---

### Krok B: Na nowym laptopie (przywrócenie kopii)
Podłącz pendrive do nowego laptopa i uruchom:
```bash
./install_kde.sh --restore
```
*Skrypt przeskanuje pendrive w poszukiwaniu kopii, zweryfikuje spójność archiwum, odtworzy klucze SSH, konfigurację Gita, hasła Wi-Fi (restartując NetworkManager) oraz portfel KWallet.*

Alternatywnie możesz wybrać opcję **[15]** w menu dialogowym obok pozostałych modułów — instalator automatycznie przywróci kopię **przed** konfiguracją innych komponentów, dzięki czemu moduł SSH nie nadpisze Twojego oryginalnego klucza!

---

## 🚀 Instrukcja instalacji środowiska na nowym laptopie

### 1. Klonowanie repozytorium
Na nowo zainstalowanym CachyOS otwórz terminal i sklonuj swoje repozytorium:
```bash
git clone https://github.com/zawiskrz/skrypty.git
cd skrypty/cache_os/kde
```

### 2. Uruchomienie instalatora

#### Opcja A: Menu interaktywne (zalecana)
```bash
./install_kde.sh
```
Pojawi się okno dialogowe z zaznaczonymi komponentami. Możesz spacją odznaczyć to, czego ewentualnie nie potrzebujesz na nowej maszynie, lub zaznaczyć opcję **[15] Przywróć prywatną kopię**, jeśli masz podłączony pendrive.

#### Opcja B: Pełna automatyczna instalacja standardowa
```bash
./install_kde.sh --all
```
*(Instaluje standardowe moduły 1-13 bez ingerencji w prywatne archiwa).*

---

## 📌 Kroki po instalacji (jednorazowe czynności)

1. **Restart systemu:**
   Zrestartuj komputer lub przeloguj się, aby zaktualizować sesję KDE Plasma, zmienne środowiskowe i usługi.
   ```bash
   systemctl reboot
   ```

2. **Konta sieciowe (Google / Microsoft):**
   *(Tylko jeśli nie przywróciłeś kopii prywatnej)*:
   - Wejdź w **Ustawienia Systemowe** $\rightarrow$ **Konta sieciowe** (Online Accounts).
   - Zaloguj się na konto Google (aktywuje to automatycznie Dysk Google w Dolphinie oraz synchronizację Kalendarza w widgecie zegara).
   - Zaloguj się na konto Microsoft, jeśli korzystasz z OneDrive.

3. **Klucz SSH do GitHuba:**
   *(Tylko jeśli nie przywróciłeś kopii prywatnej)*:
   Wyświetl nowo wygenerowany klucz publiczny:
   ```bash
   cat ~/.ssh/id_ed25519.pub
   ```
   i wklej go w ustawieniach swojego konta na GitHubie (**Settings** $\rightarrow$ **SSH and GPG keys**).
