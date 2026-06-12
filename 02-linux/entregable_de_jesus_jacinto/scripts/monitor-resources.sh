#!/usr/bin/env bash
CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'.' -f1)
RAM=$(free | awk '/Mem:/ {printf "%.0f", $3/$2 * 100}')
DISK=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
THRESHOLD=80
[[ $CPU -gt $THRESHOLD || $RAM -gt $THRESHOLD || $DISK -gt $THRESHOLD ]] && \
  mail -s "Alerta en $(hostname)" admin@equipo.com <<< "CPU=$CPU RAM=$RAM DISK=$DISK"
