#!/bin/bash

# Configurações
CONFIG_FILE="/.codes/conf.exp"
TIMEZONE="America/Sao_Paulo"

# Lista de pacotes
PACKAGES=("neofetch" "net-tools" "samba" "lm-sensors" "openssh-server" "rsync" "btop")

# Mapeamento: [Marcador]="Arquivo de destino"
declare -A CONFIG_MAP=(
    ["#CRONTAB"]="/etc/crontab"
    ["#BASHRC"]="/root/.bashrc"
    ["#FSTAB"]="/etc/fstab"
    ["#SAMBA"]="/etc/samba/smb.conf"
)

# Função para instalar pacotes
install_packages() {
    echo "Instalando pacotes necessários..."
    apt update -y && apt upgrade -y
    for pkg in "${PACKAGES[@]}"; do
        apt install "$pkg" -y
    done
}

# Função para adicionar configurações (AGORA CORRETA)
add_config() {
    local marker="$1"
    local target_file="$2"
    
    echo "Adicionando configurações em $target_file..."
    
    # Extrai o bloco INTEIRO (com marcadores) e adiciona ao FINAL do arquivo
    sed -n "/$marker/,/$marker/p" "$CONFIG_FILE" >> "$target_file"
    echo "" >> "$target_file"  # Adiciona linha vazia para separação
    sleep 2
}

# Reinicia serviços
restart_services() {
    echo "Reiniciando serviços..."
    systemctl restart cron.service smbd.service ssh.service
}

# --- Execução principal ---
echo "Iniciando importação das configurações..."

# Instala pacotes
install_packages

# Adiciona cada configuração
for marker in "${!CONFIG_MAP[@]}"; do
    add_config "$marker" "${CONFIG_MAP[$marker]}"
done

# Configurações finais
timedatectl set-timezone "$TIMEZONE"
restart_services
source ~/.bashrc

echo "Importação concluída com sucesso!"