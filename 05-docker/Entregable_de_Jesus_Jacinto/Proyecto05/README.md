# Proyecto 05 Docker

## Tecnologías

- Docker
- Docker Compose
- FastAPI
- MySQL
- Nginx

## Ejecutar

Crear el archivo `.env`

```bash
cp .env.example .env
```

Construir

```bash
docker compose up --build
```

Detener

```bash
docker compose down
```

Ver logs

```bash
docker compose logs -f
```

## Servicios

Nginx

```
http://localhost
```

API

```
http://localhost/health
```

MySQL

Puerto interno 3306.

## Redes

- frontend
- backend

## Volúmenes

mysql_data
