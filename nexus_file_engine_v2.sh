#!/data/data/com.termux/files/usr/bin/bash

nexus_log() {
  echo "[NEXUS-FE2] $1"
}

# =========================
# ESCRITA SEGURA REAL
# =========================
write_file() {
  FILE="$1"
  CONTENT="$2"

  if [ -z "$FILE" ]; then
    nexus_log "ERRO: arquivo vazio"
    return 1
  fi

  mkdir -p "$(dirname "$FILE")"

  # proteção contra quebra de EOF
  TMP_FILE=$(mktemp)

  echo "$CONTENT" > "$TMP_FILE"
  cat "$TMP_FILE" > "$FILE"
  rm -f "$TMP_FILE"

  nexus_log "arquivo escrito: $FILE"
}

# =========================
# REESCRITA FORÇADA
# =========================
rewrite_file() {
  FILE="$1"
  CONTENT="$2"

  nexus_log "reescrevendo: $FILE"
  write_file "$FILE" "$CONTENT"
}

# =========================
# HTML TEMPLATE LIMPO
# =========================
html_page() {
  TITLE="$1"
  BUTTON="$2"

  echo "<!DOCTYPE html>
<html>
<head>
  <title>$TITLE</title>
</head>
<body>

<h1>$TITLE</h1>

<button style='background:blue;color:white;padding:10px'
onclick=\"alert('Bem Vindos')\">
$BUTTON
</button>

</body>
</html>"
}

# =========================
# CRIAR SITE SEGURO
# =========================
create_site() {
  TITLE="$1"
  BUTTON="$2"

  CONTENT=$(html_page "$TITLE" "$BUTTON")
  rewrite_file "index.html" "$CONTENT"

  nexus_log "site atualizado com sucesso"
}

