# Módulo 10 — Monitoreo y Logs

> **Categoría:** Observabilidad · **Prioridad:** Fundamental · **Origen:** `devops-roadmap.html#s10`

## 1. Por qué importa

No puedes mejorar lo que no mides. La observabilidad da visibilidad total del sistema: **métricas, logs y trazas distribuidas** forman los tres pilares. En hackathon, mostrar dashboards con métricas en vivo durante la demo es uno de los efectos "wow" más efectivos.

## 2. Objetivos de aprendizaje

- Recolectar y visualizar métricas con Prometheus + Grafana
- Centralizar y buscar logs con ELK/EFK
- Implementar alertas accionables
- Configurar trazas distribuidas con OpenTelemetry o Jaeger

## 3. Prerrequisitos

- Módulos 01-09 completados
- Cluster Kubernetes (módulo 08) o infraestructura cloud (módulo 07)
- 4 GB RAM extra para stack de observabilidad

## 4. Temas detallados

### 4.1 Los tres pilares de la observabilidad

| Pilar | Pregunta que responde | Herramientas |
|-------|----------------------|--------------|
| **Métricas** | ¿Cuánto? ¿Cuándo? ¿Con qué frecuencia? | Prometheus, Grafana, CloudWatch |
| **Logs** | ¿Qué pasó exactamente? | ELK, Loki, Fluentd |
| **Trazas** | ¿Por dónde pasó la request? | Jaeger, OpenTelemetry, Zipkin |

### 4.2 Prometheus
- Sistema de métricas **basado en pull**
- Scrapea endpoints `/metrics` de servicios
- Modelo dimensional: `metric_name{label="value"}`
- PromQL: lenguaje de consulta poderoso
- AlertManager: gestiona alertas y rutas (Slack, PagerDuty, email)
- Tipos: counter, gauge, histogram, summary
- Exporters para sistemas que no exponen métricas nativas (node_exporter, kube-state-metrics)

```promql
# CPU usage por pod
sum(rate(container_cpu_usage_seconds_total[5m])) by (pod)

# Latencia p95 de requests HTTP
histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (le, service))

# Memoria disponible
node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes * 100
```

### 4.3 Grafana
- Visualización de métricas de **múltiples fuentes**
- Data sources: Prometheus, CloudWatch, Datadog, Loki, Elasticsearch, MySQL, PostgreSQL
- Dashboards pre-construidos para Kubernetes, Linux, databases
- Variables, anotaciones, drill-down
- Alertas con canales de notificación
- Grafana Cloud como SaaS

### 4.4 ELK / EFK Stack
- **Elasticsearch:** almacena y busca logs
- **Logstash / Fluentd:** procesa y enriquece
- **Kibana:** visualiza y analiza
- Para Kubernetes: **Fluent Bit** (más ligero que Fluentd) como DaemonSet
- Parseo de JSON, multi-linea, geo-IP
- ILM (Index Lifecycle Management) para retención

### 4.5 Trazas distribuidas
- **OpenTelemetry:** estándar de la industria (vendor-neutral)
- **Jaeger:** UI y storage de trazas
- Spans, traces, context propagation
- Indispensable para diagnosticar latencia y errores en microservicios
- Auto-instrumentation para Python, Node, Go, Java

### 4.6 Patrones de alerting
- **Alert on symptoms, not causes:** alertar en latencia, no en CPU
- **SLO-based alerts:** alertar cuando se consume el error budget
- **Multi-window multi-burn-rate:** Google SRE
- Evitar alert fatigue: alertas accionables, runbooks asociados
- Severidades: critical, warning, info
- Routing por severidad y equipo

## 5. Herramientas

| Herramienta | Uso |
|-------------|-----|
| `promtool` | Validar reglas Prometheus |
| `logcli` | CLI para Grafana Loki |
| `kubectl logs` / `stern` | Logs en vivo de pods |
| `vector` | Pipeline de logs moderno (alternativa a Fluentd) |
| `loki` | Logs como Prometheus (económico) |
| `tempo` | Trazas nativas para Grafana |
| `pyroscope` / `parca` | Continuous profiling |
| `thanos` / `mimir` | Prometheus a largo plazo y multi-cluster |
| `uptime-kuma` | Uptime monitoring simple |

## 6. Proyecto 10 — Stack de Observabilidad Completo

**Duración estimada:** 18-24 horas
**Entregable:** Stack Prometheus + Grafana + EFK desplegado, con dashboards y alertas

### Arquitectura
```
                          Cluster K8s
                              │
                ┌─────────────┼─────────────┐
                │             │             │
           ┌────▼────┐   ┌────▼────┐   ┌────▼────┐
           │   App   │   │   App   │   │   App   │
           │ /metrics│   │ /metrics│   │ /metrics│
           └────┬────┘   └────┬────┘   └────┬────┘
                │             │             │
        ┌───────▼─────────────▼─────────────▼───────┐
        │           kube-prometheus-stack           │
        │  ┌──────────────┐    ┌──────────────────┐  │
        │  │  Prometheus  │◄───┤ node-exporter    │  │
        │  │              │    │ kube-state-metrics│ │
        │  │              │    │ ServiceMonitors  │  │
        │  └──────┬───────┘    └──────────────────┘  │
        │         │                                  │
        │  ┌──────▼───────┐    ┌──────────────────┐  │
        │  │ AlertManager │───►│ Slack / PagerDuty│  │
        │  └──────────────┘    └──────────────────┘  │
        └────────┬───────────────────────────────────┘
                 │
        ┌────────▼─────────┐
        │     Grafana      │  ← dashboards
        └──────────────────┘

        ┌────────────────────────┐
        │   EFK Stack            │
        │ ┌─────────┐ ┌────────┐ │
        │ │Fluent Bit│►│ES      │ │
        │ │(DaemonSet)│ └────┬───┘ │
        │ └─────────┘      │   │
        │                  ▼   │
        │           ┌──────────┐│
        │           │  Kibana  ││
        │           └──────────┘│
        └────────────────────────┘
```

### Pasos

1. **Desplegar Prometheus + Grafana con kube-prometheus-stack (Helm)**
   ```bash
   helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
   helm install kube-prom prometheus-community/kube-prometheus-stack \
     --namespace monitoring --create-namespace \
     --set grafana.adminPassword=$GRAFANA_ADMIN_PWD \
     --set prometheus.prometheusSpec.retention=30d \
     --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage=50Gi
   ```
   - Incluye: Prometheus, AlertManager, Grafana, node-exporter, kube-state-metrics
   - ServiceMonitors auto-descubiertos para componentes K8s

2. **Dashboards personalizados**
   - **Cluster resources:** CPU, memoria, red, pods por estado
   - **App latency:** p50, p95, p99 por endpoint
   - **HTTP errors:** 4xx, 5xx por status code
   - **Business metrics:** requests por usuario, tiempo de respuesta por ruta
   - **Database:** connections, slow queries, replication lag

3. **AlertManager con reglas críticas**
   ```yaml
   apiVersion: monitoring.coreos.com/v1
   kind: PrometheusRule
   metadata: { name: api-alerts, namespace: monitoring }
   spec:
     groups:
       - name: api
         rules:
           - alert: PodCrashLooping
             expr: rate(kube_pod_container_status_restarts_total[10m]) > 0
             for: 5m
             labels: { severity: critical }
             annotations:
               summary: "Pod {{ $labels.pod }} reiniciándose"
               runbook: "https://wiki/runbooks/pod-crashloop"
           - alert: HighCPUUsage
             expr: (1 - rate(node_cpu_seconds_total{mode="idle"}[5m])) > 0.8
             for: 10m
             labels: { severity: warning }
   ```
   Reglas mínimas:
   - Pod reiniciándose > 3 veces en 10 min
   - CPU > 80% sostenido 10 min
   - Memoria > 85%
   - Disco > 90%
   - Latencia p95 > SLO
   - 5xx > 1% de tráfico
   - Pod sin readiness > 5 min

4. **EFK Stack (Elasticsearch + Fluentd + Kibana) o PLG (Promtail + Loki + Grafana)**
   ```bash
   helm repo add elastic https://helm.elastic.co
   helm install elasticsearch elastic/elasticsearch -n logging --create-namespace
   helm install kibana elastic/kibana -n logging
   helm install fluent-bit fluent/fluent-bit -n logging
   ```
   - Fluent Bit como DaemonSet recolecta logs de todos los pods
   - Parsing automático de JSON de stdout
   - Index pattern en Kibana: `kubernetes-*`
   - Saved searches para errores y eventos críticos

5. **Runbook para las 3 alertas más críticas**
   ```
   docs/runbooks/
   ├── pod-crashloop.md
   ├── high-cpu.md
   └── high-error-rate.md
   ```
   Cada runbook: síntoma, investigación, mitigación, postmortem.

### Estructura entregable
```
10-monitoreo-logs/
├── README.md
├── helm/
│   ├── prometheus-stack-values.yaml
│   ├── elasticsearch-values.yaml
│   ├── kibana-values.yaml
│   └── fluent-bit-values.yaml
├── alerts/
│   ├── api-alerts.yaml
│   ├── infra-alerts.yaml
│   └── database-alerts.yaml
├── dashboards/
│   ├── cluster-overview.json
│   ├── app-latency.json
│   └── business-metrics.json
├── scripts/
│   ├── install.sh
│   └── load-test.sh            # para validar alertas
└── docs/
    └── runbooks/
```

## 7. Checklist de cierre del módulo

- [ ] Prometheus recolectando métricas del cluster
- [ ] Grafana con dashboards operativos y de negocio
- [ ] AlertManager con al menos 5 reglas críticas
- [ ] Slack recibe notificaciones de alertas de prueba
- [ ] EFK/PLG centraliza logs de pods
- [ ] Runbooks para las alertas top
- [ ] Proyecto 10 entregado: el equipo puede ver y alertar sobre el sistema

## 8. Recursos recomendados

- **Prometheus:** https://prometheus.io/docs/
- **Grafana:** https://grafana.com/docs/
- **Curso:** Prometheus Certified Associate prep
- **Libro:** "Observability Engineering" — Majors, Fong-Jones, Miranda
- **SRE workbook:** https://sre.google/workbook/table-of-contents/
- **Práctica:** https://github.com/prometheus/prometheus/blob/main/docs/querying/basics.md
- **Dashboards:** https://grafana.com/grafana/dashboards/

## 9. Conexión con el hackathon

Los dashboards en vivo durante la presentación muestran:
- Que el sistema realmente está corriendo
- Que el equipo sabe medir éxito
- Que el equipo puede responder a incidentes

Para Copa Airlines — la observabilidad es crítica. Los jueces del sector aeron valoran SRE/monitoring porque en producción una caída afecta vuelos, equipajes y pasajeros. Un dashboard elegante con latencia, errores y throughput es un activo visual poderoso.

## 10. Siguiente módulo

→ [Módulo 11 — Seguridad en DevOps](../11-seguridad-devsecops/plan.md)
