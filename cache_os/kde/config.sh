#!/bin/bash
# ==============================================================================
# Konfiguracja bazowa i moduły instalatora środowiska KDE pod CachyOS Linux
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOGFILE="$SCRIPT_DIR/install_log.txt"
CONFIG_FILE="$HOME/.config/cachyos_kde_installer.conf"

mkdir -p "$(dirname "$CONFIG_FILE")"

# Kolory dla komunikatów
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}==>${NC} $1" | tee -a "$LOGFILE"
}

log_step() {
    echo -e "${BLUE}::${NC} $1" | tee -a "$LOGFILE"
}

log_warn() {
    echo -e "${YELLOW}⚠️ $1${NC}" | tee -a "$LOGFILE"
}

log_err() {
    echo -e "${RED}❌ $1${NC}" | tee -a "$LOGFILE"
}

# Sprawdzenie i oczekiwanie na ewentualną blokadę bazy danych pacmana
wait_for_pacman_lock() {
    local max_wait=30
    local waited=0
    while sudo test -f /var/lib/pacman/db.lck; do
        if [[ $waited -eq 0 ]]; then
            log_warn "Baza danych pacmana jest zablokowana (/var/lib/pacman/db.lck). Oczekiwanie..."
        fi
        sleep 2
        waited=$((waited + 2))
        if [[ $waited -ge $max_wait ]]; then
            log_err "Plik /var/lib/pacman/db.lck nadal istnieje po ${max_wait}s. Sprawdź procesy pacmana."
            break
        fi
    done
}

# Funkcja instalacji z oficjalnych repozytoriów pacman
install_pacman() {
    local pkgs=("$@")
    wait_for_pacman_lock
    log_step "Instalacja pakietów systemowych: ${pkgs[*]}"
    sudo pacman -S --needed --noconfirm "${pkgs[@]}" 2>&1 | tee -a "$LOGFILE"
}

# Funkcja instalacji pakietów AUR za pomocą paru
install_aur() {
    local pkgs=("$@")
    if ! command -v paru &>/dev/null; then
        log_warn "Narzędzie paru nie jest zainstalowane. Próba instalacji paru..."
        sudo pacman -S --needed --noconfirm paru 2>&1 | tee -a "$LOGFILE"
    fi
    log_step "Instalacja pakietów AUR: ${pkgs[*]}"
    paru -S --needed --noconfirm "${pkgs[@]}" 2>&1 | tee -a "$LOGFILE"
}

# Sprawdzenie i odblokowanie multilib
ensure_multilib() {
    if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
        log_step "Włączanie repozytorium [multilib] w /etc/pacman.conf..."
        sudo sed -i '/^#\[multilib\]/,/^#Include = \/etc\/pacman.d\/mirrorlist/ s/^#//' /etc/pacman.conf
        sudo pacman -Sy --noconfirm 2>&1 | tee -a "$LOGFILE"
    fi
}

# Załadowanie wszystkich modułów z podkatalogu ./modules/
MODULE_FILES=(
    "$SCRIPT_DIR/modules/01_system_base.sh"
    "$SCRIPT_DIR/modules/02_kde_environment.sh"
    "$SCRIPT_DIR/modules/03_firewall_ufw.sh"
    "$SCRIPT_DIR/modules/04_samba.sh"
    "$SCRIPT_DIR/modules/05_ssh.sh"
    "$SCRIPT_DIR/modules/06_browsers.sh"
    "$SCRIPT_DIR/modules/07_office_apps.sh"
    "$SCRIPT_DIR/modules/08_dev_tools.sh"
    "$SCRIPT_DIR/modules/09_multimedia.sh"
    "$SCRIPT_DIR/modules/10_printers_bluetooth.sh"
    "$SCRIPT_DIR/modules/11_intel_gpu.sh"
    "$SCRIPT_DIR/modules/12_wine_playonlinux.sh"
    "$SCRIPT_DIR/modules/13_webapps.sh"
    "$SCRIPT_DIR/modules/14_backup_private.sh"
    "$SCRIPT_DIR/modules/15_restore_private.sh"
)

for module_file in "${MODULE_FILES[@]}"; do
    if [[ -f "$module_file" ]]; then
        source "$module_file"
    else
        log_warn "Moduł $module_file nie istnieje, pomijam."
    fi
done
