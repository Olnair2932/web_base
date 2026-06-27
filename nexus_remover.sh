#!/bin/bash
# NEXUS REMOVER - Remove itens do catálogo
RAIZ_WEB="/data/data/com.termux/files/home/ia_termux/arsenal/scripts/web_base"
DB_PRODUTOS="$RAIZ_WEB/produtos.json"

if [ -z "$1" ]; then
    echo -e "\033[1;31m[ERRO]\033[0m Uso: ./nexus_remover.sh \"Nome do Produto\""
    exit 1
fi

NOME_REMOVER=$1

# Verifica se o produto existe e remove do JSON
if jq -e ".[] | select(.nome == \"$NOME_REMOVER\")" "$DB_PRODUTOS" > /dev/null; then
    TMP=$(mktemp)
    jq --arg nm "$NOME_REMOVER" 'del(.[] | select(.nome == $nm))' "$DB_PRODUTOS" > "$TMP" && mv "$TMP" "$DB_PRODUTOS"
    echo -e "\033[1;32m[SUCESSO]\033[0m Produto '$NOME_REMOVER' removido."
    
    # Agora chama o seu script original com argumentos vazios ou um "refresh" 
    # para reconstruir o index.html. 
    # Como o seu script original exige 3 args, vamos disparar a atualização:
    ./nexus_estoque.sh "REFRESH" "0" "0"
    
    # O comando acima vai adicionar um item lixo, então vamos limpar o JSON de novo 
    # (Apenas para forçar a reconstrução do HTML que está dentro do nexus_estoque.sh)
    jq 'del(.[] | select(.nome == "REFRESH"))' "$DB_PRODUTOS" > "$TMP" && mv "$TMP" "$DB_PRODUTOS"
    
    # Roda o deploy se existir
    [ -f "./deploy.sh" ] && ./deploy.sh
else
    echo -e "\033[1;33m[AVISO]\033[0m Produto não encontrado."
fi
