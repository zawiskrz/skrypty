configure_docker() {
  echo "🐳 Instalacja Docker i Docker Compose..." | tee -a "$LOGFILE"

  # Dodanie oficjalnego repozytorium Docker
  sudo apt update
  sudo apt install -y ca-certificates curl gnupg lsb-release | tee -a "$LOGFILE"
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt update

  # Instalacja Dockera i Compose jako plugin
  sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin | tee -a "$LOGFILE"

  # Dodanie użytkownika do grupy docker (bez sudo)
  sudo usermod -aG docker "$(logname)"

  echo "✅ Docker i Docker Compose zainstalowane. Wyloguj się i zaloguj ponownie, aby używać Dockera bez sudo." | tee -a "$LOGFILE"
}
