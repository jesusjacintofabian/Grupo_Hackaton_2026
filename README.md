# Grupo_Hackaton_2026
This group is in pre-training for the 2026 Copa Airlines - UTP Hackathon

# Grupo_Hackaton_2026

Repositorio oficial del equipo para el desarrollo colaborativo de proyectos durante la hackatón.

## Estructura de ramas

```text
main
│
develop
│
├── feature/frontend
├── feature/backend
├── feature/database
├── feature/docs
└── feature/*
```

### Descripción de ramas

* **main** → Rama estable y lista para producción.
* **develop** → Rama de integración de funcionalidades.
* **feature/*** → Rama para desarrollo individual por tarea.
* **fix/*** → Corrección de errores.
* **docs/*** → Documentación.

---

# Reglas del repositorio

## Rama main

La rama `main` está protegida con las siguientes reglas:

* No se permite push directo.
* Pull Request obligatorio.
* 1 aprobación mínima antes del merge.
* Bloqueo de force push.
* Restricción de eliminación.
* Resolución obligatoria de conversaciones.
* Revisión requerida para cambios recientes.

## Rama develop

La rama `develop` utiliza reglas menos estrictas:

* Pull Request obligatorio.
* Restricción de eliminación.
* Revisión mínima recomendada.

---

#  Roles y permisos

| Rol           | Permisos                          |
| ------------- | --------------------------------- |
| Administrador | Control total del repositorio     |
| Colaboradores | Permiso Write                     |
| Equipo        | Desarrollo mediante ramas feature |

---

# Flujo de trabajo

## Crear nueva funcionalidad

```bash
git checkout develop

git pull origin develop

git checkout -b feature/nombre-funcionalidad
```

## Guardar cambios

```bash
git add .

git commit -m "Descripción del cambio"

git push origin feature/nombre-funcionalidad
```

## Crear Pull Request

```text
feature/* 
   ↓
Pull Request
   ↓
develop
```

## Integración final

```text
develop
   ↓
Pull Request
   ↓
main
```

---

# Convención de nombres

## Funcionalidades

```text
feature/login
feature/dashboard
feature/api-users
feature/frontend
```

## Correcciones

```text
fix/login-error
fix/database-connection
```

## Documentación

```text
docs/readme
docs/manual
```

---

# 🛠 Tecnologías

Agregar aquí las tecnologías utilizadas:

* Frontend:
* Backend:
* Base de datos:
* Infraestructura:
* DevOps:

---

# 📞 Comunicación del equipo

* Crear Pull Requests para todos los cambios.
* Evitar trabajar directamente en `main`.
* Mantener `develop` actualizado.
* Documentar cambios importantes.

---

Hackathon Team 🚀

