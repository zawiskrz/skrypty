#!/bin/bash

configure_ufw() {
    log_info "=== [3/13] Zapora ogniowa UFW i reguły sieciowe ==="

    local ufw_pkgs=(
        ufw
        gufw
        ufw-extras
    )
    install_pacman "${ufw_pkgs[@]}"

    log_step "Włączanie usługi ufw.service..."
    sudo systemctl enable ufw.service 2>&1 | tee -a "$LOGFILE"
    sudo systemctl start ufw.service 2>&1 | tee -a "$LOGFILE"

    log_step "Ustawianie domyślnych polityk zapory..."
    sudo ufw default deny incoming 2>&1 | tee -a "$LOGFILE"
    sudo ufw default allow outgoing 2>&1 | tee -a "$LOGFILE"

    log_step "Konfiguracja reguł dla KDE Connect (porty 1714-1764 TCP/UDP)..."
    sudo ufw allow 1714:1764/udp comment 'KDE Connect' 2>&1 | tee -a "$LOGFILE"
    sudo ufw allow 1714:1764/tcp comment 'KDE Connect' 2>&1 | tee -a "$LOGFILE"

    local subnets=("192.168.0.0/24" "192.168.1.0/24" "10.0.2.0/24")

    log_step "Konfiguracja dostępu do SSH i Samba z sieci lokalnych..."
    for subnet in "${subnets[@]}"; do
        # SSH
        sudo ufw allow from "$subnet" to any port 22 proto tcp comment "SSH LAN $subnet" 2>&1 | tee -a "$LOGFILE"
        # Samba
        sudo ufw allow from "$subnet" to any port 139 proto tcp comment "Samba 139 $subnet" 2>&1 | tee -a "$LOGFILE"
        sudo ufw allow from "$subnet" to any port 445 proto tcp comment "Samba 445 $subnet" 2>&1 | tee -a "$LOGFILE"
        sudo ufw allow from "$subnet" to any port 137 proto udp comment "Samba 137 $subnet" 2>&1 | tee -a "$LOGFILE"
        sudo ufw allow from "$subnet" to any port 138 proto udp comment "Samba 138 $subnet" 2>&1 | tee -a "$LOGFILE"
    done

    log_step "Aktywacja UFW..."
    sudo ufw --force enable 2>&1 | tee -a "$LOGFILE"

    log_info "✅ Zapora UFW skonfigurowana."
}
