# Contributing

This project uses a diagram-first and documentation-first workflow for landing
zone changes. The goal is to keep OCI infrastructure patterns explainable before
they become deployable.

## Workflow

1. Create or update the relevant architecture diagram.
2. Update the blueprint or module README.
3. Implement Terraform in the smallest useful scope.
4. Run local validation.
5. Open a pull request with diagrams, docs, Terraform, and test evidence.

## Local Validation

Run these checks before opening a pull request:

```bash
terraform fmt -recursive
pre-commit run --all-files
```

When Terraform files are added, also run validation from the relevant blueprint
directory:

```bash
terraform init -backend=false
terraform validate
tflint --recursive
checkov -d . --framework terraform --compact
```

## Diagram Gate

Do not implement or apply Terraform for a blueprint until its required diagram
exists under `docs/architecture/diagrams/` and is reflected in the tracker.

## Pull Request Checklist

- The change is scoped to one blueprint, module family, or documentation area.
- The required Excalidraw source and exported image are included when relevant.
- Naming follows `docs/NAMING-CONVENTIONS.md`.
- New variables are documented in `VARIABLES.md` or the blueprint README.
- Security-sensitive defaults are conservative.
- No secrets, OCIDs from private tenancies, or local `terraform.tfvars` files are
  committed.
