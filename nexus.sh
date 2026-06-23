#!/data/data/com.termux/files/usr/bin/bash

cd "$(dirname "$0")"

echo "[NEXUS] diretório atual: $(pwd)"

if [ ! -d ".git" ]; then
    echo "[NEXUS] inicializando repo..."
    git init
    git branch -M main
    git remote add origin https://github.com/Olnair2932/web_base.git
fi

echo "[NEXUS] sincronizando..."
git add .
git commit -m "nexus auto update" || echo "sem mudanças para commit"
git pull origin main --rebase
git push origin main
