#!/bin/bash

### rotina para encontrar arquivo e excluir ###
#find xxxxxxx -type f -iname '*.*' ls -lha '{}' \;

### BACKUP DO SERVIDOR DE PASTAS PUBLICAS ### 

echo "Iniciando Backup Espelho de pastas publicas"
sleep 3 
rsync -hvrP --delete root@192.168.0.200:/publica/ /rsyncDebian/




