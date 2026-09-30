# Módulo 05 — Docker

> **Categoría:** Contenedores · **Prioridad:** Obligatorio · **Origen:** `devops-roadmap.html#s05`

## 1. Por qué importa

Los contenedores resuelven el problema "funciona en mi máquina". Docker empaqueta aplicaciones con todas sus dependencias en unidades portables y reproducibles. En el hackathon, esto significa que el mismo binario que se prueba localmente se despliega idéntico en AWS/Azure/GCP y en la presentación ante jueces.

## 2. Objetivos de aprendizaje

- Construir imágenes Docker optimizadas y seguras
- Escribir Dockerfiles multi-stage con cache eficiente
- Orquestar múltiples contenedores con Docker Compose
- Manejar redes, volúmenes y variables de entorno

## 3. Prerrequisitos

- Módulos 01-04 completados
- Docker Engine 24+ y Docker Compose v2 instalados
- Conocimientos básicos de Linux (módulo 02)

## 4. Temas detallados

### 4.1 Conceptos fundamentales
- **Imagen:** template inmutable construido en capas (layers)
- **Contenedor:** instancia en ejecución de una imagen
- **Layer:** cada instrucción del Dockerfile genera una capa
- **Registry:** almacén de imágenes (Docker Hub, ECR, GCR, GHCR)
- **Volume:** persistencia de datos fuera del ciclo del contenedor
- **Network:** red virtual entre contenedores

### 4.2 Dockerfile
```dockerfile
# Sintaxis
FROM <imagen_base>[:tag]
WORKDIR /app
COPY src/ ./src/
RUN pip install --no-cache-dir -r requirements.txt
ENV PORT=8000
EXPOSE 8000
USER nonroot                          # nunca root en producción
HEALTHCHECK --interval=30s CMD curl -f http://localhost:8000/health || exit 1
ENTRYPOINT ["python"]
CMD ["src/main.py"]
```

Instrucciones clave: `FROM`, `RUN`, `COPY`, `ADD`, `ENV`, `ARG`, `EXPOSE`, `VOLUME`, `USER`, `WORKDIR`, `ENTRYPOINT`, `CMD`, `HEALTHCHECK`, `LABEL`, `SHELL`.

### 4.3 Multi-stage builds
```dockerfile
# Stage 1: build
FROM python:3.12-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip wheel --no-cache-dir --wheel-dir /wheels -r requirements.txt

# Stage 2: runtime
FROM python:3.12-slim
COPY --from=builder /wheels /wheels
RUN pip install --no-cache-dir --no-index --find-links=/wheels /wheels/*
COPY src/ /app/src/
USER nonroot
CMD ["python", "src/main.py"]
```
Resultado: imagen final mucho más pequeña.

### 4.4 Redes de Docker
- `bridge` (default): red NAT interna
- `host`: sin aislamiento, usa la red del host
- `none`: sin red
- Redes definidas por usuario: comunicación por nombre de servicio

```bash
docker network create backend
docker run --network backend --name db postgres
docker run --network backend --name api myapi
# 'api' puede resolver 'db' por hostname
```

### 4.5 Volúmenes
```bash
docker volume create pgdata
docker run -v pgdata:/var/lib/postgresql/data postgres
# Bind mount para desarrollo
docker run -v $(pwd)/src:/app/src myapi
```

### 4.6 Docker Compose
```yaml
# docker-compose.yml
services:
  nginx:
    image: nginx:alpine
    ports: ["80:80"]
    depends_on:
      api: { condition: service_healthy }
    networks: [frontend]
  api:
    build: ./api
    environment:
      DATABASE_URL: postgresql://user:pass@db:5432/app
    depends_on:
      db: { condition: service_healthy }
    networks: [backend, frontend]
  db:
    image: postgres:16-alpine
    volumes: ["pgdata:/var/lib/postgresql/data"]
    environment:
      POSTGRES_PASSWORD: pass
    networks: [backend]

volumes:
  pgdata:

networks:
  frontend:
  backend:
```

### 4.7 Registries
| Registry | Caso de uso |
|----------|-------------|
| Docker Hub | Público, free tier limitado |
| Amazon ECR | Integrado con AWS/IAM |
| Google GCR / Artifact Registry | GCP |
| GitHub Container Registry (ghcr.io) | Integración con GitHub Actions |
| Harbor | Privado autohospedado |

## 5. Herramientas

| Herramienta | Uso |
|-------------|-----|
| `dive` | Inspección de capas de una imagen |
| `docker scan` / `trivy` | CVE scanning |
| `lazydocker` | TUI para administración |
| `ctop` | Métricas en vivo de contenedores |
| `docker buildx` | Builds multi-arquitectura (arm64/amd64) |
| `hadolint` | Linter de Dockerfile |

## 6. Proyecto 05 — Stack Multi-Servicio con Docker Compose

**Duración estimada:** 12-16 horas
**Entregable:** Aplicación web full-stack corriendo con `docker compose up`

### Arquitectura
```
        ┌──────────┐
        │  Nginx   │  :80  (reverse proxy)
        └────┬─────┘
             │ /api/*
        ┌────▼─────┐
        │   API    │  FastAPI / Node
        │  (app)   │
        └────┬─────┘
             │
        ┌────▼─────┐
        │   MySQL  │  :3306
        └──────────┘
```

### Pasos

1. **Dockerfiles optimizados multi-stage**
   - `docker/nginx/Dockerfile` basado en `nginx:alpine`
   - `docker/api/Dockerfile` multi-stage (builder + runtime en `python:3.12-slim`)
   - Crear usuario no-root con `USER`
   - `.dockerignore` para excluir `node_modules`, `.git`, `__pycache__`

2. **Docker Compose orquestando los servicios**
   - Red `frontend` (nginx-api)
   - Red `backend` (api-db) — db NO expuesta al host
   - Volumen `mysql_data` persistente
   - Volúmenes bind-mount para desarrollo de código
   - Variables de entorno vía `.env`

3. **Configuración sensible con `.env` y `.env.example`**
   ```ini
   # .env.example
   MYSQL_ROOT_PASSWORD=changeme
   MYSQL_DATABASE=hackathon
   API_PORT=8000
   ```
   - `.env` en `.gitignore`
   - Documentar en `.env.example`

4. **Health checks en cada servicio**
   ```yaml
   healthcheck:
     test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
     interval: 10s
     timeout: 5s
     retries: 5
     start_period: 30s
   ```
   - `depends_on: { condition: service_healthy }` para orden correcto

5. **Publicación en registries con versionado semántico**
   ```bash
   docker build -t ghcr.io/equipo/api:1.0.0 -t ghcr.io/equipo/api:latest ./docker/api
   docker push ghcr.io/equipo/api:1.0.0
   docker push ghcr.io/equipo/api:latest
   ```

### Estructura entregable
```
05-docker/
├── docker-compose.yml
├── docker-compose.override.yml        # solo dev
├── .env.example
├── docker/
│   ├── api/Dockerfile
│   └── nginx/Dockerfile
├── api/
│   ├── main.py
│   ├── requirements.txt
│   └── tests/
├── nginx/
│   └── nginx.conf
└── README.md
```

## 7. Checklist de cierre del módulo

- [ ] Construyo imágenes Docker optimizadas con multi-stage
- [ ] Mis Dockerfiles usan usuario no-root
- [ ] Manejo health checks y dependencias en Compose
- [ ] Separo redes frontend/backend
- [ ] Persisto datos en volúmenes
- [ ] Publico imágenes con tags semánticos
- [x] Proyecto 05 entregado, `docker compose up` funciona limpio

## 8. Recursos recomendados

- **Docs:** https://docs.docker.com/
- **Curso:** Docker Mastery (Bret Fisher, Udemy)
- **Libro:** "Docker Deep Dive" — Nigel Poulton
- **Práctica:** https://labs.play-with-docker.com/
- **Best practices:** https://docs.docker.com/develop/develop-images/dockerfile_best-practices/

## 9. Conexión con el hackathon

El MVP del hackathon correrá en contenedor. Si el equipo puede ejecutar todo el stack con `docker compose up` en menos de 5 minutos, el despliegue en AWS/Azure será trivial. Docker también permite que los jueces prueben la solución localmente si proveemos un `docker-compose.yml` y un README claro.

## 10. Siguiente módulo

→ [Módulo 06 — CI/CD Pipelines](../06-cicd-pipelines/plan.md)
