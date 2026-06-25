#!/bin/bash
RAIZ="/data/data/com.termux/files/home/ia_termux/arsenal/scripts/web_base"
INDEX_FILE="$RAIZ/index.html"
source "/data/data/com.termux/files/home/ia_termux/.env"

INPUT="$1"
PROMPT="Aja como administrador. Usuário quer: '$INPUT'. Responda APENAS JSON: {\"acao\":\"adicionar\" ou \"remover\",\"nome\":\"...\",\"preco\":\"...\",\"img\":\"...\"}. Se o preço for vago, use 'A consultar'."

RESPONSE=$(curl -s -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${GEMINI_API_KEY}" \
    -H "Content-Type: application/json" -d "{ \"contents\": [{\"parts\": [{\"text\": \"$PROMPT\"}]}] }")

CLEAN=$(echo "$RESPONSE" | jq -r '.candidates[0].content.parts[0].text' | sed 's/```json//g' | sed 's/```//g' | tr -d '\n')
ACAO=$(echo "$CLEAN" | jq -r '.acao')
NOME=$(echo "$CLEAN" | jq -r '.nome')

# REMOVE DUPLICATAS ANTES DE QUALQUER AÇÃO
sed -i "/$NOME/Id" "$INDEX_FILE"

if [ "$ACAO" == "adicionar" ]; then
    PRECO=$(echo "$CLEAN" | jq -r '.preco')
    IMG=$(echo "$CLEAN" | jq -r '.img // "https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf"')
    WA_TEXT=$(echo "Olá Kellen! Quero encomendar o(a) $NOME" | sed 's/ /%20/g')
    
    CARD="<div class='card'><img src='$IMG' alt='$NOME'><h2>$NOME</h2><p class='preco'>R$ $PRECO</p><a href='https://wa.me/5551984578173?text=$WA_TEXT' target='_blank'><button>Comprar no WhatsApp</button></a></div>"
    
    # Injeta logo abaixo do marcador de ponto de injeção
    sed -i "/<!-- PONTO_DE_INJECAO -->/a $CARD" "$INDEX_FILE"
    MSG="Nexus: + $NOME"
else
    MSG="Nexus: - $NOME"
fi

git add . && git commit -m "$MSG" && git push origin main
echo "🚀 Sincronizado: $MSG"
