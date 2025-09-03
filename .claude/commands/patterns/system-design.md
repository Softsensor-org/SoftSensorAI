# Pattern: System Design

**Use-when:** designing new systems or major architectural changes **Inputs:** requirements,
constraints, scale targets **Success:** clear architecture with trade-offs documented

---

Context:

- OS: Linux (WSL/devcontainer). Node=LTS+pnpm. Python=.venv+pytest.
- Tools available: rg, jq, pnpm, pytest, docker, kubectl, helm, git, scripts/run_checks.sh.
- Repo rules: small atomic diffs, tests-first for new behavior, link Jira key in commits.

Operate with this loop:

1. PLAN → list acceptance checks + exact commands you'll run.
2. CODE → produce the smallest diff to satisfy PLAN; show unified diff.
3. VERIFY → run the commands; if anything fails, fix and re-run.
4. STOP with a brief next-steps list. Remove temp files you created.

---

Goal: Design a robust, scalable system architecture.

PLAN:

- Define functional requirements
- Identify non-functional requirements (performance, scale, reliability)
- Design high-level architecture
- Choose technology stack
- Define API contracts
- Plan data flow and storage
- Consider failure modes and recovery
- Document deployment strategy

OUTPUT:

- **Architecture Diagram** (text/ASCII art)
- **Component Breakdown** with responsibilities
- **Technology Choices** with rationale
- **API Specifications** (OpenAPI/GraphQL schema)
- **Data Models** and storage strategy
- **Scaling Strategy** (horizontal/vertical)
- **Security Considerations**
- **Trade-offs** explicitly stated
- **Migration Plan** if replacing existing system
- **Success Metrics** to validate design

Example response structure:

```
1. REQUIREMENTS ANALYSIS
   - Functional: [list]
   - Non-functional: [scale, latency, availability targets]

2. HIGH-LEVEL ARCHITECTURE
   [ASCII diagram or component list]

3. DETAILED DESIGN
   - Service A: [purpose, tech, APIs]
   - Service B: [purpose, tech, APIs]
   - Database: [type, schema, partitioning]

4. TRADE-OFFS
   - Chose X over Y because...
   - Accepting Z limitation for simplicity

5. IMPLEMENTATION ROADMAP
   - Phase 1: [MVP components]
   - Phase 2: [Scale additions]
   - Phase 3: [Optimizations]
```
