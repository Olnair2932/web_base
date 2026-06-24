#!/bin/bash

# --- BUSCA INTELIGENTE DO .ENV ---
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
elif [ -f "$HOME/ia_termux/.env" ]; then
    export $(grep -v '^#' "$HOME/ia_termux/.env" | xargs)
else
    echo "❌ Erro: Arquivo .env não encontrado em lugar nenhum!"
    echo "Tente: ln -s ~/ia_termux/.env .env"
    exit 1
fi

INDEX_FILE="index.html"

echo "====================================="
echo "   NEXUS IA: DIAGNÓSTICO E AÇÃO      "
echo "====================================="
read -p "O que deseja adicionar? " USER_INPUT

# Chamada ao Gemini
echo "⏳ Consultando Google Gemini..."

PAYLOAD=$(cat <<EOD
{
  "contents": [{
    "parts": [{
      "text": "O usuário quer adicionar um produto: '$USER_INPUT'. Extraia Nome, Preço (número) e use uma URL de imagem do Unsplash relacionada a crochê. Responda apenas um JSON puro: {\"nome\": \"...\", \"preco\": \"...\", \"img\": \"...\"}"
    }]
  }]
}
EOD
)

RESPONSE=$(curl -s -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-lite:generateContent?key=${GEMINI_API_KEY}" \
    -H "Content-Type: application/json" \
    -d "$PAYLOAD")

# Extração do Texto e limpeza
RAW_TEXT=$(echo "$RESPONSE" | jq -r '.candidates[0].content.parts[0].text // empty')
CLEAN_JSON=$(echo "$RAW_TEXT" | sed 's/```json//g' | sed 's/```//g' | tr -d '\n')

NOME=$(echo "$CLEAN_JSON" | jq -r '.nome // empty')
PRECO=$(echo "$CLEAN_JSON" | jq -r '.preco // empty')
IMG=$(echo "$CLEAN_JSON" | jq -r '.img // empty')

if [ -z "$NOME" ]; then
    echo "❌ Erro ao processar. Verifique sua API KEY ou conexão."
    exit 1
fi

echo "📦 Produto: $NOME | 💰 R$ $PRECO"

# Injeção no HTML
WA_TEXT=$(echo "Olá! Quero o produto $NOME" | sed 's/ /%20/g')
CARD="<div class=\"card\"><img src=\"$IMG\" alt=\"$NOME\"><h2>$NOME</h2><p class=\"preco\">R$ $PRECO</p><a href=\"https://wa.me/5551984578173?text=$WA_TEXT\" target=\"_blank\"><button>Comprar por WhatsApp</button></a></div>"

sed -i "/<\/section>/i $CARD" "$INDEX_FILE"

echo "✅ index.html atualizado!"

# Git Push Automático
git add .
git commit -m "Nexus IA: + $NOME"
git push origin main
echo "🚀 Site atualizado no GitHub!"
