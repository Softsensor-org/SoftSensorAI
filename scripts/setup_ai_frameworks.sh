#!/usr/bin/env bash
# Install AI development frameworks and libraries
set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

# Helper functions
say() { echo -e "${CYAN}==> $*${NC}"; }
success() { echo -e "${GREEN}✅ $*${NC}"; }
warn() { echo -e "${YELLOW}⚠️  $*${NC}"; }
error() { echo -e "${RED}❌ $*${NC}"; }

# Check Python availability
check_python() {
  if ! command -v python3 &>/dev/null; then
    error "Python 3 is not installed"
    echo "Please install Python 3.11+ first"
    exit 1
  fi

  local python_version
  python_version=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1-2)
  echo "Found Python $python_version"
}

# Check GPU availability
check_gpu() {
  say "Checking for GPU support..."

  local has_gpu=false
  local cuda_available=false

  # Check for NVIDIA GPU
  if command -v nvidia-smi &>/dev/null; then
    if nvidia-smi &>/dev/null; then
      has_gpu=true
      success "NVIDIA GPU detected"

      # Check CUDA
      if command -v nvcc &>/dev/null; then
        local cuda_version
        cuda_version=$(nvcc --version | grep "release" | sed 's/.*release //' | sed 's/,.*//')
        success "CUDA $cuda_version available"
        cuda_available=true
      else
        warn "CUDA not found - GPU acceleration may be limited"
      fi
    fi
  fi

  # Check for AMD GPU (ROCm)
  local rocm_available=false
  if command -v rocm-smi &>/dev/null; then
    has_gpu=true
    rocm_available=true
    success "AMD GPU detected (ROCm)"
    # Note: ROCm support varies by package, will use CPU fallback where needed
  fi

  # Check for Apple Silicon
  if [[ "$(uname -s)" == "Darwin" ]] && [[ "$(uname -m)" == "arm64" ]]; then
    has_gpu=true
    success "Apple Silicon GPU detected"
  fi

  if [ "$has_gpu" = false ]; then
    warn "No GPU detected - will install CPU-only versions"
  fi

  echo "$cuda_available"
}

# Install core AI libraries
install_core_libraries() {
  say "Installing core AI libraries..."

  # Upgrade pip first
  python3 -m pip install --upgrade pip

  # Core libraries that work everywhere
  local core_packages=(
    "anthropic"          # Anthropic Claude API
    "openai"            # OpenAI GPT API
    "langchain"         # LangChain framework
    "langchain-community" # LangChain community integrations
    "langgraph"         # LangGraph for stateful agents
    "autogen"           # Microsoft AutoGen for multi-agent
    "crewai"            # CrewAI for agent teams
    "transformers"      # Hugging Face transformers
    "sentence-transformers" # Sentence embeddings
    "tiktoken"          # Token counting for OpenAI
    "chromadb"          # Vector database
    "faiss-cpu"         # Facebook AI similarity search
    "pydantic"          # Data validation
    "python-dotenv"     # Environment management
    "streamlit"         # Quick UI for demos
    "gradio"            # Alternative UI framework
  )

  for package in "${core_packages[@]}"; do
    echo "Installing $package..."
    python3 -m pip install --upgrade "$package" || warn "Failed to install $package"
  done

  success "Core AI libraries installed"
}

# Install GPU-specific packages
install_gpu_packages() {
  local cuda_available="$1"
  local rocm_available="${2:-false}"
  local is_apple="${3:-false}"

  if [ "$cuda_available" = "true" ]; then
    say "Installing CUDA-optimized packages..."

    # PyTorch with CUDA
    python3 -m pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

    # CUDA-optimized FAISS (only for CUDA)
    python3 -m pip install faiss-gpu || warn "FAISS-GPU installation failed, using CPU version"

    # Flash Attention for faster transformers (CUDA only)
    python3 -m pip install flash-attn --no-build-isolation || warn "Flash Attention requires CUDA build environment"

    success "CUDA-optimized packages installed"
  elif [ "$rocm_available" = "true" ]; then
    say "Installing ROCm-optimized packages..."
    
    # PyTorch with ROCm support
    python3 -m pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm5.7 || {
      warn "ROCm PyTorch failed, falling back to CPU version"
      python3 -m pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
    }
    
    # FAISS CPU version for ROCm (no ROCm-specific build available)
    python3 -m pip install faiss-cpu
    
    success "ROCm packages installed (with CPU fallbacks where needed)"
  elif [ "$is_apple" = "true" ]; then
    say "Installing Apple Silicon optimized packages..."
    
    # PyTorch for Apple Silicon (uses Metal Performance Shaders)
    python3 -m pip install torch torchvision torchaudio
    
    # FAISS CPU version for Apple Silicon
    python3 -m pip install faiss-cpu
    
    success "Apple Silicon packages installed"
  else
    say "Installing CPU-optimized packages..."
    python3 -m pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
    python3 -m pip install faiss-cpu
    success "CPU packages installed"
  fi
}

# Install additional ML/AI tools
install_ml_tools() {
  say "Installing additional ML/AI tools..."

  local ml_packages=(
    "scikit-learn"      # Classic ML
    "pandas"            # Data manipulation
    "numpy"             # Numerical computing
    "matplotlib"        # Plotting
    "seaborn"           # Statistical visualization
    "jupyter"           # Jupyter notebooks
    "ipykernel"         # Jupyter kernel
    "wandb"             # Weights & Biases tracking
    "mlflow"            # ML lifecycle management
    "optuna"            # Hyperparameter optimization
  )

  for package in "${ml_packages[@]}"; do
    echo "Installing $package..."
    python3 -m pip install --upgrade "$package" || warn "Failed to install $package"
  done

  success "ML tools installed"
}

# Install development tools
install_dev_tools() {
  say "Installing AI development tools..."

  local dev_packages=(
    "black"             # Code formatter
    "ruff"              # Fast linter
    "mypy"              # Type checking
    "pytest"            # Testing framework
    "pytest-asyncio"    # Async testing
    "pre-commit"        # Git hooks
    "ipdb"              # Debugger
  )

  for package in "${dev_packages[@]}"; do
    echo "Installing $package..."
    python3 -m pip install --upgrade "$package" || warn "Failed to install $package"
  done

  success "Development tools installed"
}

# Create example configuration
create_example_config() {
  say "Creating example .env configuration..."

  if [ ! -f ".env.example" ]; then
    cat > .env.example << 'EOF'
# AI API Keys (get from respective platforms)
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...
HUGGINGFACE_API_KEY=hf_...
GROQ_API_KEY=gsk_...
MISTRAL_API_KEY=...

# Optional: Vector Database
PINECONE_API_KEY=...
PINECONE_ENVIRONMENT=...
WEAVIATE_URL=...

# Optional: Monitoring
WANDB_API_KEY=...
LANGCHAIN_API_KEY=...
LANGCHAIN_TRACING_V2=true

# Model Settings
MODEL_TEMPERATURE=0.7
MODEL_MAX_TOKENS=2000
EMBEDDING_MODEL=text-embedding-ada-002

# Development
DEBUG=false
LOG_LEVEL=INFO
EOF
    success "Created .env.example - copy to .env and add your API keys"
  else
    warn ".env.example already exists"
  fi
}

# Main installation flow
main() {
  echo "╔════════════════════════════════════════════╗"
  echo "║     AI Frameworks Installation Script      ║"
  echo "╚════════════════════════════════════════════╝"
  echo

  # Check Python
  check_python

  # Check GPU and store result
  local cuda_available
  cuda_available=$(check_gpu)
  echo

  # Ask user what to install
  echo "What would you like to install?"
  echo "  1) Core AI libraries only (minimal)"
  echo "  2) Core + ML tools (recommended)"
  echo "  3) Everything (core + ML + dev tools)"
  echo "  4) Custom selection"
  echo
  read -p "Enter choice (1-4) [2]: " choice
  choice=${choice:-2}

  case $choice in
    1)
      install_core_libraries
      install_gpu_packages "$cuda_available" "$rocm_available" "$([[ "$(uname -s)" == "Darwin" ]] && echo "true" || echo "false")"
      ;;
    2)
      install_core_libraries
      install_gpu_packages "$cuda_available" "$rocm_available" "$([[ "$(uname -s)" == "Darwin" ]] && echo "true" || echo "false")"
      install_ml_tools
      ;;
    3)
      install_core_libraries
      install_gpu_packages "$cuda_available" "$rocm_available" "$([[ "$(uname -s)" == "Darwin" ]] && echo "true" || echo "false")"
      install_ml_tools
      install_dev_tools
      ;;
    4)
      echo "Custom installation:"
      read -p "Install core AI libraries? (y/n) [y]: " core
      read -p "Install ML tools? (y/n) [y]: " ml
      read -p "Install dev tools? (y/n) [n]: " dev

      [[ "${core:-y}" =~ ^[Yy] ]] && install_core_libraries
      [[ "${core:-y}" =~ ^[Yy] ]] && install_gpu_packages "$cuda_available"
      [[ "${ml:-y}" =~ ^[Yy] ]] && install_ml_tools
      [[ "${dev:-n}" =~ ^[Yy] ]] && install_dev_tools
      ;;
    *)
      error "Invalid choice"
      exit 1
      ;;
  esac

  echo
  create_example_config

  echo
  echo "╔════════════════════════════════════════════╗"
  echo "║          Installation Complete!            ║"
  echo "╚════════════════════════════════════════════╝"
  echo
  echo "Next steps:"
  echo "  1. Copy .env.example to .env and add your API keys"
  echo "  2. Test your setup with: python3 -c 'import langchain; print(\"Ready!\")'"
  echo "  3. Check GPU with: python3 -c 'import torch; print(torch.cuda.is_available())'"
  echo
  success "AI frameworks are ready for development!"
}

# Run main function
main "$@"
