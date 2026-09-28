#!/bin/bash

set -e

CONTAINER_NAME="${1:-proyecto05-api-staging}"
URL="${2:-http://localhost:8000/health}"

echo "Verificando salud del contenedor: $CONTAINER_NAME"
echo "URL: $URL"

for i in {1..10}; do
    if docker exec "$CONTAINER_NAME" python -c \
        "import urllib.request; urllib.request.urlopen('$URL')"; then
        echo "Health check exitoso."
        exit 0
    fi

    echo "Intento $i/10: servicio todavía no disponible..."
    sleep 5
done

echo "Health check fallido."
exit 1
