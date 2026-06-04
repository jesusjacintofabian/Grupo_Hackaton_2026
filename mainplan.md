# Plan Maestro DevOps — Grupo Hackathon Copa Airlines UTP 2026

> **Origen:** `devops-roadmap.html` (13 módulos · 60+ temas · 13 proyectos prácticos)
> **Audiencia:** Equipo `Grupo_Hackaton_2026` (preparación Hackathon Copa Airlines - UTP 2026)
> **Stack objetivo:** Python · TypeScript · AWS/Azure · Docker · Kubernetes · Terraform
> **Temas anticipados 2026:** IA sostenibilidad aeronáutica · Edge computing · Gemelos digitales · Blockchain trazabilidad · Realidad aumentada

---

## 1. Resumen Ejecutivo

Este plan transforma el roadmap DevOps original en una ruta ejecutable de **13 módulos secuenciales** con entregables verificables. Cada módulo termina en un **proyecto práctico** que se reutiliza como bloque constructivo de los siguientes (los proyectos están diseñados como una cadena: red → servidores → contenedor → cluster → producción).

**Filosofía:** aprender haciendo. Cada módulo produce un artefacto tangible (script, Dockerfile, pipeline, manifest, dashboard) que se integra al portafolio del equipo.

---

## 2. Mapa de los 13 Módulos

| # | Módulo | Categoría | Prioridad | Proyecto Clave |
|---|--------|-----------|-----------|----------------|
| 01 | Redes y Protocolos | Fundamentos | Obligatorio | Análisis de Red con Nmap y Wireshark |
| 02 | Linux | Sistema Operativo | Obligatorio | Automatización con Bash |
| 03 | Python para DevOps | Automatización | Recomendado | Inventario y Automatización de Red |
| 04 | Git y Flujos de Trabajo | Control de Versiones | Obligatorio | GitOps con GitHub Actions |
| 05 | Docker | Contenedores | Obligatorio | Stack Multi-Servicio con Docker Compose |
| 06 | CI/CD Pipelines | Automatización | Obligatorio | Pipeline CI/CD Completo |
| 07 | Cloud Computing (AWS) | Infraestructura | Alta demanda | Arquitectura 3-Tier en AWS |
| 08 | Kubernetes | Orquestación | Top demanda | Cluster Kubernetes en Producción |
| 09 | Terraform y Ansible | IaC | Alta demanda | Infraestructura Multi-Entorno con Terraform |
| 10 | Monitoreo y Logs | Observabilidad | Fundamental | Stack de Observabilidad Completo |
| 11 | Seguridad en DevOps | DevSecOps | Crítico | Pipeline DevSecOps |
| 12 | Arquitectura de Aplicaciones | Diseño de Sistemas | Estratégico | Migración Monolito a Microservicios |
| 13 | Site Reliability Engineering | Confiabilidad | Senior | Implementación SRE Completa |

---

## 3. Fases de Ejecución (Timeline)

### Fase 1 — Fundamentos (Semanas 1-4)
Módulos 01, 02, 03, 04. Construye la base técnica: red, OS, scripting, versionado.

### Fase 2 — Plataforma (Semanas 5-8)
Módulos 05, 06, 07, 08. Contenedores, pipelines, cloud, orquestación. **Núcleo entregable para hackathon.**

### Fase 3 — Producción (Semanas 9-11)
Módulos 09, 10, 11. IaC, observabilidad, seguridad. Endurecimiento de la plataforma.

### Fase 4 — Escala (Semanas 12-14)
Módulos 12, 13. Arquitectura avanzada y SRE. Diferenciador competitivo.

---

## 4. Cadena de Proyectos (Artefactos Acumulativos)

```
P01 Inventario de red
    ↓ (hosts descubiertos)
P02 Automatización Linux
    ↓ (servidores administrados)
P03 Inventario AWS
    ↓ (visión de infraestructura)
P04 GitOps
    ↓ (workflow versionado)
P05 Stack Docker Compose ──→ P08 K8s Production
    ↓ (imágenes construidas)        ↑
P06 Pipeline CI/CD ────────→ P11 DevSecOps
    ↓ (despliegues automatizados)
P07 3-Tier AWS
    ↓ (infraestructura base)
P09 Terraform Multi-Entorno
    ↓ (IaC reproducible)
P10 Observabilidad ──→ P13 SRE
    ↓
P12 Monolito → Microservicios
    ↓
P13 Implementación SRE Completa
```

Cada proyecto alimenta al siguiente. El Proyecto 13 integra todos los anteriores.

---

## 5. Stack Tecnológico Completo

### Lenguajes
- **Bash** — scripting de sistemas
- **Python 3.x** — automatización, APIs, scripts DevOps
- **HCL** — Terraform
- **YAML** — Kubernetes, Ansible, CI/CD, Docker Compose
- **Go (básico)** — comprensión de herramientas K8s

### Plataformas Cloud
- **AWS** (foco principal): EC2, S3, VPC, RDS, IAM, CloudWatch, EKS
- **Azure** (foco secundario para Copa Airlines): AKS, Azure DevOps
- **GCP** (opcional, mencionado en SRE)

### Herramientas Core
| Categoría | Herramientas |
|-----------|--------------|
| Contenedores | Docker, Docker Compose, containerd |
| Orquestación | Kubernetes, Helm, kubectl, kind/minikube |
| CI/CD | GitHub Actions, GitLab CI, Jenkins |
| IaC | Terraform, Ansible, Packer |
| Observabilidad | Prometheus, Grafana, ELK/EFK, Jaeger, OpenTelemetry |
| Seguridad | Trivy, Snyk, SonarQube, Vault, OPA/Gatekeeper |
| Networking | Wireshark, Nmap, tcpdump, iptables, Cloudflare |
| Monitoring Cloud | CloudWatch, SNS, PagerDuty |

---

## 6. Roles Sugeridos del Equipo

| Rol | Módulos principales |
|-----|---------------------|
| **Network/Infra Engineer** | 01, 07, 09 |
| **Platform Engineer** | 02, 05, 08 |
| **Automation Engineer** | 03, 04, 06 |
| **Security Engineer** | 11 |
| **Observability/SRE** | 10, 13 |
| **Solutions Architect** | 12, 13 |

Un mismo miembro puede cubrir varios módulos en paralelo.

---

## 7. Alineación con Copa Airlines Hackathon 2026

| Tema anticipado | Módulos que más aportan |
|-----------------|--------------------------|
| IA sostenibilidad aeronáutica | 03, 07, 08, 12 |
| Edge computing aeropuerto | 01, 05, 08 |
| Gemelos digitales (mantenimiento) | 12, 13, 10 |
| Blockchain trazabilidad | 04, 09, 11 |
| Realidad aumentada | 05, 08, 12 |

**MVP recomendado para hackathon:** Stack basado en módulos 01-08 (hasta Kubernetes) desplegado en AWS, con demos de los proyectos 04, 05, 07 y 08.

---

## 8. Estructura del Repositorio

```
Grupo_Hackaton_2026/
├── mainplan.md                    ← este documento
├── devops-roadmap.html            ← roadmap original
├── README.md
├── 01-redes-protocolos/plan.md
├── 02-linux/plan.md
├── 03-python-devops/plan.md
├── 04-git-flujos/plan.md
├── 05-docker/plan.md
├── 06-cicd-pipelines/plan.md
├── 07-cloud-aws/plan.md
├── 08-kubernetes/plan.md
├── 09-terraform-ansible/plan.md
├── 10-monitoreo-logs/plan.md
├── 11-seguridad-devsecops/plan.md
├── 12-arquitectura-apps/plan.md
└── 13-sre/plan.md
```

Cada `NN-nombre/plan.md` contiene: objetivos, prerrequisitos, temas detallados, herramientas, proyecto paso a paso, checklist de cierre, recursos y tiempo estimado.

---

## 9. Métricas de Éxito del Plan

- [ ] Los 13 proyectos completados y commiteados
- [ ] Cluster Kubernetes operativo con ≥ 3 microservicios (P12)
- [ ] Pipeline CI/CD verde end-to-end (P06 + P11)
- [ ] Stack de observabilidad con dashboards en Grafana (P10)
- [ ] Runbook SRE con al menos 5 incidentes documentados (P13)
- [ ] Al menos 2 demos públicas ensayadas para el hackathon

---

## 10. Cómo usar este plan

1. **Inicio:** Cada miembro lee este `mainplan.md` y la sección de su rol.
2. **Ejecución:** Abrir el `plan.md` del módulo activo y seguir el checklist.
3. **Cierre de módulo:** Marcar proyecto en el README del equipo, hacer demo interna de 15 min.
4. **Transición:** El siguiente módulo toma como input los artefactos del anterior.
5. **Revisión semanal:** Standup de 30 min con avance por módulo.

---

*Plan derivado del roadmap DevOps original. Cada sección tiene un plan dedicado con profundidad operativa.*
