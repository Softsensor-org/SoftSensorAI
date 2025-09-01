# 🤖 AI Frameworks Installation Guide

Complete guide for setting up a professional AI/ML development environment with DevPilot.

## Table of Contents
- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [GPU Setup](#gpu-setup)
- [Framework Details](#framework-details)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)
- [Examples](#examples)

## Overview

The AI Frameworks installer provides a comprehensive, GPU-optimized development environment for building AI agents, LLM applications, and machine learning projects.

### What Gets Installed

| Category | Packages | Purpose |
|----------|----------|---------|
| **LLM APIs** | `anthropic`, `openai`, `groq` | Access to Claude, GPT, Groq models |
| **Agent Frameworks** | `langchain`, `autogen`, `crewai` | Build multi-agent systems |
| **ML/DL** | `torch`, `transformers`, `tensorflow` | Deep learning and NLP |
| **Vector Stores** | `chromadb`, `faiss-cpu/gpu` | Semantic search and RAG |
| **Development** | `jupyter`, `streamlit`, `gradio` | Notebooks and UI development |
| **Utilities** | `tiktoken`, `python-dotenv`, `pydantic` | Token counting, config, validation |

## Prerequisites

### System Requirements

- **Python**: 3.11+ (3.12 recommended)
- **RAM**: 8GB minimum, 16GB+ recommended
- **Disk**: 10GB free space for packages
- **GPU** (optional): NVIDIA with CUDA 11.8+ for acceleration

### Check Your System

```bash
# Check Python version
python3 --version

# Check available memory
free -h

# Check GPU (if available)
nvidia-smi  # For NVIDIA
rocm-smi    # For AMD
```

## Quick Start

### 1. Basic Installation

```bash
# Run the installer
./scripts/setup_ai_frameworks.sh

# Choose option 2 (recommended): Core + ML tools
```

### 2. Verify Installation

```bash
# Test core imports
python3 -c "
import langchain
import anthropic
import openai
import torch
print('✅ All packages imported successfully!')
print(f'PyTorch CUDA available: {torch.cuda.is_available()}')
"
```

### 3. Configure API Keys

```bash
# Copy example configuration
cp .env.example .env

# Edit with your API keys
nano .env
```

Add your keys:
```env
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...
GROQ_API_KEY=gsk_...
```

## GPU Setup

### NVIDIA CUDA Setup

The installer automatically detects NVIDIA GPUs and installs CUDA-optimized packages.

#### Manual CUDA Installation (if needed)

```bash
# Ubuntu/Debian
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt-get update
sudo apt-get -y install cuda-toolkit-12-3

# Verify
nvidia-smi
nvcc --version
```

#### PyTorch CUDA Verification

```python
import torch
print(f"CUDA Available: {torch.cuda.is_available()}")
print(f"CUDA Version: {torch.version.cuda}")
print(f"GPU Count: {torch.cuda.device_count()}")
if torch.cuda.is_available():
    print(f"GPU Name: {torch.cuda.get_device_name(0)}")
```

### AMD ROCm Setup

For AMD GPUs, the installer detects ROCm and installs compatible packages.

```bash
# Install ROCm (Ubuntu)
wget https://repo.radeon.com/amdgpu-install/latest/ubuntu/jammy/amdgpu-install_6.0.60002-1_all.deb
sudo apt install ./amdgpu-install_6.0.60002-1_all.deb
sudo amdgpu-install --usecase=rocm

# Verify
rocm-smi
```

### Apple Silicon

Metal Performance Shaders are automatically used on Apple Silicon Macs.

```python
# Verify MPS availability
import torch
print(f"MPS Available: {torch.backends.mps.is_available()}")
if torch.backends.mps.is_available():
    device = torch.device("mps")
    print(f"Using device: {device}")
```

## Framework Details

### LangChain Setup

LangChain is the primary framework for building LLM applications.

```python
from langchain.llms import OpenAI
from langchain.chains import LLMChain
from langchain.prompts import PromptTemplate

# Initialize LLM
llm = OpenAI(temperature=0.7)

# Create a simple chain
prompt = PromptTemplate(
    input_variables=["product"],
    template="What is a good name for a company that makes {product}?",
)
chain = LLMChain(llm=llm, prompt=prompt)

# Run the chain
result = chain.run("eco-friendly water bottles")
print(result)
```

### AutoGen Multi-Agent

Microsoft AutoGen for building multi-agent conversations.

```python
import autogen

# Configure agents
config_list = [{
    "model": "gpt-4",
    "api_key": os.environ["OPENAI_API_KEY"],
}]

# Create assistant agent
assistant = autogen.AssistantAgent(
    name="assistant",
    llm_config={"config_list": config_list},
)

# Create user proxy agent
user_proxy = autogen.UserProxyAgent(
    name="user_proxy",
    human_input_mode="NEVER",
    max_consecutive_auto_reply=10,
)

# Start conversation
user_proxy.initiate_chat(
    assistant,
    message="Write a Python function to calculate fibonacci numbers"
)
```

### CrewAI Teams

Build teams of AI agents with specific roles.

```python
from crewai import Agent, Task, Crew

# Define agents
researcher = Agent(
    role='Researcher',
    goal='Research and provide accurate information',
    backstory='Expert at finding and analyzing information',
    verbose=True
)

writer = Agent(
    role='Writer',
    goal='Create compelling content',
    backstory='Skilled content creator and storyteller',
    verbose=True
)

# Define tasks
research_task = Task(
    description='Research the latest AI trends',
    agent=researcher
)

writing_task = Task(
    description='Write a blog post about the research findings',
    agent=writer
)

# Create and run crew
crew = Crew(
    agents=[researcher, writer],
    tasks=[research_task, writing_task],
    verbose=True
)

result = crew.kickoff()
```

### Vector Databases

#### ChromaDB Setup

```python
import chromadb
from chromadb.utils import embedding_functions

# Initialize client
client = chromadb.PersistentClient(path="./chroma_db")

# Create collection with OpenAI embeddings
openai_ef = embedding_functions.OpenAIEmbeddingFunction(
    api_key=os.environ["OPENAI_API_KEY"],
    model_name="text-embedding-ada-002"
)

collection = client.create_collection(
    name="documents",
    embedding_function=openai_ef
)

# Add documents
collection.add(
    documents=["Document 1", "Document 2"],
    metadatas=[{"source": "file1"}, {"source": "file2"}],
    ids=["doc1", "doc2"]
)

# Query
results = collection.query(
    query_texts=["search query"],
    n_results=2
)
```

#### FAISS Setup

```python
import faiss
import numpy as np

# Create index
dimension = 768  # Embedding dimension
index = faiss.IndexFlatL2(dimension)

# Add vectors (example with random data)
vectors = np.random.random((1000, dimension)).astype('float32')
index.add(vectors)

# Search
query = np.random.random((1, dimension)).astype('float32')
distances, indices = index.search(query, k=5)
print(f"Nearest neighbors: {indices}")
```

## Configuration

### Environment Variables

Create a `.env` file in your project root:

```env
# LLM API Keys
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...
GROQ_API_KEY=gsk_...
MISTRAL_API_KEY=...
HUGGINGFACE_API_KEY=hf_...

# Vector Database
PINECONE_API_KEY=...
WEAVIATE_URL=http://localhost:8080

# Model Configuration
MODEL_NAME=gpt-4
MODEL_TEMPERATURE=0.7
MODEL_MAX_TOKENS=2000
EMBEDDING_MODEL=text-embedding-ada-002

# Development
DEBUG=false
LOG_LEVEL=INFO
```

### Loading Configuration

```python
from dotenv import load_dotenv
import os

# Load environment variables
load_dotenv()

# Access configuration
api_key = os.getenv("OPENAI_API_KEY")
model_name = os.getenv("MODEL_NAME", "gpt-4")
temperature = float(os.getenv("MODEL_TEMPERATURE", "0.7"))
```

## Troubleshooting

### Common Issues

#### 1. CUDA Out of Memory

```python
# Clear GPU cache
import torch
torch.cuda.empty_cache()

# Use smaller batch sizes
batch_size = 8  # Reduce from 32

# Use mixed precision
from torch.cuda.amp import autocast
with autocast():
    # Your model code here
    pass
```

#### 2. Package Conflicts

```bash
# Create fresh virtual environment
python3 -m venv ai_env
source ai_env/bin/activate
pip install --upgrade pip

# Reinstall packages
./scripts/setup_ai_frameworks.sh
```

#### 3. API Rate Limits

```python
import time
from tenacity import retry, wait_exponential, stop_after_attempt

@retry(
    wait=wait_exponential(multiplier=1, min=4, max=10),
    stop=stop_after_attempt(3)
)
def call_api():
    # Your API call here
    pass
```

#### 4. Memory Issues

```bash
# Monitor memory usage
watch -n 1 free -h

# Limit memory usage in Python
import resource
resource.setrlimit(resource.RLIMIT_AS, (8 * 1024 * 1024 * 1024, -1))  # 8GB limit
```

## Examples

### 1. Simple RAG Application

```python
from langchain.document_loaders import TextLoader
from langchain.embeddings.openai import OpenAIEmbeddings
from langchain.vectorstores import Chroma
from langchain.chains import RetrievalQA
from langchain.llms import OpenAI

# Load documents
loader = TextLoader("document.txt")
documents = loader.load()

# Create vector store
embeddings = OpenAIEmbeddings()
vectorstore = Chroma.from_documents(documents, embeddings)

# Create QA chain
qa = RetrievalQA.from_chain_type(
    llm=OpenAI(),
    chain_type="stuff",
    retriever=vectorstore.as_retriever()
)

# Query
answer = qa.run("What is the main topic of the document?")
print(answer)
```

### 2. Streamlit Chat Interface

```python
import streamlit as st
from langchain.llms import OpenAI
from langchain.memory import ConversationBufferMemory
from langchain.chains import ConversationChain

st.title("AI Chat Assistant")

# Initialize session state
if "messages" not in st.session_state:
    st.session_state.messages = []
    st.session_state.chain = ConversationChain(
        llm=OpenAI(temperature=0.7),
        memory=ConversationBufferMemory()
    )

# Display chat history
for message in st.session_state.messages:
    with st.chat_message(message["role"]):
        st.markdown(message["content"])

# User input
if prompt := st.chat_input("What's on your mind?"):
    # Add user message
    st.session_state.messages.append({"role": "user", "content": prompt})
    with st.chat_message("user"):
        st.markdown(prompt)

    # Generate response
    response = st.session_state.chain.run(prompt)

    # Add assistant message
    st.session_state.messages.append({"role": "assistant", "content": response})
    with st.chat_message("assistant"):
        st.markdown(response)
```

### 3. Jupyter Notebook Setup

```bash
# Install Jupyter kernel
python3 -m ipykernel install --user --name ai_dev --display-name "AI Development"

# Start Jupyter
jupyter notebook

# Or JupyterLab
jupyter lab
```

## Best Practices

### 1. API Key Management

- Never commit API keys to version control
- Use `.env` files with `.gitignore`
- Rotate keys regularly
- Use different keys for dev/prod

### 2. Cost Management

```python
# Token counting
import tiktoken

def count_tokens(text, model="gpt-4"):
    encoding = tiktoken.encoding_for_model(model)
    return len(encoding.encode(text))

# Estimate cost
tokens = count_tokens(prompt)
cost = (tokens / 1000) * 0.03  # GPT-4 pricing
print(f"Estimated cost: ${cost:.4f}")
```

### 3. Error Handling

```python
import logging
from typing import Optional

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def safe_api_call(prompt: str) -> Optional[str]:
    try:
        response = llm.invoke(prompt)
        return response
    except RateLimitError:
        logger.warning("Rate limit hit, waiting...")
        time.sleep(60)
        return safe_api_call(prompt)
    except Exception as e:
        logger.error(f"API call failed: {e}")
        return None
```

### 4. Performance Optimization

- Use caching for repeated queries
- Batch process when possible
- Implement streaming for long responses
- Use async operations for concurrent calls

```python
import asyncio
from langchain.llms import OpenAI

async def async_generate(prompts):
    llm = OpenAI()
    tasks = [llm.agenerate([prompt]) for prompt in prompts]
    results = await asyncio.gather(*tasks)
    return results

# Run async
prompts = ["Prompt 1", "Prompt 2", "Prompt 3"]
results = asyncio.run(async_generate(prompts))
```

## Next Steps

1. **Explore Examples**: Check the `examples/` directory for more code samples
2. **Join Community**: Connect with other AI developers
3. **Build Projects**: Start with simple chatbots, then move to complex agents
4. **Contribute**: Share your configurations and improvements

## Resources

- [LangChain Documentation](https://python.langchain.com/)
- [AutoGen Documentation](https://microsoft.github.io/autogen/)
- [CrewAI Documentation](https://docs.crewai.com/)
- [OpenAI Cookbook](https://cookbook.openai.com/)
- [Anthropic Documentation](https://docs.anthropic.com/)

---

*Last updated: September 2025*
