#!/bin/bash
# NEXUS AUTO-PUSH v10

RAIZ="/data/data/com.termux/files/home/ia_termux/arsenal/scripts/web_base"
cd "$RAIZ" || exit

echo "📦 Preparando pacotes para o GitHub..."

# Verifica se há alterações
git add .

# Realiza o commit com data e hora
git commit -m "Nexus v10: Limpeza e Sincronização Geral [$(date +'%d/%m %H:%M')]"

echo "🚀 Subindo para https://github.com/Olnair2932/web_base"

# Envia para o GitHub
git push origin main

echo "✨ Tudo pronto! O site de crochê já deve estar atualizado no GitHub Pages."
