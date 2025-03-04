#!/bin/bash

# Função para criar um grupo
criar_grupo() {
    if ! getent group "$1" > /dev/null; then
        sudo groupadd "$1"
        echo "Grupo '$1' criado."
    else
        echo "Grupo '$1' já existe."
    fi
}

# Função para criar um usuário
criar_usuario() {
    if ! id "$1" > /dev/null 2>&1; then
        sudo useradd -m -G "$2" "$1"
        echo "Usuário '$1' criado e adicionado ao grupo '$2'."
    else
        echo "Usuário '$1' já existe."
    fi
}

# Função para adicionar usuário ao Samba
adicionar_samba() {
    if ! pdbedit -L | grep -q "^$1"; then
        echo -e "$2\n$2" | sudo smbpasswd -a "$1"
        echo "Usuário '$1' adicionado ao Samba com senha."
    else
        echo "Usuário '$1' já existe no Samba."
    fi
}

# Pergunta se deseja adicionar um ou mais usuários
read -p "Deseja adicionar 1 ou mais usuários e grupos? (1/mais): " resposta

if [ "$resposta" == "1" ]; then
    # Para 1 usuário e 1 grupo
    read -p "Digite o nome do usuário: " NOME_USUARIO
    read -p "Digite o nome do grupo: " NOME_GRUPO
    read -sp "Digite a senha para o Samba: " SENHA_SAMBA
    echo

    criar_grupo "$NOME_GRUPO"
    criar_usuario "$NOME_USUARIO" "$NOME_GRUPO"
    adicionar_samba "$NOME_USUARIO" "$SENHA_SAMBA"

else
    # Para múltiplos usuários e grupos
    read -p "Quantos usuários você deseja adicionar? " NUM_USUARIOS

    # Declara os arrays
    declare -a USUARIOS
    declare -a GRUPOS

    # Loop para coletar nomes de usuários e grupos
    for ((i = 0; i < NUM_USUARIOS; i++)); do
        read -p "Digite o nome do usuário $((i + 1)): " usuario
        read -p "Digite o nome do grupo para o usuário $usuario: " grupo
        read -sp "Digite a senha para o Samba do usuário $usuario: " senha
        echo

        USUARIOS+=("$usuario")
        GRUPOS+=("$grupo")
        SENHAS+=("$senha")
    done

    # Cria grupos e usuários
    for ((i = 0; i < NUM_USUARIOS; i++)); do
        criar_grupo "${GRUPOS[i]}"
        criar_usuario "${USUARIOS[i]}" "${GRUPOS[i]}"
        adicionar_samba "${USUARIOS[i]}" "${SENHAS[i]}"
    done
fi
