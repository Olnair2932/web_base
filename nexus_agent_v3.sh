#!/data/data/com.termux/files/usr/bin/bash

source ./nexus_override.sh

nexus_log() {
  echo "[NEXUS-V3] $1"
}

# =========================
# UTIL
# =========================

ensure_base_files() {
  [ ! -f index.html ] && echo "<h1>Nexus</h1>" > index.html
  [ ! -f style.css ] && echo "body{font-family:Arial}" > style.css
  [ ! -f index.js ] && echo "console.log('Nexus ativo')" > index.js
}

# =========================
# EDITORES INTELIGENTES
# =========================

set_title() {
  TITLE="$1"
  nexus_log "atualizando título: $TITLE"

  cat << HTML > index.html
<!DOCTYPE html>
<html>
<head>
  <title>$TITLE</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <h1>$TITLE</h1>
  <div id="app"></div>
  <script src="index.js"></script>
</body>
</html>
HTML

  nexus_log "título atualizado"
}

add_button() {
  LABEL="$1"
  nexus_log "adicionando botão: $LABEL"

  # adiciona botão sem destruir HTML
  echo "<button style='background:blue;color:white;padding:10px' onclick=\"alert('Bem Vindos')\">$LABEL</button>" >> index.html

  nexus_log "botão adicionado"
}

update_js() {
  CODE="$1"
  nexus_log "atualizando JS"

  echo "$CODE" > index.js
}

# =========================
# AGENTE PRINCIPAL
# =========================

execute_intent_v3() {
  INTENT="$1"

  ensure_base_files

  nexus_log "recebido: $INTENT"

  # criar site novo
  if [[ "$INTENT" == *"novo site"* ]]; then
    set_title "Novo Site Nexus"
  fi

  # mudar título
  if [[ "$INTENT" == *"título"* ]]; then
    TITLE=$(echo "$INTENT" | sed 's/.*título para //')
    set_title "$TITLE"
  fi

  # botão
  if [[ "$INTENT" == *"botão"* ]]; then
    LABEL=$(echo "$INTENT" | sed 's/.*botão //')
    add_button "$LABEL"
  fi

  # JS custom
  if [[ "$INTENT" == *"javascript"* ]]; then
    update_js "console.log('Nexus JS atualizado')"
  fi

  git add .
  git commit -m "nexus v3 update" || true
  git push || true

  nexus_log "deploy concluído"
}

