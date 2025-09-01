FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Install base dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    wget \
    git \
    vim \
    nano \
    jq \
    unzip \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    sudo \
    locales \
    tzdata \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Install mise for runtime management
RUN curl https://mise.run | sh && \
    echo 'eval "$(~/.local/bin/mise activate bash)"' >> /etc/bash.bashrc && \
    echo 'eval "$(~/.local/bin/mise activate zsh)"' >> /etc/zsh/zshrc

# Install Node.js LTS via mise
ENV PATH="/root/.local/share/mise/shims:${PATH}"
RUN /root/.local/bin/mise use --global node@lts

# Install Python via mise
RUN /root/.local/bin/mise use --global python@3.11

# Install essential package managers
RUN npm install -g pnpm@latest && \
    pip install --upgrade pip && \
    pip install pipx uv && \
    pipx ensurepath

# Install just (task runner)
RUN curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin

# Install development tools
RUN apt-get update && apt-get install -y \
    ripgrep \
    fd-find \
    direnv \
    httpie \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && ln -s $(which fdfind) /usr/local/bin/fd

# Install Docker CLI (Docker-in-Docker handled by devcontainer feature)
RUN curl -fsSL https://get.docker.com | sh

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl

# Install Helm
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install Terraform
RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list && \
    apt-get update && apt-get install -y terraform && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Python development tools
RUN pipx install ruff black mypy pytest poetry

# Node development tools
RUN npm install -g \
    typescript \
    @types/node \
    eslint \
    prettier \
    jest \
    @devcontainers/cli

# API development tools
RUN npm install -g \
    @redocly/cli \
    @stoplight/spectral-cli \
    openapi-typescript \
    @graphql-codegen/cli \
    newman

# Database tools
RUN pipx install \
    pgcli \
    sqlite-utils \
    sqlfluff

# Security tools
RUN pipx install semgrep

# Create vscode user (if not exists)
RUN id -u vscode &>/dev/null || useradd -m -s /bin/bash vscode && \
    echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/vscode

# Switch to vscode user
USER vscode
WORKDIR /home/vscode

# Configure mise for vscode user
RUN curl https://mise.run | sh && \
    echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc && \
    echo 'eval "$(~/.local/bin/mise activate zsh)"' >> ~/.zshrc && \
    ~/.local/bin/mise use --global node@lts python@3.11

# Set up direnv
RUN echo 'eval "$(direnv hook bash)"' >> ~/.bashrc && \
    echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc

# Final environment setup
ENV DEBIAN_FRONTEND=dialog
ENV PATH="/home/vscode/.local/bin:${PATH}"

# Default command
CMD ["sleep", "infinity"]
