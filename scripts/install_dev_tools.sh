#!/bin/bash

set -e

echo "=== Перевірка та встановлення необхідних інструментів ==="

# --- Docker ---
if ! command -v docker &> /dev/null; then
    echo "[+] Docker не знайдено. Встановлюємо..."
    sudo apt update
    sudo apt install -y ca-certificates curl gnupg lsb-release

    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    sudo usermod -aG docker $USER
    echo "[✔] Docker встановлено."
else
    echo "[✔] Docker вже встановлений."
fi

# --- Docker Compose ---
if ! command -v docker-compose &> /dev/null; then
    echo "[+] Docker Compose не знайдено. Встановлюємо..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
        -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "[✔] Docker Compose встановлено."
else
    echo "[✔] Docker Compose вже встановлений."
fi

# --- Python ---
if ! command -v python3 &> /dev/null; then
    echo "[+] Python не знайдено. Встановлюємо Python 3.9..."
    sudo apt update
    sudo apt install -y python3 python3-pip python3-venv
    echo "[✔] Python встановлено."
else
    PY_VER=$(python3 -V | cut -d " " -f2 | cut -d "." -f1,2)
    if (( $(echo "$PY_VER < 3.9" | bc -l) )); then
        echo "[!] Встановлена версія Python $PY_VER < 3.9. Оновлюємо..."
        sudo apt update
        sudo apt install -y python3.9 python3.9-venv python3.9-distutils
        sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 2
        echo "[✔] Python оновлено до $(python3 -V)"
    else
        echo "[✔] Python версії $PY_VER вже встановлений."
    fi
fi

# --- Django ---
if ! python3 -m django --version &> /dev/null; then
    echo "[+] Django не знайдено. Встановлюємо через pip..."
    python3 -m pip install --upgrade pip
    python3 -m pip install django
    echo "[✔] Django встановлено."
else
    DJANGO_VER=$(python3 -m django --version)
    echo "[✔] Django вже встановлений (версія $DJANGO_VER)."
fi

echo "=== Установка завершена! ==="
