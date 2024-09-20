#!/bin/bash

### Script de backup para um servidor via rsync

echo "Iniciando atualizacao dos scripts para o servidor de pastas publicas"
sleep 2
rsync -azvh --progress /scripts/ root@192.168.0.200:/publica/scripts/ >> /var/log/rsync_backup_incremental.log 2>&1
