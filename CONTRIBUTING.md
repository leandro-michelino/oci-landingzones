# Contributing

This project creates Terraform and Ansible scaffolding first, then requires
diagrams and documentation before scaffolds become deployable OCI resources.
The goal is to keep infrastructure patterns explainable before they are applied.

## Workflow

1. Add or update Terraform and Ansible scaffold files.
2. Create or update the relevant architecture diagram before real resources.
3. Update the blueprint or module README.
4. Implement Terraform in the smallest useful scope.
5. Run local validation.

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

Do not add real OCI resources or apply Terraform for a blueprint until its
required diagram exists under `docs/architecture/diagrams/` and is reflected in
the tracker.

## Pull Request Checklist

- The change is scoped to one blueprint, module family, or documentation area.
- The required Excalidraw source and exported image are included when relevant.
- Naming follows `docs/NAMING-CONVENTIONS.md`.
- New variables are documented in `VARIABLES.md` or the blueprint README.
- Security-sensitive defaults are conservative.
- No secrets, OCIDs from private tenancies, or local `terraform.tfvars` files are
  committed.
