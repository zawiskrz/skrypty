#!/bin/bash

configure_pycharm(){
  echo "🐍 Instalacja PyCharma..." | tee -a "$LOGFILE"
  wget https://download-cdn.jetbrains.com/python/pycharm-${PYCHARM_VERSION}.tar.gz -O pycharm.tar.gz 2>&1 | tee -a "$LOGFILE"
  tar -xzf pycharm.tar.gz 2>&1 | tee -a "$LOGFILE"
  sudo mv pycharm-${PYCHARM_VERSION} "$PYCHARM_DIR"
  cat <<EOF | sudo tee /usr/share/applications/pycharm.desktop
[Desktop Entry]
Name=PyCharm IDE
Comment=Python IDE for Professional Developers
Exec=/opt/pycharm/bin/pycharm
Icon=/opt/pycharm/bin/pycharm.png
Type=Application
Categories=Development;IDE;
EOF

}