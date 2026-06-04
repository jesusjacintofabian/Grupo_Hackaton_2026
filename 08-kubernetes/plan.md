# Módulo 08 — Kubernetes

> **Categoría:** Orquestación · **Prioridad:** Top demanda · **Origen:** `devops-roadmap.html#s08`

## 1. Por qué importa

La habilidad más demandada actualmente en DevOps. Kubernetes orquesta contenedores a escala, gestionando despliegues, escalado, recuperación de fallos y red. En hackathon, levantar un cluster K8s y demostrar que el sistema se auto-recupera impresiona a jueces técnicos.

## 2. Objetivos de aprendizaje

- Comprender la arquitectura de un cluster Kubernetes
- Desplegar aplicaciones con Deployments, Services e Ingress
- Configurar almacenamiento persistente y configuración externa
- Aplicar autoescalado, rolling updates y rollbacks

## 3. Prerrequisitos

- Módulos 01-07 completados
- Docker sólido (módulo 05)
- Cuenta AWS o local con kind/minikube
- 4 GB RAM mínimo para cluster local

## 4. Temas detallados

### 4.1 Arquitectura del cluster

**Control Plane (cerebro):**
- `kube-apiserver` — recibe todas las instrucciones (API REST)
- `etcd` — almacenamiento consistente del estado del cluster
- `kube-scheduler` — decide en qué nodo corre cada Pod
- `kube-controller-manager` — mantiene el estado deseado
- `cloud-controller-manager` — integración con cloud provider

**Worker Nodes (trabajadores):**
- `kubelet` — agente que corre en cada nodo, gestiona Pods
- `kube-proxy` — reglas de red para Services
- Container runtime — `containerd`, `CRI-O`

### 4.2 Objetos principales
| Objeto | Función |
|--------|---------|
| `Pod` | Unidad mínima, 1+ contenedores |
| `Deployment` | Gestiona réplicas y rolling updates |
| `StatefulSet` | Para apps con estado (DBs, colas) |
| `DaemonSet` | Un Pod por nodo (logs, monitoring) |
| `Service` | IP estable para acceder a Pods |
| `Ingress` | Routing HTTP/HTTPS desde el exterior |
| `ConfigMap` | Configuración no sensible |
| `Secret` | Configuración sensible (base64) |
| `PersistentVolume` / `PVC` | Almacenamiento durable |
| `Job` / `CronJob` | Tareas batch y programadas |
| `Namespace` | Aislamiento lógico |

### 4.3 kubectl esencial
```bash
kubectl get pods -A
kubectl describe pod <name>
kubectl logs -f <pod>
kubectl exec -it <pod> -- /bin/sh
kubectl apply -f manifest.yaml
kubectl delete -f manifest.yaml
kubectl rollout status deployment/<name>
kubectl rollout undo deployment/<name>
kubectl scale deployment/<name> --replicas=5
kubectl top nodes
kubectl get events --sort-by=.metadata.creationTimestamp
```

### 4.4 Manifest ejemplo
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
  namespace: hackathon
spec:
  replicas: 3
  selector:
    matchLabels: { app: api }
  template:
    metadata:
      labels: { app: api }
    spec:
      containers:
        - name: api
          image: ghcr.io/equipo/api:1.0.0
          ports: [{ containerPort: 8000 }]
          env:
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef: { name: db-secrets, key: url }
          resources:
            requests: { cpu: "100m", memory: "128Mi" }
            limits:   { cpu: "500m", memory: "512Mi" }
          livenessProbe:
            httpGet: { path: /health, port: 8000 }
            initialDelaySeconds: 30
            periodSeconds: 10
          readinessProbe:
            httpGet: { path: /ready, port: 8000 }
            initialDelaySeconds: 5
            periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: api
spec:
  selector: { app: api }
  ports: [{ port: 80, targetPort: 8000 }]
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  tls: [{ hosts: [api.hackathon.local], secretName: api-tls }]
  rules:
    - host: api.hackathon.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend: { service: { name: api, port: { number: 80 } } }
```

### 4.5 Helm
- Gestor de paquetes para Kubernetes
- Charts: templates parametrizados de aplicaciones
- Repos: `helm repo add bitnami https://charts.bitnami.com/bitnami`
- Comandos: `helm install`, `helm upgrade`, `helm rollback`, `helm list`
- Útil para: Prometheus, Grafana, cert-manager, ingress-nginx, Redis, Postgres

### 4.6 Estrategias de autoescalado
- **HPA** (Horizontal Pod Autoscaler): réplicas según CPU/RAM/custom metrics
- **VPA** (Vertical Pod Autoscaler): ajusta requests/limits
- **Cluster Autoscaler**: nodos según demanda
- **KEDA**: event-driven autoscaling

### 4.7 Seguridad
- **RBAC:** Roles, ClusterRoles, RoleBindings
- **Network Policies:** segmentación de tráfico entre Pods
- **Pod Security Standards:** restricted, baseline, privileged
- **Secrets cifrados en etcd**
- **Service Accounts** por aplicación
- **OPA/Gatekeeper** para políticas como código

## 5. Herramientas

| Herramienta | Uso |
|-------------|-----|
| `kubectl` | CLI principal |
| `kubectx` / `kubens` | Cambio rápido de contexto/namespace |
| `k9s` | TUI poderosa para administración |
| `stern` | Logs multi-pod con colores |
| `lens` | IDE para Kubernetes |
| `helm` | Gestor de paquetes |
| `kustomize` | Personalización de manifests |
| `argocd` / `flux` | GitOps |
| `krew` | Plugin manager para kubectl |
| `kind`, `minikube`, `k3d` | Clusters locales |

## 6. Proyecto 08 — Cluster Kubernetes en Producción

**Duración estimada:** 18-24 horas
**Entregable:** Cluster K8s con la app del proyecto 05 desplegada, escalable, con TLS y RBAC

### Opciones de cluster
| Entorno | Cuándo |
|---------|--------|
| `kind` (Kubernetes in Docker) | Desarrollo local, cero costo |
| `minikube` | Desarrollo local, single node |
| `k3d` | K3s en Docker, muy ligero |
| EKS (AWS) | Producción real |
| GKE (GCP) | Producción real, free tier $300 |
| AKS (Azure) | Producción real, free tier generoso |

### Pasos

1. **Crear el cluster y configurar kubectl**
   ```bash
   # Local con kind
   kind create cluster --name hackathon --config kind.yaml
   # AWS con EKS
   eksctl create cluster --name hackathon --region us-east-1 --nodes 3
   aws eks update-kubeconfig --name hackathon
   ```

2. **Desplegar la app del Proyecto 05 como Deployment + Service**
   - Namespace: `hackathon`
   - Deployment con 3 réplicas
   - HPA: target 60% CPU, min 3 max 10
   - Service ClusterIP
   - ConfigMap y Secret para variables de entorno
   - PVC para datos persistentes

3. **Ingress con nginx-ingress y cert-manager para TLS automático**
   ```bash
   helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
   helm install ingress-nginx ingress-nginx/ingress-nginx
   helm repo add jetstack https://charts.jetstack.io
   helm install cert-manager jetstack/cert-manager --set installCRDs=true
   ```
   - ClusterIssuer Let's Encrypt (HTTP-01 challenge)
   - Ingress con TLS automático

4. **Rolling Updates + Rollback**
   ```bash
   kubectl set image deployment/api api=ghcr.io/equipo/api:1.1.0
   kubectl rollout status deployment/api
   # Si falla:
   kubectl rollout undo deployment/api
   # Historial:
   kubectl rollout history deployment/api
   ```
   - Configurar `maxUnavailable: 0` y `maxSurge: 1` para zero-downtime
   - Probar `preStop` hook para graceful shutdown

5. **Network Policies y RBAC**
   ```yaml
   # NetworkPolicy: solo ingress puede hablar con api
   apiVersion: networking.k8s.io/v1
   kind: NetworkPolicy
   metadata: { name: api-ingress-only }
   spec:
     podSelector: { matchLabels: { app: api } }
     policyTypes: [Ingress]
     ingress:
       - from:
           - podSelector: { matchLabels: { app: ingress-nginx } }
         ports: [{ port: 8000 }]
   ```
   ```yaml
   # RBAC: developer solo puede listar pods en su namespace
   apiVersion: rbac.authorization.k8s.io/v1
   kind: Role
   metadata: { namespace: hackathon, name: dev-readonly }
   rules:
     - apiGroups: [""]
       resources: ["pods", "services", "configmaps"]
       verbs: ["get", "list", "watch"]
   ```

### Estructura entregable
```
08-kubernetes/
├── README.md
├── k8s/
│   ├── namespaces/
│   ├── deployments/
│   ├── services/
│   ├── ingress/
│   ├── configmaps/
│   ├── secrets/
│   ├── hpa/
│   ├── networkpolicies/
│   └── rbac/
├── helm/
│   └── api-chart/
├── scripts/
│   ├── setup-cluster.sh
│   ├── deploy.sh
│   ├── rollback.sh
│   └── load-test.sh
└── docs/
    ├── architecture.md
    └── runbooks/
```

## 7. Checklist de cierre del módulo

- [ ] Despliego Deployments y Services
- [ ] Configuro Ingress con TLS automático
- [ ] Implemento HPA y verifico escalado con load test
- [ ] Ejecuto rolling update y rollback con éxito
- [ ] Aplico Network Policies y RBAC
- [ ] Proyecto 08 desplegado, documentado, con runbook básico

## 8. Recursos recomendados

- **Docs:** https://kubernetes.io/docs/home/
- **Curso:** Kubernetes for the Absolute Beginners (KodeKloud)
- **Curso:** Certified Kubernetes Administrator (CKA) prep
- **Libro:** "Kubernetes in Action" — Marko Lukša
- **Práctica:** https://killercoda.com/kubernetes
- **Labs:** https://labs.play-with-k8s.com/
- **Juego:** https://kubeinvaders.com (CTF)

## 9. Conexión con el hackathon

Kubernetes es la navaja suiza de DevOps. En 30 minutos de demo, el equipo puede mostrar: deploy, scale, fail, recover — los jueces ven un sistema con auto-sanación, que es exactamente lo que un sistema de aviación debe tener. La arquitectura K8s es directamente relevante a temas como edge computing aeroportuario y gemelos digitales (estado distribuido, alta disponibilidad).

## 10. Siguiente módulo

→ [Módulo 09 — Terraform y Ansible](../09-terraform-ansible/plan.md)
