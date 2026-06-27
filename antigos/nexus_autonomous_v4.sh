#!/data/data/com.termux/files/usr/bin/bash

source ./nexus_override.sh

STATE_FILE="nexus_queue.txt"

nexus_log() {
  echo "[NEXUS-V4] $1"
}

# =========================
# GARANTIR BASE
# =========================
ensure_base() {
  [ ! -f index.html ] && echo "<h1>Nexus</h1>" > index.html
  [ ! -f style.css ] && echo "body{font-family:Arial}" > style.css
  [ ! -f index.js ] && echo "console.log('Nexus ativo')" > index.js
  [ ! -f "$STATE_FILE" ] && touch "$STATE_FILE"
}

# =========================
# INTERPRETADOR
# =========================
process_command() {
  CMD="$1"

  nexus_log "processando: $CMD"

  if [[ "$CMD" == *"novo site"* ]]; then
    cat << HTML > index.html
<!DOCTYPE html>
<html>
<head><title>Nexus Site</title></head>
<body><h1>Novo Site Nexus</h1></body>
</html>
HTML
    nexus_log "site criado"

  elif [[ "$CMD" == *"título"* ]]; then
    TITLE=$(echo "$CMD" | sed 's/.*título para //')
    cat << HTML > index.html
<!DOCTYPE html>
<html>
<head><title>$TITLE</title></head>
<body><h1>$TITLE</h1></body>
</html>
HTML
    nexus_log "título atualizado"

  elif [[ "$CMD" == *"botão"* ]]; then
    LABEL=$(echo "$CMD" | sed 's/.*botão //')
    echo "<button style='background:blue;color:white' onclick=\"alert('Bem Vindos')\">$LABEL</button>" >> index.html
    nexus_log "botão adicionado"

  else
    nexus_log "comando ignorado"
  fi
}

# =========================
# LOOP AUTÔNOMO
# =========================
run_agent() {
  ensure_base
  nexus_log "agente iniciado"

  while true; do

    if [ -s "$STATE_FILE" ]; then
      CMD=$(head -n 1 "$STATE_FILE")
      sed -i '1d' "$STATE_FILE"

      process_command "$CMD"

      git add .
      git commit -m "nexus v4 auto update" || true
      git push || true

      nexus_log "deploy concluído"
    fi

    sleep 3
  done
}

