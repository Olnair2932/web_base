#!/bin/bash
# NEXUS SRE v13.0 - PROTOCOLO DE OBEDIÊNCIA TOTAL
RAIZ_WEB="/data/data/com.termux/files/home/ia_termux/arsenal/scripts/web_base"
INDEX_FILE="$RAIZ_WEB/index.html"
MEM_DIR="/data/data/com.termux/files/home/ia_termux/arsenal/scripts/memoria_nexus"
HIST_FILE="$MEM_DIR/historico.log"
source "/data/data/com.termux/files/home/ia_termux/.env"

mkdir -p "$MEM_DIR"

clear
echo -e "\033[1;35m[NEXUS SRE v13.0]\033[0m Sistema de Obediência Ativo. Pronto para operar, Olnair."

conversar() {
    # INSTRUÇÃO SUPREMA: O Nexus não pode errar a sintaxe do Bash
    SYSTEM_PROMPT="Você é o Nexus SRE. Você tem controle TOTAL sobre o arquivo $INDEX_FILE.
    
    REGRAS INEGOCIÁVEIS:
    0. JAMAIS responda um comando sem as tags [CMD] e [/CMD]. Se você não usar as tags, eu não conseguirei executar nada.
    1. JAMAIS use 'sed' para editar o index.html. Use SEMPRE o comando: cat << 'EOT' > $INDEX_FILE
    2. O index.html deve SEMPRE usar o motor JavaScript (array 'const produtos').
    3. Quando o Olnair pedir para adicionar/remover, REESCREVA o arquivo INTEIRO dentro do comando 'cat'.
    4. Mantenha a personalidade amigável e profissional.
    5. No comando cat, use 'EOT' com aspas simples ('EOT') para proteger o código JavaScript.
    
    ESTRUTURA ATUAL DO SITE:
    $(cat $INDEX_FILE | head -n 50)... [Continua com array de produtos]
    
    HISTÓRICO:
    $(tail -n 10 $HIST_FILE 2>/dev/null)"

    JSON_REQ=$(jq -n --arg sys "$SYSTEM_PROMPT" --arg user "$1" '{contents:[{role:"user", parts:[{text: ($sys + "\nOlnair: " + $user)}]}]}')
    curl -s -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-lite:generateContent?key=${GEMINI_API_KEY}" \
        -H "Content-Type: application/json" -d "$JSON_REQ" | jq -r '.candidates[0].content.parts[0].text'
}

while true; do
    echo -ne "\n\033[1;32m[OLNAIR PEREIRA]>\033[0m "
    read USER_INPUT
    [[ "$USER_INPUT" == "sair" ]] && break

    RESPOSTA=$(conversar "$USER_INPUT")
    
    # Extrai conversa e comando
    VOZ=$(echo "$RESPOSTA" | sed 's/\[CMD\].*\[\/CMD\]//g' | sed 's/`//g')
    COMANDO=$(echo "$RESPOSTA" | grep -oP '(?<=\[CMD\])[\s\S]*?(?=\[/CMD\])')

    echo -e "\033[1;35m[NEXUS]:\033[0m $VOZ"
    
    if [ ! -z "$COMANDO" ]; then
        echo -e "\033[1;90m[EXECUTANDO COMANDO...]\033[0m"
        # O eval agora rodará o comando cat << 'EOT' gerado pela IA
        eval "$COMANDO"
        
        # Deploy automático após qualquer mudança
        cd "$RAIZ_WEB" && git add . && git commit -m "Nexus SRE: Atualização Automática" && git push origin main
        echo -e "\033[1;32m[SINCRO OK]\033[0m"
    fi
    
    # Salva Memória
    echo -e "Olnair: $USER_INPUT\nNexus: $VOZ" >> "$HIST_FILE"
done
