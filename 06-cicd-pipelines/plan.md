# Módulo 06 — CI/CD Pipelines

> **Categoría:** Automatización · **Prioridad:** Obligatorio · **Origen:** `devops-roadmap.html#s06`

## 1. Por qué importa

CI/CD automatiza el ciclo completo: desde el commit hasta producción, con pruebas en cada paso. Elimina el "deployment day" como evento estresante. En hackathon, un pipeline sólido significa que el equipo puede hacer merges sin miedo y tener demos reproducibles.

## 2. Objetivos de aprendizaje

- Diseñar pipelines de CI con jobs paralelos
- Construir CD con despliegues automatizados a staging/prod
- Implementar estrategias de rollback
- Integrar notificaciones y artefactos

## 3. Prerrequisitos

- Módulos 01-05 completados
- Repositorio en GitHub con proyecto Docker (módulo 05)
- Cuenta en Docker Hub o GitHub Container Registry

## 4. Temas detallados

### 4.1 Continuous Integration (CI)
En cada push/PR:
1. Checkout del código
2. Instalación de dependencias con cache
3. Linting (ruff, eslint, golangci-lint)
4. Análisis estático (mypy, tsc, sonarqube)
5. Tests unitarios (pytest, jest, go test)
6. Tests de integración
7. Build del artefacto
8. Escaneo de seguridad (Trivy, Snyk, CodeQL)

### 4.2 Continuous Delivery / Deployment (CD)
- **Continuous Delivery:** el artefacto pasa a staging automáticamente; producción requiere aprobación manual
- **Continuous Deployment:** promoción a producción automática si pasan los checks

### 4.3 Herramientas principales
| Herramienta | Fortalezas | Caso de uso |
|-------------|------------|-------------|
| **GitHub Actions** | Integrado con GitHub, ecosistema enorme | Proyectos open source, equipos pequeños |
| **GitLab CI** | Muy potente autohospedado, registry incluido | Empresas con GitLab autohospedado |
| **Jenkins** | Altamente extensible, plugins infinitos | Enterprise legacy, máximo control |
| **CircleCI** | Rapidez, parallelismo | Startups |
| **Buildkite** | Self-hosted agents | Empresas con restricciones de compliance |
| **Drone** | Ligero, basado en Docker | Cloud-native |

### 4.4 Estrategias de despliegue
- **Rolling update:** reemplaza instancias gradualmente (default en K8s)
- **Blue/Green:** dos entornos idénticos, switch atómico de tráfico
- **Canary:** nuevo release a 5-10% de usuarios, se expande si métricas OK
- **Recreate:** terminación total y recreación (downtime, simple)
- **A/B testing:** variantes para experimentar features

### 4.5 GitHub Actions — anatomía
```yaml
name: Pipeline
on:
  push:
    branches: [main]
  pull_request:

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix: { python-version: ["3.11", "3.12"] }
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}
          cache: pip
      - run: pip install -e ".[test]"
      - run: pytest -v --cov
```

## 5. Herramientas

| Herramienta | Uso |
|-------------|-----|
| `act` | Ejecutar GitHub Actions localmente |
| `nektos/act` | CI local |
| `pre-commit` | Hooks pre-commit |
| `renovate` / `dependabot` | Actualización automática de dependencias |
| `dagger` | Pipelines CI portables (CUE/Go/Python) |
| `earthly` | Builds reproducibles |

## 6. Proyecto 06 — Pipeline CI/CD Completo

**Duración estimada:** 14-18 horas
**Entregable:** Pipeline end-to-end desde commit hasta deploy con rollback

### Pasos

1. **Jobs paralelos en CI**
   ```yaml
   jobs:
     lint:    { ... } # ruff, black --check
     type:    { ... } # mypy
     test:    { ... } # pytest
     security:{ ... } # bandit, safety
   ```
   - Ejecución en paralelo con `strategy.matrix`
   - Cache de pip con `actions/setup-python`
   - Reportes de coverage

2. **Escaneo de seguridad en dependencias**
   ```yaml
   - uses: github/codeql-action/analyze@v2
   - uses: snyk/actions/python-3.12@master
     env: { SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }} }}
   - uses: aquasecurity/trivy-action@master
   ```
   Dependabot habilitado para PRs automáticas de updates.

3. **Build y push de imagen a GHCR al mergear a main**
   ```yaml
   build:
     needs: [lint, test, security]
     runs-on: ubuntu-latest
     permissions:
       contents: read
       packages: write
     steps:
       - uses: actions/checkout@v4
       - uses: docker/setup-buildx-action@v3
       - uses: docker/login-action@v3
         with:
           registry: ghcr.io
           username: ${{ github.actor }}
           password: ${{ secrets.GITHUB_TOKEN }}
       - uses: docker/build-push-action@v5
         with:
           context: ./docker/api
           push: true
           tags: |
             ghcr.io/${{ github.repository }}/api:${{ github.sha }}
             ghcr.io/${{ github.repository }}/api:latest
           cache-from: type=gha
           cache-to: type=gha,mode=max
   ```

4. **Despliegue a staging con health check y rollback**
   ```yaml
   deploy-staging:
     needs: build
     runs-on: ubuntu-latest
     environment: staging
     steps:
       - name: Deploy
         run: |
           SSH_CONFIG=...
           ssh $SSH_CONFIG "docker pull ghcr.io/.../api:${{ github.sha }}"
           ssh $SSH_CONFIG "docker compose up -d --no-deps api"
       - name: Health check
         run: |
           for i in {1..30}; do
             if curl -fsS https://staging.example.com/health; then
               echo "Healthy"; exit 0
             fi
             sleep 10
           done
           echo "Unhealthy, rolling back"
           ssh $SSH_CONFIG "docker compose rollback api"
           exit 1
   ```
   - Si los health checks fallan: rollback automático
   - Promotion a `production` con approval manual (`environment` con reviewers)

5. **Notificaciones a Slack o correo**
   ```yaml
   - uses: 8398a7/action-slack@v3
     with:
       status: ${{ job.status }}
       text: "Pipeline ${{ github.workflow }} en ${{ github.ref }}"
     env:
       SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
     if: always()
   ```

### Estructura entregable
```
06-cicd-pipelines/
├── .github/
│   ├── workflows/
│   │   ├── ci.yml
│   │   ├── cd-staging.yml
│   │   ├── cd-production.yml
│   │   └── codeql.yml
│   └── dependabot.yml
├── scripts/
│   ├── deploy.sh
│   └── healthcheck.sh
└── README.md
```

## 7. Checklist de cierre del módulo

- [ ] CI corre lint + test + security en cada PR
- [ ] Build automático de imagen Docker al mergear a main
- [ ] Deploy a staging automático con health checks
- [ ] Rollback automático si falla el health check
- [ ] Notificaciones a Slack/email funcionan
- [ ] Promotion a producción con approval manual
- [ ] Proyecto 06 entregado y deploy verificable

## 8. Recursos recomendados

- **Docs:** https://docs.github.com/actions
- **Curso:** GitHub Actions: The Complete Guide (Udemy)
- **Libro:** "Continuous Delivery" — Humble & Farley
- **Patterns:** https://martinfowler.com/bliki/BlueGreenDeployment.html
- **Tools:** https://github.com/marketplace?type=actions

## 9. Conexión con el hackathon

Un demo en vivo es la mejor tarjeta de presentación. Un pipeline que despliega la app en staging mientras el equipo presenta, demuestra madurez técnica. Si el demo falla, el rollback automático mantiene la cara del equipo. La historia del pipeline es parte de la presentación.

## 10. Siguiente módulo

→ [Módulo 07 — Cloud Computing (AWS)](../07-cloud-aws/plan.md)
