#!/data/data/com.termux/files/usr/bin/bash

source ./nexus_core_v5.sh
source ./nexus_override.sh

echo "[NEXUS] pronto para comandos em linguagem natural"
echo "Ex: criar site, mudar título para X, adicionar botão"

while true; do
  read -p "NEXUS> " CMD

  if [[ "$CMD" == *"sair"* ]]; then
    echo "Nexus encerrado"
    break
  fi

  # converte linguagem natural para ações simples
  if [[ "$CMD" == *"site"* ]]; then
    execute_action "create_site"
  elif [[ "$CMD" == *"título"* ]]; then
    VALUE=$(echo "$CMD" | sed 's/.*para //')
    execute_action "set_title" "$VALUE"
  elif [[ "$CMD" == *"botão"* ]]; then
    VALUE=$(echo "$CMD" | sed 's/.*botão //')
    execute_action "add_button" "$VALUE"
  else
    echo "[NEXUS] comando não reconhecido"
  fi

done
