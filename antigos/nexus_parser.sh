#!/data/data/com.termux/files/usr/bin/bash

source ./nexus_override.sh

execute_command() {
  CMD="$1"

  echo "[NEXUS] comando recebido: $CMD"

  if [[ "$CMD" == *"título"* ]]; then
    overwrite_file index.html "<html><head><title>Novo Site Nexus</title></head><body><h1>Site atualizado</h1></body></html>"
  
  elif [[ "$CMD" == *"botão"* ]]; then
    overwrite_file index.html "<html><body><button style='background:blue'>Botão Nexus</button></body></html>"

  else
    echo "[NEXUS] comando não reconhecido"
  fi
}

