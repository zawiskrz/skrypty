#!/bin/bash
# ==============================================================================
# Główny skrypt instalacyjny środowiska pracy KDE pod CachyOS Linux
# ==============================================================================

set -e

if [[ $EUID -eq 0 ]]; then
    echo "❌ BŁĄD: Nie uruchamiaj instalatora bezpośrednio jako root (przez sudo)!"
    echo "   Uruchom go jako zwykły użytkownik: ./install_kde.sh"
    echo "   Skrypt sam poprosi o uprawnienia administratora w momentach, gdy są one wymagane."
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

echo "=========================================================="
echo "🚀 Instalator i konfigurator środowiska KDE dla CachyOS"
echo "=========================================================="
echo

# 1. Aktualizacja bazy pakietów
log_step "Aktualizacja bazy pakietów pacman..."
sudo pacman -Sy --noconfirm 2>&1 | tee -a "$LOGFILE"

# 2. Zapewnienie narzędzia dialog
if ! command -v dialog &>/dev/null; then
    log_step "Instalacja narzędzia dialog..."
    sudo pacman -S --needed --noconfirm dialog 2>&1 | tee -a "$LOGFILE"
fi

# Obsługa dedykowanych flag CLI (--all, --backup, --restore)
if [[ "$1" == "--backup" ]]; then
    create_private_backup
    exit 0
fi

if [[ "$1" == "--restore" ]]; then
    restore_private_backup
    exit 0
fi

AUTO_MODE=false
if [[ "$1" == "--all" || "$1" == "-y" ]]; then
    AUTO_MODE=true
fi

if [[ "$AUTO_MODE" == "true" ]]; then
    log_info "Uruchomiono w trybie automatycznym (--all). Standardowe moduły (1-13) zostaną zainstalowane."
    choices="1 2 3 4 5 6 7 8 9 10 11 12 13"
else
    # Interaktywne menu dialogowe
    cmd=(dialog --separate-output --checklist "Wybierz komponenty środowiska KDE do instalacji/konfiguracji:" 28 86 17)
    options=(
        1  "[SYSTEM] Baza systemu, paru (AUR) i narzędzia CLI" on
        2  "[KDE] KDE Connect (sshfs), kio-gdrive, widget pogody, KWin" on
        3  "[BEZPIECZEŃSTWO] Firewall UFW (reguły KDE Connect, SSH, Samba)" on
        4  "[SIEĆ] Serwer Samba (udziały Muzyka, Obrazy, Wideo)" on
        5  "[SIEĆ] Serwer OpenSSH i klucz SSH ed25519" on
        6  "[PRZEGLĄDARKI] Firefox (PL), Google Chrome, Microsoft Edge" on
        7  "[BIURO] LibreOffice (PL), Okular, Calibre, Thunderbird" on
        8  "[PROGRAMOWANIE] VS Code, PyCharm, R, RStudio, Git, Meld" on
        9  "[MULTIMEDIA] VLC + kodeki, Haruna, Handbrake, Flatpaki" on
        10 "[SPRZĘT] Drukarki (CUPS) i Bluetooth" on
        11 "[GRAFIKA] Sterowniki Intel GPU i akceleracja wideo VA-API" on
        12 "[WINE] PlayOnLinux i biblioteki 32-bit (wsparcie MS Office)" on
        13 "[WEBAPPS] WebApp Manager i aplikacje VOD/Teams" on
        14 "[BACKUP] Utwórz prywatną kopię (SSH, KWallet, Wi-Fi, Konta)" off
        15 "[RESTORE] Przywróć prywatną kopię z pendrive'a/pliku" off
    )

    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty) || {
        echo "Anulowano instalację."
        exit 0
    }
    clear
fi

# Zapis wybranej konfiguracji
echo "# Wygenerowano: $(date)" > "$CONFIG_FILE"
for choice in $choices; do
    case $choice in
        1)  echo "MOD_SYSTEM_BASE=true" >> "$CONFIG_FILE" ;;
        2)  echo "MOD_KDE_ENV=true" >> "$CONFIG_FILE" ;;
        3)  echo "MOD_UFW=true" >> "$CONFIG_FILE" ;;
        4)  echo "MOD_SAMBA=true" >> "$CONFIG_FILE" ;;
        5)  echo "MOD_SSH=true" >> "$CONFIG_FILE" ;;
        6)  echo "MOD_BROWSERS=true" >> "$CONFIG_FILE" ;;
        7)  echo "MOD_OFFICE=true" >> "$CONFIG_FILE" ;;
        8)  echo "MOD_DEV_TOOLS=true" >> "$CONFIG_FILE" ;;
        9)  echo "MOD_MULTIMEDIA=true" >> "$CONFIG_FILE" ;;
        10) echo "MOD_PRINTERS_BT=true" >> "$CONFIG_FILE" ;;
        11) echo "MOD_INTEL_GPU=true" >> "$CONFIG_FILE" ;;
        12) echo "MOD_WINE_POL=true" >> "$CONFIG_FILE" ;;
        13) echo "MOD_WEBAPPS=true" >> "$CONFIG_FILE" ;;
        14) echo "MOD_BACKUP_PRIVATE=true" >> "$CONFIG_FILE" ;;
        15) echo "MOD_RESTORE_PRIVATE=true" >> "$CONFIG_FILE" ;;
    esac
done

source "$CONFIG_FILE"

# Jeśli wybrano przywracanie kopii prywatnej, wykonaj je na początku
# (dzięki temu moduł SSH nie nadpisze Twojego oryginalnego klucza!)
[[ "$MOD_RESTORE_PRIVATE" == "true" ]] && restore_private_backup

# Zapytanie o hasło Samby przed rozpoczęciem, jeśli moduł Samby jest włączony
if [[ "$MOD_SAMBA" == "true" && -z "$SAMBA_PASS" ]]; then
    SAMBA_USER="${SUDO_USER:-$USER}"
    if [[ -t 0 ]]; then
        echo
        read -s -p "🔑 Podaj hasło dla użytkownika Samba ($SAMBA_USER): " SAMBA_PASS
        echo
        export SAMBA_PASS
        export SAMBA_USER
    else
        log_warn "Brak aktywnego terminala tty. Hasło Samby można ustawić później: sudo smbpasswd -a $SAMBA_USER"
    fi
fi

echo "Rozpoczynam sekwencyjne wdrażanie wybranych modułów..."
echo

# Sekwencyjne wykonywanie modułów
[[ "$MOD_SYSTEM_BASE" == "true" ]]  && configure_system_base
[[ "$MOD_KDE_ENV" == "true" ]]      && configure_kde_environment
[[ "$MOD_UFW" == "true" ]]          && configure_ufw
[[ "$MOD_SAMBA" == "true" ]]        && configure_samba
[[ "$MOD_SSH" == "true" ]]          && configure_ssh
[[ "$MOD_BROWSERS" == "true" ]]     && configure_browsers
[[ "$MOD_OFFICE" == "true" ]]       && configure_office_apps
[[ "$MOD_DEV_TOOLS" == "true" ]]    && configure_dev_tools
[[ "$MOD_MULTIMEDIA" == "true" ]]   && configure_multimedia
[[ "$MOD_PRINTERS_BT" == "true" ]]  && configure_printers_bluetooth
[[ "$MOD_INTEL_GPU" == "true" ]]    && configure_intel_gpu
[[ "$MOD_WINE_POL" == "true" ]]     && configure_wine_playonlinux
[[ "$MOD_WEBAPPS" == "true" ]]      && configure_webapps
[[ "$MOD_BACKUP_PRIVATE" == "true" ]] && create_private_backup

echo
echo "=========================================================="
log_info "🎉 Konfiguracja środowiska KDE w CachyOS zakończona pomyślnie!"
echo "Logi instalacji zapisano w: $LOGFILE"
echo "Zaleca się przelogowanie lub restart systemu, aby zastosować wszystkie zmiany w KDE."
echo "=========================================================="
