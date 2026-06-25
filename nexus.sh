#!/bin/bash
RAIZ="/data/data/com.termux/files/home/ia_termux/arsenal/scripts/web_base"
INDEX_FILE="$RAIZ/index.html"
ENV_FILE="/data/data/com.termux/files/home/ia_termux/.env"

cd "$RAIZ" || exit
[ -f "$ENV_FILE" ] && source "$ENV_FILE"

INPUT="${1:-"Nenhum comando"}"

# IA Gemini para processar Adicionar/Remover
PROMPT="Aja como um catalogador artesanal. Identifique se quer ADICIONAR ou REMOVER um produto. Responda APENAS JSON: {\"acao\": \"adicionar\" ou \"remover\", \"nome\": \"...\", \"preco\": \"...\", \"img\": \"...\"}"

RESPONSE=$(curl -s -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${GEMINI_API_KEY}" \
    -H "Content-Type: application/json" \
    -d "{ \"contents\": [{\"parts\": [{\"text\": \"$PROMPT. Comando: $INPUT\"}]}] }")

CLEAN=$(echo "$RESPONSE" | jq -r '.candidates[0].content.parts[0].text' | sed 's/```json//g' | sed 's/```//g' | tr -d '\n')
ACAO=$(echo "$CLEAN" | jq -r '.acao')
NOME=$(echo "$CLEAN" | jq -r '.nome')

if [ "$ACAO" == "adicionar" ]; then
    PRECO=$(echo "$CLEAN" | jq -r '.preco')
    IMG=$(echo "$CLEAN" | jq -r '.img')
    WA_TEXT=$(echo "Olá, quero o produto $NOME" | sed 's/ /%20/g')
    CARD="<div class=\"card\"><img src=\"$IMG\" alt=\"$NOME\"><h2>$NOME</h2><p class=\"preco\">R$ $PRECO</p><a href=\"https://wa.me/5551984578173?text=$WA_TEXT\" target=\"_blank\"><button>Comprar</button></a></div>"
    sed -i "\|</section>|i $CARD" "$INDEX_FILE"
    MSG="Nexus IA: + $NOME"
elif [ "$ACAO" == "remover" ]; then
    sed -i "/$NOME/Id" "$INDEX_FILE"
    MSG="Nexus IA: - $NOME"
fi

# Sincroniza com o GitHub Pages
git add .
git commit -m "$MSG"
git push origin main
echo "🚀 Catálogo web_base atualizado!"
