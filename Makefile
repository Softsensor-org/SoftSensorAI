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

