#!/data/data/com.termux/files/usr/bin/bash

# =========================
# NEXUS FILE ENGINE (NFE)
# Escrita segura com EOF
# =========================

nexus_log() {
  echo "[NEXUS-FE] $1"
}

# =========================
# ESCRITA SEGURA (EOF REAL)
# =========================
write_file() {
  FILE="$1"
  CONTENT="$2"

  if [ -z "$FILE" ]; then
    nexus_log "ERRO: arquivo vazio"
    return 1
  fi

  mkdir -p "$(dirname "$FILE")"

  cat << EOF > "$FILE"
$CONTENT
