# Process Impact Analyzer

Analyzes the impact of killing or modifying running processes, especially for long-running data science workloads.

## Usage
```
/process-impact [PID or process name] [--action kill|pause|resume|modify]
```

## Core Analysis

### 1. Process Tree Visualization
```
Training Process (PID: 5000) - 45% complete
├── Memory: 32GB RAM, 18GB GPU VRAM
├── CPU: 8 cores (400% usage)
├── GPU: 2x NVIDIA A100 (95% utilization)
├── Runtime: 4h 23m (estimated 5h 30m remaining)
├── Checkpoints: Last saved 12 minutes ago (epoch 18/40)
│
├── Child Processes:
│   ├── DataLoader (PID: 5001-5004)
│   │   ├── Memory: 2GB each
│   │   ├── CPU: 100% each
│   │   └── Queue: 1000 batches prefetched
│   │
│   ├── TensorBoard (PID: 5010)
│   │   ├── Memory: 500MB
│   │   ├── Logs: 2.3GB written
│   │   └── Port: 6006
│   │
│   └── GPU Monitor (PID: 5011)
│       ├── Memory: 100MB
│       └── Metrics: GPU temp, power, memory
│
├── Network Connections:
│   ├── Parameter Server: 192.168.1.100:9999
│   ├── Data Server: 192.168.1.101:8888
│   └── Monitoring: localhost:6006
│
└── File Handles:
    ├── Dataset: /data/imagenet (READ, 1.2TB)
    ├── Checkpoint: /models/checkpoint.pt (WRITE, 5GB)
    ├── Logs: /logs/train.log (APPEND, 500MB)
    └── Temp: /tmp/cuda_* (12 files, 8GB total)
```

### 2. Kill Impact Analysis

#### Immediate Effects
```yaml
If you kill PID 5000 now:

Data Loss:
  - Training Progress: 2 epochs (45 minutes of compute)
  - Unsaved Metrics: 12 minutes worth
  - In-memory Gradients: Will be lost
  - Current Batch: 256 samples being processed

Resource Liberation:
  - RAM: 32GB freed immediately
  - GPU VRAM: 18GB freed (both GPUs)
  - CPU: 8 cores freed
  - Disk I/O: 500 MB/s read freed
  - Network: 100 Mbps bandwidth freed

Cascade Effects:
  - Child processes (5001-5011): Terminated with SIGTERM
  - GPU Context: Destroyed, requires reinitialization
  - CUDA Kernels: All pending operations cancelled
  - DMA Transfers: In-flight transfers lost
  - TCP Connections: Dropped, peers notified

Recovery Requirements:
  - Restart from: Checkpoint at epoch 18
  - Time to recover: ~5 minutes (load checkpoint + warm-up)
  - Data to reprocess: 2 epochs (45 minutes)
  - Total time lost: ~50 minutes
```

#### GPU-Specific Impact
```yaml
GPU State Before Kill:
  GPU 0:
    - Active Kernels: 3 (MatMul, ReLU, BatchNorm)
    - Pending Kernels: 12 in queue
    - Memory: 9GB allocated (4GB model, 3GB activations, 2GB workspace)
    - Temperature: 78°C
    - Power: 350W

  GPU 1:
    - Active Kernels: 2 (Backward pass)
    - Pending Kernels: 8 in queue
    - Memory: 9GB allocated
    - Temperature: 76°C
    - Power: 340W

After Kill:
  - All CUDA contexts destroyed
  - Memory freed instantly
  - Kernels terminated mid-execution
  - No memory corruption (CUDA isolation)
  - GPUs return to idle (50W each)
  - Temperature drops to 45°C in ~2 minutes
```

### 3. Safe Interruption Points

```python
# The analyzer identifies safe points to interrupt:

Safe Points:
✓ Between epochs (no data loss)
✓ After checkpoint save (minimal loss)
✓ After validation run (metrics preserved)

Unsafe Points:
✗ During backward pass (gradient accumulation incomplete)
✗ During optimizer step (parameters partially updated)
✗ During checkpoint save (file corruption risk)
✗ During distributed sync (deadlock risk)

Current Status: UNSAFE - In backward pass
Next Safe Point: In 45 seconds (end of batch)
Recommended: Wait 3 minutes for checkpoint
```

### 4. Process Modification Impact

```bash
# If modifying process priority or resources:

Current: nice -n 0 (normal priority)
Change to: nice -n 10 (lower priority)

Impact:
- Training speed: -15% (5h 30m → 6h 20m)
- GPU utilization: Unchanged (GPU-bound)
- CPU scheduling: Yields to higher priority
- DataLoader impact: Possible starvation
- Recommendation: Not recommended during training

Alternative: CPU Affinity Change
Current: CPUs 0-15 (all cores)
Change to: CPUs 0-7 (half cores)

Impact:
- DataLoader throughput: -50%
- GPU utilization: Drops to 60% (data starvation)
- Training time: +70% (5h 30m → 9h 20m)
- Memory bandwidth: Reduced NUMA locality
- Recommendation: Strongly discouraged
```

### 5. Distributed Training Impact

```yaml
Distributed Training Topology:
  Node 1 (Master): Current process
  Node 2 (Worker): 192.168.1.102
  Node 3 (Worker): 192.168.1.103
  Node 4 (Worker): 192.168.1.104

If Master Killed:
  - All workers detect timeout in 30 seconds
  - Training halts across all nodes
  - Worker GPUs go idle
  - Total GPU-hours wasted: 16 (4 nodes × 4 hours)
  - Checkpoint: Only if workers have local copies

Recovery Strategy:
  1. All nodes must restart
  2. Elect new master (or restart same)
  3. Restore from distributed checkpoint
  4. Resync random seeds
  5. Resume from same batch
  Time: 10-15 minutes

If Worker Killed:
  - Master detects in 10 seconds
  - Options:
    a) Continue with 3 nodes (25% slower)
    b) Halt and wait for recovery
    c) Checkpoint and reschedule
  - Recommendation: Continue if >80% complete
```

### 6. Memory & Storage Impact

```yaml
Memory State:
  System RAM:
    Total: 128GB
    Process: 32GB
    Cache: 48GB (will be reclaimed)
    Available: 48GB

  After Kill:
    Immediate: +32GB available
    After cache clear: +48GB (80GB total free)
    Page cache rebuild: ~5 minutes

  GPU VRAM:
    Total: 40GB per GPU
    Allocated: 18GB
    Reserved: 22GB (PyTorch pool)

  After Kill:
    All 40GB freed immediately
    No fragmentation cleanup needed

Storage I/O:
  Current:
    - Read: 500 MB/s from dataset
    - Write: 50 MB/s to checkpoints
    - IOPS: 10,000 (small random reads)

  After Kill:
    - All I/O stops immediately
    - No filesystem corruption risk
    - Temp files cleaned by OS
    - Dataset cache remains valid
```

### 7. Alternative Actions

```python
# Instead of killing, consider:

1. Checkpoint and Suspend:
   os.kill(pid, signal.SIGUSR1)  # Trigger checkpoint
   time.sleep(30)  # Wait for save
   os.kill(pid, signal.SIGSTOP)  # Suspend
   # Resume later with: os.kill(pid, signal.SIGCONT)

2. Graceful Shutdown:
   os.kill(pid, signal.SIGTERM)  # Request termination
   # Process saves checkpoint and exits cleanly
   # Data loss: 0
   # Time to stop: 30-60 seconds

3. Resource Limiting:
   # Limit GPU memory (requires restart):
   export CUDA_VISIBLE_DEVICES="0"  # Use only GPU 0
   export PYTORCH_CUDA_ALLOC_CONF="max_split_size_mb:512"

4. Priority Adjustment:
   # Lower priority for background training:
   renice -n 19 -p $PID
   # Limit GPU usage:
   nvidia-smi -i 0 -pl 250  # Limit to 250W

5. Checkpoint More Frequently:
   # Modify running process via shared memory:
   echo "checkpoint_frequency=100" > /dev/shm/train_config
   # Process reads and adjusts
```

## Real-time Monitoring

```bash
# The command also starts a monitor showing:

╔══════════════════════════════════════════════════════╗
║ Process Impact Monitor - PID: 5000                   ║
╠══════════════════════════════════════════════════════╣
║ Status: RUNNING (Epoch 20/40, Batch 1234/5000)       ║
║ Safe to Kill: NO - In critical section               ║
║ Next Safe Point: 45 seconds                          ║
╠══════════════════════════════════════════════════════╣
║ GPU 0: ████████░░ 85% | Mem: 18/40GB | Temp: 78°C   ║
║ GPU 1: ████████░░ 83% | Mem: 18/40GB | Temp: 76°C   ║
║ CPU:   ████░░░░░░ 40% | RAM: 32/128GB               ║
╠══════════════════════════════════════════════════════╣
║ If Killed Now:                                       ║
║ - Data Loss: 45 minutes (2 epochs)                   ║
║ - Recovery Time: 50 minutes total                    ║
║ - Resource Freedom: 32GB RAM, 36GB VRAM             ║
╠══════════════════════════════════════════════════════╣
║ Recommendations:                                      ║
║ [W]ait 3 min for checkpoint                         ║
║ [G]raceful shutdown (saves state)                   ║
║ [S]uspend process (resumable)                       ║
║ [K]ill immediately (data loss!)                     ║
║ [Q]uit monitor                                      ║
╚══════════════════════════════════════════════════════╝
```
