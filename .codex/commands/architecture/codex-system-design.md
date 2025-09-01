# Codex System Design Generator

Generate complete system architectures with implementation code.

## Usage
```
/codex-system-design --type [microservices|serverless|monolith] --scale [small|medium|large]
```

## What Codex Generates

### 1. Architecture Blueprint
```yaml
# Complete architecture specification:
- Service definitions
- API contracts
- Database schemas
- Message queue setup
- Cache layers
- Load balancing
- Service mesh configuration
```

### 2. Implementation Code

#### Microservices Example
```python
# Codex generates for each service:

# Service bootstrap
from fastapi import FastAPI
from prometheus_client import Counter, Histogram
import asyncio
import aioredis

class UserService:
    def __init__(self):
        self.app = FastAPI(title="User Service")
        self.redis = None
        self.metrics = self._setup_metrics()
        self._setup_routes()
        self._setup_middleware()

    def _setup_metrics(self):
        return {
            'requests': Counter('requests_total', 'Total requests'),
            'latency': Histogram('request_latency', 'Request latency')
        }

    async def startup(self):
        self.redis = await aioredis.create_redis_pool('redis://cache')
        await self._register_service_discovery()

    # Auto-generated CRUD operations
    async def create_user(self, user_data):
        # Validation
        # Database transaction
        # Cache invalidation
        # Event publishing
        # Metric recording
        pass
```

### 3. Infrastructure as Code
```terraform
# Codex generates Terraform/K8s configs:

resource "kubernetes_deployment" "user_service" {
  metadata {
    name = "user-service"
  }
  spec {
    replicas = var.replicas
    selector {
      match_labels = {
        app = "user-service"
      }
    }
    template {
      spec {
        container {
          image = "user-service:${var.version}"
          resources {
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }
          # Health checks, env vars, volumes
        }
      }
    }
  }
}
```

### 4. API Gateway Configuration
```yaml
# Generated Kong/Istio configuration:
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: user-service
spec:
  http:
  - match:
    - uri:
        prefix: /api/users
    route:
    - destination:
        host: user-service
      weight: 100
    timeout: 30s
    retries:
      attempts: 3
      perTryTimeout: 10s
```

### 5. Database Migrations
```sql
-- Codex generates versioned migrations:
-- Version: 001_create_users.sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_created_at ON users(created_at);
```

### 6. Monitoring & Observability
```python
# Generated monitoring setup:
from opentelemetry import trace
from opentelemetry.exporter.jaeger import JaegerExporter

class Monitoring:
    def __init__(self):
        self.tracer = trace.get_tracer(__name__)
        self.setup_exporters()

    @contextmanager
    def trace_operation(self, name):
        with self.tracer.start_as_current_span(name) as span:
            span.set_attribute("service.name", self.service_name)
            yield span
```

## Architecture Patterns

Codex implements best practices:
- Circuit breakers
- Retry logic with exponential backoff
- Rate limiting
- Bulkhead isolation
- Health checks
- Graceful degradation

## Scalability Features

Generated code includes:
- Horizontal scaling support
- Database connection pooling
- Caching strategies
- Async/await patterns
- Event-driven architecture
- CQRS where appropriate

## Security Built-in

- Authentication/Authorization
- Input validation
- SQL injection prevention
- Rate limiting
- CORS configuration
- Secrets management

## Testing Infrastructure

Codex also generates:
```python
# Integration tests
async def test_user_service():
    async with TestClient(app) as client:
        response = await client.post("/users", json={...})
        assert response.status_code == 201

# Load tests
from locust import HttpUser, task

class UserLoadTest(HttpUser):
    @task
    def create_user(self):
        self.client.post("/users", json={...})
```

## Deployment Scripts

Complete CI/CD pipeline:
```yaml
# GitHub Actions / GitLab CI
name: Deploy
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Build and push Docker image
      - name: Deploy to Kubernetes
      - name: Run smoke tests
```
