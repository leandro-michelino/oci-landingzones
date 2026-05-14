# Contributing

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This project keeps Terraform, Ansible, and architecture documentation moving
together. A blueprint is considered ready only when its Terraform resources,
local runners, README, and ASCII architecture describe the same deployable OCI
pattern.

## Workflow

1. Add or update Terraform and local Ansible runner files.
2. Create or update the relevant `architecture/README.md` with the intended
   control flow, trust boundary, traffic or signal path, and review assumptions.
3. Update the blueprint or module README.
4. Keep Terraform changes in the smallest useful scope.
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
- Architecture notes are updated when relevant.
- Naming follows `docs/NAMING-CONVENTIONS.md`.
- New variables are documented in `VARIABLES.md` or the blueprint README.
- Security-sensitive defaults are conservative.
- No secrets, OCIDs from private tenancies, or local `terraform.tfvars` files are
  committed.
