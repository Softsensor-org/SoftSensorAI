# GPU Optimization Guide

Understanding GPU acceleration for ML/AI workloads and development optimization strategies.

## Table of Contents

- [Overview](#overview)
- [GPU Detection](#gpu-detection)
- [Understanding GPU Architecture](#understanding-gpu-architecture)
- [Optimization Strategies](#optimization-strategies)
- [Process Management](#process-management)
- [Monitoring and Debugging](#monitoring-and-debugging)
- [Best Practices](#best-practices)

## Overview

This guide explains GPU optimization at a technical level, helping developers understand:

- How GPUs accelerate ML workloads
- What happens during parallelization
- Impact of process management decisions
- Memory and compute optimization strategies

## GPU Detection

SoftSensorAI automatically detects your GPU during setup:

### Detection Methods

```bash
# NVIDIA GPUs
nvidia-smi --query-gpu=name,memory.total,compute_cap --format=csv,noheader

# AMD GPUs
rocm-smi --showproductname

# Apple Silicon
system_profiler SPDisplaysDataType | grep "Chipset Model"

# Intel GPUs
glxinfo | grep "OpenGL renderer"
```

### Manual Verification

```python
import torch
import tensorflow as tf

# PyTorch GPU detection
print(f"CUDA available: {torch.cuda.is_available()}")
print(f"CUDA device count: {torch.cuda.device_count()}")
if torch.cuda.is_available():
    print(f"Current device: {torch.cuda.get_device_name(0)}")
    print(f"Memory allocated: {torch.cuda.memory_allocated(0) / 1024**3:.2f} GB")
    print(f"Memory cached: {torch.cuda.memory_reserved(0) / 1024**3:.2f} GB")

# TensorFlow GPU detection
print(f"TF GPUs: {tf.config.list_physical_devices('GPU')}")
```

## Understanding GPU Architecture

### CUDA Cores vs CPU Cores

**CPU Cores (4-32 cores typically):**

- Complex, independent processing units
- Optimized for sequential tasks
- Large cache, branch prediction
- ~2-5 GHz clock speed

**CUDA Cores (1000s of cores):**

- Simple, parallel processing units
- Optimized for parallel tasks
- Shared memory architecture
- ~1-2 GHz clock speed

```python
# Example: Matrix multiplication comparison

# CPU version (sequential)
def cpu_matmul(A, B):
    """O(n³) sequential operations"""
    C = np.zeros((A.shape[0], B.shape[1]))
    for i in range(A.shape[0]):
        for j in range(B.shape[1]):
            for k in range(A.shape[1]):
                C[i,j] += A[i,k] * B[k,j]
    return C

# GPU version (parallel)
def gpu_matmul(A, B):
    """Parallel execution across thousands of cores"""
    # Each CUDA core handles one element of C
    # All computations happen simultaneously
    return torch.matmul(A, B)

# Performance difference
# CPU: 1000x1000 matrix = ~1 second
# GPU: 1000x1000 matrix = ~0.001 seconds (1000x faster)
```

### Memory Hierarchy

```
CPU Memory          GPU Memory
==========          ==========
RAM (32-256GB)  ←→  VRAM (8-80GB)      [PCIe Transfer: ~15 GB/s]
     ↓                   ↓
L3 Cache (MB)       L2 Cache (MB)       [Fast]
     ↓                   ↓
L2 Cache (KB)       L1 Cache (KB)       [Faster]
     ↓                   ↓
L1 Cache            Registers           [Fastest]
     ↓                   ↓
Registers           CUDA Cores
```

### Memory Bandwidth Impact

```python
# Understanding memory bandwidth bottlenecks

import torch
import time

def measure_bandwidth(size_gb):
    """Measure effective memory bandwidth"""
    size = int(size_gb * 1024**3 / 4)  # float32 elements

    # Create tensors
    a = torch.randn(size, device='cuda')
    b = torch.randn(size, device='cuda')

    # Warm up
    c = a + b
    torch.cuda.synchronize()

    # Measure
    start = time.time()
    for _ in range(100):
        c = a + b
    torch.cuda.synchronize()
    end = time.time()

    # Calculate bandwidth
    bytes_transferred = size * 4 * 2 * 100  # read a, read b, 100 iterations
    bandwidth = bytes_transferred / (end - start) / 1024**3

    print(f"Effective bandwidth: {bandwidth:.1f} GB/s")
    print(f"Memory bound operation - limited by memory, not compute")

# Typical results:
# RTX 3090: ~700 GB/s (theoretical: 936 GB/s)
# V100: ~800 GB/s (theoretical: 900 GB/s)
# A100: ~1400 GB/s (theoretical: 1555 GB/s)
```

## Optimization Strategies

### 1. Batch Size Optimization

```python
def find_optimal_batch_size(model, input_shape, max_batch=512):
    """Find optimal batch size for your GPU"""
    batch_size = 1
    optimal_batch = 1
    max_throughput = 0

    while batch_size <= max_batch:
        try:
            # Clear cache
            torch.cuda.empty_cache()

            # Create batch
            batch = torch.randn(batch_size, *input_shape, device='cuda')

            # Measure throughput
            start = time.time()
            with torch.no_grad():
                for _ in range(10):
                    _ = model(batch)
            torch.cuda.synchronize()
            elapsed = time.time() - start

            throughput = (batch_size * 10) / elapsed

            if throughput > max_throughput:
                max_throughput = throughput
                optimal_batch = batch_size

            print(f"Batch {batch_size}: {throughput:.1f} samples/sec")

            # Increase batch size
            batch_size *= 2

        except RuntimeError as e:
            if "out of memory" in str(e):
                print(f"OOM at batch size {batch_size}")
                break
            raise e

    return optimal_batch

# Impact of batch size:
# Too small: GPU underutilized (low occupancy)
# Too large: Out of memory or reduced speed (cache thrashing)
# Optimal: Maximum throughput while fitting in memory
```

### 2. Mixed Precision Training

```python
from torch.cuda.amp import autocast, GradScaler

def train_with_mixed_precision(model, dataloader, optimizer):
    """Use FP16 for faster training with minimal accuracy loss"""
    scaler = GradScaler()

    for batch in dataloader:
        optimizer.zero_grad()

        # Forward pass in FP16
        with autocast():
            outputs = model(batch['input'])
            loss = criterion(outputs, batch['target'])

        # Backward pass with gradient scaling
        scaler.scale(loss).backward()
        scaler.step(optimizer)
        scaler.update()

    # Benefits:
    # - 2x memory reduction (FP32 → FP16)
    # - 2-3x speedup on modern GPUs (Tensor Cores)
    # - Maintains FP32 accuracy with loss scaling
```

### 3. Data Pipeline Optimization

```python
class OptimizedDataLoader:
    """GPU-optimized data loading"""

    def __init__(self, dataset, batch_size):
        self.loader = torch.utils.data.DataLoader(
            dataset,
            batch_size=batch_size,
            shuffle=True,
            num_workers=4,  # Parallel data loading
            pin_memory=True,  # Page-locked memory for faster transfer
            persistent_workers=True,  # Keep workers alive
            prefetch_factor=2  # Prefetch batches
        )

    def prefetch_to_gpu(self):
        """Overlap data transfer with computation"""
        stream = torch.cuda.Stream()

        for batch in self.loader:
            # Transfer next batch while processing current
            with torch.cuda.stream(stream):
                batch_gpu = {k: v.cuda(non_blocking=True)
                            for k, v in batch.items()}

            # Ensure transfer completes
            stream.synchronize()

            yield batch_gpu

# Impact:
# - Eliminates CPU-GPU transfer bottleneck
# - Overlaps data loading with training
# - Can improve throughput by 20-50%
```

### 4. Kernel Fusion and Graph Optimization

```python
# PyTorch 2.0 compile for kernel fusion
import torch._dynamo as dynamo

@torch.compile(mode="max-autotune")
def optimized_forward(x, weight, bias):
    """Fused operations for better performance"""
    # These operations will be fused into a single kernel
    x = torch.matmul(x, weight)
    x = x + bias
    x = torch.relu(x)
    x = torch.dropout(x, p=0.1, training=True)
    return x

# Before fusion: 4 kernel launches, 4 memory reads/writes
# After fusion: 1 kernel launch, 1 memory read/write
# Speedup: 2-4x for memory-bound operations
```

## Process Management

### Understanding Process Impact

#### 1. Killing a Training Process

```python
def understand_process_termination():
    """What happens when you kill a GPU process"""

    # Immediate effects:
    print("1. CUDA context destroyed")
    print("2. GPU memory freed (usually)")
    print("3. Gradients and optimizer state lost")
    print("4. Current batch progress lost")

    # Potential issues:
    print("\nPotential issues:")
    print("- Memory leak if using multiprocessing")
    print("- Corrupted checkpoint if killed during save")
    print("- Zombie processes if using distributed training")

    # Safe termination:
    print("\nSafe termination:")
    print("1. Catch SIGINT/SIGTERM")
    print("2. Save checkpoint")
    print("3. Cleanup resources")
    print("4. Exit gracefully")

# Implementation of safe termination
import signal
import sys

class SafeTrainer:
    def __init__(self):
        self.should_stop = False
        signal.signal(signal.SIGINT, self.signal_handler)
        signal.signal(signal.SIGTERM, self.signal_handler)

    def signal_handler(self, sig, frame):
        print("\nGraceful shutdown initiated...")
        self.should_stop = True

    def train(self):
        for epoch in range(num_epochs):
            for batch in dataloader:
                if self.should_stop:
                    self.save_checkpoint()
                    self.cleanup()
                    sys.exit(0)

                # Training step
                self.train_step(batch)
```

#### 2. Memory Management

```python
def diagnose_memory_issues():
    """Understanding GPU memory allocation"""

    # Check current memory state
    print(f"Allocated: {torch.cuda.memory_allocated() / 1024**3:.2f} GB")
    print(f"Reserved: {torch.cuda.memory_reserved() / 1024**3:.2f} GB")

    # Common memory issues and solutions
    issues = {
        "Fragmentation": {
            "Cause": "Many small allocations/deallocations",
            "Solution": "torch.cuda.empty_cache()",
            "Impact": "Can't allocate large tensors despite free memory"
        },
        "Memory Leak": {
            "Cause": "Holding references to intermediate tensors",
            "Solution": "Use .detach() or torch.no_grad()",
            "Impact": "Gradual memory increase until OOM"
        },
        "Gradient Accumulation": {
            "Cause": "Not zeroing gradients",
            "Solution": "optimizer.zero_grad()",
            "Impact": "Memory usage grows each iteration"
        }
    }

    for issue, details in issues.items():
        print(f"\n{issue}:")
        for key, value in details.items():
            print(f"  {key}: {value}")

# Memory profiling
from torch.profiler import profile, ProfilerActivity

def profile_memory_usage(model, input_data):
    """Profile memory usage during forward/backward pass"""

    with profile(
        activities=[ProfilerActivity.CPU, ProfilerActivity.CUDA],
        record_shapes=True,
        profile_memory=True,
        with_stack=True
    ) as prof:

        # Forward pass
        output = model(input_data)
        loss = output.mean()

        # Backward pass
        loss.backward()

    # Print memory usage
    print(prof.key_averages().table(
        sort_by="cuda_memory_usage",
        row_limit=10
    ))

    # Save detailed trace
    prof.export_chrome_trace("memory_trace.json")
    print("View trace at: chrome://tracing")
```

#### 3. Multi-GPU Parallelization

```python
def understand_parallelization():
    """Different parallelization strategies and their impact"""

    strategies = {
        "Data Parallel (DP)": {
            "How": "Split batch across GPUs",
            "Communication": "Through CPU (slow)",
            "Scaling": "Good for small models",
            "Memory": "Model replicated on each GPU"
        },
        "Distributed Data Parallel (DDP)": {
            "How": "Split batch across GPUs/nodes",
            "Communication": "Direct GPU-to-GPU (NCCL)",
            "Scaling": "Near-linear scaling",
            "Memory": "Model replicated on each GPU"
        },
        "Model Parallel": {
            "How": "Split model across GPUs",
            "Communication": "Between layer boundaries",
            "Scaling": "For models > single GPU memory",
            "Memory": "Different layers on different GPUs"
        },
        "Pipeline Parallel": {
            "How": "Split model into stages",
            "Communication": "Micro-batches between stages",
            "Scaling": "Good for deep models",
            "Memory": "Balanced across GPUs"
        }
    }

    for strategy, details in strategies.items():
        print(f"\n{strategy}:")
        for key, value in details.items():
            print(f"  {key}: {value}")

# DDP implementation
import torch.distributed as dist
import torch.multiprocessing as mp

def ddp_training(rank, world_size):
    """Distributed training across multiple GPUs"""

    # Initialize process group
    dist.init_process_group("nccl", rank=rank, world_size=world_size)

    # Set device
    torch.cuda.set_device(rank)

    # Create model and wrap with DDP
    model = MyModel().cuda(rank)
    model = torch.nn.parallel.DistributedDataParallel(
        model,
        device_ids=[rank],
        output_device=rank,
        find_unused_parameters=False
    )

    # Create distributed sampler
    sampler = torch.utils.data.distributed.DistributedSampler(
        dataset,
        num_replicas=world_size,
        rank=rank,
        shuffle=True
    )

    # Training loop
    for epoch in range(num_epochs):
        sampler.set_epoch(epoch)  # For proper shuffling

        for batch in dataloader:
            # Training happens in parallel
            # Gradients automatically synchronized
            loss = train_step(model, batch)

    # Cleanup
    dist.destroy_process_group()

# Launch distributed training
if __name__ == "__main__":
    world_size = torch.cuda.device_count()
    mp.spawn(ddp_training, args=(world_size,), nprocs=world_size)
```

## Monitoring and Debugging

### Real-time GPU Monitoring

```bash
# Basic monitoring
watch -n 0.5 nvidia-smi

# Detailed monitoring
nvidia-smi dmon -s pucvmet -i 0

# Python monitoring
pip install gpustat
watch -n 1 gpustat -cpu

# Advanced monitoring with nvitop
pip install nvitop
nvitop
```

### Performance Profiling

```python
import torch.profiler as profiler
import torch.cuda.nvtx as nvtx

def profile_training_loop(model, dataloader):
    """Comprehensive performance profiling"""

    with profiler.profile(
        schedule=profiler.schedule(wait=1, warmup=1, active=3, repeat=2),
        on_trace_ready=profiler.tensorboard_trace_handler('./log/profiler'),
        record_shapes=True,
        profile_memory=True,
        with_stack=True
    ) as prof:

        for step, batch in enumerate(dataloader):
            # Mark regions for detailed analysis
            with nvtx.range("data_transfer"):
                batch = batch.cuda()

            with nvtx.range("forward"):
                output = model(batch)

            with nvtx.range("loss"):
                loss = criterion(output, target)

            with nvtx.range("backward"):
                loss.backward()

            with nvtx.range("optimizer"):
                optimizer.step()
                optimizer.zero_grad()

            prof.step()  # Next profiler step

            if step >= 10:
                break

    # Analyze results
    print(prof.key_averages().table(sort_by="cuda_time_total", row_limit=10))

    # View in TensorBoard
    print("Run: tensorboard --logdir=./log/profiler")
```

### Debugging GPU Issues

```python
def debug_gpu_issues():
    """Common GPU debugging techniques"""

    # 1. Synchronous execution for debugging
    torch.cuda.set_sync_debug_mode(1)  # Force synchronous CUDA calls

    # 2. Check for CUDA errors
    torch.cuda.synchronize()
    if torch.cuda.is_initialized():
        print(f"Last CUDA error: {torch.cuda.get_last_error()}")

    # 3. Memory debugging
    torch.cuda.memory._record_memory_history()

    # 4. Deterministic mode for reproducibility
    torch.use_deterministic_algorithms(True)
    torch.backends.cudnn.benchmark = False

    # 5. Device-side assertions
    os.environ['CUDA_LAUNCH_BLOCKING'] = '1'

    # 6. NaN detection
    torch.autograd.set_detect_anomaly(True)

# GPU memory leak detection
class MemoryTracker:
    def __init__(self):
        torch.cuda.reset_peak_memory_stats()
        self.begin = torch.cuda.memory_allocated()

    def check(self, message=""):
        current = torch.cuda.memory_allocated()
        peak = torch.cuda.max_memory_allocated()
        diff = (current - self.begin) / 1024**2

        print(f"{message}")
        print(f"  Memory change: {diff:+.1f} MB")
        print(f"  Current: {current/1024**2:.1f} MB")
        print(f"  Peak: {peak/1024**2:.1f} MB")

        if diff > 100:  # More than 100MB increase
            print("  ⚠️ Possible memory leak!")

            # Get detailed allocation info
            snapshot = torch.cuda.memory_snapshot()
            for alloc in snapshot:
                if alloc['size'] > 1024**2:  # Allocations > 1MB
                    print(f"    {alloc['size']/1024**2:.1f} MB at {alloc['filename']}:{alloc['line']}")
```

## Best Practices

### 1. Development Workflow

```python
# Start with CPU for debugging
device = torch.device("cpu")
model = Model().to(device)

# Validate with small batch
small_batch = next(iter(dataloader))
output = model(small_batch)
print(f"Output shape: {output.shape}")

# Profile before optimization
with profiler.profile() as prof:
    for _ in range(10):
        model(small_batch)
print(prof.key_averages())

# Move to GPU and optimize
device = torch.device("cuda")
model = model.to(device)
model = torch.compile(model)  # PyTorch 2.0 optimization

# Benchmark
benchmark_model(model, dataloader)
```

### 2. Memory Management Best Practices

```python
# Clear cache regularly
torch.cuda.empty_cache()

# Use context managers
with torch.no_grad():
    # Inference without gradient tracking
    output = model(input)

# Detach tensors when needed
loss_value = loss.detach().cpu().item()

# Delete large tensors explicitly
del large_tensor
torch.cuda.empty_cache()

# Use checkpointing for large models
from torch.utils.checkpoint import checkpoint
output = checkpoint(model_layer, input)
```

### 3. Multi-GPU Best Practices

```python
# Always use DDP over DP
model = torch.nn.parallel.DistributedDataParallel(model)

# Synchronize when needed
if rank == 0:
    # Only on main process
    save_checkpoint(model)
dist.barrier()  # Wait for all processes

# Gradient accumulation for large batches
accumulation_steps = 4
for i, batch in enumerate(dataloader):
    loss = model(batch) / accumulation_steps
    loss.backward()

    if (i + 1) % accumulation_steps == 0:
        optimizer.step()
        optimizer.zero_grad()
```

### 4. Production Deployment

```python
# Model optimization for inference
model.eval()
model = torch.jit.script(model)  # TorchScript
model = torch.jit.optimize_for_inference(model)

# Batch inference
@torch.inference_mode()
def batch_inference(model, inputs, batch_size=32):
    results = []
    for i in range(0, len(inputs), batch_size):
        batch = inputs[i:i+batch_size]
        with torch.cuda.amp.autocast():
            output = model(batch)
        results.append(output.cpu())
    return torch.cat(results)

# Memory-efficient serving
class ModelServer:
    def __init__(self, model_path):
        self.device = torch.device("cuda")
        self.model = torch.jit.load(model_path, map_location=self.device)
        self.model.eval()

    @torch.inference_mode()
    def predict(self, input_tensor):
        # Move to GPU, compute, move back
        input_gpu = input_tensor.to(self.device)
        output = self.model(input_gpu)
        return output.cpu()

    def __del__(self):
        # Cleanup
        torch.cuda.empty_cache()
```

## Troubleshooting Guide

### Common Issues and Solutions

| Issue                     | Cause                 | Solution                                       |
| ------------------------- | --------------------- | ---------------------------------------------- |
| OOM Error                 | Batch too large       | Reduce batch size or use gradient accumulation |
| Slow Training             | CPU bottleneck        | Use DataLoader optimizations                   |
| Memory Leak               | Gradient accumulation | Call optimizer.zero_grad()                     |
| Low GPU Utilization       | Small batch size      | Increase batch size or use mixed precision     |
| Inconsistent Results      | Non-deterministic ops | Set torch.use_deterministic_algorithms(True)   |
| Kernel Launch Failure     | Driver issue          | Update CUDA drivers                            |
| Distributed Training Hang | Process sync issue    | Check dist.barrier() calls                     |

## Summary

GPU optimization involves understanding:

1. **Hardware**: CUDA cores, memory hierarchy, bandwidth limits
2. **Software**: Parallelization strategies, memory management
3. **Process Impact**: Safe termination, resource cleanup
4. **Monitoring**: Profiling, debugging, performance analysis

Key takeaways:

- Always profile before optimizing
- Memory bandwidth often more limiting than compute
- Batch size significantly impacts performance
- Mixed precision provides free speedup on modern GPUs
- Proper process management prevents resource leaks

---

_For framework-specific optimization, see [AI_FRAMEWORKS.md](AI_FRAMEWORKS.md)_
