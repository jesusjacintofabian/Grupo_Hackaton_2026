##############
# Builder
##############

FROM python:3.12-slim AS builder

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

##############
# Runtime
##############

FROM python:3.12-slim

WORKDIR /app

COPY --from=builder /install /usr/local

COPY . .

RUN useradd -m appuser

USER appuser

EXPOSE 8000

HEALTHCHECK CMD ["python", "-c", "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')"]

CMD ["uvicorn","main:app","--host","0.0.0.0","--port","8000"]
