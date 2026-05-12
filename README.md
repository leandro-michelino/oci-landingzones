# OCI Landing Zones

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This repository is a practical OCI landing-zone framework built from recurring
customer patterns: core governance, IAM, networking, security controls,
operating-entity onboarding, and optional service extensions.

It is a personal engineering project, not an official Oracle product. The goal
is to provide reusable Terraform modules, independently deployable architecture
blueprints, local Ansible orchestration, and editable Excalidraw diagrams that
can be adapted for real OCI environments.

## What Is Included

- A core landing-zone baseline for compartments, IAM, tagging, logging,
  monitoring, budgets, Cloud Guard, Vault/KMS, Security Zones, VSS, events, and
  related governance controls.
- Standalone architecture blueprints for networking, CIS profiles, operating
  entities, extensions, compliance, data platform, disaster recovery, identity,
  and industry patterns.
- Reusable Terraform modules under `modules/`.
- Local Ansible playbooks for bootstrap checks, validation, Terraform plan,
  guarded apply, guarded destroy, and ephemeral tests.
- Architecture documentation with editable Excalidraw sources.

## Repository Layout

```text
blueprints/    Deployable architecture entry points
modules/       Reusable Terraform building blocks
ansible/       Local orchestration and validation playbooks
docs/          Deployment guides, architecture notes, runbooks, and mappings
environments/  Environment examples and backend shape
scripts/       Thin local command wrappers
tests/         Test scaffolding
```

## Requirements

- Terraform `1.12.0` or later.
- OCI CLI configured for the target tenancy.
- Git for pinned module sources and sparse checkout workflows.
- Ansible for the full local validation and orchestration workflow.
- Optional local scanners: `tflint`, `tfsec`, `checkov`, `ansible-lint`, and
  `pre-commit`.

## Use One Architecture

Blueprints are designed to be consumed independently. Their module sources are
pinned Git sources, so Terraform fetches shared modules from this repository
release during `terraform init`.

Example: use only the default standalone three-tier VCN blueprint.

```bash
git clone --filter=blob:none --sparse https://github.com/leandro-michelino/oci-landingzones.git
cd oci-landingzones

git sparse-checkout set blueprints/networking/standalone-three-tier-vcn-defaults

cd blueprints/networking/standalone-three-tier-vcn-defaults
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

Set `compartment_ocid` to the target workload compartment when deploying a
single blueprint. That compartment can come from `blueprints/core/`, another
landing-zone process, or an existing brownfield tenancy.

## Use The Full Repository

For full landing-zone work, start with the core baseline and then add the
blueprints needed by the environment.

```bash
git clone https://github.com/leandro-michelino/oci-landingzones.git
cd oci-landingzones

./scripts/validate-all.sh
```

Recommended deployment order:

1. Bootstrap remote state, OCI CLI access, and tenancy prerequisites.
2. Deploy `blueprints/core/`.
3. Deploy one networking blueprint.
4. Add operating entities or workload vending where needed.
5. Add optional extensions such as OKE, WAF, Exadata, API Gateway, or Streaming.
6. Run validation and security scanning before merging changes.

## Blueprint Families

| Family | Purpose |
|---|---|
| `blueprints/core/` | Shared landing-zone baseline for IAM, governance, security, logging, and operations. |
| `blueprints/cis/` | Dedicated CIS Level 1 and Level 2 landing-zone profiles. |
| `blueprints/networking/` | Standalone VCN, private-only, hub-spoke, DRG, VPN, FastConnect, DNS, firewall, NVA, ZPR, multicloud, and regional patterns. |
| `blueprints/operating-entity/` | Business unit, subsidiary, workload owner, and application-team onboarding. |
| `blueprints/extensions/` | Optional service add-ons such as OKE, WAF, Exadata, API Gateway, and Streaming. |
| `blueprints/identity/` | Identity-domain and federation patterns. |
| `blueprints/compliance/` | Regulated and stricter-control landing-zone shapes. |
| `blueprints/data-platform/` | Private data and analytics landing-zone patterns. |
| `blueprints/disaster-recovery/` | OCI Full Stack Disaster Recovery patterns. |
| `blueprints/industry/` | Industry-oriented landing-zone variants. |

Use `docs/DEPLOYMENT-PATTERN-CATALOG.md` for the full pattern list and status.

## CIS Profiles

Generic blueprints do not enable CIS behavior by default. Use one of the
dedicated CIS folders when a CIS-aligned landing zone is required:

```text
blueprints/cis/level1/
blueprints/cis/level2/
```

See `docs/CIS-PROFILES.md` for the current CIS contract and behavior.

## Module Contract

Reusable modules should keep a consistent interface where applicable:

- `tenancy_ocid`
- `compartment_ocid`
- `region`
- `org`
- `environment`
- `region_key`
- `cis_level`
- `defined_tags`
- `freeform_tags`

Modules output stable identifiers such as OCIDs, names, and maps needed by
blueprints. Remote state belongs to deployable blueprints, not shared modules.

## Validation

The main local validation command is:

```bash
./scripts/validate-all.sh
```

When Ansible is installed, this delegates to `ansible/playbooks/validate.yml`.
The playbook runs Terraform formatting, discovers implemented blueprints under
`blueprints/`, initializes and validates them without a backend, checks Ansible
syntax, runs optional local linters when available, and removes generated
Terraform artifacts afterward.

## Documentation

- `docs/DEPLOYMENT-GUIDE.md` - deployment sequence and operating notes.
- `docs/DEPLOYMENT-PATTERN-CATALOG.md` - blueprint catalog and selection notes.
- `docs/architecture/` - shared architecture diagrams and diagram rules.
- `docs/CIS-PROFILES.md` - CIS profile behavior.
- `docs/ARCH-MAPPING-CIS.md` - CIS mapping notes.
- `docs/NAMING-CONVENTIONS.md` - naming standard.
- `docs/RUNBOOK.md` - operational runbook.

Every deployable blueprint should include:

- `README.md`
- `terraform.tfvars.example`
- `architecture/README.md`
- an editable `.excalidraw` diagram

## Repository Hygiene

Generated Terraform and local test files are intentionally ignored:
`.terraform/`, `.terraform.lock.hcl`, `terraform.tfstate*`, `*.tfplan`,
local `terraform.tfvars`, and `.codex-local/`.

The validation playbook cleans generated Terraform artifacts automatically. For
manual cleanup:

```bash
find . -name ".terraform" -type d -prune -exec rm -rf {} +
find . -name ".terraform.lock.hcl" -type f -delete
find . -name "terraform.tfstate*" -type f -delete
rm -rf .codex-local
```

## Release Discipline

Blueprint module sources are pinned to release tags such as `v0.1.0`. When a
new release is cut, update blueprint source refs deliberately in the tagged
commit. Avoid `?ref=main` for customer-facing architecture folders because it
can change module behavior without review.

## License

This project is licensed under the Apache License 2.0. See `LICENSE` for
details.
