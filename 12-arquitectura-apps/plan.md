# Módulo 12 — Arquitectura de Aplicaciones

> **Categoría:** Diseño de Sistemas · **Prioridad:** Estratégico · **Origen:** `devops-roadmap.html#s12`

## 1. Por qué importa

Un DevOps que entiende arquitectura puede tomar mejores decisiones de infraestructura. La forma de la aplicación define cómo debe desplegarse. En hackathon, elegir la arquitectura correcta para el MVP puede ser la diferencia entre terminar a tiempo o no.

## 2. Objetivos de aprendizaje

- Comparar monolitos vs microservicios con criterio
- Diseñar APIs REST y elegir estilo de comunicación
- Implementar service mesh y API Gateway
- Aplicar patrones de descomposición (Strangler Fig, Bounded Contexts)

## 3. Prerrequisitos

- Módulos 01-11 completados
- Al menos un monolito simple construido en módulos previos
- Cluster K8s operativo (módulo 08)

## 4. Temas detallados

### 4.1 Estilos arquitectónicos

**Monolito**
- Toda la aplicación en un solo proceso
- Simple de desarrollar y desplegar al inicio
- Se vuelve complejo cuando el equipo crece
- Despliegues lentos y riesgo concentrado
- **No siempre es la solución incorrecta** — para MVPs y equipos pequeños es óptimo

**Microservicios**
- Servicios pequeños, independientes y especializados
- Equipos autónomos, escalado por servicio
- Deployments independientes
- Mayor complejidad operacional: requiere Kubernetes, service mesh y observabilidad sofisticada

**Serverless**
- Funciones como unidad de deploy (Lambda, Cloud Functions)
- Escala automática, pago por uso
- Cold start, timeouts, vendor lock-in
- Ideal para: APIs intermitentes, procesamiento de eventos, webhooks

**Modular Monolith**
- Monolito con módulos bien definidos internamente
- Migrable a microservicios si es necesario
- Balance entre simplicidad del monolito y límites del microservicio

### 4.2 APIs y comunicación

**REST**
- Estándar para APIs síncronas
- Stateless, basado en HTTP
- Versionado: `/v1/`, `/v2/`
- OpenAPI/Swagger para documentación

**GraphQL**
- Permite consultas flexibles
- Single endpoint, cliente decide qué datos traer
- N+1 query problem, cacheo complejo

**gRPC**
- Binario, basado en HTTP/2
- Streaming bidireccional
- Excelente para comunicación interna entre microservicios
- Schema en .proto, generación de código

**Mensajería asíncrona**
- **RabbitMQ** — colas de mensajes, ideal para tareas
- **Apache Kafka** — event streaming, alto throughput
- **Amazon SQS / SNS** — serverless, simple
- **NATS** — ligero, cloud-native
- Patrones: pub/sub, event sourcing, CQRS

### 4.3 Service Mesh
- **Istio** — más features, más complejo
- **Linkerd** — más simple, ultraligero
- **Cilium** — eBPF-based, moderno
- Funciones: mTLS automático, traffic shifting, retry, circuit breaker, observabilidad sin tocar código

### 4.4 API Gateway
- **Kong** — Open source, plugins
- **nginx** — clásico, simple
- **Traefik** — cloud-native, auto-discovery
- **AWS API Gateway** — serverless, integración AWS
- **Kusk Gateway** — OpenAPI-driven
- Funciones: routing, auth, rate limiting, caching, transformations

### 4.5 Patrones de migración
- **Strangler Fig Pattern** — reemplazo gradual: el gateway enruta partes al nuevo servicio
- **Bounded Contexts** (DDD) — identificar límites del negocio
- **Anti-Corruption Layer** — traducir entre legacy y nuevo
- **Branch by Abststraction** — abstraer detrás de interfaz
- **Parallel Run** — viejo y nuevo corren juntos por un tiempo

### 4.6 Patrones de resiliencia
- **Circuit Breaker** — corta llamadas a servicio caído
- **Bulkhead** — aísla fallos por recurso
- **Retry with exponential backoff**
- **Timeout y deadline propagation**
- **Health checks** (liveness + readiness)
- **Graceful shutdown**

## 5. Herramientas

| Categoría | Herramientas |
|-----------|--------------|
| API REST | FastAPI, Express, Spring, Gin |
| GraphQL | Apollo, Hasura, Graphene |
| gRPC | grpc-python, grpc-go |
| Mensajería | RabbitMQ, Kafka, NATS, Redis Streams |
| Service Mesh | Istio, Linkerd, Cilium |
| API Gateway | Kong, Traefik, nginx, Envoy |
| Documentación | OpenAPI, Redoc, Swagger UI |
| Diseño | draw.io, Mermaid, C4 model |

## 6. Proyecto 12 — Migración Monolito a Microservicios

**Duración estimada:** 22-30 horas
**Entregable:** Monolito original + 3 microservicios extraídos comunicándose vía API Gateway y eventos

### Punto de partida
Usar el monolito del proyecto 05 (Nginx + API + MySQL). Si se prefiere, se puede partir de un monolito de referencia (e.g., https://github.com/microservices-demo/microservices-demo).

### Bounded contexts identificados
1. **auth** — autenticación y autorización
2. **users** — gestión de usuarios y perfiles
3. **orders** — pedidos (o el dominio del MVP del hackathon)

### Arquitectura objetivo
```
              Internet
                 │
            ┌────▼────┐
            │ API GW  │  (Kong/nginx)
            └────┬────┘
                 │
   ┌─────────────┼─────────────┐
   │             │             │
┌──▼──┐      ┌──▼──┐      ┌──▼──┐
│auth │      │users│      │orders│
│ svc │      │ svc │      │ svc │
└──┬──┘      └──┬──┘      └──┬──┘
   │             │             │
┌──▼──┐      ┌──▼──┐      ┌──▼──┐
│ DB  │      │ DB  │      │ DB  │
└─────┘      └─────┘      └─────┘
                 │
            ┌────▼─────┐
            │ RabbitMQ │  (eventos async)
            └──────────┘
```

### Pasos

1. **Analizar el monolito e identificar 3 bounded contexts**
   - Mapa de dominio (Mermaid o C4)
   - Eventos de dominio definidos
   - Contratos de API pública

2. **Extraer el servicio de auth como microservicio con su propia DB**
   - Nuevo repositorio `auth-svc`
   - Base de datos independiente (no compartir schema)
   - JWT firmado con clave compartida (JWKS endpoint)
   - Endpoints: `/register`, `/login`, `/refresh`, `/verify`
   - Migración de usuarios del monolito a la nueva DB (script de migración)

3. **Comunicación asíncrona con RabbitMQ para eventos de dominio**
   ```python
   # Productor
   import pika
   connection = pika.BlockingConnection(pika.ConnectionParameters('rabbitmq'))
   channel = connection.channel()
   channel.exchange_declare(exchange='events', exchange_type='topic')
   channel.basic_publish(
       exchange='events',
       routing_key='order.created',
       body=json.dumps({"order_id": 123, "user_id": 456, "total": 99.99})
   )
   ```
   ```python
   # Consumidor
   def callback(ch, method, properties, body):
       event = json.loads(body)
       if method.routing_key == 'order.created':
           send_confirmation_email(event['user_id'], event['order_id'])
   channel.basic_consume(queue='email-service', on_message_callback=callback, auto_ack=False)
   ```
   - Eventos: `order.created`, `order.shipped`, `user.registered`
   - Outbox pattern para garantizar entrega

4. **Deployments independientes con su propio pipeline CI/CD**
   - Repo por servicio
   - Mismo workflow del módulo 06
   - Versionado semántico independiente
   - Deploy puede ocurrir en cualquier momento sin coordinar

5. **API Gateway (Kong o nginx) como punto de entrada único**
   ```nginx
   # nginx.conf
   upstream auth_svc   { server auth-svc:8000; }
   upstream users_svc  { server users-svc:8000; }
   upstream orders_svc { server orders-svc:8000; }

   server {
     location /api/auth   { proxy_pass http://auth_svc; }
     location /api/users  { proxy_pass http://users_svc; }
     location /api/orders { proxy_pass http://orders_svc; }
   }
   ```
   - Routing por path prefix
   - Autenticación centralizada (valida JWT antes de pasar al servicio)
   - Rate limiting
   - Logging centralizado

### Estructura entregable
```
12-arquitectura-apps/
├── README.md
├── architecture/
│   ├── c4-context.png
│   ├── c4-containers.png
│   ├── bounded-contexts.md
│   └── sequence-diagrams/
├── services/
│   ├── auth-svc/
│   ├── users-svc/
│   └── orders-svc/
├── gateway/
│   ├── nginx.conf
│   └── kong.yml
├── messaging/
│   ├── rabbitmq-definitions.json
│   └── events-contract.md
├── monolith/                # el legacy que se está reemplazando
│   └── legacy-monolith/
├── docs/
│   ├── migration-strategy.md
│   └── strangler-fig-progress.md
└── scripts/
    ├── migrate-users.py
    └── smoke-test-all.sh
```

## 7. Checklist de cierre del módulo

- [ ] Identifiqué bounded contexts con criterio
- [ ] Auth-svc extraído con su propia DB
- [ ] RabbitMQ (o Kafka) comunica eventos entre servicios
- [ ] Cada servicio tiene pipeline CI/CD independiente
- [ ] API Gateway enruta y autentica centralizadamente
- [ ] Strangler fig documentado: qué % migrado
- [ ] Proyecto 12 entregado: el monolito es opcional, los microservicios lo reemplazan

## 8. Recursos recomendados

- **Libro:** "Building Microservices" — Sam Newman (2nd ed.)
- **Libro:** "Designing Data-Intensive Applications" — Martin Kleppmann
- **Curso:** Software Architecture (Codecademy, Educative)
- **System Design:** https://github.com/donnemartin/system-design-primer
- **C4 model:** https://c4model.com/
- **Patterns:** https://microservices.io/patterns/index.html
- **Practice:** https://github.com/EventStore/EventStore (event sourcing)

## 9. Conexión con el hackathon

La elección arquitectónica impacta directamente en el alcance del MVP. Para un hackathon de 24-48 horas, un monolito modular bien diseñado es usualmente más práctico que microservicios prematuros. Sin embargo, si el tema del hackathon es **edge computing, gemelos digitales o blockchain**, los microservicios pueden ser necesarios para cumplir requisitos de distribución o event sourcing.

**Recomendación:** empezar con monolito modular, extraer servicios solo si hay tiempo o si la naturaleza del problema lo exige.

## 10. Siguiente módulo

→ [Módulo 13 — Site Reliability Engineering](../13-sre/plan.md)
