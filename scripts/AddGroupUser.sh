#!/bin/bash

#Script para criação de usuarios e grupos já no samba

# Verifica se o número de argumentos está correto
if [ "$#" -ne 2 ]; then
    echo "Uso: $0 <nome_usuario> <nome_grupo>"
    exit 1
fi

NOME_USUARIO=$1
NOME_GRUPO=$2

# Cria o grupo
if ! getent group "$NOME_GRUPO" > /dev/null; then
    sudo groupadd "$NOME_GRUPO"
    echo "Grupo '$NOME_GRUPO' criado."
else
    echo "Grupo '$NOME_GRUPO' já existe."
fi

# Cria o usuário e adiciona ao grupo
if ! id "$NOME_USUARIO" > /dev/null 2>&1; then
    sudo useradd -m -G "$NOME_GRUPO" "$NOME_USUARIO"
    echo "Usuário '$NOME_USUARIO' criado e adicionado ao grupo '$NOME_GRUPO'."
else
    echo "Usuário '$NOME_USUARIO' já existe."
fi

# Cria o usuário no Samba
if ! pdbedit -L | grep -q "^$NOME_USUARIO"; then
    sudo smbpasswd -a "$NOME_USUARIO"
    echo "Usuário '$NOME_USUARIO' adicionado ao Samba."
else
    echo "Usuário '$NOME_USUARIO' já existe no Samba."
fi
