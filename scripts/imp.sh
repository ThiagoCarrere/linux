#!/bin/bash

# ===== CONFIGURAÇÕES PRINCIPAIS =====
TIMEZONE="America/Sao_Paulo"
CONFIG_FILE="/.codes/conf.exp"

# Listas (arrays)
PACKAGES=("neofetch" "net-tools" "samba" "lm-sensors" "openssh-server" "rsync")
SERVICES=("cron.service" "smbd.service" "ssh.service")

# Mapeamento: [Marcador]="Mensagem original;Arquivo"
declare -A CONFIG_MAP=(
    ["#CRONTAB"]="Adicionando agendamentos de crontab.;/etc/crontab"
    ["#BASHRC"]="Adicionando configuracoes e aliases..;/root/.bashrc"
    ["#FSTAB"]="Adicionando configurações de montagem de discos...;/etc/fstab"
    ["#SAMBA"]="Adicionando mapeamentos do Samba....;/etc/samba/smb.conf"
)

# ===== FUNÇÕES =====
install_packages() {
    echo "Instalando pacotes necessários..."
    apt update -y && apt upgrade -y
    for pkg in "${PACKAGES[@]}"; do
        apt install "$pkg" -y
    done
}

apply_config() {
    local marker="$1"
    local msg_file="${CONFIG_MAP[$marker]}"
    local message="${msg_file%;*}"  # Mensagem original
    local target_file="${msg_file#*;}"  # Arquivo de destino

    echo "$message"
    sed -n "/$marker/,/$marker/p" "$CONFIG_FILE" | sed "/$marker/d" >> "$target_file"
    sleep 2  # Pausa igual ao seu script original
}

restart_services() {
    echo "Reiniciando serviços..."
    for service in "${SERVICES[@]}"; do
        if systemctl is-active --quiet "$service"; then
            systemctl restart "$service"
        else
            echo "[AVISO] Serviço $service não está ativo."
        fi
    done
}

# ===== EXECUÇÃO PRINCIPAL =====
echo "Iniciando a instalação de programas e importação das configurações..."

install_packages

# Aplica configurações COM PAUSAS (igual ao seu original)
for marker in "${!CONFIG_MAP[@]}"; do
    apply_config "$marker"  # Já inclui o sleep 2 dentro da função
done

# Finalização
timedatectl set-timezone "$TIMEZONE"
restart_services
source ~/.bashrc

echo "Importação e configuração concluída com sucesso!"