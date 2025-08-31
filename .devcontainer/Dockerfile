FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl wget git jq unzip software-properties-common \
    ripgrep fd-find direnv shellcheck make \
    python3 python3-venv python3-pip \
    bats \
  && ln -s $(which fdfind) /usr/local/bin/fd \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Node LTS + pnpm via corepack
RUN curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash \
  && . "$HOME/.nvm/nvm.sh" \
  && nvm install --lts \
  && corepack enable \
  && corepack prepare pnpm@latest --activate

# Install mise and apply pinned versions from .mise.toml (optional)
ENV PATH="/root/.local/bin:${PATH}"
RUN curl -fsSL https://mise.run | sh \
  && echo 'eval "$(~/.local/bin/mise activate bash)"' >> /etc/bash.bashrc \
  && ~/.local/bin/mise --version || true \
  && ~/.local/bin/mise install || true

ENV DEBIAN_FRONTEND=dialog
CMD ["sleep","infinity"]
