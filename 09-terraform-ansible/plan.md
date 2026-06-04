# Módulo 09 — Terraform y Ansible

> **Categoría:** Infraestructura como Código · **Prioridad:** Alta demanda · **Origen:** `devops-roadmap.html#s09`

## 1. Por qué importa

La infraestructura declarativa hace que los servidores, redes y servicios cloud sean **reproducibles, versionables y auditables** como cualquier otro código. En hackathon, un equipo con IaC puede recrear el entorno completo en minutos — los jueces técnicos notan inmediatamente esta madurez.

## 2. Objetivos de aprendizaje

- Escribir infraestructura declarativa con Terraform (HCL)
- Gestionar estado remoto y multi-entorno
- Configurar servidores existentes con Ansible
- Integrar ambos en pipelines CI/CD

## 3. Prerrequisitos

- Módulos 01-08 completados
- Cuenta AWS (o cloud de preferencia) con credenciales configuradas
- Conocimiento de Linux y SSH (módulo 02)

## 4. Temas detallados

### 4.1 Terraform — Provisioning

**Conceptos core:**
- **Provider:** plugin que conecta con un cloud (AWS, Azure, GCP, K8s)
- **Resource:** bloque que declara infraestructura a crear
- **Data source:** lectura de recursos existentes
- **Variable:** parámetro de entrada
- **Output:** valor expuesto tras el apply
- **State:** archivo que rastrea lo desplegado (`terraform.tfstate`)
- **Module:** agrupación reutilizable de recursos
- **Workspace:** múltiples estados en el mismo directorio

**Workflow:**
```bash
terraform init          # descarga providers y módulos
terraform fmt           # formatea el código
terraform validate      # valida sintaxis
terraform plan          # muestra qué cambiará
terraform apply         # aplica los cambios
terraform destroy       # elimina todo
```

**Ejemplo:**
```hcl
terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
  backend "s3" {
    bucket         = "equipo-tfstate"
    key            = "hackathon/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tfstate-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "api" {
  ami                    = var.ami_id
  instance_type          = "t3.small"
  vpc_security_group_ids = [aws_security_group.api.id]
  subnet_id              = aws_subnet.private.id
  user_data              = file("./scripts/userdata.sh")
  tags = { Name = "api-${var.environment}" }
}

output "api_public_ip" {
  value = aws_instance.api.public_ip
}
```

### 4.2 Ansible — Configuration Management

**Conceptos core:**
- **Inventory:** lista de hosts (estática o dinámica)
- **Playbook:** lista de tareas en YAML
- **Task:** acción a ejecutar (módulo + parámetros)
- **Module:** unidad de acción (`apt`, `copy`, `service`, `docker_container`)
- **Role:** agrupación reutilizable con estructura estándar
- **Handler:** tarea que se ejecuta solo si otra cambió
- **Variables:** parametrización (vars, group_vars, host_vars)
- **Templates (Jinja2):** archivos con variables

**Inventario dinámico (AWS):**
```ini
# inventory/aws_ec2.yml
plugin: amazon.aws.aws_ec2
regions: [us-east-1]
filters:
  tag:Environment: production
  instance-state-name: running
keyed_groups:
  - key: tags.Role
```

**Playbook ejemplo:**
```yaml
---
- name: Configurar servidor API
  hosts: api
  become: true
  roles:
    - common
    - docker
    - api
```

**Role estructura:**
```
roles/api/
├── tasks/main.yml
├── handlers/main.yml
├── templates/
├── files/
├── vars/main.yml
├── defaults/main.yml
└── meta/main.yml
```

**Tarea ejemplo:**
```yaml
- name: Asegurar que el servicio api está corriendo
  community.docker.docker_container:
    name: api
    image: ghcr.io/equipo/api:{{ api_version }}
    state: started
    restart_policy: always
    ports: ["8000:8000"]
    env:
      DATABASE_URL: "{{ vault_db_url }}"
  notify: restart api
```

### 4.3 Terraform vs Ansible
| Aspecto | Terraform | Ansible |
|---------|-----------|---------|
| **Propósito** | Provisioning (crear/destruir infra) | Configuration (configurar lo creado) |
| **Estado** | Stateful (tfstate) | Stateless (idempotente por diseño) |
| **Lenguaje** | HCL (declarativo) | YAML + Jinja2 (declarativo) |
| **Agentes** | No requiere agentes | No requiere agentes (SSH) |
| **Cuándo** | Antes de que la infra exista | Después de provisionar |
| **Idempotencia** | Sí | Sí |
| **Se complementan** | ✅ Terraform crea → Ansible configura |

## 5. Herramientas

| Herramienta | Uso |
|-------------|-----|
| `tflint` / `tfsec` / `checkov` | Linting y seguridad para Terraform |
| `terraform-docs` | Genera docs de módulos |
| `pre-commit-terraform` | Hooks de calidad |
| `ansible-lint` | Linting de playbooks |
| `molecule` | Testing de roles Ansible |
| `infracost` | Estimación de costos desde el plan |
| `atlantis` | Terraform en PRs |

## 6. Proyecto 09 — Infraestructura Multi-Entorno con Terraform

**Duración estimada:** 18-24 horas
**Entregable:** Infra reproducible para dev/staging/prod, con módulos reutilizables, state remoto y Ansible integrado

### Pasos

1. **Módulos de Terraform reutilizables**
   ```
   terraform-modules/
   ├── vpc/
   │   ├── main.tf
   │   ├── variables.tf
   │   ├── outputs.tf
   │   └── README.md
   ├── ec2-asg/
   ├── rds/
   ├── eks/
   └── s3-cloudfront/
   ```
   Cada módulo con: variables tipadas, outputs descriptivos, `terraform-docs` auto-generado, ejemplos en `examples/`.

2. **Workspaces para dev/staging/prod**
   ```hcl
   # environments/prod/main.tf
   module "vpc" {
     source = "../../terraform-modules/vpc"
     cidr   = "10.10.0.0/16"
     env    = terraform.workspace
   }
   ```
   ```bash
   terraform workspace new dev
   terraform workspace new staging
   terraform workspace new prod
   terraform apply -var-file=envs/dev.tfvars
   ```

3. **Backend remoto con S3 + DynamoDB**
   - S3 bucket con versioning y cifrado
   - DynamoDB table con PK `LockID` para state locking
   - Evita corrupción de estado en trabajo en equipo
   - Setup inicial: `terraform init` crea el bucket y la tabla

4. **Ansible playbook para configurar las instancias**
   ```yaml
   # site.yml
   - hosts: api
    roles:
      - common
      - docker
      - api
   ```
   Roles:
   - `common` — paquetes base, timezone, NTP
   - `docker` — instalación, usuario en grupo docker
   - `api` — pull de imagen, systemd unit, log rotation
   - Variables cargadas desde AWS SSM Parameter Store (no en repo)

5. **Terraform Plan como paso en pipeline CI/CD**
   ```yaml
   - name: Terraform Plan
     run: |
       terraform init -backend-config=envs/dev.hcl
       terraform plan -var-file=envs/dev.tfvars -out=tfplan
   - name: Terraform Apply (manual approval)
     if: github.ref == 'refs/heads/main'
     uses: hashicorp/github-actions/terraform-actions@v1
     with:
       command: apply
       args: -auto-approve
   ```
   - Plan se publica como comentario en el PR
   - Apply solo en merge a main, con approval manual para prod
   - Infracost comenta estimación de costos en el PR

### Estructura entregable
```
09-terraform-ansible/
├── terraform/
│   ├── modules/
│   │   ├── vpc/
│   │   ├── ec2-asg/
│   │   ├── rds/
│   │   └── eks/
│   ├── environments/
│   │   ├── dev/
│   │   ├── staging/
│   │   └── prod/
│   └── README.md
├── ansible/
│   ├── ansible.cfg
│   ├── inventories/
│   │   └── aws_ec2.yml
│   ├── playbooks/
│   │   ├── site.yml
│   │   ├── deploy.yml
│   │   └── rollback.yml
│   ├── roles/
│   │   ├── common/
│   │   ├── docker/
│   │   └── api/
│   └── group_vars/
│       └── all.yml
└── .github/workflows/terraform.yml
```

## 7. Checklist de cierre del módulo

- [ ] Escribo módulos de Terraform reutilizables y tipados
- [ ] Uso workspaces o directorios separados para entornos
- [ ] Configuro backend remoto S3 + DynamoDB
- [ ] Ejecuto terraform plan antes de apply
- [ ] Tengo playbooks de Ansible idempotentes
- [ ] Integro terraform plan en el pipeline CI/CD
- [ ] Proyecto 09 entregado: puedo destruir y recrear toda la infra en < 15 min

## 8. Recursos recomendados

- **Terraform:** https://developer.hashicorp.com/terraform
- **Curso:** Terraform Up & Running (Yevgeniy Brikman, libro)
- **Ansible:** https://docs.ansible.com/
- **Curso:** Ansible for the Absolute Beginners (KodeKloud)
- **Práctica Terraform:** https://developer.hashicorp.com/terraform/tutorials
- **Práctica Ansible:** https://labs.ansible.com/
- **AWS + Terraform:** https://registry.terraform.io/providers/hashicorp/aws/latest/docs

## 9. Conexión con el hackathon

Con Terraform, el equipo puede recrear el entorno del hackathon desde cero en minutos. Si los jueces piden "muéstrame cómo lo desplegaron", la respuesta es: `terraform apply`. Para Copa Airlines — temas como edge computing se benefician de Terraform para provisionar infraestructura distribuida geográficamente (multi-región), lo que sería imposible de hacer a mano durante el evento.

## 10. Siguiente módulo

→ [Módulo 10 — Monitoreo y Logs](../10-monitoreo-logs/plan.md)
