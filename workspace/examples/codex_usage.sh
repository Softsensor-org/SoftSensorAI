#!/usr/bin/env bash
# Example usage of Codex with persona-based configurations

set -euo pipefail

echo "==================================="
echo "Codex Integration Usage Examples"
echo "==================================="
echo

# Check for API key
if [ -z "${OPENAI_API_KEY:-}" ]; then
    echo "❌ OPENAI_API_KEY not set. Codex requires an OpenAI API key."
    echo "   Export it with: export OPENAI_API_KEY='your-key-here'"
    exit 1
fi

echo "✅ OpenAI API key detected"
echo

# Function to show command and pause
show_example() {
    local description="$1"
    local command="$2"

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📝 $description"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Command: $command"
    echo
    read -p "Press Enter to run this example (or Ctrl+C to skip)..."
    echo
    eval "$command"
    echo
}

# 1. Basic Codex Setup
show_example "Setting up Codex in a new project" \
    "echo 'cp ~/devpilot/templates/CODEX.md .' && echo 'cp -r ~/devpilot/.codex .'"

# 2. Activate Data Scientist Persona
show_example "Activating Data Scientist persona for ML work" \
    "./scripts/persona_manager.sh add data-scientist 2>/dev/null || echo '[Simulated] Data Scientist persona activated'"

# 3. Generate ML Pipeline
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 Generate GPU-optimized ML pipeline"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cat << 'EOF'
Command: codex exec "/codex-ml-pipeline --type training --gpu"

Expected output:
- Optimized data loaders with GPU memory pinning
- Mixed precision training setup
- Distributed training configuration
- GPU utilization monitoring
- Automatic checkpoint management
EOF
echo
read -p "Press Enter to continue..."
echo

# 4. Activate Software Architect Persona
show_example "Switching to Software Architect persona" \
    "./scripts/persona_manager.sh add software-architect 2>/dev/null || echo '[Simulated] Software Architect persona activated'"

# 5. Generate System Architecture
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 Generate microservices architecture"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cat << 'EOF'
Command: codex exec "/codex-system-design --type microservices --scale medium"

Expected output:
- Service definitions and boundaries
- API contracts (OpenAPI specs)
- Database schemas
- Kubernetes manifests
- Monitoring setup
- CI/CD pipelines
EOF
echo
read -p "Press Enter to continue..."
echo

# 6. Multi-Persona Mode
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 Combining multiple personas"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cat << 'EOF'
# ML Engineering Mode (Data Scientist + Backend + DevOps)
./scripts/persona_manager.sh switch
# Select option 5: ML Engineering Mode

This combines:
- GPU optimization from Data Scientist
- API design from Backend Developer
- Deployment from DevOps Engineer

Example command:
codex exec "Create a complete ML serving API with GPU inference"

Codex will generate:
- Optimized inference pipeline
- FastAPI endpoints
- Docker configuration with CUDA
- Kubernetes deployment with GPU nodes
- Monitoring and scaling setup
EOF
echo
read -p "Press Enter to continue..."
echo

# 7. Sandbox Execution
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 Running generated code in sandbox"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cat << 'EOF'
# Generate code
codex exec "Simple FastAPI health check endpoint" > api.py

# Run in sandbox (network isolated, read-only filesystem)
./scripts/codex_sandbox.sh run api.py

The sandbox provides:
- Network isolation (no external access)
- Read-only filesystem
- Memory/CPU limits
- Timeout protection
- No privilege escalation
EOF
echo
read -p "Press Enter to continue..."
echo

# 8. Integration with Claude
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 Using Codex with Claude"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cat << 'EOF'
Personas are shared between Claude and Codex:

1. Generate with Codex:
   codex exec "Create user authentication system"

2. Review with Claude:
   claude "/security-review auth_system.py"

3. Both tools share:
   - Same personas and permissions
   - Unified command structure
   - Repository context
   - Safety restrictions
EOF
echo
read -p "Press Enter to continue..."
echo

# 9. Checking Active Configuration
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 Viewing current configuration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Active personas:"
if [ -f ".claude/personas/active.json" ]; then
    cat .claude/personas/active.json 2>/dev/null | grep '"name"' | cut -d'"' -f4 || echo "  (none active)"
else
    echo "  (no personas configured)"
fi
echo
echo "Codex settings:"
if [ -f ".codex/settings.json" ]; then
    echo "  Model: $(grep '"model"' .codex/settings.json | cut -d'"' -f4)"
    echo "  Execution mode: $(grep '"mode"' .codex/settings.json | cut -d'"' -f4)"
else
    echo "  (using defaults)"
fi
echo

# 10. Quick Reference
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📚 Quick Reference"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cat << 'EOF'
Common Commands:

Data Science:
  /codex-ml-pipeline      - Generate ML training pipelines
  /codex-gpu-optimize     - Optimize code for GPU execution
  /codex-distributed      - Setup distributed training
  /codex-data-pipeline    - Create ETL pipelines

Architecture:
  /codex-system-design    - Design system architecture
  /codex-api-design       - Create API specifications
  /codex-database-schema  - Design database schemas
  /codex-infrastructure   - Generate IaC (Terraform/K8s)

Backend:
  /codex-api-crud         - Generate CRUD operations
  /codex-auth-system      - Create authentication
  /codex-test-suite       - Generate comprehensive tests

General:
  /codex-generate         - General code generation
  /codex-refactor         - Refactor with safety checks
  /codex-optimize         - Performance optimization
  /codex-review           - Code review

Persona Management:
  ./scripts/persona_manager.sh add [persona]     - Add persona
  ./scripts/persona_manager.sh remove [persona]  - Remove persona
  ./scripts/persona_manager.sh switch            - Interactive switch
  ./scripts/persona_manager.sh show              - Show active personas

EOF

echo "==================================="
echo "✅ Codex usage examples complete!"
echo "==================================="
