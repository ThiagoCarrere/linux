#!/bin/bash

# Definindo arrays de usuários, grupos, senhas do Samba e senhas do Linux
usuarios=(
    'thiago' 
    'andre' 
    'carol'
)

grupos=(
    'adm' 
    'ti' 
    'rh'
)

senhas_samba=(
    'a1s23' 
    'a54sd65as' 
    'a45s6d4as'
)

senhas_linux=(
    'senhaThiago' 
    'senhaAndre' 
    'senhaCarol'
)

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
        # Define a senha do usuário Linux
        echo "$1:${senhas_linux[i]}" | sudo chpasswd
        echo "Senha do usuário '$1' definida."
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

# Loop para criar grupos, usuários e adicionar ao Samba
for i in "${!usuarios[@]}"; do
    criar_grupo "${grupos[i]}"
    criar_usuario "${usuarios[i]}" "${grupos[i]}"
    adicionar_samba "${usuarios[i]}" "${senhas_samba[i]}"
done
