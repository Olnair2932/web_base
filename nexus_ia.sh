#!/bin/bash

# Carrega chaves do .env
[ -f .env ] && source .env

INDEX_FILE="index.html"

# Função para enviar ao Gemini e obter JSON
perguntar_ao_gemini() {
    local PERGUNTA="$1"
    
    # System Prompt: Força a IA a retornar apenas dados úteis
    local SYSTEM_PROMPT="Você é um integrador de sistemas. O usuário quer adicionar um produto ao site. 
    Extraia: nome do produto, preço (apenas números) e nome da imagem. 
    Responda EXCLUSIVAMENTE em formato JSON como no exemplo: 
    {\"nome\": \"Bolsa de Crochê\", \"preco\": \"120\", \"imagem\": \"foto.jpg\"}
    Se não houver imagem mencionada, use 'placeholder.jpg'.
    Comando do usuário: $PERGUNTA"

    local RESPONSE=$(curl -s -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${GEMINI_API_KEY}" \
        -H "Content-Type: application/json" \
        -d "{
            \"contents\": [{\"parts\": [{\"text\": \"$SYSTEM_PROMPT\"}]}]
        }")

    # Limpa a resposta para garantir que seja JSON puro
    echo "$RESPONSE" | jq -r '.candidates[0].content.parts[0].text' | sed 's/```json//g' | sed 's/```//g'
}

echo "====================================="
echo "   NEXUS IA - INTELIGÊNCIA NATURAL   "
echo "====================================="
read -p "O que deseja adicionar? " USER_INPUT

echo "⏳ Nexus interpretando..."
JSON_DATA=$(perguntar_ao_gemini "$USER_INPUT")

# Extração de variáveis do JSON
NOME=$(echo "$JSON_DATA" | jq -r '.nome')
PRECO=$(echo "$JSON_DATA" | jq -r '.preco')
IMG=$(echo "$JSON_DATA" | jq -r '.imagem')

if [ "$NOME" != "null" ]; then
    echo "✅ Interpretado: $NOME | R$ $PRECO"
    
    # Prepara o link do WhatsApp (URL Encoded)
    WA_TEXT=$(echo "Olá, quero encomendar: $NOME" | sed 's/ /%20/g')
    
    # Cria o Card HTML em uma única linha para o SED não quebrar
    CARD="<div class='card'><img src='$IMG' alt='$NOME'><h2>$NOME</h2><p class='preco'>R$ $PRECO</p><p>Artesanato Premium 🧶</p><a href='https://wa.me/5551984578173?text=$WA_TEXT' target='_blank'><button>Comprar</button></a></div>"

    # Injeção via SED antes do fechamento da section
    sed -i "/<\/section>/i $CARD" "$INDEX_FILE"

    echo "🚀 $NOME injetado com sucesso no index.html!"
else
    echo "❌ Erro ao processar comando. Resposta da IA: $JSON_DATA"
fi
