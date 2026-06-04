# Módulo 13 — Site Reliability Engineering (SRE)

> **Categoría:** Confiabilidad · **Prioridad:** Senior · **Origen:** `devops-roadmap.html#s13`

## 1. Por qué importa

SRE es la disciplina que Google creó para operar sistemas a escala. Combina software engineering con administración de sistemas para crear servicios escalables y altamente confiables. Para el equipo, este módulo cierra el ciclo: aplica prácticas profesionales de producción al sistema completo construido en los módulos anteriores.

## 2. Objetivos de aprendizaje

- Definir SLI/SLO/SLA y gestionar error budgets
- Conducir incident response profesional con postmortems blameless
- Reducir toil mediante automatización
- Aplicar Chaos Engineering para validar resiliencia
- Planificar capacidad y costos

## 3. Prerrequisitos

- Módulos 01-12 completados
- Sistema completo desplegado (proyectos 05-12)
- Stack de observabilidad operativo (módulo 10)

## 4. Temas detallados

### 4.1 SLA / SLI / SLO

- **SLA** (Service Level Agreement): contrato con el cliente. Compromiso externo, con compensación si se incumple.
- **SLI** (Service Level Indicator): la métrica que se mide realmente (latencia, tasa de errores, throughput).
- **SLO** (Service Level Objective): objetivo interno más estricto que el SLA, da margen de maniobra.

**Relación típica:** SLA = 99.9% → SLO interno = 99.95%

**SLIs comunes:**
- Disponibilidad: % de requests exitosas
- Latencia: p50, p95, p99
- Throughput: requests/segundo
- Freshness: qué tan frescos son los datos
- Durability: % de datos retenidos

**User journeys:** definir SLIs por funcionalidad de usuario, no por servicio técnico. "El usuario puede completar un checkout" es mejor SLI que "API /checkout responde 200".

### 4.2 Error Budget
- Si el SLO es 99.9%, el **error budget mensual = 0.1% × tiempo total = ~43 minutos**
- Si se consume el error budget:
  - Se prioriza confiabilidad sobre features
  - Se pausan deploys
  - El equipo se enfoca en reducir el riesgo de incidentes
- Alinea incentivos entre dev y ops
- Cultura: el error budget es para gastarlo, no para evitarlo a toda costa

### 4.3 Incident Response

**Fases:**
1. **Detección** — alerta o reporte de usuario
2. **Triage** — evaluar severidad, asignar roles
3. **Comunicación** — status page, canales de Slack, updates periódicos
4. **Mitigación** — acción rápida para reducir impacto (rollback, scale up, failover)
5. **Resolución** — restaurar servicio completo
6. **Postmortem** — análisis blameless con action items

**Roles durante incidente (ICS):**
- **Incident Commander (IC):** coordina, no ejecuta
- **Communications Lead:** actualiza stakeholders
- **Operations Lead:** ejecuta mitigación técnica
- **Subject Matter Experts:** consultados según necesidad

**Severidades:**
| Sev | Definición | Ejemplo |
|-----|------------|---------|
| Sev 1 | Caída total, impacto masivo | API down, pérdida de datos |
| Sev 2 | Degradación significativa | Latencia p95 10x normal |
| Sev 3 | Degradación parcial | Funcionalidad secundaria rota |
| Sev 4 | Cosmético | Bug visual |

### 4.4 Eliminar Toil
- **Toil:** trabajo manual, repetitivo, sin valor a largo plazo
- **Regla SRE:** máximo 50% del tiempo en toil, el resto en automatización
- Automatizar con runbooks, scripts, herramientas internas
- Si una tarea se hace > 2 veces, vale la pena automatizarla

### 4.5 Chaos Engineering
- Introducir fallos deliberados en producción (con control) para verificar resiliencia
- **Netflix** fue pionero con Chaos Monkey
- **Principios:** construir hipótesis, variar blast radius, ejecutar en producción (con guardrails), automatizar
- **Herramientas:** Gremlin, Chaos Mesh, Litmus, AWS Fault Injection Service

**Experimentos típicos:**
- Matar un pod aleatorio → verificar que HPA recrea
- Cortar la red entre servicios → verificar circuit breaker
- Inyectar latencia 500ms en DB → verificar timeouts degradan gracefully
- Apagar una AZ completa → verificar que la app sigue sirviendo

### 4.6 On-Call
- **Rotación justa** — compartir guardias
- **Alertas accionables** — no ruidosas (alert fatigue)
- **Runbooks** para incidentes comunes
- **Escalation paths** claros
- **Objetivo:** reducir MTTR (Mean Time to Recovery)
- Compensación: tiempo libre después de guardia

### 4.7 Capacity Planning
- **Anticipar el crecimiento** para no quedar sin recursos
- **Load testing** regular (k6, Locust, Gatling, JMeter)
- **Análisis de tendencias** de uso histórico
- **Proyecciones de costos** mensuales
- **Evita:**
  - Over-provisioning costoso (gastar de más)
  - Under-provisioning que genera outages

### 4.8 Blameless Postmortem
- El objetivo es **identificar causas sistémicas**, no buscar culpables
- Estructura:
  1. **Resumen ejecutivo** — qué pasó, impacto, duración
  2. **Timeline** — eventos con timestamps
  3. **Root cause analysis** — 5 whys, fishbone
  4. **What went well** — lo que funcionó
  5. **What went poorly** — lo que falló
  6. **Action items** — con dueño, severidad, fecha
- Compartir con todo el equipo y la organización

## 5. Herramientas

| Categoría | Herramientas |
|-----------|--------------|
| Status page | Statuspage, Better Uptime, Instatus |
| Incident mgmt | PagerDuty, Opsgenie, FireHydrant, incident.io |
| On-call schedule | PagerDuty, Opsgenie |
| Chaos | Gremlin, Chaos Mesh, Litmus, AWS FIS |
| Load testing | k6, Locust, Gatling, JMeter, Vegeta |
| Postmortem | Confluence, Notion, custom templates |
| Error budget tracking | PromQL + Grafana, Sloth, Nobl9 |
| Runbook | Confluence, Notion, markdown en repo |
| Cost | CloudHealth, Vantage, AWS Cost Explorer |

## 6. Proyecto 13 — Implementación SRE Completa

**Duración estimada:** 22-30 horas
**Entregable:** Sistema del proyecto 12 instrumentado con SLIs/SLOs, error budget tracking, runbooks, chaos tests y postmortem documentado

### Pasos

1. **Definir SLIs y SLOs para servicios críticos**
   ```yaml
   # slos/api.yaml
   apiVersion: sloth.slok.dev/v1
   kind: SLO
   metadata: { name: api-availability }
   spec:
     service: api
     description: "99.9% de requests exitosas"
     sli:
       events:
         error_query: sum(rate(http_requests_total{code=~"5.."}[5m]))
         total_query: sum(rate(http_requests_total[5m]))
     objectives:
       - objective: 99.9
         description: "30-day availability"
         sli:     # SLI = success rate
           success_rate: 0.999
         alerting:
           page_alert:   {burnrate: 14.4, long: 1h,  short: 5m}
           ticket_alert: {burnrate: 6,    long: 24h, short: 30m}
   ```
   - SLI: availability, latency p95, error rate
   - SLO: 99.9% availability, p95 < 300ms, error rate < 0.1%

2. **Error budget tracking en Grafana con alertas al 50%**
   - Dashboard que muestra consumo del error budget en tiempo real
   - Alerta cuando se consume el 50% (alerta de awareness)
   - Alerta cuando se consume el 100% (parar deploys)
   - Burn rate alerting (multi-window, multi-burn-rate)

3. **Runbooks detallados para los 5 incidentes más probables**
   ```
   docs/runbooks/
   ├── pod-crashloop.md
   │   ├── Síntoma
   │   ├── Investigación
   │   │   ├── kubectl get pods
   │   │   ├── kubectl describe pod
   │   │   └── kubectl logs --previous
   │   ├── Mitigación
   │   │   ├── Rollback
   │   │   ├── Scale
   │   │   └── Fix forward
   │   └── Postmortem checklist
   ├── db-connection-limit.md
   ├── disk-full.md
   ├── high-error-rate.md
   └── latency-spike.md
   ```
   Cada runbook: copy-paste de comandos, links a dashboards, escalation path.

4. **Chaos Engineering con Chaos Mesh**
   ```yaml
   apiVersion: chaos-mesh.org/v1alpha1
   kind: PodChaos
   metadata: { name: pod-kill-test, namespace: hackathon }
   spec:
     action: pod-kill
     mode: one
     selector:
       namespaces: [hackathon]
       labelSelectors: { app: api }
     duration: "30s"
     scheduler: { cron: "@every 2h" }
   ```
   - Eliminar pods aleatorios cada 2 horas
   - Cortar la red entre servicios por 1 minuto
   - Inyectar latencia 500ms en DB
   - Verificar: la app se recupera sin intervención humana

5. **Postmortem de un incidente real o simulado**
   ```
   postmortems/2026-XX-YY-pod-crashloop.md
   ```
   Secciones:
   - **TL;DR:** 2-3 oraciones con qué pasó y el impacto
   - **Impacto:** usuarios afectados, duración, métricas de negocio
   - **Timeline:** eventos clave con timestamps (T+0, T+5, T+10, T+30)
   - **Root cause:** análisis con 5 whys
   - **Detection:** cómo se detectó, por qué no antes
   - **Response:** qué funcionó, qué no
   - **Action items:**
     - [ ] AI-1: agregar health check readiness (owner: alice, sev: high, due: 2026-XX-YY)
     - [ ] AI-2: alerta en Prometheus para crash loop (owner: bob, sev: medium, due: 2026-XX-YY)
     - [ ] AI-3: runbook específico (owner: alice, sev: low, due: 2026-XX-YY)
   - **Lessons learned**

### Estructura entregable
```
13-sre/
├── README.md
├── slos/
│   ├── api-availability.yaml
│   ├── api-latency.yaml
│   └── database-availability.yaml
├── alerts/
│   ├── burn-rate-alerts.yaml
│   └── error-budget-alerts.yaml
├── dashboards/
│   ├── error-budget.json
│   ├── slo-overview.json
│   └── on-call-dashboard.json
├── runbooks/
│   ├── pod-crashloop.md
│   ├── db-connection-limit.md
│   ├── disk-full.md
│   ├── high-error-rate.md
│   └── latency-spike.md
├── chaos/
│   ├── pod-kill-experiment.yaml
│   ├── network-partition.yaml
│   └── latency-injection.yaml
├── postmortems/
│   ├── template.md
│   └── 2026-XX-YY-incident-name.md
├── load-tests/
│   ├── locustfile.py
│   └── k6-script.js
├── docs/
│   ├── slo-methodology.md
│   ├── on-call-rotation.md
│   └── capacity-planning.md
└── scripts/
    ├── error-budget-report.sh
    └── chaos-schedule.sh
```

## 7. Checklist de cierre del módulo

- [ ] SLIs y SLOs definidos para ≥ 3 servicios críticos
- [ ] Error budget tracking en Grafana con alertas
- [ ] 5 runbooks detallados para incidentes comunes
- [ ] Al menos 2 experimentos de chaos ejecutados con resultados documentados
- [ ] Postmortem documentado con action items trackeados
- [ ] On-call rotation definida (incluso si rotamos entre 4 personas)
- [ ] Load test ejecutado con baseline de capacidad
- [ ] Proyecto 13 entregado: el equipo opera el sistema con disciplina SRE

## 8. Recursos recomendados

- **Libro:** "Site Reliability Engineering" — Google (gratis https://sre.google/sre-book/table-of-contents/)
- **Libro:** "The Site Reliability Workbook" — Google (gratis)
- **Libro:** "Chaos Engineering" — Casey Rosenthal
- **Curso:** SRE fundamentals (Linux Foundation)
- **Newsletter:** https://sreweekly.com/
- **Tools:** https://github.com/dastergon/awesome-sre
- **Comunidad:** https://www.usenix.org/srecon
- **Postmortems reales:** https://github.com/danluu/post-mortems

## 9. Conexión con el hackathon

Para Copa Airlines, la confiabilidad no es opcional — un sistema que cae en producción es un problema de seguridad, regulatory y reputacional. Demostrar SRE practices (SLIs visibles en dashboard, runbook, chaos test en vivo) eleva el pitch a nivel enterprise. **Es el diferenciador final entre un proyecto de fin de semana y un MVP creíble para una aerolínea.**

## 10. Cierre del roadmap

Con este módulo se cierra el ciclo completo. El equipo habrá pasado de la nada a:
- Red diagnosticada (P01)
- Servidores automatizados (P02)
- Inventario cloud (P03)
- Repositorio con GitOps (P04)
- Stack contenedorizado (P05)
- Pipeline CI/CD verde (P06)
- Infraestructura cloud segura (P07)
- Cluster Kubernetes productivo (P08)
- IaC reproducible (P09)
- Observabilidad full-stack (P10)
- DevSecOps (P11)
- Arquitectura escalable (P12)
- Disciplina SRE (P13)

**Este es un perfil DevOps completo, listo para contribuir a un equipo de ingeniería serio desde el día 1.**

---

*Plan completo del roadmap DevOps. Ejecutar módulo por módulo, proyecto por proyecto, hasta tener un sistema production-ready con disciplina SRE.*
