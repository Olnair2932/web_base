#!/data/data/com.termux/files/usr/bin/bash

INDEX_FILE="index.html"

nexus_log() {
  echo "[NEXUS-CATÁLOGO] $1"
}

# Extrai dados do comando
parse_command() {
  INPUT="$1"

  # remove prefixo
  DATA="${INPUT#novo produto: }"

  NOME=$(echo "$DATA" | awk '{print $1" "$2}')
  PRECO=$(echo "$DATA" | awk '{print $3}')
  IMG=$(echo "$DATA" | awk '{print $4}')

  # texto whatsapp
  WA_TEXT=$(echo "Quero comprar $NOME" | sed 's/ /%20/g')

  CARD=$(cat <<EOC
<div class="card">
  <img src="$IMG" alt="$NOME">

  <h2>$NOME</h2>

  <p class="preco">R$ $PRECO</p>

  <p>Peça artesanal feita com carinho 💖</p>

  <a href="https://wa.me/5551984578173?text=$WA_TEXT" target="_blank">
    <button>Comprar por WhatsApp</button>
  </a>
</div>

EOC
)

  insert_card "$CARD"
}

# Insere antes do fechamento da section produtos
insert_card() {
  CARD="$1"

  if ! grep -q "</section>" "$INDEX_FILE"; then
    nexus_log "ERRO: section não encontrada"
    exit 1
  fi

  sed -i "/<\/section>/i $CARD" "$INDEX_FILE"

  nexus_log "produto adicionado ao site"
}

# executor principal
run_catalogo() {
  echo "[NEXUS] catálogo ativo"
  while true; do
    read -p "NEXUS> " CMD

    if [[ "$CMD" == "sair" ]]; then
      break
    fi

    if [[ "$CMD" == novo\ produto:* ]]; then
      parse_command "$CMD"
    else
      nexus_log "comando inválido"
    fi
  done
}

run_catalogo
