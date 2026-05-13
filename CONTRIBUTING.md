# Contributing

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This project creates Terraform and Ansible scaffolding first, then requires
architecture notes and documentation before scaffolds become deployable OCI
resources. The goal is to keep infrastructure patterns explainable before they
are applied.

## Workflow

1. Add or update Terraform and Ansible scaffold files.
2. Create or update the relevant `architecture/README.md` before real resources.
3. Update the blueprint or module README.
4. Implement Terraform in the smallest useful scope.
5. Run local validation.

## Local Validation

Run these checks before opening a pull request:

```bash
./scripts/validate-all.sh
```

The validation helper delegates to Ansible when available. It runs Terraform
formatting, discovers implemented blueprints, initializes and validates them
without a backend, runs optional local linters when installed, checks Ansible
playbook syntax, and removes generated Terraform artifacts.

For a focused local check from a single blueprint directory:

```bash
terraform init -backend=false
terraform validate
```

Generated Terraform folders, lock files, plans, state files, local tfvars, and
`.codex-local/` or `.claude/` workspace data are workstation-only artifacts.
Clean them before committing so reviews stay focused on source, examples, and
documentation.

## Architecture Gate

Do not add real OCI resources or apply Terraform for a blueprint until its local
architecture notes describe the intended design, scope, and review assumptions.

## Pull Request Checklist

- The change is scoped to one blueprint, module family, or documentation area.
- Architecture notes and rendered review artifacts are updated when relevant.
- Naming follows `docs/NAMING-CONVENTIONS.md`.
- New variables are documented in `VARIABLES.md` or the blueprint README.
- Security-sensitive defaults are conservative.
- No secrets, OCIDs from private tenancies, or local `terraform.tfvars` files are
  committed.
