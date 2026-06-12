!/usr/bin/env bash
# backup-incremental.sh
# Realiza un respaldo incremental de /etc hacia un servidor remoto usando rsync.
# Cada respaldo solo copia los archivos cambiados desde el último respaldo,
# enlazando (hard-link) los archivos no modificados al respaldo anterior.
#
# Uso: bash scripts/backup-incremental.sh
# Recomendado: ejecutarlo vía cron (ver crontab/equipo.cron)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/logging.sh"

SOURCE="/etc"
REMOTE_USER="backup"
REMOTE_HOST="remote"
REMOTE_BASE="/backups/$(hostname)"
TODAY="$(date +%F)"
YESTERDAY="$(date -d 'yesterday' +%F)"

