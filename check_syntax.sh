#!/bin/bash
# NEXUS SRE - Validador de Integridade v2.0
RAIZ_WEB="/data/data/com.termux/files/home/ia_termux/arsenal/scripts/web_base"
ERROS=0

echo -e "\n\033[1;34m[NEXUS CHECK]\033[0m Iniciando varredura de integridade..."
echo "-----------------------------------------------"

# 1. Verificar Banco de Dados JSON
echo -n "--- Verificando produtos.json: "
if jq . "$RAIZ_WEB/produtos.json" > /dev/null 2>&1; then
    echo -e "\033[1;32mOK\033[0m"
else
    echo -e "\033[1;31mERRO (Arquivo corrompido ou JSON inválido)\033[0m"
    ERROS=$((ERROS + 1))
fi

# 2. Verificar Scripts Principais (Sintaxe Bash)
scripts=("nexus_estoque.sh" "nexus_remover.sh" "nexus_editar.sh" "deploy.sh")
for s in "${scripts[@]}"; do
    echo -n "--- Verificando $s: "
    if [ ! -f "$RAIZ_WEB/$s" ]; then
        echo -e "\033[1;33mFALTANDO\033[0m"
        ERROS=$((ERROS + 1))
    elif bash -n "$RAIZ_WEB/$s" 2>/dev/null; then
        echo -e "\033[1;32mOK\033[0m"
    else
        echo -e "\033[1;31mERRO DE SINTAXE\033[0m"
        ERROS=$((ERROS + 1))
    fi
done

# 3. Verificar Pastas de Imagens
echo -n "--- Verificando pasta carrossel: "
if [ -d "$RAIZ_WEB/img/carrossel" ]; then
    echo -e "\033[1;32mOK\033[0m"
else
    echo -e "\033[1;33mAVISO (Pasta não encontrada)\033[0m"
fi

# Conclusão
echo "-----------------------------------------------"
if [ $ERROS -eq 0 ]; then
    echo -e "\033[1;32m[RESULTADO]\033[0m Tudo pronto para as vendas! 🧶🚀"
else
    echo -e "\033[1;31m[RESULTADO]\033[0m Foram encontrados $ERROS problema(s)."
fi
echo ""
