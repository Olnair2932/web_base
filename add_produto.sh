#!/bin/bash

ARQUIVO="index.html"

read -p "Nome do produto: " NOME
read -p "Preço (ex: 99,90): " PRECO
read -p "URL da imagem: " IMG
read -p "Link WhatsApp: " LINK

CARD=$(cat <<EOF

<div class="card">
<img src="$IMG" alt="$NOME">

<h2>$NOME</h2>
<p class="preco">R$ $PRECO</p>

<a href="$LINK" target="_blank">
<button>Comprar por WhatsApp</button>
</a>
</div>

EOF
)

# insere antes do fechamento da section produtos
sed -i "/<\/section>/i $CARD" "$ARQUIVO"

echo "Produto adicionado com sucesso!"
