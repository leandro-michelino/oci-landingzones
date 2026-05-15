# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com

.PHONY: help validate changed clean blueprint blueprints links

help:
	@printf '%s\n' "Targets:"
	@printf '%s\n' "  make validate                         Run full repository validation"
	@printf '%s\n' "  make changed                          Validate changed files against origin/main"
	@printf '%s\n' "  make clean                            Remove local Terraform and test artifacts"
	@printf '%s\n' "  make blueprint family=<family> name=<name> [title='Nice Name']"
	@printf '%s\n' "  make blueprint path=blueprints/<family>/<name> [title='Nice Name']"
	@printf '%s\n' "  make blueprints                       Regenerate BLUEPRINTS.md"
	@printf '%s\n' "  make links                            Check local Markdown links and anchors"

validate:
	./scripts/validate-all.sh

changed:
	./scripts/validate-changed.sh

clean:
	find . -name ".terraform" -type d -prune -exec rm -rf {} +
	find . \( -name ".terraform.lock.hcl" -o -name "terraform.tfstate*" -o -name "tfplan" -o -name "tfplan.*" -o -name "*.tfplan" -o -name ".DS_Store" \) -type f -delete
	rm -rf .codex-local .claude .ansible

blueprint:
	@if [ -n "$(path)" ]; then \
		./scripts/new-blueprint.sh "$(path)" "$(title)"; \
	else \
		test -n "$(family)" || { echo "family=<family> or path=blueprints/<family>/<name> is required"; exit 1; }; \
		test -n "$(name)" || { echo "name=<name> is required"; exit 1; }; \
		./scripts/new-blueprint.sh "$(family)" "$(name)" "$(title)"; \
	fi

blueprints:
	./scripts/generate-blueprints-index.sh

links:
	./scripts/check-markdown-links.sh
