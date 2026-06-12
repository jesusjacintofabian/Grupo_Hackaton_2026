!/usr/bin/env bash
# monitor-resources.sh
# Revisa el uso de CPU, RAM y disco. Si alguno supera el umbral definido,
# envía una alerta por correo y registra el evento en el log.
#
# Uso: bash scripts/monitor-resources.sh
# Recomendado: ejecutarlo vía cron cada 5-15 minutos

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/logging.sh"

THRESHOLD=80
ALERT_EMAIL="admin@equipo.com"

CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'.' -f1)
RAM=$(free | awk '/Mem:/ {printf "%.0f", $3/$2 * 100}')
