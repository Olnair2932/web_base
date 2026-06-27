#!/bin/bash

ARQUIVO="index.html"

# Solicitar dados
read -p "Nome do produto: " NOME
read -p "Preço (ex: 99,90): " PRECO
read -p "URL da imagem: " IMG
read -p "Link WhatsApp: " LINK

# Criar o HTML do card em um arquivo temporário
cat <<EOC > card.tmp
<div class="card">
    <img src="$IMG" alt="$NOME">
    <h2>$NOME</h2>
    <p class="preco">R$ $PRECO</p>
    <a href="$LINK" target="_blank">
        <button>Comprar por WhatsApp</button>
    </a>
</div>
EOC

# Inserir o conteúdo do card.tmp ANTES da tag </section> no index.html
# Esta é a forma mais segura de lidar com HTML no shell
sed -i "/<\/section>/ {
    r card.tmp
    a </section>
    d
}" "$ARQUIVO"

# Limpar arquivo temporário
rm card.tmp

echo "✔ Produto ($NOME) adicionado com sucesso!"
