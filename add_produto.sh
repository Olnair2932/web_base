#!/bin/bash

ARQUIVO="index.html"

read -p "Nome do produto: " NOME
read -p "Preço (ex: 99,90): " PRECO
read -p "URL da imagem: " IMG
read -p "Link WhatsApp: " LINK

CARD=$(cat <<EOC

<div class="card">
<img src="$IMG" alt="$NOME">

<h2>$NOME</h2>
<p class="preco">R$ $PRECO</p>

<a href="$LINK" target="_blank">
<button>Comprar por WhatsApp</button>
</a>
</div>

EOC
)

# evita quebra de linha no sed (versão mais segura)
echo "$CARD" | sed ':a;N;$!ba;s/\n/\\n/g' | sed "/<\/section>/i $CARD" "$ARQUIVO"

echo "✔ Produto adicionado com sucesso!"
