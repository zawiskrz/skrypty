#!/bin/bash

configure_printers_bluetooth() {
    log_info "=== [10/13] Obsługa drukarek (CUPS) i łączności Bluetooth ==="

    local hardware_pkgs=(
        # Drukarki i skanery
        cups
        cups-filters
        cups-pdf
        system-config-printer
        hplip
        gutenprint
        foomatic-db
        foomatic-db-engine
        foomatic-db-nonfree
        foomatic-db-ppds
        foomatic-db-gutenprint-ppds

        # Bluetooth
        bluez
        bluez-utils
        bluez-obex
        bluez-hid2hci
        bluedevil
    )
    install_pacman "${hardware_pkgs[@]}"

    log_step "Włączanie i uruchamianie usług CUPS..."
    sudo systemctl enable cups.service cups.socket cups.path 2>&1 | tee -a "$LOGFILE"
    sudo systemctl restart cups.service 2>&1 | tee -a "$LOGFILE"

    log_step "Włączanie i uruchamianie usługi Bluetooth..."
    sudo systemctl enable bluetooth.service 2>&1 | tee -a "$LOGFILE"
    sudo systemctl restart bluetooth.service 2>&1 | tee -a "$LOGFILE"

    log_info "✅ Drukarki i Bluetooth skonfigurowane."
}
