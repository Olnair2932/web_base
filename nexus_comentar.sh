#!/bin/bash
RAIZ_WEB="/data/data/com.termux/files/home/ia_termux/arsenal/scripts/web_base"
DB_COMER="$RAIZ_WEB/comentarios.json"

if [ "$#" -ne 2 ]; then
    echo -e "Uso: ./nexus_comentar.sh \"Nome da Cliente\" \"Texto do Elogio\""
    exit 1
fi

NOME=$1; TEXTO=$2

TMP=$(mktemp)
jq --arg nm "$NOME" --arg tx "$TEXTO" '. += [{nome: $nm, texto: $tx}]' "$DB_COMER" > "$TMP" && mv "$TMP" "$DB_COMER"

echo "[OK] Recadinho de $NOME adicionado!"

# Sincroniza o site (usamos o editar apenas para disparar o deploy)
./nexus_editar.sh "Tapete Luxo Roxo" "60,00"
