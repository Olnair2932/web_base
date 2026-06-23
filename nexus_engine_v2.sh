#!/data/data/com.termux/files/usr/bin/bash

source ./nexus_override.sh

nexus_log() {
  echo "[NEXUS-V2] $1"
}

# =========================
# TEMPLATES
# =========================

template_home() {
cat << HTML
<!DOCTYPE html>
<html>
<head>
  <title>$1</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <h1>$1</h1>
  <div id="app"></div>
  <script src="index.js"></script>
</body>
</html>
HTML
}

template_button() {
cat << HTML
<button style="background:blue;color:white;padding:10px;"
onclick="alert('Bem Vindos')">
$1
</button>
HTML
}

# =========================
# ENGINE PRINCIPAL
# =========================

execute_intent() {
  INTENT="$1"

  nexus_log "recebido: $INTENT"

  # criar site completo
  if [[ "$INTENT" == *"site"* && "$INTENT" == *"novo"* ]]; then
    TITLE="Novo Site Nexus"
    template_home "$TITLE" > index.html
    nexus_log "site base criado"

  # atualizar título
  elif [[ "$INTENT" == *"título"* ]]; then
    TITLE=$(echo "$INTENT" | sed 's/.*título para //')
    template_home "$TITLE" > index.html
    nexus_log "título atualizado"

  # criar botão
  elif [[ "$INTENT" == *"botão"* ]]; then
    LABEL="teste"
    template_button "$LABEL" > button.html
    nexus_log "botão gerado em button.html"

  # fallback seguro
  else
    nexus_log "comando não reconhecido"
  fi

  git add .
  git commit -m "nexus v2 update" || true
  git push || true

  nexus_log "sync concluído"
}

