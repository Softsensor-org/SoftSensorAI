# Setup Scripts Makefile
# Automation for setup, auditing, and ticket generation

.PHONY: help install setup audit tickets clean lint test
.DEFAULT_GOAL := help

# Colors for output
CYAN := \033[0;36m
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m # No Color

help: ## Show this help message
	@echo "$(CYAN)Setup Scripts - Development Automation$(NC)"
	@echo ""
	@echo "$(YELLOW)Usage:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Examples:$(NC)"
	@echo "  make install                    # Install all tools globally"
	@echo "  make setup repo=my-project     # Setup agent files for repo"
	@echo "  make audit:full                # Run comprehensive audit"
	@echo "  make tickets mode=BOTH         # Generate tickets in both formats"

install: ## Install global agent tools and dependencies
	@echo "$(CYAN)Installing global agent setup...$(NC)"
	./setup_agents_global.sh
	@echo "$(GREEN)✓ Global setup complete$(NC)"

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
