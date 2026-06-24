#!/bin/bash

ARQUIVO="index.html"

menu() {
  echo "=============================="
  echo "   PAINEL DE PRODUTOS"
  echo "=============================="
  echo "1 - Adicionar produto"
  echo "2 - Excluir produto"
  echo "3 - Sair"
  echo "=============================="
  read -p "Escolha: " OPCAO
}

adicionar() {
  read -p "Nome do produto: " NOME
  read -p "Preço: " PRECO
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

  sed -i "/<\/section>/i $CARD" "$ARQUIVO"

  echo "✔ Produto adicionado!"
}

excluir() {
  read -p "Nome exato do produto para excluir: " NOME

  # remove bloco inteiro do card baseado no título
  awk -v nome="$NOME" '
  BEGIN { skip=0 }
  {
    if ($0 ~ "<h2>"nome"</h2>") {
      skip=1
    }
    if (!skip) print
    if (skip && $0 ~ "</div>") {
      skip=0
    }
  }' "$ARQUIVO" > tmp.html && mv tmp.html "$ARQUIVO"

  echo "✔ Produto removido (se encontrado)."
}

while true; do
  menu

  case $OPCAO in
    1) adicionar ;;
    2) excluir ;;
    3) echo "Saindo..."; break ;;
    *) echo "Opção inválida" ;;
  esac
done
