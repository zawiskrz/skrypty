#!/bin/bash

configure_ssh() {
    log_info "=== [5/13] Serwer OpenSSH i konfiguracja kluczy SSH ==="

    local ssh_pkgs=(
        openssh
    )
    install_pacman "${ssh_pkgs[@]}"

    log_step "Włączanie i uruchamianie sshd.service..."
    sudo systemctl enable sshd.service 2>&1 | tee -a "$LOGFILE"
    sudo systemctl restart sshd.service 2>&1 | tee -a "$LOGFILE"

    # Generowanie klucza SSH ed25519 (np. dla GitHuba) jeśli nie istnieje
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"

    if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
        log_step "Generowanie nowego klucza SSH (ed25519)..."
        ssh-keygen -t ed25519 -C "$USER@$(hostname)" -f "$HOME/.ssh/id_ed25519" -N "" 2>&1 | tee -a "$LOGFILE"
        log_info "Twój klucz publiczny (~/.ssh/id_ed25519.pub):"
        cat "$HOME/.ssh/id_ed25519.pub" | tee -a "$LOGFILE"
    else
        log_info "Klucz ~/.ssh/id_ed25519 już istnieje."
    fi

    # Obsługa ssh-agent w powłoce Fish
    local fish_conf_dir="$HOME/.config/fish/conf.d"
    mkdir -p "$fish_conf_dir"
    if [[ ! -f "$fish_conf_dir/ssh_agent.fish" ]]; then
        log_step "Dodawanie automatycznego uruchamiania ssh-agent dla powłoki fish..."
        cat << 'EOF' > "$fish_conf_dir/ssh_agent.fish"
# Automatyczny ssh-agent dla fish shell
if not set -q SSH_AUTH_SOCK
    eval (ssh-agent -c) > /dev/null
end
EOF
    fi

    log_info "✅ OpenSSH skonfigurowany."
}
