# DevPilot Makefile
# Automation for AI development platform setup, auditing, and ticket generation

.PHONY: help install setup audit tickets clean lint test fmt docs-index prompt-audit security-json config-validate test-bats devcontainer-build devcontainer-open doctor
.DEFAULT_GOAL := help

# Colors for output
CYAN := \033[0;36m
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m # No Color

help: ## Show this help message
	@echo "$(CYAN)DevPilot - AI Development Platform$(NC)"
	@echo ""
	@echo "$(YELLOW)Usage:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Examples:$(NC)"
	@echo "  make install                    # Install DevPilot globally"
	@echo "  make clean                      # Clean up generated files"
	@echo "  make test                       # Run syntax validation"
	@echo "  make security-json              # Generate security report"

install: ## Install DevPilot global configuration
	@echo "$(CYAN)Installing DevPilot global setup...$(NC)"
	./setup_agents_global.sh
	@echo "$(GREEN)✓ DevPilot global setup complete$(NC)"

audit\:prompt: ## Open audit template for Claude Code
	@echo "$(CYAN)Audit commands available:$(NC)"
	@echo "  /audit-full    - Comprehensive 90-minute audit"
	@echo "  /audit-quick   - Quick 20-minute scan"
	@echo ""
	@echo "$(YELLOW)Variables to customize:$(NC)"
	@echo "  RUNTIMES: Node.js/Python/Go/etc"
	@echo "  TARGET_ENV: Docker+k8s/Local/Cloud"
	@echo "  KEY_CONCERNS: security, performance, reliability"

tickets: ## Generate tickets (usage: make tickets mode=BOTH)
	@echo "$(CYAN)Generating tickets...$(NC)"
	./scripts/generate_tickets.sh --mode $(or $(mode),GITHUB_MARKDOWN)
	@echo "$(GREEN)✓ Tickets generated$(NC)"

clean: ## Clean up generated files
	@echo "$(CYAN)Cleaning up...$(NC)"
	rm -rf tickets/ temp/ *.log 2>/dev/null || true
	@echo "$(GREEN)✓ Cleanup complete$(NC)"

lint: ## Run shellcheck on scripts  
	@echo "$(CYAN)Running ShellCheck...$(NC)"
	find . -name "*.sh" -exec shellcheck {} \; || true
	@echo "$(GREEN)✓ Linting complete$(NC)"

test: ## Basic syntax check for core scripts
	@echo "$(CYAN)Bash syntax checks$(NC)"
	@bash -n setup_all.sh
	@bash -n setup_agents_global.sh
	@bash -n setup_agents_repo.sh
	@bash -n repo_setup_wizard.sh
	@bash -n validate_agents.sh
	@echo "$(GREEN)✓ Scripts have valid syntax$(NC)"

fmt: ## Normalize CRLF line endings (portable)
	@echo "$(CYAN)Normalizing line endings...$(NC)"
	@find . -type f -name "*.sh" -print0 | xargs -0 -n1 sh -c 'tmp="$$0.tmp"; tr -d "\r" < "$$0" > "$$tmp" && mv "$$tmp" "$$0"'
	@echo "$(GREEN)✓ Formatting complete$(NC)"

docs-index: ## List available documentation pages
	@echo "$(CYAN)Documentation Index$(NC)"
	@find docs -maxdepth 1 -type f -name "*.md" | sort | sed 's/^/ - /'

prompt-audit: ## Lint CLAUDE.md sections and presence of key commands
	@echo "$(CYAN)Prompt audit$(NC)"
	@bash tools/prompt_lint.sh CLAUDE.md || true
	@[ -f .claude/commands/secure-fix.md ] && echo "[ok] /secure-fix present" || echo "[miss] .claude/commands/secure-fix.md"
	@[ -f .claude/commands/explore-plan-code-test.md ] && echo "[ok] /explore-plan-code-test present" || echo "[miss] .claude/commands/explore-plan-code-test.md"
	@[ -f .claude/commands/think-deep.md ] && echo "[ok] /think-deep present" || echo "[miss] .claude/commands/think-deep.md"
	@[ -f .claude/commands/long-context-map-reduce.md ] && echo "[ok] /long-context-map-reduce present" || echo "[miss] .claude/commands/long-context-map-reduce.md"

security-json: ## Generate security JSON summary (best-effort)
	@echo "$(CYAN)Security scan (JSON)$(NC)"
	@echo '{"scan_date":"'$$(date -u +"%Y-%m-%dT%H:%M:%SZ")'",' > security-scan.json
	@echo '"checks":{' >> security-scan.json
	@echo '"secrets":'`(gitleaks detect --no-banner --report-format json --report-path - 2>/dev/null || echo '{"findings":0}') | tr -d '\n'`',' >> security-scan.json
	@echo '"shell_scripts":'$$(find . -type f -name "*.sh" | wc -l)',' >> security-scan.json
	@echo '"exec_perms":'$$(find . -type f -name "*.sh" -perm /111 | wc -l) >> security-scan.json
	@echo '}}' >> security-scan.json
	@echo "$(GREEN)✓ Wrote security-scan.json$(NC)"

config-validate: ## Validate repo configs against lightweight schemas
	@echo "$(CYAN)Config validation$(NC)"
	@bash tools/config_validate.sh || (echo "$(RED)Schema validation failed$(NC)" && exit 1)
	@echo "$(GREEN)✓ Configs valid$(NC)"

test-bats: ## Run bats tests if available
	@echo "$(CYAN)Running bats tests$(NC)"
	@if command -v bats >/dev/null 2>&1; then \
		bats tests/bats || exit 1; \
	else \
		echo "bats not installed (skipping)"; \
	fi

devcontainer-build: ## Build devcontainer image
	@echo "$(CYAN)Building devcontainer$(NC)"
	@devcontainer build --workspace-folder . || echo "Install @devcontainers/cli to use this"

devcontainer-open: ## Open devcontainer shell
	@devcontainer open --workspace-folder . || echo "Install @devcontainers/cli to use this"

doctor: ## Run environment checks and tips
	@bash scripts/doctor.sh
