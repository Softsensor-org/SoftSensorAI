.PHONY: audit fmt

audit:
	@bash tools/audit_setup_scripts.sh

fmt:
	@find . -type f -name "*.sh" -print0 | xargs -0 -n1 sh -c 'sed -i "s/\r$$//" "$$0";'

