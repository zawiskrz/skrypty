#!/bin/bash

configure_dev_tools() {
    log_info "=== [8/13] Narzędzia programistyczne (Python, R, PyCharm, VS Code, Git) ==="

    local dev_pkgs=(
        code                         # Visual Studio Code
        pycharm-community-edition    # PyCharm Community IDE
        git                          # System kontroli wersji
        meld                         # Graficzne narzędzie diff / merge
        python                       # Interpreter Python
        python-packaging
        python-defusedxml
        python-reportlab
        python-pyqt5
        r                            # Środowisko obliczeń statystycznych R
        gcc-fortran                  # Kompilator Fortran dla bibliotek R
    )
    install_pacman "${dev_pkgs[@]}"

    # RStudio Desktop z AUR
    local aur_dev=(
        rstudio-desktop-bin
    )
    install_aur "${aur_dev[@]}"

    log_info "✅ Narzędzia programistyczne zainstalowane."
}
