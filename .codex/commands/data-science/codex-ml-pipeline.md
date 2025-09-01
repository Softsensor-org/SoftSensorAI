# Codex ML Pipeline Generator

Generate complete ML pipelines with GPU optimization and distributed training support.

## Usage
```
/codex-ml-pipeline --type [training|inference|feature] --distributed --gpu
```

## What Codex Will Generate

### 1. Data Pipeline
```python
# Codex generates optimized data loading with:
- Parallel data preprocessing
- GPU memory pinning
- Efficient batching
- Data augmentation pipelines
- Distributed data sharding
```

### 2. Model Architecture
```python
# Auto-generated based on task:
- Optimal layer configurations
- GPU-efficient operations
- Mixed precision setup
- Gradient checkpointing
- Model parallelism if needed
```

### 3. Training Loop
```python
# Complete training pipeline with:
- Distributed training setup (DDP/Horovod)
- Automatic mixed precision
- Gradient accumulation
- Learning rate scheduling
- Early stopping
- Checkpoint management
- TensorBoard/WandB integration
```

### 4. GPU Optimization
```python
# Codex automatically adds:
- CUDA kernel fusion
- Memory efficient attention
- Flash attention where applicable
- Optimized data transfers
- Stream synchronization
```

### 5. Monitoring & Logging
```python
# Generated monitoring includes:
- GPU utilization tracking
- Memory usage monitoring
- Training metrics logging
- Performance profiling
- Distributed metrics aggregation
```

## Example Generation

**Input**: "Generate a distributed training pipeline for image classification"

**Codex Output**:
```python
import torch
import torch.nn as nn
import torch.distributed as dist
from torch.nn.parallel import DistributedDataParallel as DDP
from torch.cuda.amp import autocast, GradScaler

class OptimizedPipeline:
    def __init__(self, model, dataset, config):
        # Distributed setup
        dist.init_process_group(backend='nccl')
        self.rank = dist.get_rank()
        self.world_size = dist.get_world_size()

        # Model setup with optimizations
        self.model = model.cuda()
        self.model = nn.SyncBatchNorm.convert_sync_batchnorm(self.model)
        self.model = DDP(self.model, device_ids=[self.rank])

        # Mixed precision
        self.scaler = GradScaler()

        # Optimized data loader
        self.loader = self._create_distributed_loader(dataset)

    def train_epoch(self):
        for batch in self.loader:
            # Optimized forward pass
            with autocast():
                loss = self.model(batch)

            # Efficient backward
            self.scaler.scale(loss).backward()
            self.scaler.step(self.optimizer)
            self.scaler.update()

            # GPU memory management
            if self.rank == 0:
                self._log_gpu_metrics()
```

## Sandbox Execution

Codex can test the generated pipeline in sandbox:
```bash
codex-sandbox run pipeline.py --gpus 2 --validate
```

## Safety Features

- Validates GPU availability before generation
- Checks memory requirements
- Estimates training time
- Warns about potential OOM issues
- Provides fallback CPU implementations
