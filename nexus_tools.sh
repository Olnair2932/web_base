#!/data/data/com.termux/files/usr/bin/bash

# =========================
# NEXUS TOOLBOX v1
# Ferramentas padrão de edição
# =========================

nexus_log() {
  echo "[NEXUS] $1"
}

write_file() {
  FILE="$1"
  CONTENT="$2"
  mkdir -p "$(dirname "$FILE")"
  echo "$CONTENT" > "$FILE"
  nexus_log "arquivo escrito: $FILE"
}

append_file() {
  FILE="$1"
  CONTENT="$2"
  echo "$CONTENT" >> "$FILE"
  nexus_log "append em: $FILE"
}

replace_file() {
  FILE="$1"
  CONTENT="$2"
  > "$FILE"
  echo "$CONTENT" > "$FILE"
  nexus_log "arquivo substituído: $FILE"
}

ensure_file() {
  FILE="$1"
  DEFAULT="$2"
  if [ ! -f "$FILE" ]; then
    write_file "$FILE" "$DEFAULT"
    nexus_log "arquivo criado automaticamente: $FILE"
  fi
}

list_project() {
  echo "[NEXUS] estrutura do projeto:"
  ls -la
}

safe_cd() {
  TARGET="$1"
  if [ -d "$TARGET" ]; then
    cd "$TARGET"
    nexus_log "entrando em $TARGET"
  else
    nexus_log "diretório não existe: $TARGET"
  fi
}

git_sync() {
  nexus_log "sincronizando git..."
  git add .
  git commit -m "nexus auto update" || nexus_log "sem mudanças"
  git pull origin main --rebase
  git push origin main
  nexus_log "sync concluído"
}

install_web_template() {
  nexus_log "criando template básico web..."

  ensure_file "index.html" "<html><body><h1>Nexus Site</h1></body></html>"
  ensure_file "style.css" "body { font-family: Arial; }"
  ensure_file "script.js" "console.log('Nexus ativo');"

  nexus_log "template criado"
}
