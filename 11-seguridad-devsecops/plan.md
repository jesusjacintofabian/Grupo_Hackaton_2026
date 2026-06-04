# Módulo 11 — Seguridad en DevOps (DevSecOps)

> **Categoría:** DevSecOps · **Prioridad:** Crítico · **Origen:** `devops-roadmap.html#s11`

## 1. Por qué importa

La seguridad ya no es responsabilidad exclusiva del equipo de seguridad. En DevSecOps, **cada ingeniero integra seguridad en cada paso** del ciclo de desarrollo. En hackathon, demostrar controles de seguridad (escaneo de imágenes, secretos en Vault, RBAC) señala madurez profesional que muchos equipos ignoran.

## 2. Objetivos de aprendizaje

- Aplicar principio de mínimo privilegio y MFA en todo
- Escanear imágenes, código y dependencias por vulnerabilidades
- Gestionar secretos sin exponerlos en código
- Implementar políticas de seguridad en Kubernetes (PSA, OPA, Network Policies)

## 3. Prerrequisitos

- Módulos 01-10 completados
- Cluster K8s operativo (módulo 08)
- Pipeline CI/CD activo (módulo 06)

## 4. Temas detallados

### 4.1 Gestión de identidades
- **IAM con mínimo privilegio** — solo permisos necesarios
- **MFA obligatorio** — para todos los usuarios humanos
- **Rotación de credenciales** — automática cuando sea posible
- **RBAC en Kubernetes** — Roles, ClusterRoles, Bindings
- **Service Accounts** dedicados por aplicación
- **Nunca credenciales en código** — usar Vault, AWS Secrets Manager, o env cifradas
- **Workload Identity** — pods asumen roles IAM sin secrets estáticos

### 4.2 Seguridad de contenedores
- **Trivy** — escaneo de imágenes Docker por CVEs
- **Nunca ejecutar como root** — `USER nonroot` en Dockerfile
- **Imágenes base mínimas** — distroless, alpine, scratch
- **Signed images** con cosign (Supply Chain Security)
- **SBOM** (Software Bill of Materials) — inventario de componentes
- **Multi-stage builds** — minimizan superficie de ataque
- **Read-only filesystem** en pods

### 4.3 Seguridad en Kubernetes
- **Network Policies** — restringen comunicación entre pods
- **Secrets cifrados en etcd** — con KMS provider
- **Pod Security Standards** — restricted, baseline, privileged
- **OPA/Gatekeeper** — políticas como código
- **Kyverno** — alternativa más amigable a OPA
- **Falco** — runtime security (detección de anomalías)
- **Admission controllers** — validación de objetos al ingresar al cluster

### 4.4 Seguridad en el pipeline
- **SAST** (Static Application Security Testing): análisis estático del código fuente
  - Herramientas: SonarQube, Semgrep, Snyk Code, Bandit (Python), ESLint security plugins
- **DAST** (Dynamic Application Security Testing): prueba la app en ejecución
  - Herramientas: OWASP ZAP, Burp Suite
- **SCA** (Software Composition Analysis): vulnerabilidades en dependencias
  - Herramientas: Snyk, Dependabot, OWASP Dependency-Check, Trivy
- **Container Scanning**: Trivy, Clair, Anchore
- **Secret scanning**: git-secrets, TruffleHog, GitHub secret scanning
- **Firmar commits con GPG** — verifica autoría
- **Branch protection rules** + revisión obligatoria

### 4.5 Gestión de secretos
- **HashiCorp Vault** — secretos dinámicos, leasing, audit
- **AWS Secrets Manager / SSM Parameter Store** — integrado con AWS
- **Sealed Secrets** (Bitnami) — secrets cifrados en Git
- **External Secrets Operator** — sincroniza secretos desde Vault/AWS
- **Rotación automática** de credenciales de DB
- **Nunca en variables de CI** — usar secrets context

### 4.6 Compliance y frameworks
- **OWASP Top 10** — web app security risks
- **CIS Benchmarks** — hardening guides
- **NIST Cybersecurity Framework**
- **SOC 2 / ISO 27001** — para empresas
- **SLSA** (Supply Chain Levels for Software Artifacts)

## 5. Herramientas

| Categoría | Herramientas |
|-----------|--------------|
| SAST | SonarQube, Semgrep, Bandit, CodeQL |
| DAST | OWASP ZAP, Burp Suite |
| SCA | Snyk, Dependabot, npm audit, pip-audit |
| Container scan | Trivy, Clair, Anchore, Grype |
| Secret scan | git-secrets, TruffleHog, gitleaks |
| K8s policy | OPA/Gatekeeper, Kyverno, Falco |
| Secrets | Vault, AWS Secrets Manager, Sealed Secrets |
| SBOM | syft, cyclonedx, SPDX |
| Supply chain | cosign (Sigstore), SLSA, in-toto |

## 6. Proyecto 11 — Pipeline DevSecOps

**Duración estimada:** 16-22 horas
**Entregable:** Pipeline CI/CD con controles de seguridad en cada fase, secretos dinámicos, hardening K8s

### Capas de seguridad

```
┌──────────────────────────────────────────────────────────────┐
│  Pre-commit: secret scan (gitleaks)                          │
└────────────────────────┬─────────────────────────────────────┘
                         │
┌────────────────────────▼─────────────────────────────────────┐
│  CI: SAST (semgrep/sonarqube) + SCA (snyk/dependabot)        │
│       + Dockerfile lint (hadolint)                           │
└────────────────────────┬─────────────────────────────────────┘
                         │
┌────────────────────────▼─────────────────────────────────────┐
│  Build: image scan (trivy) + SBOM (syft) + sign (cosign)    │
└────────────────────────┬─────────────────────────────────────┘
                         │
┌────────────────────────▼─────────────────────────────────────┐
│  Deploy: admission control (Kyverno/OPA) + Falco runtime    │
└──────────────────────────────────────────────────────────────┘
```

### Pasos

1. **Trivy en el pipeline para fallar si hay CVEs críticos**
   ```yaml
   - name: Trivy image scan
     uses: aquasecurity/trivy-action@master
     with:
       image-ref: ghcr.io/equipo/api:${{ github.sha }}
       format: 'sarif'
       output: 'trivy-results.sarif'
       severity: 'CRITICAL,HIGH'
       exit-code: '1'              # falla el build
       ignore-unfixed: true
   ```
   - Bloquea CVEs críticos y altos no parcheados
   - Publica resultados en GitHub Security tab

2. **SAST con SonarQube o Semgrep**
   ```yaml
   - name: Semgrep
     uses: returntocorp/semgrep-action@v1
     with:
       config: >-
         p/security-audit
         p/secrets
         p/owasp-top-ten
   ```
   - Detecta vulnerabilidades de código (SQL injection, XSS, etc.)
   - Reporta al PR con explicaciones y fixes sugeridos

3. **HashiCorp Vault para secretos dinámicos**
   ```bash
   # Levantar Vault en dev mode
   vault server -dev -dev-root-token-id=root
   # Habilitar KV v2
   vault secrets enable -path=secret kv-v2
   # Crear secreto
   vault kv put secret/database url="postgresql://user:pass@db:5432/app"
   # Lectura desde app vía sidecar o External Secrets Operator
   ```
   - En K8s: External Secrets Operator sincroniza a un K8s Secret
   - DB credentials rotativos: Vault genera credenciales temporales por servicio

4. **Network Policies en Kubernetes**
   ```yaml
   apiVersion: networking.k8s.io/v1
   kind: NetworkPolicy
   metadata: { name: api-ingress-only, namespace: hackathon }
   spec:
     podSelector: { matchLabels: { app: api } }
     policyTypes: [Ingress, Egress]
     ingress:
       - from:
           - podSelector: { matchLabels: { app: ingress-nginx } }
         ports: [{ port: 8000 }]
     egress:
       - to:
           - podSelector: { matchLabels: { app: postgres } }
         ports: [{ port: 5432 }]
       - to:
           - namespaceSelector: { matchLabels: { name: kube-system } }
         ports:
           - { port: 53, protocol: UDP }   # DNS
   ```
   - Por defecto todo está prohibido
   - Solo se permite lo explícitamente declarado

5. **Rotación automática de credenciales con AWS Secrets Manager**
   ```hcl
   # Terraform
   resource "aws_secretsmanager_secret_rotation" "db" {
     secret_id           = aws_secretsmanager_secret.db.id
     rotation_lambda_arn = aws_lambda_function.rotator.arn
     rotation_rules { automatically_after_days = 30 }
   }
   ```
   - Lambda rota la contraseña cada 30 días
   - Aplicación lee siempre la versión más reciente
   - Auditoría de accesos en CloudTrail

### Estructura entregable
```
11-seguridad-devsecops/
├── README.md
├── .github/workflows/
│   ├── secret-scan.yml          # gitleaks en pre-commit hook
│   ├── sast.yml                  # semgrep
│   ├── sca.yml                   # snyk/dependabot
│   ├── container-scan.yml        # trivy
│   └── sign.yml                  # cosign
├── k8s/
│   ├── networkpolicies/
│   ├── podsecurity/
│   ├── kyverno-policies/
│   └── external-secrets/
├── terraform/
│   └── secrets-rotation/
├── vault/
│   ├── policies/
│   └── roles/
├── docs/
│   ├── threat-model.md
│   ├── security-checklist.md
│   └── incident-response.md
└── scripts/
    ├── scan-all.sh
    └── compliance-check.sh
```

## 7. Checklist de cierre del módulo

- [ ] MFA habilitado en todas las cuentas
- [ ] Imágenes Docker corren como usuario no-root
- [ ] Trivy bloquea CVEs críticos en el pipeline
- [ ] SAST (Semgrep/Sonar) integrado en CI
- [ ] Secretos dinámicos con Vault
- [ ] Network Policies restrictivas en K8s
- [ ] Pod Security Standards: restricted
- [ ] Rotación automática de credenciales DB
- [ ] Proyecto 11 entregado con threat model documentado

## 8. Recursos recomendados

- **OWASP:** https://owasp.org/www-project-top-ten/
- **CIS Benchmarks:** https://www.cisecurity.org/cis-benchmarks/
- **Curso:** DevSecOps Fundamentals (Linux Foundation)
- **Libro:** "DevSecOps" — Jim Bird
- **Trivy:** https://github.com/aquasecurity/trivy
- **Falco:** https://falco.org/
- **Vault:** https://developer.hashicorp.com/vault
- **Práctica:** https://www.practice-labs.com/ (security labs)
- **Hack your skills:** https://www.hackthebox.com/, https://tryhackme.com

## 9. Conexión con el hackathon

En el sector aeronáutico, la seguridad es regulatoria (FAA, IATA). Un equipo que demuestra controles de seguridad en su MVP señala que entiende el dominio. Incluso un análisis Trivy de la imagen final (mostrando "0 vulnerabilidades críticas") es un punto en la presentación. Para blockchain en trazabilidad de carga — DevSecOps es obligatorio por compliance.

## 10. Siguiente módulo

→ [Módulo 12 — Arquitectura de Aplicaciones](../12-arquitectura-apps/plan.md)
