# 🤖 Codex Integration Guide

Complete integration of OpenAI Codex with the same level of support as Claude, including
persona-based configurations and sandboxed execution.

## Overview

Codex is fully integrated with:

- **Persona System** - Same personas work across Claude and Codex
- **Command Structure** - Unified command interface
- **Sandbox Execution** - Safe, isolated code execution
- **Repository-Specific** - Configurations per project
- **Multi-Model Support** - Works alongside Claude, Copilot, Cursor

## Quick Start

### 1. Basic Setup

```bash
# Add Codex configuration to your project
cd /your/project

# Copy Codex templates
cp ~/softsensorai/templates/CODEX.md .
cp -r ~/softsensorai/.codex .

# Apply personas (shared with Claude)
./scripts/persona_manager.sh add data-scientist
```

### 2. Using Codex Commands

Codex commands mirror Claude commands but with code generation focus:

```bash
# Generate ML pipeline
codex exec "/codex-ml-pipeline --type training --gpu"

# Generate system architecture
codex exec "/codex-system-design --type microservices"

# Refactor with optimization
codex exec "Optimize this function for GPU execution" < function.py
```

### 3. Sandbox Execution

All Codex-generated code runs in a secure sandbox:

```bash
# Run generated code safely
./scripts/codex_sandbox.sh

# The sandbox provides:
# - Network isolation
# - Memory/CPU limits
# - Read-only filesystem
# - Timeout protection
```

## Persona-Specific Features

### Data Scientist Persona

When data-scientist persona is active, Codex provides:

#### GPU-Optimized Code Generation

```python
# Codex automatically generates:
- CUDA kernels for custom operations
- Mixed precision training loops
- Distributed training setup
- Memory-efficient data loaders
- GPU profiling instrumentation
```

#### Commands Available

- `/codex-ml-pipeline` - Complete ML pipelines
- `/codex-gpu-optimize` - GPU optimization
- `/codex-distributed` - Distributed training setup
- `/codex-data-pipeline` - ETL pipelines

#### Example: Generate Distributed Training

```bash
codex exec "Generate distributed training for BERT on 4 GPUs"

# Codex generates:
# - DDP setup with proper initialization
# - Gradient accumulation for large batches
# - Mixed precision with AMP
# - Checkpoint management
# - TensorBoard integration
```

### Software Architect Persona

When architect persona is active:

#### System Design Generation

```yaml
# Codex generates complete:
- Microservice architectures
- API specifications (OpenAPI)
- Database schemas
- Infrastructure as Code
- CI/CD pipelines
- Monitoring setup
```

#### Commands Available

- `/codex-system-design` - Full system architecture
- `/codex-api-design` - RESTful/GraphQL APIs
- `/codex-database-schema` - Optimized schemas
- `/codex-infrastructure` - IaC generation

#### Example: Generate Microservices

```bash
codex exec "/codex-system-design --type microservices --scale large"

# Generates:
# - Service definitions
# - Docker configurations
# - Kubernetes manifests
# - API Gateway setup
# - Service mesh configuration
# - Monitoring stack
```

### Backend Developer Persona

#### API Generation

```python
# Codex generates production-ready:
- FastAPI/Flask/Express endpoints
- Input validation
- Error handling
- Authentication/Authorization
- Database operations
- Caching logic
- Rate limiting
```

#### Commands

- `/codex-api-crud` - CRUD operations
- `/codex-auth-system` - Authentication setup
- `/codex-database-ops` - Optimized queries
- `/codex-test-suite` - Comprehensive tests

## Configuration Files

### `.codex/settings.json`

```json
{
  "version": "1.0.0",
  "model": "code-davinci-002",
  "temperature": 0.2,
  "execution": {
    "mode": "sandbox",
    "timeout": 30000,
    "memory_limit": "512M"
  },
  "personas": {
    "enabled": true,
    "sync_with_claude": true
  }
}
```

### `CODEX.md`

Repository-specific instructions for Codex:

```markdown
# Codex Configuration

## Active Personas

- data-scientist
- backend-developer

## Code Generation Rules

1. Match existing patterns
2. Use established libraries
3. Include comprehensive tests
4. Add error handling
5. Document complex logic
```

## Sandbox Execution

### Security Features

The sandbox provides multiple layers of security:

```bash
# Network isolation
--network none

# Capability dropping
--cap-drop ALL

# Read-only filesystem
--read-only

# Memory limits
--memory="512m"

# CPU limits
--cpus="1"

# Timeout protection
timeout 30s
```

### Running Generated Code

```bash
# Interactive mode
./scripts/codex_sandbox.sh
# Paste code and Ctrl+D

# File execution
./scripts/codex_sandbox.sh run generated.py

# With custom limits
CODEX_MEMORY_LIMIT=1g CODEX_TIMEOUT=60 ./scripts/codex_sandbox.sh run script.py
```

## Integration with Other Tools

### Claude Integration

Codex shares personas and configurations with Claude:

```bash
# Personas work across both
./scripts/persona_manager.sh add data-scientist

# Both Claude and Codex now have:
# - Same permissions
# - Same focus areas
# - Complementary commands
```

### GitHub Copilot

Codex works alongside Copilot:

```json
{
  "integration": {
    "copilot": {
      "enabled": true,
      "priority": "codex_first"
    }
  }
}
```

### Cursor

Unified command interface:

```bash
# Same commands work in Cursor
/codex-ml-pipeline
/codex-system-design
```

## Multi-Persona Combinations

### ML Engineering Mode

Combines Data Scientist + Backend + DevOps:

```bash
./scripts/persona_manager.sh switch
# Select: 5) ML Engineering Mode

# Codex now generates:
# - ML pipelines (DS)
# - API endpoints (Backend)
# - Deployment configs (DevOps)
```

### Full Stack Mode

Frontend + Backend:

```bash
# Codex generates:
# - React/Vue components
# - API endpoints
# - Database schemas
# - Integration tests
```

## Best Practices

### 1. Start with Sandbox

Always test generated code in sandbox first:

```bash
# Generate
codex exec "complex algorithm" > algorithm.py

# Test safely
./scripts/codex_sandbox.sh run algorithm.py

# Then use in production
```

### 2. Use Appropriate Personas

Switch personas based on task:

```bash
# For ML work
./scripts/persona_manager.sh add data-scientist

# For system design
./scripts/persona_manager.sh add software-architect
```

### 3. Review Generated Code

Codex generates good code, but always review:

- Security implications
- Performance characteristics
- Error handling
- Edge cases

### 4. Combine with Claude

Use both for best results:

```bash
# Codex for generation
codex exec "Generate API endpoint"

# Claude for review
claude "/security-review"
```

## Troubleshooting

### API Key Issues

```bash
# Check if key is set
echo $OPENAI_API_KEY

# Export if needed
export OPENAI_API_KEY="sk-..."
```

### Sandbox Issues

```bash
# Check Docker
docker --version
docker info

# Test sandbox
./scripts/codex_sandbox.sh test
```

### Persona Sync Issues

```bash
# Verify personas
cat .claude/personas/active.json

# Check Codex config
cat .codex/settings.json

# Resync
./scripts/persona_manager.sh show
```

## Advanced Features

### Custom Code Generation

Create custom generation templates:

```bash
# Create template
cat > .codex/templates/my-pattern.md <<EOF
Generate a [PATTERN] that:
- Uses async/await
- Handles errors gracefully
- Includes logging
- Has comprehensive tests
EOF

# Use template
codex exec --template my-pattern "user authentication"
```

### Batch Processing

Generate multiple components:

```bash
# Generate all CRUD operations
for entity in user product order; do
  codex exec "/codex-api-crud --entity $entity" > "api_${entity}.py"
done
```

### CI/CD Integration

Add to GitHub Actions:

```yaml
- name: Generate Code
  run: |
    codex exec "${{ github.event.inputs.prompt }}" > generated.py
    ./scripts/codex_sandbox.sh run generated.py
```

## Summary

Codex is now fully integrated with:

- ✅ Same persona system as Claude
- ✅ Repository-specific configurations
- ✅ Secure sandbox execution
- ✅ Persona-based commands
- ✅ Multi-model support
- ✅ Safety features

Use Codex for code generation, Claude for review and analysis, achieving the best of both worlds!
