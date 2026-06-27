#!/bin/bash
RAIZ_WEB="/data/data/com.termux/files/home/ia_termux/arsenal/scripts/web_base"
DB_PRODUTOS="$RAIZ_WEB/produtos.json"

if [ "$#" -ne 2 ]; then
    echo -e "\033[1;31m[ERRO]\033[0m Uso: ./nexus_editar.sh \"Nome do Produto\" \"Novo Preço\""
    echo -e "Exemplo: ./nexus_editar.sh \"Tapete Luxo Roxo\" \"160,00\""
    exit 1
fi

NOME_ALVO=$1
PRECO_NOVO="R$ $2"

# 1. Verifica se o produto existe
if ! jq -e ".[] | select(.nome == \"$NOME_ALVO\")" "$DB_PRODUTOS" > /dev/null; then
    echo -e "\033[1;33m[AVISO]\033[0m Produto '$NOME_ALVO' não encontrado."
    exit 1
fi

# 2. Atualiza o preço no JSON
TMP=$(mktemp)
jq --arg nm "$NOME_ALVO" --arg pr "$PRECO_NOVO" \
'(map(if .nome == $nm then .preco = $pr else . end))' "$DB_PRODUTOS" > "$TMP" && mv "$TMP" "$DB_PRODUTOS"

echo -e "\033[1;32m[SUCESSO]\033[0m Preço do item '$NOME_ALVO' alterado para $PRECO_NOVO."

# 3. Força a atualização do site sem criar duplicatas
# Pegamos o último item apenas para o script de estoque rodar a reconstrução
ULTIMO_NOME=$(jq -r '.[-1].nome' "$DB_PRODUTOS")
ULTIMO_VALOR=$(jq -r '.[-1].preco' "$DB_PRODUTOS" | sed 's/R\$ //')
ULTIMA_IMG=$(jq -r '.[-1].img' "$DB_PRODUTOS" | sed 's/img\///')

./nexus_estoque.sh "$ULTIMO_NOME" "$ULTIMO_VALOR" "$ULTIMA_IMG"

# Remove o item extra que o nexus_estoque criou na reconstrução
jq 'del(.[-1])' "$DB_PRODUTOS" > "$TMP" && mv "$TMP" "$DB_PRODUTOS"

echo -e "\033[1;34m[OK]\033[0m Site sincronizado com o novo preço!"
