from src.app import saludo


def test_saludo():
    resultado = saludo("Jesús")

    assert resultado == "Hola Jesús, bienvenido al ambiente DevOps"
