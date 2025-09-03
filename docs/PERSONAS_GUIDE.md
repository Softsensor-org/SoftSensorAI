# 🎭 Complete Persona Guide

This guide explains each persona in detail with step-by-step tutorials and real-world examples.

## Table of Contents

- [Data Scientist Persona](#-data-scientist-persona)
- [Software Architect Persona](#️-software-architect-persona)
- [Software Developer Persona](#-software-developer-persona)
- [Product Manager Persona](#-product-manager-persona)
- [Designer Persona](#-designer-persona)

---

## 🧬 Data Scientist Persona

### Overview

The Data Scientist persona is optimized for ML/AI workflows with deep insights into GPU computing,
parallelization, and process management.

### Setup Instructions

#### Step 1: Initial Configuration

```bash
# Navigate to your ML project
cd ~/projects/ml/your-model

# Apply data scientist persona
dp persona add data-scientist

# OR use interactive menu
dp profile
# Select: 3) Data Scientist
```

#### Step 2: What Gets Installed

Your project now has:

```
your-ml-project/
├── scripts/
│   ├── gpu_monitor.sh          # Real-time GPU monitoring
│   ├── analyze_process_impact.sh # Process kill impact analyzer
│   └── parallel_optimizer.sh    # Parallelization helper
├── .claude/
│   ├── persona.json            # Data science configuration
│   └── commands/
│       └── data-science/
│           ├── gpu-optimize.md
│           ├── parallel-explain.md
│           └── process-impact.md
└── CLAUDE.md (updated)          # DS-specific instructions
```

### Key Features & Commands

#### 1. GPU Optimization Analysis

**Command**: `/gpu-optimize`

**Example Scenario**: You have a training loop that's running slowly.

```python
# Your code:
for batch in dataloader:
    output = model(batch.to(device))
    loss = criterion(output, labels)
    loss.backward()
```

**AI Assistant Response**:

```python
# Optimized version with explanations:

# Hardware Analysis:
# - Current: 15% GPU utilization (memory transfers bottleneck)
# - Target: 85% GPU utilization
# - Strategy: Overlapped data loading + mixed precision

# Enable mixed precision (2x memory, 3x speed)
scaler = torch.cuda.amp.GradScaler()

# Pin memory for faster transfers (25% improvement)
dataloader = DataLoader(
    dataset,
    batch_size=256,      # Increased from 32 (better GPU saturation)
    num_workers=4,       # Parallel data loading
    pin_memory=True,     # Direct CPU->GPU transfer
    persistent_workers=True  # Avoid worker restart overhead
)

# Optimized training loop
for batch_idx, (data, target) in enumerate(dataloader):
    # Async transfer while GPU computes previous batch
    data = data.to(device, non_blocking=True)
    target = target.to(device, non_blocking=True)

    with torch.cuda.amp.autocast():  # Mixed precision
        output = model(data)
        loss = criterion(output, target)

    # Scaled backward for mixed precision
    scaler.scale(loss).backward()
    scaler.step(optimizer)
    scaler.update()

# Performance Impact:
# - GPU Utilization: 15% → 85%
# - Training Speed: 3.2x faster
# - Memory Usage: 18GB → 12GB (mixed precision)
# - Power Draw: 250W → 350W (higher utilization)
```

#### 2. Process Impact Analysis

**Command**: `/process-impact` or `scripts/analyze_process_impact.sh <PID>`

**Real-world Example**: Your model has been training for 6 hours.

```bash
$ scripts/analyze_process_impact.sh 12345
```

**Output**:

```
Process Impact Analysis - PID: 12345 (python train.py)
═══════════════════════════════════════════════════════

Current State:
  Runtime: 6h 15m (estimated 8h total)
  Progress: Epoch 45/60 (75% complete)

Resources:
  CPU: 8 cores (400% usage)
  RAM: 48GB allocated
  GPU 0: 95% util, 22GB VRAM, 78°C
  GPU 1: 93% util, 22GB VRAM, 76°C

Checkpoints:
  Last saved: 8 minutes ago (epoch 44)
  Location: checkpoints/model_epoch_44.pt
  Size: 4.5GB

If Killed Now:
  ⚠️  Data Loss: 1 epoch (10 minutes compute)
  ⚠️  GPU hours wasted: 0.33 (2 GPUs × 10 min)
  ✓  Recovery possible from epoch 44
  ✓  Estimated recovery time: 12 minutes

Child Processes (will also terminate):
  - TensorBoard logger (PID: 12346)
  - 4 DataLoader workers (PIDs: 12347-12350)
  - GPU monitor (PID: 12351)

Distributed Training Impact:
  - This is rank 0 (master)
  - 3 worker nodes will detect failure in 30s
  - Total cluster waste: 1.32 GPU-hours

Recommendations:
  [W] Wait 15 min for epoch 46 checkpoint
  [G] Graceful shutdown (saves current state)
  [S] Suspend process (resumable later)
  [K] Kill immediately (accept data loss)
```

#### 3. Parallelization Deep Dive

**Command**: `/parallel-explain`

**Example**: Understanding your distributed training setup.

```python
# Your question: "Explain how my 4-GPU training works"
```

**AI Assistant Explanation**:

```
Parallelization Architecture for Your Training
═══════════════════════════════════════════════

Current Setup: 4× NVIDIA A100 GPUs

1. DATA PARALLELISM (Your Current Strategy)
   ┌─────────────────────────────────┐
   │     Batch Size: 256 samples      │
   └─────────────┬───────────────────┘
                 │ Split
    ┌────────────┼────────────┬────────────┐
    ▼            ▼            ▼            ▼
┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐
│ GPU 0   │ │ GPU 1   │ │ GPU 2   │ │ GPU 3   │
│ 64 samp │ │ 64 samp │ │ 64 samp │ │ 64 samp │
└────┬────┘ └────┬────┘ └────┬────┘ └────┬────┘
     │           │           │           │
     └───────────┴───────────┴───────────┘
                 │ AllReduce Gradients
                 ▼
           Model Update

Hardware Details:
- Each GPU: 2048 CUDA cores @ 1.4 GHz
- Memory bandwidth: 1.6 TB/s per GPU
- NVLink between GPUs: 600 GB/s
- PCIe to CPU: 64 GB/s

Communication Cost:
- Gradient size: 500MB (model parameters)
- AllReduce time: 500MB ÷ 600GB/s = 0.83ms
- Per iteration overhead: 0.83ms
- Scaling efficiency: 3.92x (98% of ideal 4x)

Alternative: MODEL PARALLELISM
(For models too large for single GPU)
┌──────────────────────────────────┐
│        175B Parameter Model       │
└──────────────────────────────────┘
                │ Split by layers
    ┌───────────┼───────────┬───────────┐
    ▼           ▼           ▼           ▼
┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐
│ GPU 0   │ │ GPU 1   │ │ GPU 2   │ │ GPU 3   │
│Layer 0-7│→│Layer 8-15│→│Layer16-23│→│Layer24-31│
└─────────┘ └─────────┘ └─────────┘ └─────────┘

Pipeline bubble time: 25% (less efficient than data parallel)
Use only when model doesn't fit in single GPU
```

### Real-World Workflows

#### Workflow 1: Optimizing Training Performance

```bash
# Step 1: Profile current performance
$ scripts/gpu_monitor.sh  # Run in separate terminal

# Step 2: In your AI assistant
/gpu-optimize analyze my training script

# Step 3: Apply optimizations
# AI provides specific code changes

# Step 4: Monitor improvements
$ nvidia-smi dmon -s pucvmet  # Detailed GPU metrics
```

#### Workflow 2: Managing Long-Running Experiments

```bash
# Before starting training
$ screen -S training  # Or tmux new -s training

# Start training with checkpoint strategy
$ python train.py --checkpoint-freq 10  # Every 10 epochs

# Monitor in another terminal
$ scripts/analyze_process_impact.sh $(pgrep -f train.py)

# Safe interruption if needed
$ kill -USR1 $(pgrep -f train.py)  # Trigger checkpoint
$ kill -TERM $(pgrep -f train.py)  # Graceful shutdown
```

#### Workflow 3: Distributed Training Management

```python
# Your AI assistant helps set up distributed training:

# 1. Environment setup (AI generates this)
export MASTER_ADDR=localhost
export MASTER_PORT=29500
export WORLD_SIZE=4
export CUDA_VISIBLE_DEVICES=0,1,2,3

# 2. Launch script (AI creates)
python -m torch.distributed.launch \
    --nproc_per_node=4 \
    --nnodes=1 \
    --node_rank=0 \
    train_distributed.py

# 3. Monitoring (AI explains)
# - Use scripts/gpu_monitor.sh for GPU status
# - Check scripts/analyze_process_impact.sh for kill impact
# - Monitor with tensorboard for training metrics
```

---

## 🏗️ Software Architect Persona

### Overview

Focused on system design, scalability, performance optimization, and architectural decisions.

### Setup Instructions

```bash
# Apply architect persona
dp persona add software-architect

# OR interactive
dp profile
# Select: 2) Software Architect
```

### Key Features

#### 1. Architecture Review

**Command**: `/architecture-review`

**Example**: Reviewing a microservices architecture.

**AI Response**:

```yaml
Architecture Analysis
═══════════════════

Current Architecture Pattern: Microservices
Scale: ~50K daily active users
Infrastructure: AWS EKS

Service Map:
┌─────────────┐     ┌──────────────┐
│   Frontend  │────▶│  API Gateway │
│  (Next.js)  │     │    (Kong)    │
└─────────────┘     └──────┬───────┘
                           │
        ┌──────────────────┼──────────────────┐
        ▼                  ▼                  ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│ Auth Service │  │ User Service │  │Payment Service│
│  (Node.js)   │  │   (Node.js)  │  │   (Java)     │
└──────┬───────┘  └──────┬───────┘  └──────┬───────┘
        │                 │                  │
        └────────────────┼──────────────────┘
                         ▼
                ┌─────────────────┐
                │   PostgreSQL    │
                │   (Primary)     │
                └────────┬────────┘
                         │
         ┌───────────────┼───────────────┐
         ▼               ▼               ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│  Read Rep 1  │ │  Read Rep 2  │ │Redis Cache   │
└──────────────┘ └──────────────┘ └──────────────┘

Identified Issues:
1. ❌ Single point of failure: API Gateway
2. ⚠️  Database coupling: All services share DB
3. ⚠️  No event streaming: Synchronous only
4. ❌ Missing service mesh: No observability

Recommendations:
1. Implement API Gateway HA (multi-instance)
2. Separate databases per service (CQRS pattern)
3. Add Kafka for async communication
4. Deploy Istio for service mesh

Scalability Analysis:
- Current: Handles 500 req/s
- Bottleneck: Database connections (100 max)
- Projected: Can scale to 2000 req/s with changes
- Cost impact: +40% infrastructure cost
```

#### 2. Performance Audit

**Command**: `/performance-audit`

**Example Output**:

```
Performance Bottlenecks Identified:
1. N+1 queries in User Service (345ms avg)
2. Missing database indexes (5 critical)
3. No HTTP caching headers
4. Synchronous payment processing (2.3s avg)
5. Large bundle size (2.4MB ungzipped)

Optimization Plan:
- Quick wins (1 day): Add indexes, HTTP cache
- Medium (1 week): Fix N+1, async payments
- Long-term (1 month): Redis cache layer, CDN
```

---

## 💻 Software Developer Persona

### Skill Progression

#### Beginner Level

- Detailed explanations for every action
- Safety checks before destructive operations
- Guided workflows with teaching

**Example**:

```bash
# AI explains each step
"Let me help you fix this bug. First, I'll write a test to reproduce it..."
"Now I'll implement the fix, explaining each change..."
"Finally, let's verify our fix works..."
```

#### Level 1 (L1)

- Focus on testing and code quality
- Linting and basic security checks
- Structured development patterns

#### Level 2 (L2)

- Advanced features unlocked
- Performance optimization tools
- Migration capabilities

#### Expert

- Full access to all tools
- Minimal hand-holding
- Architecture-level decisions

---

## 📊 Product Manager Persona

### Features

- Requirements documentation
- User story generation
- Roadmap planning
- Stakeholder communication templates

### Commands

- `/generate-prd` - Product requirement docs
- `/user-stories` - Create user stories from features
- `/acceptance-criteria` - Define test criteria
- `/release-notes` - Generate release documentation

---

## 🎨 Designer Persona

### Features

- UI/UX mockup generation
- Accessibility checking
- Design system documentation
- Component specifications

### Commands

- `/mock-screen` - Create UI mockups
- `/design-system` - Document design patterns
- `/accessibility-audit` - Check WCAG compliance
- `/component-spec` - Define component APIs

---

## Switching Between Personas

You can switch personas based on your current task:

```bash
# Morning: Architecture planning
dp persona add software-architect

# Afternoon: Coding implementation
dp persona add developer

# Evening: Training ML model
dp persona add data-scientist
```

## Customizing Personas

### Creating Your Own Persona

1. Create persona configuration:

```json
// profiles/personas/my-role.json
{
  "persona": "my-role",
  "display_name": "My Custom Role",
  "permissions": {
    "allow": ["..."],
    "block": ["..."]
  },
  "environment": {
    "CUSTOM_VAR": "value"
  }
}
```

2. Add specialized commands:

```bash
mkdir -p .claude/commands/sets/my-role
echo "Custom prompt" > .claude/commands/sets/my-role/my-command.md
```

3. Apply persona:

```bash
scripts/apply_persona.sh my-role
```

## Best Practices

### For Data Scientists

1. Always check process impact before killing
2. Use checkpoint strategies for long runs
3. Monitor GPU utilization continuously
4. Profile before optimizing

### For Architects

1. Document decisions in ADRs
2. Consider CAP theorem trade-offs
3. Plan for failure modes
4. Measure before optimizing

### For Developers

1. Write tests first
2. Use appropriate skill level
3. Follow project phase guidelines
4. Graduate when ready

## Troubleshooting

### Persona Not Applying

```bash
# Check current persona
cat .claude/persona.json

# Reapply
dp persona add [persona-name]
```

### Commands Not Available

```bash
# Verify command installation
ls .claude/commands/sets/

# Copy missing commands
cp -r ~/setup-scripts/.claude/commands/sets/[persona]/ .claude/commands/
```

### GPU Monitoring Not Working

```bash
# Check NVIDIA drivers
nvidia-smi

# Install monitoring tools
sudo apt-get install nvidia-utils-xxx  # Match your driver version
```
