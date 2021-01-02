#!/bin/bash

### rotina para encontrar arquivo e excluir ###
#echo "Iniciando limpeza de arquivos .txt"
#sleep 2
#find /rsyncDebian/ -type f -iname '*.txt*' -exec rm -fv {} \; 


### BACKUP DOS SCRIPTS CRIADOS PARA O SERVIDOR DE PASTAS PUBLICAS ### 

echo "Iniciando atualizacao dos scripts para o servidor de pastas publicas"
sleep 2
rsync -azvh --progress /scripts/ root@192.168.0.200:/publica/scripts/
