#!/bin/bash

configure_intel_gpu() {
    log_info "=== [11/13] Sterowniki karty graficznej Intel i akceleracja VA-API ==="

    local intel_pkgs=(
        mesa-utils
        vulkan-intel
        opencl-mesa
    )

    # Detekcja sterownika VA-API odpowiedniego dla danej generacji Intel
    if pacman -Si libva-intel-driver-irql &>/dev/null; then
        intel_pkgs+=(libva-intel-driver-irql)
    elif pacman -Si libva-intel-driver &>/dev/null; then
        intel_pkgs+=(libva-intel-driver)
    else
        intel_pkgs+=(intel-media-driver)
    fi

    install_pacman "${intel_pkgs[@]}"

    log_info "✅ Karta graficzna Intel i akceleracja wideo skonfigurowane."
}
