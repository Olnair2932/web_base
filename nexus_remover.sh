#!/bin/bash
RAIZ_WEB="/data/data/com.termux/files/home/ia_termux/arsenal/scripts/web_base"
DB_PRODUTOS="$RAIZ_WEB/produtos.json"

if [ -z "$1" ]; then
    echo "Uso: ./nexus_remover.sh \"Nome\""
    exit 1
fi

# Remove do JSON
TMP=$(mktemp)
jq --arg nm "$1" 'del(.[] | select(.nome == $nm))' "$DB_PRODUTOS" > "$TMP" && mv "$TMP" "$DB_PRODUTOS"

# Dispara a reconstrução do HTML sem adicionar lixo
# Usamos um truque: chamamos o estoque com um nome que o estoque já vai apagar em seguida
./nexus_estoque.sh "TEMP_REBUILD" "0" "0"
jq 'del(.[] | select(.nome == "TEMP_REBUILD"))' "$DB_PRODUTOS" > "$TMP" && mv "$TMP" "$DB_PRODUTOS"

echo "[SUCESSO] Item '$1' removido e site atualizado."
