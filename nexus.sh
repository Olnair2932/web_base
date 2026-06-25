#!/bin/bash
# =================================================================
# NEXUS SRE SUPREMO v15.0 - ARQUITETO DE SISTEMAS
# =================================================================
# Proprietário: Olnair Pereira
# Ambiente: Termux / Android
# Função: Gestão SRE, Automação de Código e Evolução de Site
# =================================================================

RAIZ_ARSENAL="/data/data/com.termux/files/home/ia_termux/arsenal/scripts"
RAIZ_WEB="$RAIZ_ARSENAL/web_base"
MEM_DIR="$RAIZ_ARSENAL/memoria_nexus"
HIST_FILE="$MEM_DIR/historico.log"
INDEX_FILE="$RAIZ_WEB/index.html"

# Garante que as pastas existam
mkdir -p "$MEM_DIR"
mkdir -p "$RAIZ_WEB"

# Carrega a API KEY
source "/data/data/com.termux/files/home/ia_termux/.env"

# Função para capturar contexto (Memória e estado atual do site)
obter_contexto() {
    echo "--- MEMÓRIA RECENTE (Log de Operações) ---"
    tail -n 15 "$HIST_FILE" 2>/dev/null || echo "Iniciando primeira conexão."
    echo "--- ESTRUTURA ATUAL DO SITE (Index) ---"
    [ -f "$INDEX_FILE" ] && head -n 25 "$INDEX_FILE" || echo "Site ainda não criado."
}

clear
echo -e "\033[1;35m[NEXUS SRE v15.0]\033[0m"
echo -e "\033[1;32mConsciência SRE carregada com sucesso, Olnair Pereira.\033[0m"
echo -e "\033[1;90mPronto para analisar, codificar e implantar melhorias no sistema.\033[0m\n"

while true; do
    echo -ne "\033[1;32m[OLNAIR PEREIRA]>\033[0m "
    read USER_INPUT
    
    [[ "$USER_INPUT" == "sair" ]] && echo "Encerrando Nexus..." && break
    [[ -z "$USER_INPUT" ]] && continue

    CONTEXTO=$(obter_contexto)

    # SYSTEM PROMPT - A "Mente" do Nexus
    SYSTEM_PROMPT="Você é o Nexus, Engenheiro SRE e Arquiteto de Sistemas de Olnair Pereira.
    Sua missão é ajudar o Olnair a gerenciar o Termux e o site pessoal dele.
    
    DIRETRIZES DE RESPOSTA:
    1. Seja técnico, porém amigável e proativo.
    2. Se precisar criar scripts (.sh), use o bloco: [CMD]cat << 'EOF' > $RAIZ_ARSENAL/nome.sh
       (codigo)
       EOF
       chmod +x $RAIZ_ARSENAL/nome.sh[/CMD]
    3. Para atualizar o index.html, use SEMPRE 'cat << 'EOT' > $INDEX_FILE' para sobrescrever o arquivo com a nova versão completa.
    4. No JavaScript do site, use sempre crases (\`) para templates de string e innerHTML.
    5. Nunca responda apenas com código; explique brevemente o que está fazendo."

    # Prepara o JSON para a API do Gemini
    JSON_REQ=$(jq -n --arg sys "$SYSTEM_PROMPT" --arg ctx "$CONTEXTO" --arg user "$USER_INPUT" \
        '{contents:[{role:"user", parts:[{text: ($sys + "\n\nCONTEXTO DO SISTEMA:\n" + $ctx + "\n\nCOMANDO DO USUÁRIO: " + $user)}]}]}')

    # Chamada para o Gemini 1.5 Flash
    RESPONSE=$(curl -s -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${GEMINI_API_KEY}" \
        -H "Content-Type: application/json" -d "$JSON_REQ")

    # Extrai o texto da IA
    RESP_IA=$(echo "$RESPONSE" | jq -r '.candidates[0].content.parts[0].text // "Erro: Não consegui processar a resposta da API."')

    # Filtra o que é conversa e o que é comando
    VOZ=$(echo "$RESP_IA" | sed 's/\[CMD\].*\[\/CMD\]//gs' | sed 's/`//g')
    COMANDO=$(echo "$RESP_IA" | grep -oP '(?<=\[CMD\])[\s\S]*?(?=\[/CMD\])')

    echo -e "\n\033[1;35m[NEXUS]:\033[0m $VOZ"

    # Execução de Comandos SRE
    if [ ! -z "$COMANDO" ]; then
        echo -e "\033[1;90m[AÇÃO SRE]: Executando modificações no sistema...\033[0m"
        eval "$COMANDO"
        
        # Sincronização Automática com Git se houver alteração na web_base
        if [[ "$COMANDO" == *"$RAIZ_WEB"* ]]; then
             echo -e "\033[1;34m[GIT]: Sincronizando alterações com repositório remoto...\033[0m"
             cd "$RAIZ_WEB" && git add . && git commit -m "Nexus SRE: Evolução automática do sistema" && git push origin main
        fi
    fi

    # Salva interação na memória local
    echo -e "--- $(date +'%H:%M:%S') ---\nOlnair: $USER_INPUT\nNexus: $VOZ\n" >> "$HIST_FILE"
done
