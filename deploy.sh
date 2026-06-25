#!/bin/bash
# Script de Deploy Nexus SRE
cd /data/data/com.termux/files/home/ia_termux/arsenal/scripts/web_base
git add .
git commit -m "Nexus SRE: Atualização automatizada via CLI"
git push origin main
echo "--- Deploy finalizado com sucesso ---"
