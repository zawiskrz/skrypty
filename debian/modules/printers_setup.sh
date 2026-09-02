#!/bin/bash

install_printer_support() {
    echo "🔧 Instalacja sterowników i usług dla drukarek Wi-Fi..."

    # Instalacja CUPS – system kolejkowania drukowania
    sudo apt install -y cups hplip avahi-daemon firmware-iwlwifi firmware-realtek printer-driver-all

    # Dodanie użytkownika do grupy lpadmin (uprawnienia do zarządzania drukarkami)
    sudo usermod -aG lpadmin "$USER"

    # Uruchomienie i włączenie CUPS przy starcie
    sudo systemctl enable cups
    sudo systemctl start cups

    echo "✅ Instalacja zakończona. Możesz teraz skonfigurować drukarkę przez http://localhost:631"
}