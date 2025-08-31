# Devcontainer

This repo includes a minimal devcontainer for consistent local development:

Location
- `.devcontainer/devcontainer.json`
- `.devcontainer/Dockerfile`

What’s inside
- Ubuntu base with: bash, curl/wget, jq, ripgrep, fd, direnv, shellcheck, make, bats
- Node LTS via nvm + pnpm via corepack
- Python 3 + venv + pip

Use it
```bash
devcontainer build --workspace-folder .
devcontainer open --workspace-folder .
```

Templates for downstream repos
- A richer template exists under `templates/.devcontainer/` with language/tool features.
- Use `scripts/apply_profile.sh` to configure repos and copy templates as needed.

