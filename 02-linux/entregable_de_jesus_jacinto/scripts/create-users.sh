#!/usr/bin/env bash
# create-users.sh
# Crea usuarios masivamente a partir de data/users.csv
# Formato del CSV: usuario,grupo,contraseña
#
# Uso: sudo bash scripts/create-users.sh

set -euo pipefail

# Cargar librería de logging
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/logging.sh"

CSV_FILE="${1:-$SCRIPT_DIR/../data/users.csv}"

if [[ ! -f "$CSV_FILE" ]]; then
  log_error "No se encontró el archivo CSV: $CSV_FILE"
  exit 1
fi

if [[ "$EUID" -ne 0 ]]; then
  log_error "Este script debe ejecutarse como root (usa sudo)."
  exit 1
fi

log "Iniciando creación de usuarios desde $CSV_FILE"

while IFS=',' read -r user group pass; do
  # Saltar líneas vacías o comentarios
  [[ -z "$user" || "$user" == \#* ]] && continue

  if id "$user" &>/dev/null; then
    log "El usuario '$user' ya existe, se omite creación."
  else
    useradd -m -s /bin/bash "$user"
    echo "$user:$pass" | chpasswd
    log "Usuario '$user' creado."
  fi

  groupadd -f "$group"
  usermod -aG "$group" "$user"
  log "Usuario '$user' agregado al grupo '$group'."

done < "$CSV_FILE"

log "Proceso de creación de usuarios finalizado."

