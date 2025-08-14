#!/bin/bash

# Configurações
DESTINO="/.codes/conf.exp"
CODES_DIR="/.codes"
CRONTAB="/etc/crontab"
BASHRC="/root/.bashrc"
FSTAB="/etc/fstab"
SAMBA="/etc/samba/smb.conf"

# Funções
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

separador() {
  echo "" >> "$DESTINO"
}

# Início do script
log "Iniciando o script de exportação de configurações..."

# Limpa/cria o arquivo de destino
> "$DESTINO"
log "Arquivo de destino ($DESTINO) inicializado."

# Mapeamento: Marcador => Arquivo
declare -A CONFIG_SOURCES=(
  ["#CRONTAB"]="$CRONTAB"
  ["#BASHRC"]="$BASHRC"
  ["#FSTAB"]="$FSTAB"
  ["#SAMBA"]="$SAMBA"
)

# Exporta cada configuração (preservando marcadores, comentários e formatação)
for marker in "${!CONFIG_SOURCES[@]}"; do
  case "$marker" in
    "#CRONTAB") log_msg="crontab exportado com sucesso!" ;;
    "#BASHRC")  log_msg=".bashrc exportado com sucesso!" ;;
    "#FSTAB")   log_msg="fstab exportado com sucesso!" ;;
    "#SAMBA")   log_msg="samba exportado com sucesso!" ;;
  esac

  # Extrai TUDO entre os marcadores (incluindo os próprios marcadores)
  awk "/$marker/{flag=1; next} /$marker/{flag=0} flag" "${CONFIG_SOURCES[$marker]}" | \
    sed "1i\\$marker" | \
    sed "\$a\\$marker" >> "$DESTINO"
  
  separador
  log "$log_msg"
done

log "Processamento concluido com sucesso!"