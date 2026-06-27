#!/data/data/com.termux/files/usr/bin/bash

# =========================
# NEXUS OVERRIDE ENGINE
# =========================

nexus_log() {
  echo "[NEXUS-OVERRIDE] $1"
}

overwrite_file() {
  FILE="$1"
  CONTENT="$2"

  if [ -z "$FILE" ]; then
    nexus_log "ERRO: arquivo não definido"
    exit 1
  fi

  nexus_log "sobrescrevendo: $FILE"

  # garante pasta
  mkdir -p "$(dirname "$FILE")"

  # sobrescrita limpa e segura
  cat << CONTENT_EOF > "$FILE"
$CONTENT
CONTENT_EOF

  nexus_log "arquivo atualizado com sucesso: $FILE"
}

safe_preview() {
  FILE="$1"
  echo "===== PREVIEW: $FILE ====="
  cat "$FILE"
  echo "=========================="
}

confirm_and_overwrite() {
  FILE="$1"
  CONTENT="$2"

  echo "[NEXUS] você está prestes a sobrescrever: $FILE"
  echo "Deseja continuar? (y/n)"
  read CONFIRM

  if [ "$CONFIRM" = "y" ]; then
    overwrite_file "$FILE" "$CONTENT"
  else
    nexus_log "operação cancelada"
  fi
}

