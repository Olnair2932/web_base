#!/data/data/com.termux/files/usr/bin/bash

source ./nexus_override.sh

QUEUE_FILE="nexus_queue.json"
LOG_FILE="nexus_log.txt"
STATE_DIR="nexus_state"

mkdir -p "$STATE_DIR"

log() {
  echo "[NEXUS-V5] $1"
  echo "$(date) - $1" >> "$LOG_FILE"
}

# =========================
# INIT PROJETO
# =========================
init_project() {
  [ ! -f index.html ] && echo "<h1>Nexus</h1>" > index.html
  [ ! -f style.css ] && echo "body{font-family:Arial}" > style.css
  [ ! -f index.js ] && echo "console.log('Nexus ativo')" > index.js
  [ ! -f "$QUEUE_FILE" ] && echo "[]" > "$QUEUE_FILE"
}

# =========================
# PARSER JSON
# =========================
read_queue() {
  cat "$QUEUE_FILE"
}

clear_queue() {
  echo "[]" > "$QUEUE_FILE"
}

# =========================
# EXECUTOR
# =========================
execute_action() {
  ACTION="$1"
  VALUE="$2"

  log "executando: $ACTION"

  case "$ACTION" in

    "create_site")
      cat << HTML > index.html
<!DOCTYPE html>
<html>
<head><title>Nexus Site</title></head>
<body><h1>Novo Site Nexus</h1></body>
</html>
HTML
    ;;

    "set_title")
      cat << HTML > index.html
<!DOCTYPE html>
<html>
<head><title>$VALUE</title></head>
<body><h1>$VALUE</h1></body>
</html>
HTML
    ;;

    "add_button")
      echo "<button style='background:blue;color:white' onclick=\"alert('Bem Vindos')\">$VALUE</button>" >> index.html
    ;;

    "update_js")
      echo "$VALUE" > index.js
    ;;

  esac
}

# =========================
# PROCESSADOR JSON SIMPLES
# =========================
process_json() {
  RAW=$(cat "$QUEUE_FILE")

  ACTION=$(echo "$RAW" | grep -o '"action":"[^"]*"' | cut -d':' -f2 | tr -d '"')
  VALUE=$(echo "$RAW" | grep -o '"value":"[^"]*"' | cut -d':' -f2 | tr -d '"')

  if [ -n "$ACTION" ]; then
    execute_action "$ACTION" "$VALUE"
  fi
}

# =========================
# LOOP PRINCIPAL
# =========================
run_v5() {
  init_project
  log "Nexus v5 iniciado"

  while true; do

    if [ -s "$QUEUE_FILE" ] && [ "$(cat $QUEUE_FILE)" != "[]" ]; then

      process_json

      git add .
      git commit -m "nexus v5 auto deploy" || true
      git push || true

      clear_queue

      log "deploy concluído"

    fi

    sleep 2
  done
}

