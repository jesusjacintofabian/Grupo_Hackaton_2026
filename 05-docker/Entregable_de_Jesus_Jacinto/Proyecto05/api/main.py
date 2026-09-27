import os

from fastapi import FastAPI

app = FastAPI()


@app.get("/")
def home():
    return {"message": "Proyecto Docker funcionando correctamente"}


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/info")
def info():
    return {"database": os.getenv("MYSQL_DATABASE"), "port": os.getenv("API_PORT")}
