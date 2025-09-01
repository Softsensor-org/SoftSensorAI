# GPU Optimization Analyzer

Analyze and optimize code for GPU execution with detailed explanations.

## Usage
```
/gpu-optimize [--explain-level deep|medium|basic] [--target cuda|rocm|metal|opencl]
```

## What it does

1. **Analyzes current GPU usage:**
   - CUDA cores utilization
   - Memory bandwidth usage
   - Kernel launch overhead
   - Host-device transfer bottlenecks

2. **Suggests optimizations:**
   - Kernel fusion opportunities
   - Memory coalescing improvements
   - Shared memory optimization
   - Stream parallelism

3. **Explains impact at hardware level:**
   - Warp divergence effects
   - Memory access patterns
   - Occupancy calculations
   - Register pressure

4. **Provides before/after metrics:**
   - Expected speedup
   - Memory usage changes
   - Power consumption impact
   - Thermal considerations

## Example Output

```python
# BEFORE: Naive implementation
for i in range(n):
    result[i] = compute(data[i])

# AFTER: GPU-optimized
# Explanation:
# - Uses 2048 CUDA cores in parallel (vs 1 CPU core)
# - Coalesced memory access pattern (32x bandwidth improvement)
# - Shared memory for frequently accessed data (100x latency reduction)
# - Stream overlap hides 67% of memory transfer time
#
# GPU Resource Impact:
# - CUDA Cores: 85% utilization (up from 0%)
# - Memory Bandwidth: 280 GB/s (up from 25 GB/s)
# - Power Draw: +150W (but 50x faster completion)
# - VRAM Usage: 4.2 GB allocated, 3.8 GB active
#
# Process Kill Impact:
# - Immediate: 4.2 GB VRAM freed
# - Computation lost: 2.3M iterations (45 seconds of work)
# - Recovery: Can resume from last checkpoint (iteration 2M)

import cupy as cp
result = cp.asarray(parallel_compute(cp.asarray(data)))
```

## Deep Explanations

When `--explain-level deep` is used, provides:

### Memory Hierarchy Impact
- L1 cache: 128 KB per SM, 4 cycle latency
- L2 cache: 6 MB total, 200 cycle latency
- Global memory: 24 GB, 500 cycle latency
- Optimization moves 70% of accesses to L1 (125x faster)

### Parallelization Strategy
- Thread block size: 256 (optimal for occupancy)
- Grid dimensions: (8192, 1, 1)
- Warps per SM: 32
- Theoretical occupancy: 75%

### Kill Process Impact Analysis
```
Process: python train.py (PID: 12345)
- GPU Memory held: 4.2 GB
- Active kernels: 3
- Pending kernels: 12
- DMA transfers in flight: 2

If killed now:
- Data loss: 45 minutes of training (checkpoint available at epoch 18)
- GPU memory freed immediately
- No corruption risk (atomic checkpoint)
- Dependent processes affected:
  - TensorBoard logger (will stop receiving metrics)
  - Data loader processes (3 workers will terminate)
  - Distributed training peers (will trigger re-election)

Safe to kill: YES (checkpoint exists)
Recommended: Wait 30s for epoch completion
```
