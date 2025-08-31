# Validation & Troubleshooting

Validate Config Across Projects
```bash
./validate_agents.sh               # defaults to ~/projects
./validate_agents.sh ~/my-workarea
./validate_agents.sh --json ~/my-workarea   # machine-readable
./validate_agents.sh --fix  ~/my-workarea   # auto-seed missing files (no overwrite)
```

What It Checks
- Required files: `CLAUDE.md`, `AGENTS.md`, `.claude/settings.json`, `.mcp.json`
- Optional commands: `.claude/commands/*`
- JSON validity via `jq`
- Tool availability (ripgrep, jq, pnpm, direnv, CLIs)

Fix Common Issues
```bash
# In the repo missing files
<path-to-setup-scripts>/setup_agents_repo.sh --force   # or rerun from this repo: ./setup_agents_repo.sh

# CRLF or shell nits in this repo
make fmt && make audit
```

Common Pitfalls
- Missing API keys: export provider keys in your shell rc or `.envrc.local`
- Direnv not loading: run `direnv allow` in the repo folder
- Docker sandbox errors: ensure Docker Desktop + WSL integration are enabled
- YAML/JSON errors: run `yamllint` and `jq -e type <file>`

Getting Help
- See `README.md` for commands
- Open an issue with the error output and `tools/audit_setup_scripts.sh` results
