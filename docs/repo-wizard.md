# Repo Wizard Tutorial

Use the wizard to clone a repository into an organized folder structure and seed agent configs.

Interactive
```bash
./repo_setup_wizard.sh
```

Non-Interactive
```bash
./repo_setup_wizard.sh --non-interactive \
  --org myorg \
  --category backend \
  --url git@github.com:user/repo.git \
  --branch main
```

After Cloning
```bash
cd ~/projects/<org>/<category>/<repo>
# The wizard can apply a profile for you. If you skip that:
scripts/apply_profile.sh --skill beginner --phase mvp --teach-mode on
```

What gets created
- `CLAUDE.md`, `AGENTS.md`: guardrails and agent guidance
- `.claude/` with `settings.json` and command prompts
- `.mcp.json` (if enabled)
- `.envrc` and `.envrc.local` template
- `.gitignore` hygiene entries
- `system/active.md` built from layered system templates (when applying a profile)

Tips
- Use `scripts/repo_analysis.sh` for a quick repository survey
- `scripts/run_checks.sh` runs available lints/tests
- Add Codex targets with `--with-codex` to the wizard if needed

Beginner Teach Mode Prompt
- In interactive mode, the wizard asks: “Beginner teach mode (guided, verbose CoT)? (Y/n)”
- Your choice is persisted via `scripts/apply_profile.sh --teach-mode on|off`.
- Extended thinking remains off by default; use `/think-deep` when needed.

Secrets Guidance
- If API keys are missing (e.g., `ANTHROPIC_API_KEY`, `OPENAI_API_KEY`), the wizard prints GitHub repo secrets commands.
- With `gh` authenticated, you can optionally run `gh secret set <KEY>` interactively.
- Placeholders are added to `.envrc.local.example`; remember to `direnv allow` when you set real values.
