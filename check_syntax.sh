#!/bin/bash
# Script de verificação de sintaxe para Nexus SRE
FILE="/data/data/com.termux/files/home/ia_termux/arsenal/scripts/web_base/index.html"

echo "Iniciando verificação de sintaxe em: $FILE"

# Verifica se o arquivo existe
if [ ! -f "$FILE" ]; then
    echo "Erro: Arquivo não encontrado!"
    exit 1
fi

# Verifica se tags essenciais estão fechadas (simples verificação de estrutura)
if grep -q "<script>" "$FILE" && ! grep -q "</script>" "$FILE"; then
    echo "Erro: Tag <script> aberta sem fechamento correspondente."
    exit 1
fi

echo "Verificação concluída: Estrutura básica OK."
echo "Dica: Para uma análise profunda de JS, recomendo instalar o 'jshint' via npm."
