#!/bin/bash

set -e

IMAGE="${1}"
CONTAINER_NAME="proyecto05-api-staging"
PORT="8000"
PREVIOUS_IMAGE_FILE="/tmp/proyecto05-api-previous-image"

rollback() {
    echo "Iniciando rollback..."

    docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

    if [ -f "$PREVIOUS_IMAGE_FILE" ]; then
        PREVIOUS_IMAGE=$(cat "$PREVIOUS_IMAGE_FILE")

        echo "Restaurando imagen anterior:"
        echo "$PREVIOUS_IMAGE"

        docker pull "$PREVIOUS_IMAGE"

        docker run -d \
            --name "$CONTAINER_NAME" \
            -p "$PORT:8000" \
            "$PREVIOUS_IMAGE"

        echo "Rollback completado."
    else
        echo "No existe una imagen anterior para realizar rollback."
        exit 1
    fi
}

if [ -z "$IMAGE" ]; then
    echo "Error: debes indicar la imagen Docker."
    echo "Uso: ./deploy.sh <imagen>"
    exit 1
fi

echo "Nueva imagen:"
echo "$IMAGE"

if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    CURRENT_IMAGE=$(docker inspect --format='{{.Config.Image}}' "$CONTAINER_NAME")
    echo "$CURRENT_IMAGE" > "$PREVIOUS_IMAGE_FILE"

    echo "Imagen anterior guardada: $CURRENT_IMAGE"

    docker rm -f "$CONTAINER_NAME"
fi

echo "Descargando nueva imagen..."

if ! docker pull "$IMAGE"; then
    echo "No se pudo descargar la nueva imagen."
    rollback
    exit 1
fi

echo "Creando nuevo contenedor Staging..."

docker run -d \
    --name "$CONTAINER_NAME" \
    -p "$PORT:8000" \
    "$IMAGE"

echo "Esperando Health Check..."

if ./06-cicd-pipelines/scripts/healthcheck.sh; then
    echo "Deployment exitoso."
    rm -f "$PREVIOUS_IMAGE_FILE"
    exit 0
fi

echo "Health check fallido."
rollback
