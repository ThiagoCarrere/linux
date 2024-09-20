#!/bin/bash

### rotina para encontrar arquivo e excluir ###
#find xxxxxxx -type f -iname '*.*' ls -lha '{}' \;

### Script de Backup Espelho

echo "Iniciando Backup Espelho de pastas publicas"
sleep 3 
rsync -avz --delete root@192.168.0.200:/publica/ /rsyncDebian/ >> /var/log/rsync_backup_espelho.log 2>&1


