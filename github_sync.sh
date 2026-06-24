#!/bin/bash
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

# Configurações de Identidade
git config user.name "Olnair2932"
# Substitua o email abaixo pelo seu email do GitHub se souber
git config user.email "olnair2932@gmail.com" 

BRANCH="main"
COMMIT_MSG="Atualização de produtos por Olnair2932 em $(date '+%d/%m/%Y %H:%M:%S')"

echo "Iniciando sincronização para Olnair2932..."
git add .
git commit -m "$COMMIT_MSG"
git push origin "$BRANCH"

if [ $? -eq 0 ]; then
    echo "✔ Enviado para o GitHub com sucesso!"
else
    echo "✖ Erro ao enviar para o GitHub."
fi
