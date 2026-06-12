# Proyecto 02 — Automatización con Bash

Suite de scripts administrativos con logging centralizado para Linux (Ubun>

## Estructura

```
02-linux/
├── scripts/
│   ├── create-users.sh        # Creación masiva de usuarios desde CSV
│   ├── backup-incremental.sh  # Respaldo incremental con rsync
│   ├── monitor-resources.sh   # Monitoreo de CPU/RAM/disco con alertas
│   └── lib/
│       └── logging.sh         # Función de logging compartida
├── data/
│   └── users.csv               # Datos de prueba: usuario,grupo,contraseña
├── crontab/
│   └── equipo.cron             # Tareas programadas (cron)
