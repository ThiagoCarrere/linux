#criando pastas privadas
mkdir nome_pasta_privada

#criando grupos
groudadd nome_grupo

#criando usuario sem criar pasta e sem permissao de login
adduser --no-create-home --disabled-login nome_usuario

#vinculando pastas aos grupos
chgrp nome_grupo nome_pasta_privada

#inserindo usuario em grupo
usermod -aG nome_grupo nome_usuario

#verificando se o usuario tem acesso ao grupo
groups nome_usuario

#criando senha no samba para o usuario
smbpasswd -a nome_usuario

#criando permissao de acesso a pasta
chmod -R 770 nome_pasta_privada    

#configurando o samba
path = /dados/rh/
writable = yes
force create mode = 0770
force directory mode = 0770
guest ok = no
valid users = @nome_grupo

####################################################################################
#!/bin/bash

# Verifica se o usuário é root
if [ "$(id -u)" -ne 0 ]; then
    echo "Este script deve ser executado como root ou com sudo." >&2
    exit 1
fi

# Função para verificar se grupo já existe
verifica_grupo() {
    if grep -q "^$1:" /etc/group; then
        echo -e "\n⚠️  O grupo '$1' já existe! Deseja:"
        echo "1) Usar o grupo existente"
        echo "2) Cancelar a operação"
        read -p "Opção [1/2]: " OPCAO
        
        case $OPCAO in
            1) return 1 ;;
            2) echo "Operação cancelada."; exit 0 ;;
            *) echo "Opção inválida!"; exit 1 ;;
        esac
    fi
    return 0
}

# Pede os dados de entrada
read -p "Nome da pasta privada: " NOME_PASTA
read -p "Nome do grupo: " NOME_GRUPO
read -p "Nome do usuário: " NOME_USUARIO

# Verifica se usuário já existe
if id "$NOME_USUARIO" &>/dev/null; then
    echo -e "\n❌ Erro: O usuário '$NOME_USUARIO' já existe!" >&2
    exit 1
fi

# Verifica se pasta já existe
if [ -d "$NOME_PASTA" ]; then
    echo -e "\n❌ Erro: A pasta '$NOME_PASTA' já existe!" >&2
    exit 1
fi

# Validação do grupo
verifica_grupo "$NOME_GRUPO"
GRUPO_EXISTENTE=$?

# Confirmação final
echo -e "\n✔ Resumo da operação:"
echo "Pasta: $NOME_PASTA"
echo "Grupo: $NOME_GRUPO ($([ $GRUPO_EXISTENTE -eq 1 ] && echo "Existente" || echo "Novo"))"
echo "Usuário: $NOME_USUARIO (Novo)"
echo -e "\n⚠️  ATENÇÃO: Esta ação não pode ser desfeita automaticamente!"
read -p "Confirmar a execução? (s/n): " CONFIRMAR

if [[ ! "$CONFIRMAR" =~ ^[Ss]$ ]]; then
    echo "Operação cancelada pelo usuário."
    exit 0
fi

# Execução das ações
echo -e "\nIniciando a criação..."

# Cria a pasta privada
mkdir -p "$NOME_PASTA" || { echo "Erro ao criar pasta!"; exit 1; }

# Cria o grupo (se não existir)
if [ $GRUPO_EXISTENTE -eq 0 ]; then
    groupadd "$NOME_GRUPO" || { echo "Erro ao criar grupo!"; exit 1; }
fi

# Cria o usuário
adduser --no-create-home --disabled-login "$NOME_USUARIO" || { echo "Erro ao criar usuário!"; exit 1; }

# Configurações de permissão
chgrp "$NOME_GRUPO" "$NOME_PASTA" || { echo "Erro ao definir grupo da pasta!"; exit 1; }
usermod -aG "$NOME_GRUPO" "$NOME_USUARIO" || { echo "Erro ao adicionar usuário ao grupo!"; exit 1; }
chmod -R 770 "$NOME_PASTA" || { echo "Erro ao definir permissões!"; exit 1; }

# Samba
echo -e "\nDefina a senha do Samba para o usuário '$NOME_USUARIO':"
smbpasswd -a "$NOME_USUARIO" || { echo "Erro ao configurar Samba!"; exit 1; }

# Verificação final+++
echo -e "\n✔ Concluído! Verificação:"
echo -e "\nGrupos do usuário '$NOME_USUARIO':"
groups "$NOME_USUARIO"
echo -e "\nPermissões da pasta '$NOME_PASTA':"
ls -ld "$NOME_PASTA"