#!/bin/bash

### Script para encontrar arquivo e excluir ###
echo "Iniciando limpeza de arquivos .txt"
sleep 2
find /Diretorio/ -type f -iname '*.txt' -exec rm -fv {} \;

