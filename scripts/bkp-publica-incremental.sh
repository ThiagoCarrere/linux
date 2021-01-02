#!/bin/bash

### rotina para encontrar arquivo e excluir ###
echo "Iniciando limpeza de arquivos .txt"
sleep 2
find /rsyncDebian/ -type f -iname '*.txt*' -exec rm -fv {} \; 


### BACKUP DO SERVIDOR DE PASTAS PUBLICAS ### 

echo "Iniciando Backup Incremental de pastas publicas"
sleep 2 
rsync -azvh --progress root@192.168.0.200:/publica/ /rsyncDebian/




