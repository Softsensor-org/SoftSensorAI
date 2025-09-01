# Architecture Spike

Rapid evaluation of technical approaches with production constraints.

## Input Required
- Constraints: latency, throughput, cost, team size
- SLOs: availability target, p95/p99 latency
- Scale: current load, 6-month projection

## Evaluation Framework

### Option A: Monolithic Enhancement
```yaml
complexity: LOW
risk: LOW  
time_to_market: 2 weeks
scalability_limit: 10K RPS
cost: $500/month
```

### Option B: Service Extraction  
```yaml
complexity: MEDIUM
risk: MEDIUM
time_to_market: 6 weeks
scalability_limit: 100K RPS
cost: $2000/month
```

### Option C: Event-Driven
```yaml
complexity: HIGH
risk: MEDIUM
time_to_market: 8 weeks
scalability_limit: 1M RPS
cost: $5000/month
```

## Decision Matrix
| Factor | Weight | A | B | C |
|--------|--------|---|---|---|
| TTM | 0.3 | 9 | 6 | 4 |
| Scale | 0.3 | 3 | 7 | 10 |
| Cost | 0.2 | 9 | 6 | 3 |
| Risk | 0.2 | 9 | 6 | 6 |
| **Score** | | **7.2** | **6.3** | **5.7** |

## Recommendation: Option A (iterate to B)

Start monolithic, extract when >5K RPS.

## Implementation Path
```bash
# Week 1: Prototype
git checkout -b spike/approach-a
# Core implementation

# Week 2: Load test
k6 run --vus 100 --duration 30s load-test.js

# Decision gate
hyperfine --runs 10 "curl -X POST localhost:8080/api/process"
```

## Rollback Strategy
- Feature flag: `ENABLE_NEW_ARCH=false`
- Database: Blue/green with fallback
- Traffic: Canary 1% → 10% → 50% → 100%

## Monitoring Requirements
```yaml
metrics:
  - request_duration_p99
  - error_rate
  - throughput
alerts:
  - p99 > 200ms
  - errors > 0.1%
  - throughput < SLO
```

Decision required by: EOW
