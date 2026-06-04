# Módulo 03 — Python para DevOps

> **Categoría:** Automatización · **Prioridad:** Recomendado · **Origen:** `devops-roadmap.html#s03`

## 1. Por qué importa

Python es el lenguaje universal de la automatización DevOps. AWS SDK, herramientas de testing, scripts de CI/CD, frameworks de IA/ML — todo consume Python. En el contexto del hackathon, las APIs de aviación, los modelos de optimización de rutas y la analítica de datos se construyen en Python.

## 2. Objetivos de aprendizaje

- Escribir scripts Python robustos con manejo de errores
- Consumir APIs REST autenticadas (AWS, GitHub, Slack)
- Automatizar conexiones SSH masivas
- Exportar y transformar datos con pandas

## 3. Prerrequisitos

- Módulos 01 y 02 completados
- Python 3.10+ instalado
- Conocimientos básicos de programación (variables, funciones, bucles)

## 4. Temas detallados

### 4.1 Nivel básico
- Sintaxis, tipos primitivos, colecciones
- Funciones, lambdas, decoradores
- Clases y objetos (OOP básica)
- Manejo de excepciones (`try/except/finally`)
- Context managers (`with`)
- Módulos y paquetes
- List/dict comprehensions

### 4.2 Nivel intermedio
- Consumo de APIs REST con `requests`
- Trabajo con JSON (`json`, `orjson`)
- Expresiones regulares (`re`)
- Lectura/escritura de archivos (pathlib)
- Argumentos CLI (`argparse`, `click`, `typer`)
- Logging estructurado (`logging`)
- Testing (`pytest`)

### 4.3 Bibliotecas clave DevOps
| Librería | Uso |
|----------|-----|
| `requests` | HTTP client para APIs |
| `boto3` | AWS SDK oficial |
| `paramiko` | Conexión SSH programática |
| `fabric` | Automatización remota high-level |
| `pandas` | Manipulación de datos tabulares |
| `pyyaml` | Parsing YAML (K8s, Ansible, Compose) |
| `click` / `typer` | CLIs profesionales |
| `pydantic` | Validación de datos |
| `rich` | Terminal output enriquecido |

### 4.4 APIs REST y JSON
```python
import requests
response = requests.get(
    "https://api.github.com/repos/torvalds/linux",
    headers={"Authorization": f"Bearer {TOKEN}"},
    timeout=10
)
response.raise_for_status()
data = response.json()
```

### 4.5 Automatización SSH
```python
import paramiko
client = paramiko.SSHClient()
client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
client.connect(hostname, username=username, key_filename=key_path)
stdin, stdout, stderr = client.exec_command("uptime")
print(stdout.read().decode())
client.close()
```

### 4.6 AWS con boto3
```python
import boto3
ec2 = boto3.client('ec2', region_name='us-east-1')
response = ec2.describe_instances()
for reservation in response['Reservations']:
    for instance in reservation['Instances']:
        print(instance['InstanceId'], instance['State']['Name'])
```

## 5. Herramientas

| Herramienta | Uso |
|-------------|-----|
| `pyenv` | Gestión de versiones Python |
| `poetry` / `pipenv` | Dependency management |
| `black` / `ruff` | Formateo y linting |
| `mypy` | Type checking |
| `ipython` / `jupyter` | REPL interactivo |
| `pre-commit` | Hooks de calidad |

## 6. Proyecto 03 — Inventario y Automatización de Red

**Duración estimada:** 14-18 horas
**Entregable:** Sistema CLI de inventario con reportes automatizados

### Pasos

1. **Listar instancias EC2 con boto3**
   ```python
   import boto3, json
   ec2 = boto3.client('ec2')
   instances = []
   for page in ec2.get_paginator('describe_instances').paginate():
       for r in page['Reservations']:
           for i in r['Instances']:
               instances.append({
                   'id': i['InstanceId'],
                   'type': i['InstanceType'],
                   'state': i['State']['Name'],
                   'ip': i.get('PublicIpAddress', 'N/A'),
                   'launched': i['LaunchTime'].isoformat()
               })
   with open('inventory.json', 'w') as f:
       json.dump(instances, f, indent=2)
   ```

2. **Conexión SSH masiva con paramiko**
   - Leer lista de hosts desde CSV
   - Pool de threads para paralelizar (max 10)
   - Recolectar: hostname, OS, kernel, CPU cores, RAM total
   - Timeout y reintentos

3. **Exportar a JSON y CSV con pandas**
   ```python
   import pandas as pd
   df = pd.DataFrame(inventario)
   df.to_csv('inventory.csv', index=False)
   df.to_excel('inventory.xlsx', index=False)
   print(df.describe())
   ```

4. **Respaldo automático de `/etc` desde múltiples servidores**
   - `tar czf - /etc | ssh backup@server "cat > backup-$(hostname).tar.gz"`
   - Manejo de errores por host
   - Verificación de checksums

5. **Reporte por correo con smtplib**
   ```python
   import smtplib
   from email.mime.multipart import MIMEMultipart
   from email.mime.text import MIMEText
   from email.mime.application import MIMEApplication
   msg = MIMEMultipart()
   msg['Subject'] = f"[Inventario] {datetime.now():%Y-%m-%d}"
   msg.attach(MIMEText("Inventario adjunto", 'plain'))
   with open('inventory.csv', 'rb') as f:
       msg.attach(MIMEApplication(f.read(), Name='inventory.csv'))
   with smtplib.SMTP_SSL('smtp.gmail.com', 465) as s:
       s.login(user, app_password)
       s.send_message(msg)
   ```

### Estructura entregable
```
03-python-devops/
├── pyproject.toml
├── src/
│   ├── inventory/
│   │   ├── __init__.py
│   │   ├── ec2.py
│   │   ├── ssh.py
│   │   ├── backup.py
│   │   ├── report.py
│   │   └── cli.py
│   └── config.py
├── data/hosts.csv
├── tests/
└── README.md
```

## 7. Checklist de cierre del módulo

- [ ] Escribo scripts Python con manejo de errores
- [ ] Consumo APIs REST con autenticación
- [ ] Conecto a servidores vía SSH programáticamente
- [ ] Uso boto3 para interactuar con AWS
- [ ] Exporto datos a JSON/CSV/Excel
- [ ] Proyecto 03 entregado con tests unitarios básicos

## 8. Recursos recomendados

- **Libro:** "Automate the Boring Stuff with Python" — Al Sweigart (gratis)
- **Libro:** "Python for DevOps" — Noah Gift
- **Curso:** Real Python (realpython.com)
- **Docs:** https://boto3.amazonaws.com/v1/documentation/api/latest/index.html
- **Práctica:** https://www.hackerrank.com/domains/python
- **Repo:** https://github.com/realpython/python-scripts

## 9. Conexión con el hackathon

Python es la lengua franca del stack del equipo (TensorFlow, PyTorch, boto3, requests). Las APIs de aviación (OpenSky, AviationStack) se consumen con `requests`. Los modelos de IA para optimización de rutas se entrenan con pandas + sklearn. Tener dominio de Python es **prerrequisito para presentar un MVP creíble**.

## 10. Siguiente módulo

→ [Módulo 04 — Git y Flujos de Trabajo](../04-git-flujos/plan.md)
