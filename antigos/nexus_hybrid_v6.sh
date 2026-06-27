#!/data/data/com.termux/files/usr/bin/bash

source ./nexus_override.sh

nexus_log() {
  echo "[NEXUS-V6] $1"
}

# =========================
# CORE ACTIONS
# =========================

execute_action() {
  ACTION="$1"
  VALUE="$2"

  nexus_log "ação: $ACTION | valor: $VALUE"

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

  esac
}

# =========================
# JSON PARSER
# =========================

parse_json() {
  RAW="$1"

  ACTION=$(echo "$RAW" | grep -o '"action":"[^"]*"' | cut -d':' -f2 | tr -d '"')
  VALUE=$(echo "$RAW" | grep -o '"value":"[^"]*"' | cut -d':' -f2 | tr -d '"')

  if [ -n "$ACTION" ]; then
    execute_action "$ACTION" "$VALUE"
    return
  fi

  nexus_log "JSON inválido"
}

# =========================
# NATURAL LANGUAGE PARSER
# =========================

parse_natural() {
  CMD="$1"

  nexus_log "natural: $CMD"

  if [[ "$CMD" == *"site"* ]]; then
    execute_action "create_site"

  elif [[ "$CMD" == *"título"* ]]; then
    VALUE=$(echo "$CMD" | sed 's/.*para //')
    execute_action "set_title" "$VALUE"

  elif [[ "$CMD" == *"botão"* ]]; then
    VALUE=$(echo "$CMD" | sed 's/.*botão //')
    execute_action "add_button" "$VALUE"

  else
    nexus_log "comando não reconhecido"
  fi
}

# =========================
# ROUTER PRINCIPAL
# =========================

run() {
  echo "[NEXUS-V6] pronto (JSON ou linguagem natural)"

  while true; do
    read -p "NEXUS> " INPUT

    if [[ "$INPUT" == "sair" ]]; then
      break
    fi

    # detecta JSON
    if [[ "$INPUT" == \{*\} ]]; then
      parse_json "$INPUT"
    else
      parse_natural "$INPUT"
    fi

    git add .
    git commit -m "nexus v6 update" || true
    git push || true

  done
}

