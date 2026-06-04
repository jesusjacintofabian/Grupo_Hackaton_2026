# Módulo 02 — Linux

> **Categoría:** Sistema Operativo · **Prioridad:** Obligatorio · **Origen:** `devops-roadmap.html#s02`

## 1. Por qué importa

Más del 90% de los servidores cloud funcionan sobre Linux. No es opcional, es el piso sobre el que se construye todo el ecosistema DevOps. AWS, Azure, GCP, Kubernetes, Docker — todo corre sobre Linux. En hackathons cloud-native, Linux es el sistema operativo por defecto.

## 2. Objetivos de aprendizaje

- Navegar y administrar el sistema de archivos Linux
- Ejecutar tareas administrativas con la línea de comandos
- Crear y mantener servicios con systemd
- Escribir scripts de Bash para automatizar operaciones

## 3. Prerrequisitos

- Módulo 01 completado (fundamentos de red)
- Distribución Linux instalada (Ubuntu 22.04 LTS recomendada) o WSL2
- Acceso a terminal con permisos sudo

## 4. Temas detallados

### 4.1 Sistema de archivos (FHS)
| Path | Propósito |
|------|-----------|
| `/` | Raíz del sistema |
| `/etc` | Archivos de configuración |
| `/var` | Logs, datos variables |
| `/home` | Directorios de usuarios |
| `/opt` | Software de terceros |
| `/tmp` | Archivos temporales |
| `/usr` | Binarios del sistema |
| `/srv` | Datos de servicios |

### 4.2 Comandos esenciales
```
Navegación:   ls -la, cd, pwd, tree
Archivos:     cp, mv, rm, mkdir, touch, cat, less, head, tail
Búsqueda:     grep, find, locate
Procesos:     ps aux, top, htop, kill, pkill
Red:          ip addr, ping, curl, wget, netstat, ss, dig
Permisos:     chmod, chown, chgrp, umask, setuid
Archivado:    tar, gzip, zip, rsync
Texto:        awk, sed, sort, uniq, cut
```

### 4.3 Systemd y servicios
```bash
systemctl status nginx
systemctl start nginx
systemctl stop nginx
systemctl restart nginx
systemctl enable nginx         # al boot
journalctl -u nginx -f        # logs en vivo
journalctl --since "1 hour ago"
```

### 4.4 Bash scripting
- Variables y exportación (`export VAR=value`)
- Condicionales: `if/elif/else`, `case`
- Bucles: `for`, `while`, `until`
- Funciones y argumentos (`$1`, `$@`, `$#`)
- Arrays
- Exit codes (`$?`) y `set -euo pipefail`
- Trap para cleanup
- Cron: `crontab -e`

### 4.5 Gestión de usuarios
```
useradd, userdel, usermod
passwd
groupadd, groupdel, gpasswd
sudo, visudo (/etc/sudoers)
id, who, w, last
```

### 4.6 Permisos
```
chmod 755 archivo        # rwxr-xr-x
chown user:group archivo
umask 022
setuid, setgid, sticky bit
ACLs: getfacl, setfacl
```

### 4.7 Procesos
```
ps aux | grep nginx
htop
kill -9 PID
nice -n 10 comando
nohup comando &
jobs, fg, bg
```

### 4.8 Red desde CLI
```
ip addr show
ip route show
ping -c 4 destino
curl -I https://ejemplo.com
dig hackathon.local
ss -tulnp                       # sockets escuchando
```

## 5. Herramientas

| Herramienta | Uso |
|-------------|-----|
| `tmux` / `screen` | Multiplexor de terminales |
| `ssh` | Acceso remoto seguro |
| `rsync` | Sincronización eficiente |
| `cron` / `systemd-timer` | Programación de tareas |
| `htop` / `btop` | Monitoreo de procesos |
| `ncdu` | Analizador de disco interactivo |

## 6. Proyecto 02 — Automatización con Bash

**Duración estimada:** 12-16 horas
**Entregable:** Suite de scripts administrativos con logging centralizado

### Pasos

1. **Script de creación masiva de usuarios desde CSV**
   ```bash
   #!/usr/bin/env bash
   set -euo pipefail
   while IFS=',' read -r user group pass; do
     useradd -m -s /bin/bash "$user"
     echo "$user:$pass" | chpasswd
     groupadd -f "$group"
     usermod -aG "$group" "$user"
   done < users.csv
   ```

2. **Script de respaldo incremental con rsync**
   ```bash
   #!/usr/bin/env bash
   SOURCE="/etc"
   DEST="backup@remote:/backups/$(hostname)/$(date +%F)"
   rsync -avz --delete --link-dest="$DEST.1" "$SOURCE" "$DEST"
   ```

3. **Configuración de cron jobs**
   ```bash
   crontab -e
   # Respaldo diario a las 02:00
   0 2 * * * /opt/scripts/backup.sh >> /var/log/backup.log 2>&1
   # Inventario cada lunes a las 08:00
   0 8 * * 1 /opt/scripts/inventory.sh
   ```

4. **Script de monitoreo con alertas por correo**
   ```bash
   #!/usr/bin/env bash
   CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'.' -f1)
   RAM=$(free | awk '/Mem:/ {printf "%.0f", $3/$2 * 100}')
   DISK=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
   THRESHOLD=80
   [[ $CPU -gt $THRESHOLD || $RAM -gt $THRESHOLD || $DISK -gt $THRESHOLD ]] && \
     mail -s "Alerta en $(hostname)" admin@equipo.com <<< "CPU=$CPU RAM=$RAM DISK=$DISK"
   ```

5. **Logging centralizado en `/var/log/admin-scripts.log`**
   ```bash
   LOG="/var/log/admin-scripts.log"
   log() { echo "[$(date '+%F %T')] $*" | tee -a "$LOG"; }
   ```

### Estructura entregable
```
02-linux/
├── scripts/
│   ├── create-users.sh
│   ├── backup-incremental.sh
│   ├── monitor-resources.sh
│   └── lib/logging.sh
├── data/users.csv
├── crontab/equipo.cron
├── logs/admin-scripts.log
└── README.md
```

## 7. Checklist de cierre del módulo

- [ ] Navego el sistema de archivos Linux con soltura
- [ ] Gestiono usuarios, grupos y permisos correctamente
- [ ] Administro servicios con systemctl y leo logs con journalctl
- [ ] He escrito al menos 3 scripts de Bash funcionales
- [ ] Configuro cron jobs para tareas automáticas
- [ ] Proyecto 02 entregado, probado y documentado

## 8. Recursos recomendados

- **Libro:** "The Linux Command Line" — William Shotts (gratis PDF)
- **Curso:** Linux Foundation LFS101 (gratuito en edX)
- **Práctica:** https://linuxsurvival.com, https://overthewire.org/wargames/bandit/
- **Docs:** https://www.gnu.org/software/bash/manual/
- **Cheatsheet:** https://devhints.io/bash

## 9. Conexión con el hackathon

El deploy de un MVP en cloud se hace vía SSH sobre instancias Linux. La automatización de despliegue, monitoreo y respuesta a incidentes se ejecuta con scripts de Bash. Para el edge computing aeroportuario, los nodos perimetrales corren distribuciones Linux ligeras (Alpine, Ubuntu Core).

## 10. Siguiente módulo

→ [Módulo 03 — Python para DevOps](../03-python-devops/plan.md)
