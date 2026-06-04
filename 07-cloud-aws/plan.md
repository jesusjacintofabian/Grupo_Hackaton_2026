# Módulo 07 — Cloud Computing (AWS)

> **Categoría:** Infraestructura · **Prioridad:** Alta demanda · **Origen:** `devops-roadmap.html#s07`

## 1. Por qué importa

AWS domina el mercado cloud con más del 31% de cuota. Aprender sus servicios core te prepara para trabajar en la mayoría de las empresas tecnológicas. En el hackathon, el MVP se desplegará en AWS o Azure — los créditos educativos o free tier son la vía principal para empezar.

## 2. Objetivos de aprendizaje

- Diseñar arquitecturas seguras en AWS siguiendo Well-Architected Framework
- Operar cómputo (EC2), almacenamiento (S3) y redes (VPC)
- Configurar bases de datos gestionadas (RDS)
- Implementar monitoreo y alertas con CloudWatch

## 3. Prerrequisitos

- Módulos 01-06 completados
- Cuenta AWS con MFA habilitado (usar IAM user, no root)
- AWS CLI configurado (`aws configure`)
- Free tier o créditos educativos activos

## 4. Temas detallados

### 4.1 IAM — Identidad y Acceso
- **Lo primero a dominar.** Gestiona quién puede hacer qué.
- Usuarios, grupos, roles, políticas
- Principio de mínimo privilegio
- MFA obligatorio para root y usuarios privilegiados
- Roles para servicios (EC2 assume role, Lambda execution role)
- Políticas gestionadas vs inline
- AWS Organizations para multi-cuenta

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": ["s3:GetObject", "s3:PutObject"],
    "Resource": "arn:aws:s3:::mi-bucket/*"
  }]
}
```

### 4.2 EC2 — Cómputo
- Tipos de instancia (familias: t, m, c, r, x)
- AMIs (Amazon Machine Images)
- Security Groups (firewall a nivel instancia)
- Key pairs (SSH)
- User data (bootstrap scripts)
- Auto Scaling Groups + Launch Templates
- Spot, On-Demand, Reserved, Savings Plans
- Instance metadata service v2 (IMDSv2)

### 4.3 S3 — Almacenamiento de objetos
- Buckets con nombres únicos globales
- Versionado, lifecycle policies
- Clases de almacenamiento (Standard, IA, Glacier)
- Replicación cross-region
- Event notifications a Lambda/SQS
- Static website hosting
- CloudFront como CDN

### 4.4 VPC — Red Privada
- Subredes públicas y privadas
- Internet Gateway (IGW)
- NAT Gateway / NAT Instance
- Route Tables
- Network ACLs (stateless) vs Security Groups (stateful)
- VPN Site-to-Site y Direct Connect
- VPC Peering y Transit Gateway
- PrivateLink
- Flow Logs para troubleshooting

### 4.5 RDS — Bases de Datos
- Engines: MySQL, PostgreSQL, MariaDB, Oracle, SQL Server, Aurora
- Multi-AZ para alta disponibilidad
- Read Replicas para escalar lecturas
- Automated backups y point-in-time recovery
- Encryption at rest y in transit
- Parameter groups y option groups
- RDS Proxy para connection pooling

### 4.6 CloudWatch — Monitoreo
- Métricas (CPU, red, disco, custom)
- Logs centralizados de EC2, Lambda, ECS
- Alarmas con thresholds
- SNS para notificaciones
- CloudWatch Logs Insights (queries similares a SQL)
- Dashboards personalizables
- Anomaly detection (ML)

### 4.7 Servicios complementarios clave
| Servicio | Uso |
|----------|-----|
| Route 53 | DNS y dominios |
| CloudFront | CDN global |
| ELB (ALB/NLB) | Balanceo de carga |
| Lambda | Computación serverless |
| ECR | Registry de contenedores |
| EKS / ECS | Orquestación |
| Secrets Manager / SSM Parameter Store | Secretos |
| SQS / SNS | Colas y pub/sub |
| API Gateway | Endpoints HTTP |
| DynamoDB | NoSQL serverless |

## 5. Well-Architected Framework — 6 pilares

1. **Operational Excellence** — automatizar, monitorear, documentar
2. **Security** — mínimo privilegio, defensa en profundidad, cifrado
3. **Reliability** — recovery, redundancia, graceful degradation
4. **Performance Efficiency** — elegir recursos correctos, monitorear
5. **Cost Optimization** — right-sizing, reserved capacity, lifecycle
6. **Sustainability** — minimizar impacto ambiental (relevante para Copa)

## 6. Herramientas

| Herramienta | Uso |
|-------------|-----|
| AWS Console | GUI web |
| AWS CLI | Línea de comandos |
| AWS CDK / CloudFormation | IaC nativo AWS |
| Terraform | IaC multi-cloud |
| `aws-vault` | Manejo seguro de credenciales |
| `steampipe` | SQL sobre recursos AWS |
| `cloudsploit` | Escaneo de seguridad |

## 7. Proyecto 07 — Arquitectura 3-Tier en AWS

**Duración estimada:** 16-22 horas
**Entregable:** Web app accesible públicamente con arquitectura de 3 capas siguiendo Well-Architected

### Diagrama
```
                    Internet
                       │
                  ┌────▼─────┐
                  │ Route 53 │
                  └────┬─────┘
                       │
                  ┌────▼─────┐
                  │CloudFront│
                  └────┬─────┘
                       │
                  ┌────▼─────┐
                  │   ALB    │  (público, subred pública)
                  └────┬─────┘
                       │
            ┌──────────▼──────────┐
            │  EC2 Auto Scaling   │  (subred privada app)
            │  (Docker container) │
            └──────────┬──────────┘
                       │
            ┌──────────▼──────────┐
            │  RDS MySQL Multi-AZ │  (subred privada db)
            └─────────────────────┘

            S3 bucket para assets estáticos
            CloudWatch alarms + SNS
```

### Pasos

1. **VPC con subredes públicas y privadas en 2 AZs**
   - CIDR: 10.0.0.0/16
   - Subredes públicas: /20 en 2 AZs
   - Subredes privadas app: /20 en 2 AZs
   - Subredes privadas db: /20 en 2 AZs
   - IGW + NAT Gateway (en subred pública)
   - Route tables separadas

2. **EC2 Auto Scaling Group detrás de ALB**
   - Launch Template con AMI (Amazon Linux 2023)
   - User data que instala Docker y hace pull de la imagen del proyecto 05
   - Target Group con health check `/health`
   - Scaling policy: target tracking CPU 60%
   - Min 2, Max 6, Desired 2

3. **RDS MySQL Multi-AZ en subred privada**
   - DB Subnet Group con las 2 subredes privadas db
   - Instance class: db.t3.micro (free tier) o db.t4g.small
   - Storage: 20 GB gp3 con autoscaling
   - Backup window: 03:00-04:00 UTC
   - Encryption at rest habilitado
   - Security Group: solo ingress desde el SG de las EC2 de app en puerto 3306

4. **S3 + CloudFront para assets estáticos**
   - Bucket privado, acceso solo via OAI (Origin Access Identity)
   - CloudFront con origin en S3 y ALB
   - Cache policy para estáticos
   - HTTPS强制 redirect

5. **Alarmas CloudWatch**
   - ALB 5xx > 5 en 5 minutos → SNS topic → email
   - EC2 CPU > 80% sostenido 10 min
   - RDS CPU > 80% o connections > 80% del max
   - RDS storage < 5 GB free
   - Health check del target group unhealthy > 2 min

### Estructura entregable
```
07-cloud-aws/
├── README.md
├── architecture/
│   ├── diagram.png
│   └── README.md
├── cloudformation/             # o terraform/ (módulo 09)
│   ├── vpc.yaml
│   ├── iam.yaml
│   ├── compute.yaml
│   ├── database.yaml
│   └── monitoring.yaml
├── scripts/
│   ├── deploy.sh
│   ├── smoke-test.sh
│   └── teardown.sh             # importante: evita costos
└── cost-estimate.md
```

## 8. Checklist de cierre del módulo

- [ ] Configuro IAM con mínimo privilegio
- [ ] Diseño VPC con subredes públicas/privadas
- [ ] Despliego EC2 con ASG y ALB
- [ ] Configuro RDS Multi-AZ accesible solo desde app tier
- [ ] Sirvo estáticos desde S3 con CloudFront
- [ ] Alertas de CloudWatch configuradas y probadas
- [ ] Proyecto 07 desplegado, documentado y con script de teardown

## 9. Recursos recomendados

- **Docs:** https://docs.aws.amazon.com/
- **Curso:** AWS Cloud Practitioner Essentials (gratuito)
- **Curso:** AWS Solutions Architect Associate (Stephane Maarek, Udemy)
- **Labs:** https://wellarchitectedlabs.com/
- **Free tier:** https://aws.amazon.com/free/
- **Pricing calculator:** https://calculator.aws/
- **Whitepapers:** https://aws.amazon.com/whitepapers/

## 10. Consideraciones de costo

- **Free tier 12 meses:** t2.micro, 750h/mes de RDS db.t2.micro, 5 GB S3, 15 GB CloudFront
- **Siempre-always-free:** Lambda 1M requests/mes, DynamoDB 25 GB, SNS, CloudWatch
- **Configurar billing alarms** desde el día 1
- **Teardown automático** de recursos al final del proyecto (evita sorpresas)

## 11. Conexión con el hackathon

El MVP de Copa Airlines se desplegará idealmente en AWS (o Azure). La arquitectura 3-tier demuestra conocimiento de cloud, alta disponibilidad y seguridad — todos diferenciadores en la presentación. Los créditos de AWS Educate o GitHub Student Pack son la vía recomendada para el equipo.

## 12. Siguiente módulo

→ [Módulo 08 — Kubernetes](../08-kubernetes/plan.md)
