# Módulo 04 — Git y Flujos de Trabajo

> **Categoría:** Control de Versiones · **Prioridad:** Obligatorio · **Origen:** `devops-roadmap.html#s04`

## 1. Por qué importa

Todo en DevOps vive en repositorios: código, infraestructura, configuraciones, pipelines. Git es el lenguaje común de los equipos de ingeniería. En hackathon, una historia de commits limpia y una estrategia de branching profesional es señal inmediata de equipo competente.

## 2. Objetivos de aprendizaje

- Operar Git con confianza (branch, merge, rebase, cherry-pick)
- Elegir e implementar un flujo de trabajo colaborativo
- Configurar protección de ramas y políticas de merge
- Integrar GitHub Actions para automatizar tareas del repositorio

## 3. Prerrequisitos

- Módulo 03 completado (Python scripting)
- Cuenta de GitHub para el equipo
- Git 2.30+ instalado

## 4. Temas detallados

### 4.1 Conceptos core
- Repository (local vs remote)
- Working directory, staging area, commit history
- Commits (snapshots inmutables)
- Branches (punteros ligeros)
- Tags (marcas de release: lightweight vs annotated)
- Merge, rebase, cherry-pick
- Stash, reflog
- HEAD, HEAD~, HEAD^

### 4.2 Comandos esenciales
```bash
git init / git clone
git status / git log --oneline --graph
git add -A / git commit -m "feat: ..."
git branch feature/x / git checkout -b feature/x
git merge --no-ff feature/x
git rebase main
git push origin feature/x
git pull --rebase
git stash / git stash pop
git tag v1.0.0 / git push --tags
```

### 4.3 Flujos de trabajo
| Flujo | Ramas | Cuándo usarlo |
|-------|-------|---------------|
| **GitFlow** | main, develop, feature/*, release/*, hotfix/* | Equipos grandes, releases versionados |
| **GitHub Flow** | main, feature/* | Equipos pequeños, deploy continuo |
| **Trunk-Based** | main, feature/* (corta vida) | Equipos senior, deploy continuo |
| **Forking** | forks + main | Open source, contribuidores externos |

### 4.4 Plataformas
- **GitHub** — el más popular, Actions, Codespaces, Packages
- **GitLab** — CI/CD más potente autohospedado, registry integrado
- **Bitbucket** — común en empresas con stack Atlassian

### 4.5 Conventional Commits
```
feat: nueva funcionalidad
fix: corrección de bug
docs: solo documentación
style: formateo, sin cambio lógico
refactor: cambio interno sin nueva feature
test: agregar o corregir tests
chore: tareas de mantenimiento
perf: mejora de performance
ci: cambios en CI/CD
```

### 4.6 Protección de ramas
- Requerir PR antes de merge
- Requerir N revisiones aprobadas
- Requerir checks de CI verdes
- Requerir linear history
- Restringir quién puede pushear
- Signed commits

## 5. Herramientas

| Herramienta | Uso |
|-------------|-----|
| `gh` (GitHub CLI) | PRs, issues, releases desde terminal |
| `lazygit` / `tig` | TUI para Git |
| `pre-commit` | Hooks locales de calidad |
| `git-cliff` | Generación automática de CHANGELOG |
| `semantic-release` / `release-please` | Versionado semántico automatizado |
| `husky` | Hooks en proyectos Node |

## 6. Proyecto 04 — GitOps con GitHub Actions

**Duración estimada:** 10-14 horas
**Entregable:** Repositorio multi-ambiente con pipeline GitOps funcional

### Pasos

1. **Estructura multi-ambiente**
   ```
   .
   ├── .github/
   │   ├── workflows/
   │   │   ├── ci.yml
   │   │   ├── release.yml
   │   │   └── changelog.yml
   │   ├── CODEOWNERS
   │   └── PULL_REQUEST_TEMPLATE.md
   ├── environments/
   │   ├── dev/
   │   ├── staging/
   │   └── production/
   ├── src/
   ├── tests/
   ├── CHANGELOG.md
   ├── pyproject.toml
   └── README.md
   ```

2. **Protección de ramas en `main`**
   - Settings → Branches → Add rule
   - Require pull request before merging
   - Require 2 approvals
   - Require status checks to pass (CI, lint, test)
   - Require signed commits
   - Include administrators

3. **GitHub Actions — CI pipeline**
   ```yaml
   name: CI
   on: [push, pull_request]
   jobs:
     lint:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v4
         - uses: actions/setup-python@v5
           with: { python-version: "3.12" }
         - run: pip install ruff
         - run: ruff check .
     test:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v4
         - uses: actions/setup-python@v5
           with: { python-version: "3.12", cache: pip }
         - run: pip install -e ".[test]"
         - run: pytest --cov --cov-report=xml
   ```

4. **Semantic versioning automático**
   - Workflow que analiza conventional commits
   - `release-please-action` o `python-semantic-release`
   - Genera PR con bump de versión + CHANGELOG
   - Al merge, crea tag + GitHub Release

5. **CHANGELOG automático con git-cliff**
   ```toml
   # cliff.toml
   [changelog]
   header = """
   # Changelog\n
   """
   body = """
   {% for commit in commits %}\
   * {{ commit.message | upper_first }}\
   {% endfor %}\n
   """
   ```
   ```bash
   git cliff --tag v1.2.0 --output CHANGELOG.md
   ```

### Entregables
- [ ] Repositorio con estructura completa
- [ ] Workflows de CI verdes
- [ ] Branch protection en main
- [ ] Primer release generado automáticamente
- [ ] CHANGELOG.md mantenido por CI

## 7. Checklist de cierre del módulo

- [ ] Opero Git con confianza (rebase, cherry-pick, reflog)
- [ ] He elegido e implementado un flujo de trabajo para el equipo
- [ ] Configuré protección de rama main
- [ ] GitHub Actions corre lint + tests en cada PR
- [ ] Semantic versioning funciona y se actualiza CHANGELOG
- [ ] Proyecto 04 entregado y el equipo ya opera con el flujo definido

## 8. Recursos recomendados

- **Libro:** "Pro Git" — Scott Chacon (gratis)
- **Curso:** GitHub Learning Lab (gratuito integrado en GitHub)
- **Docs:** https://git-scm.com/doc
- **Cheatsheet:** https://education.github.com/git-cheat-sheet-education.pdf
- **Práctica:** https://learngitbranching.js.org/
- **Conventional Commits:** https://www.conventionalcommits.org/

## 9. Conexión con el hackathon

En hackathon el tiempo es limitado. Un Git workflow claro evita conflictos de merge y pérdidas de trabajo. GitHub Actions ejecuta los tests del proyecto en cada push, liberando al equipo de tareas manuales. La historia de commits es el primer portafolio que ven los jueces.

## 10. Siguiente módulo

→ [Módulo 05 — Docker](../05-docker/plan.md)
