#!/bin/bash
RAIZ_ARSENAL="/data/data/com.termux/files/home/ia_termux/arsenal/scripts"
RAIZ_WEB="$RAIZ_ARSENAL/web_base"
MEM_DIR="$RAIZ_ARSENAL/memoria_nexus"
INDEX_FILE="$RAIZ_WEB/index.html"
HISTORICO_FILE="$MEM_DIR/historico.log"

mkdir -p "$MEM_DIR"
source "/data/data/com.termux/files/home/ia_termux/.env"

carregar_memoria() { tail -n 20 "$HISTORICO_FILE" 2>/dev/null || echo "Nova consciência."; }

clear
echo -e "\033[1;32m--- NEXUS SRE ENGINE v12.0 (MODO BLINDADO) ---\033[0m"
echo -e "\033[1;90mAnálise de risco de sintaxe ativa. Memória operacional.\033[0m\n"

while true; do
    echo -ne "\033[1;32m[OLNAIR PEREIRA]>\033[0m "
    read USER_INPUT
    if [[ "$USER_INPUT" == "sair" ]]; then break; fi

    MEMORIA=$(carregar_memoria)
    HTML_ATUAL=$(cat "$INDEX_FILE")

    SYSTEM_PROMPT="Você é o Nexus, Engenheiro SRE. 
    HISTÓRICO RECENTE: $MEMORIA
    HTML ATUAL: $HTML_ATUAL

    SUA MISSÃO:
    1. Analise se o pedido do Olnair pode ser feito com 'sed' sem quebrar o HTML.
    2. Se o 'sed' for arriscado (mudanças de CSS complexas ou reestruturação), gere o código HTML COMPLETO e otimizado.
    3. Para reescrever tudo use: [CMD]cat << 'EOT' > $INDEX_FILE
    (CÓDIGO HTML COMPLETO AQUI)
    EOT[/CMD]
    4. Se for simples, use: [CMD]cd $RAIZ_WEB && ./nexus.sh 'instrução'[/CMD]
    
    Aja com cautela. Não quebre a sintaxe. Explique sua decisão técnica ao Olnair."

    JSON_REQ=$(jq -n --arg sys "$SYSTEM_PROMPT" --arg user "$USER_INPUT" '{contents:[{role:"user", parts:[{text: ($sys + "\n\nOlnair: " + $user)}]}]}')
    
    RESPONSE=$(curl -s -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-lite:generateContent?key=${GEMINI_API_KEY}" \
        -H "Content-Type: application/json" -d "$JSON_REQ")

    RESP_IA=$(echo "$RESPONSE" | jq -r '.candidates[0].content.parts[0].text // "Erro de rede."')
    
    VOZ=$(echo "$RESP_IA" | sed 's/\[CMD\].*\[\/CMD\]//g' | sed 's/`//g')
    COMANDO=$(echo "$RESP_IA" | grep -oP '(?<=\[CMD\])[\s\S]*?(?=\[/CMD\])')

    # Salva Memória
    echo -e "Olnair: $USER_INPUT\nNexus: $VOZ" >> "$HISTORICO_FILE"

    echo -e "\n\033[1;35m[NEXUS SRE]:\033[0m $VOZ"

    if [ ! -z "$COMANDO" ]; then
        echo -e "\033[1;90m[AÇÃO SRE]: Executando com segurança...\033[0m"
        eval "$COMANDO"
    fi
    echo ""
done
