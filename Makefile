.PHONY: audit fmt lint test install help

# Default target
help:
	@echo "Available targets:"
	@echo "  audit    - Run comprehensive audit on all scripts"
	@echo "  fmt      - Fix line endings and formatting issues"
	@echo "  lint     - Run shellcheck on all scripts"
	@echo "  test     - Run basic tests"
	@echo "  install  - Install required tools"
	@echo "  help     - Show this help message"

audit:
	@bash tools/audit_setup_scripts.sh

fmt:
	@echo "==> Fixing line endings..."
	@find . -type f -name "*.sh" -print0 | xargs -0 -n1 sh -c 'sed -i "s/\r$$//" "$$0"'
	@echo "==> Making scripts executable..."
	@find . -type f -name "*.sh" -not -path "./.git/*" -print0 | xargs -0 chmod +x
	@echo "✓ Formatting complete"

lint:
	@if command -v shellcheck >/dev/null 2>&1; then \
		echo "==> Running shellcheck..."; \
		find . -type f -name "*.sh" -not -path "./.git/*" -print0 | xargs -0 shellcheck -S warning; \
	else \
		echo "shellcheck not installed. Run 'make install' first."; \
		exit 1; \
	fi

test:
	@echo "==> Running basic tests..."
	@bash -n install_key_software_wsl.sh
	@bash -n setup_agents_global.sh
	@bash -n setup_agents_repo.sh
	@bash -n repo_setup_wizard.sh
	@bash -n validate_agents.sh
	@echo "✓ All scripts have valid syntax"

install:
	@echo "==> Installing required tools..."
	@if ! command -v shellcheck >/dev/null 2>&1; then \
		sudo apt-get update && sudo apt-get install -y shellcheck; \
	fi
	@if ! command -v pre-commit >/dev/null 2>&1; then \
		pip install --user pre-commit || pipx install pre-commit; \
	fi
	@echo "✓ Tools installed"


# --- Prompt checks ---
prompt-audit:
	@bash tools/prompt_lint.sh CLAUDE.md || true
	@[ -f .claude/commands/secure-fix.md ] && echo "[ok] /secure-fix present" || echo "[miss] .claude/commands/secure-fix.md"

.PHONY: prompt-audit

# --- Structured Output Targets ---
audit-json:
	@echo '{"timestamp":"'$$(date -u +"%Y-%m-%dT%H:%M:%SZ")'",' > audit-results.json
	@echo '"shellcheck":' >> audit-results.json
	@find . -type f -name "*.sh" -not -path "./.git/*" -print0 | \
		xargs -0 shellcheck -f json >> audit-results.json 2>&1 || echo '[]' >> audit-results.json
	@echo ',' >> audit-results.json
	@echo '"file_count":'$$(find . -type f -name "*.sh" | wc -l)',' >> audit-results.json
	@echo '"status":"complete"}' >> audit-results.json
	@echo "✓ JSON audit results written to audit-results.json"

security-json:
	@echo '{"scan_date":"'$$(date -u +"%Y-%m-%dT%H:%M:%SZ")'",' > security-scan.json
	@echo '"checks":{' >> security-scan.json
	@echo '"secrets":'$$(gitleaks detect --no-banner --report-format json 2>/dev/null || echo '{"findings":0}')','  >> security-scan.json
	@echo '"permissions":'$$(find . -type f -name "*.sh" -perm /111 | wc -l)',' >> security-scan.json
	@echo '"sensitive_files":'$$(find . -name ".env*" -o -name "*secret*" -o -name "*token*" | wc -l) >> security-scan.json
	@echo '}}' >> security-scan.json
	@echo "✓ Security scan results written to security-scan.json"

stats:
	@echo "=== Repository Statistics ==="
	@echo "Scripts: $$(find . -type f -name "*.sh" | wc -l)"
	@echo "Lines of code: $$(find . -type f -name "*.sh" -exec cat {} \; | wc -l)"
	@echo "Functions: $$(grep -h "^[[:space:]]*.*()[[:space:]]*{" **/*.sh 2>/dev/null | wc -l)"
	@echo "TODOs: $$(grep -r "TODO\|FIXME" --include="*.sh" . | wc -l)"
	@echo ""
	@echo "=== File Breakdown ==="
	@find . -type f -name "*.sh" -exec wc -l {} \; | sort -rn | head -10

stats-json:
	@echo '{' > stats.json
	@echo '"scripts":'$$(find . -type f -name "*.sh" | wc -l)',' >> stats.json
	@echo '"loc":'$$(find . -type f -name "*.sh" -exec cat {} \; | wc -l)',' >> stats.json
	@echo '"functions":'$$(grep -h "^[[:space:]]*.*()[[:space:]]*{" **/*.sh 2>/dev/null | wc -l)',' >> stats.json
	@echo '"todos":'$$(grep -r "TODO\|FIXME" --include="*.sh" . | wc -l) >> stats.json
	@echo '}' >> stats.json
	@echo "✓ Stats written to stats.json"

.PHONY: audit-json security-json stats stats-json
