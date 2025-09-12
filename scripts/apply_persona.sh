#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only
# Apply persona-specific configurations
set -euo pipefail

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_SCRIPTS_DIR="$(dirname "$SCRIPT_DIR")"

# Function to apply data scientist persona
apply_data_scientist() {
  echo -e "${CYAN}Applying Data Scientist Persona...${NC}"

  # Copy persona config
  if [ -f "$SETUP_SCRIPTS_DIR/profiles/personas/data-scientist.json" ]; then
    mkdir -p .claude
    cp "$SETUP_SCRIPTS_DIR/profiles/personas/data-scientist.json" .claude/persona.json
  fi

  # Copy specialized commands
  if [ -d "$SETUP_SCRIPTS_DIR/.claude/commands/sets/data-science" ]; then
    mkdir -p .claude/commands
    cp -r "$SETUP_SCRIPTS_DIR/.claude/commands/sets/data-science" .claude/commands/
    echo -e "${GREEN}✓ Installed data science commands${NC}"
  fi

  # Create GPU monitoring script
  cat > scripts/gpu_monitor.sh <<'EOF'
#!/usr/bin/env bash
# Real-time GPU and process monitor for ML workloads

while true; do
  clear
  echo "╔══════════════════════════════════════════════════════╗"
  echo "║              GPU & Process Monitor                    ║"
  echo "╚══════════════════════════════════════════════════════╝"

  # GPU Status
  if command -v nvidia-smi >/dev/null 2>&1; then
    echo ""
    echo "GPU Status:"
    nvidia-smi --query-gpu=index,name,utilization.gpu,memory.used,memory.total,temperature.gpu,power.draw --format=csv,noheader,nounits | while IFS=',' read -r idx name util mem_used mem_total temp power; do
      echo "  GPU $idx: $name"
      echo "    Utilization: $util% | Memory: ${mem_used}MB/${mem_total}MB"
      echo "    Temperature: ${temp}°C | Power: ${power}W"
    done
  fi

  # Top Python processes
  echo ""
  echo "Top ML Processes:"
  ps aux | grep -E "python|jupyter|ipython" | grep -v grep | head -5 | while read -r line; do
    pid=$(echo "$line" | awk '{print $2}')
    cpu=$(echo "$line" | awk '{print $3}')
    mem=$(echo "$line" | awk '{print $4}')
    cmd=$(echo "$line" | awk '{for(i=11;i<=NF;i++) printf "%s ", $i; print ""}')
    echo "  PID $pid: CPU ${cpu}% | MEM ${mem}% | ${cmd:0:50}"
  done

  sleep 2
done
EOF
  chmod +x scripts/gpu_monitor.sh
  echo -e "${GREEN}✓ Created GPU monitoring script${NC}"

  # Create process impact analyzer
  cat > scripts/analyze_process_impact.sh <<'EOF'
#!/usr/bin/env bash
# Analyze impact of killing ML processes

PID=${1:-}
if [ -z "$PID" ]; then
  echo "Usage: $0 <PID>"
  exit 1
fi

echo "Analyzing process $PID..."
echo ""

# Get process info
if ! ps -p "$PID" > /dev/null; then
  echo "Process $PID not found"
  exit 1
fi

# Memory usage
echo "Memory Impact:"
ps -o pid,vsz,rss,comm -p "$PID" | tail -1 | while read p vsz rss comm; do
  echo "  Virtual: $((vsz/1024))MB | Resident: $((rss/1024))MB"
done

# GPU memory (if using)
if command -v nvidia-smi >/dev/null 2>&1; then
  gpu_mem=$(nvidia-smi --query-compute-apps=pid,used_memory --format=csv,noheader,nounits | grep "^$PID" | cut -d',' -f2)
  if [ -n "$gpu_mem" ]; then
    echo "  GPU Memory: ${gpu_mem}MB"
  fi
fi

# Child processes
echo ""
echo "Child Processes:"
pgrep -P "$PID" | while read child; do
  ps -o pid,comm -p "$child" | tail -1
done

# Open files
echo ""
echo "Open Files:"
lsof -p "$PID" 2>/dev/null | grep -E "\.h5|\.pkl|\.pt|\.ckpt|\.safetensors" | head -5

# Network connections
echo ""
echo "Network Connections:"
lsof -i -p "$PID" 2>/dev/null | tail -5

echo ""
echo "Kill Impact:"
echo "  - All child processes will be terminated"
echo "  - GPU memory will be freed immediately"
echo "  - Any unsaved model state will be lost"
echo "  - Distributed training peers will detect failure in ~30s"
EOF
  chmod +x scripts/analyze_process_impact.sh
  echo -e "${GREEN}✓ Created process impact analyzer${NC}"

  # Add to CLAUDE.md
  if [ -f "CLAUDE.md" ]; then
    cat >> CLAUDE.md <<'EOF'

## Data Science Persona Configuration

You are configured as a Data Scientist assistant with special capabilities:

### GPU Optimization
- Always explain GPU utilization changes (CUDA cores, memory bandwidth)
- Show parallelization strategies (data parallel vs model parallel)
- Provide memory impact analysis (GPU VRAM, system RAM)
- Explain process dependencies and kill impacts

### Available Tools
- `scripts/gpu_monitor.sh` - Real-time GPU and process monitoring
- `scripts/analyze_process_impact.sh <PID>` - Analyze impact of killing processes
- `/gpu-optimize` - GPU optimization with hardware explanations
- `/parallel-explain` - Deep parallelization explanations
- `/process-impact` - Process termination impact analysis

### When Optimizing Code
1. Explain changes at hardware level (cache, memory, compute units)
2. Provide before/after performance metrics
3. Show resource utilization changes
4. Document recovery strategies for interrupted processes
5. Explain distributed computing implications

### Process Management
- Always warn about data loss risks before suggesting process termination
- Provide checkpoint/recovery strategies
- Explain cascade effects on distributed training
- Show GPU memory and compute impact
EOF
    echo -e "${GREEN}✓ Updated CLAUDE.md with data science guidance${NC}"
  fi
}

# Function to apply software architect persona
apply_software_architect() {
  echo -e "${CYAN}Applying Software Architect Persona...${NC}"

  # Copy persona config
  if [ -f "$SETUP_SCRIPTS_DIR/profiles/personas/software-architect.json" ]; then
    mkdir -p .claude
    cp "$SETUP_SCRIPTS_DIR/profiles/personas/software-architect.json" .claude/persona.json
  fi

  # Create architecture analysis tools
  mkdir -p scripts

  cat > scripts/analyze_architecture.sh <<'EOF'
#!/usr/bin/env bash
# Analyze project architecture

echo "Project Architecture Analysis"
echo "=============================="
echo ""

# Detect project type
if [ -f "package.json" ]; then
  echo "Type: Node.js/JavaScript"
  echo "Dependencies:"
  jq -r '.dependencies | keys[]' package.json 2>/dev/null | head -10
fi

if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
  echo "Type: Python"
  echo "Dependencies:"
  [ -f "requirements.txt" ] && head -10 requirements.txt
fi

echo ""
echo "Directory Structure:"
find . -type d -name "node_modules" -prune -o -type d -name ".git" -prune -o -type d -print | head -20

echo ""
echo "Service Components:"
find . -name "*.service.*" -o -name "*service*.js" -o -name "*service*.py" 2>/dev/null | head -10

echo ""
echo "API Endpoints:"
grep -r "router\.\|app\.\|@app.route\|@router" --include="*.js" --include="*.py" --include="*.ts" 2>/dev/null | head -10

echo ""
echo "Database Models:"
find . -name "*model*" -o -name "*schema*" 2>/dev/null | grep -E "\.(js|py|ts)$" | head -10
EOF
  chmod +x scripts/analyze_architecture.sh
  echo -e "${GREEN}✓ Created architecture analyzer${NC}"

  # Add to CLAUDE.md
  if [ -f "CLAUDE.md" ]; then
    cat >> CLAUDE.md <<'EOF'

## Software Architect Persona Configuration

You are configured as a Software Architect assistant with focus on:

### System Design
- Explain architectural patterns and trade-offs
- Analyze scalability bottlenecks
- Document service boundaries and contracts
- Consider fault tolerance and resilience
- Evaluate technology choices with rationale

### Performance Analysis
- CPU cache utilization and branch prediction
- Memory allocation patterns and GC pressure
- Network latency and throughput constraints
- Database query plans and index strategies
- Horizontal vs vertical scaling implications

### Available Tools
- `scripts/analyze_architecture.sh` - Project architecture analysis
- Architecture review commands
- Performance audit tools
- Dependency analysis

### When Designing Systems
1. Document architectural decisions (ADRs)
2. Explain CAP theorem trade-offs
3. Provide scalability projections
4. Consider operational complexity
5. Plan for failure modes
EOF
    echo -e "${GREEN}✓ Updated CLAUDE.md with architect guidance${NC}"
  fi
}

# Main logic
PERSONA="${1:-}"

case "$PERSONA" in
  data-scientist|ds)
    apply_data_scientist
    ;;
  software-architect|architect|sa)
    apply_software_architect
    ;;
  *)
    echo "Usage: $0 [data-scientist|software-architect]"
    echo ""
    echo "Available personas:"
    echo "  data-scientist (ds)     - ML/AI workflows with GPU insights"
    echo "  software-architect (sa) - System design and architecture"
    exit 1
    ;;
esac

echo ""
echo -e "${GREEN}✓ Persona configuration complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. Review CLAUDE.md for persona-specific guidance"
echo "  2. Check scripts/ directory for new analysis tools"
echo "  3. Use specialized commands in your AI assistant"
