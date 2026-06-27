#!/bin/bash
RAIZ_WEB="/data/data/com.termux/files/home/ia_termux/arsenal/scripts/web_base"
DB_PRODUTOS="$RAIZ_WEB/produtos.json"

if [ -z "$1" ]; then
    echo "Uso: ./nexus_remover.sh \"Nome\""
    exit 1
fi

# 1. Remove do JSON
TMP=$(mktemp)
jq --arg nm "$1" 'del(.[] | select(.nome == $nm))' "$DB_PRODUTOS" > "$TMP" && mv "$TMP" "$DB_PRODUTOS"

# 2. Pega o último produto real para disparar a reconstrução do HTML sem lixo
ULTIMO_NOME=$(jq -r '.[-1].nome' "$DB_PRODUTOS")
ULTIMO_PRECO=$(jq -r '.[-1].preco' "$DB_PRODUTOS" | sed 's/R\$ //')
ULTIMA_IMG=$(jq -r '.[-1].img' "$DB_PRODUTOS" | sed 's/img\///')

# 3. Atualiza o site e remove a duplicata automática
./nexus_estoque.sh "$ULTIMO_NOME" "$ULTIMO_PRECO" "$ULTIMA_IMG"
jq 'del(.[] | select(.id == (map(.id|tonumber) | max | tostring)))' "$DB_PRODUTOS" > "$TMP" && mv "$TMP" "$DB_PRODUTOS"

echo -e "\033[1;32m[SUCESSO]\033[0m Item '$1' removido e site limpo!"
