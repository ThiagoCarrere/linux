#!/bin/bash

SOURCE1="root@192.168.142.250:/mnt/"
DESTINATION1="/mnt/hd1/"
SOURCE2="/mnt/hd1/"
DESTINATION2="root@54.1.9.1:/pasta/"
LOGFILE="/.codes/bkp.log"
TMP_OUTPUT=$(mktemp)  # Cria um arquivo temporário para armazenar a saída do rsync

# Função para adicionar mensagens ao log
add_to_log() {
    local message="$1"
    if [ ! -f "$LOGFILE" ]; then
        echo "$message" > "$LOGFILE"
    else
        sed -i "1s|^|${message}\n|" "$LOGFILE"
    fi
}

# Função para executar o rsync e registrar o log
execute_rsync() {
    local source="$1"
    local destination="$2"
    local description="$3"
    local ssh_options="$4"

    echo "Iniciando $description"

    # Executa o rsync, exibindo a saída em tempo real e registrando no arquivo temporário
    if eval rsync -azvh --progress $ssh_options "$source" "$destination" 2>&1 | tee "$TMP_OUTPUT"; then
        msg=$(printf "%(%x_%X)T => $description EFETUADO COM SUCESSO +++\n")

        # Verifica se a linha "received" existe na saída
        if grep -q "received" "$TMP_OUTPUT"; then
            # Extrai o volume de dados transferidos (usando a linha "received")
            transferred_size=$(grep -oP "received \K[0-9.]+[KMGT]? bytes" "$TMP_OUTPUT")
            msg="$msg => $transferred_size"
        else
            msg="$msg => Nenhum dado transferido ou informação não disponível"
        fi
    else
        msg=$(printf "%(%x_%X)T => FALHA AO EFETUAR $description ---\n")
    fi

    # Adicionando a mensagem no início do bkp.log
    add_to_log "$msg"
}

# Primeira chamada rsync (sincronização do servidor na rede)
execute_rsync "$SOURCE1" "$DESTINATION1" "SINCRONIZACAO DO SERVIDOR ESPELHO"

# Segunda chamada rsync (backup em nuvem)
execute_rsync "$SOURCE2" "$DESTINATION2" "BACKUP DE CONTINGENCIA" "-e 'ssh -p 45'"

# Limpeza: Remove o arquivo temporário
rm "$TMP_OUTPUT"