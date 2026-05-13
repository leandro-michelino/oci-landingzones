# OCI Landing Zones

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This repo is a practical OCI landing-zone toolkit. It collects Terraform
modules, ready-to-use blueprints, Ansible helpers, and architecture notes for
the landing-zone patterns that tend to come up again and again: core
governance, IAM, networking, security, operating entities, extensions, and a few
specialized industry or compliance shapes.

Small but important note: this is a personal engineering project, not an
official Oracle product. Treat it as a reusable accelerator that you can review,
adapt, and harden for your own OCI environments.

## Start Here

Most people use this repo in one of two ways:

1. Use one blueprint, such as a standalone three-tier VCN or an OKE extension.
2. Use the full repo, starting with `blueprints/core/` and then adding the
   network, operating entity, and extension patterns needed by the environment.

If you are just exploring, start with the validation command:

```bash
git clone https://github.com/leandro-michelino/oci-landingzones.git
cd oci-landingzones

./scripts/validate-all.sh
```

That checks Terraform formatting, validates implemented blueprints, runs Ansible
syntax checks, uses optional scanners when installed, and cleans generated
Terraform artifacts afterward.

## What You Get

- A core landing-zone baseline for compartments, IAM, tagging, logging,
  monitoring, budgets, Cloud Guard, Vault/KMS, Security Zones, VSS, Events, and
  related governance controls.
- Deployable blueprints for networking, CIS profiles, operating entities,
  extensions, compliance, data platform, disaster recovery, identity, and
  industry patterns.
- Reusable Terraform modules under `modules/`.
- Local Ansible orchestration for bootstrap, validation, plan, guarded apply,
  guarded destroy, and ephemeral tests.
- Blueprint-local architecture notes with ASCII diagrams, assumptions, and
  review checklists.

## Repo Map

```text
blueprints/    Pick one of these when you want a deployable architecture.
modules/       Reusable Terraform building blocks used by the blueprints.
ansible/       Local orchestration for validation, plan, apply, and destroy.
docs/          Deployment guides, catalog, runbooks, mappings, and standards.
environments/  Example backend and tfvars shapes for dev, uat, and prod.
scripts/       Thin command wrappers around Ansible and Terraform workflows.
tests/         Test scaffolding.
```

## Requirements

- Terraform `1.12.0` or later.
- OCI CLI configured for the target tenancy.
- Git, because blueprints use pinned Git module sources.
- Ansible for the full local workflow.
- Optional scanners: `tflint`, `tfsec`, `checkov`, `ansible-lint`, and
  `pre-commit`.

The repo still works without the optional scanners; validation will simply skip
what is not installed.

## Use One Blueprint

Blueprints are meant to stand on their own. Their Terraform module sources are
pinned to repository release tags, so you can sparse-checkout a single
architecture and still fetch the shared modules during `terraform init`.

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

For a single networking blueprint, set `compartment_ocid` to the workload
compartment where resources should land. That compartment can come from
`blueprints/core/`, another landing-zone process, or an existing brownfield
tenancy.

## Use The Full Landing Zone

For a fuller environment, start with the core baseline and add only the patterns
you actually need.

Recommended order:

1. Bootstrap remote state, OCI CLI access, and tenancy prerequisites.
2. Deploy `blueprints/core/`.
3. Deploy one networking blueprint.
4. Add operating entities or workload vending if ownership boundaries matter.
5. Add optional extensions such as OKE, WAF, Exadata, API Gateway, or Streaming.
6. Run validation and security scanning before merging or applying changes.

The deployment guide has the longer version:

```text
docs/DEPLOYMENT-GUIDE.md
```

## Blueprint Families

| Family | When To Use It |
|---|---|
| `blueprints/core/` | You need the shared IAM, governance, security, logging, and operations baseline. |
| `blueprints/cis/` | You need dedicated CIS Level 1 or Level 2 landing-zone behavior. |
| `blueprints/networking/` | You need standalone VCNs, hub-spoke, DRG, VPN, FastConnect, DNS, firewall, NVA, ZPR, multicloud, or regional patterns. |
| `blueprints/operating-entity/` | You need business unit, subsidiary, workload owner, or application-team onboarding. |
| `blueprints/extensions/` | You want optional service add-ons such as OKE, WAF, Exadata, API Gateway, or Streaming. |
| `blueprints/identity/` | You are shaping identity domains, federation, groups, and policy scope. |
| `blueprints/compliance/` | You need a stricter landing-zone shape for regulated environments. |
| `blueprints/data-platform/` | You are building a private data or analytics landing-zone pattern. |
| `blueprints/disaster-recovery/` | You are working on OCI Full Stack Disaster Recovery patterns. |
| `blueprints/industry/` | You need an industry-oriented variant, such as telco cloud-native. |

For the complete menu and current implementation status, see:

```text
docs/DEPLOYMENT-PATTERN-CATALOG.md
```

## CIS Profiles

Generic blueprints do not turn on CIS behavior by default. If you need a
CIS-aligned landing zone, start from one of these dedicated folders:

```text
blueprints/cis/level1/
blueprints/cis/level2/
```

The current CIS contract lives here:

```text
docs/CIS-PROFILES.md
```

## Architecture Notes

Every deployable blueprint should include:

- `README.md`
- `terraform.tfvars.example`
- `architecture/README.md`

The local `architecture/README.md` is the lightweight design artifact for that
blueprint. It should include an `## ASCII Architecture` section that shows the
main ownership boundary, traffic path, dependencies, and operational hand-offs
in plain text.

Rendered diagrams are useful for customer reviews, but keep draft, LLD, and
tool-specific work files outside the reusable blueprint folders unless they
become the canonical artifact for that pattern.

## Module Shape

Reusable modules try to keep a familiar interface where it makes sense:

- `tenancy_ocid`
- `compartment_ocid`
- `region`
- `org`
- `environment`
- `region_key`
- `cis_level`
- `defined_tags`
- `freeform_tags`

Modules should output stable identifiers such as OCIDs, names, and maps that
blueprints can compose. Remote state belongs to deployable blueprints, not
shared modules.

## Validation

Use this before committing or before trusting a local change:

```bash
./scripts/validate-all.sh
```

When Ansible is installed, the script delegates to
`ansible/playbooks/validate.yml`. The playbook discovers implemented blueprints,
runs `terraform init -backend=false`, runs `terraform validate`, checks Ansible
syntax, runs optional scanners when available, and removes generated Terraform
folders and lock files afterward.

## Useful Docs

- `docs/DEPLOYMENT-GUIDE.md` - deployment sequence and operating notes.
- `docs/DEPLOYMENT-PATTERN-CATALOG.md` - blueprint catalog and selection notes.
- `docs/architecture/` - shared architecture rules and review-artifact guidance.
- `docs/CIS-PROFILES.md` - CIS profile behavior.
- `docs/ARCH-MAPPING-CIS.md` - CIS mapping notes.
- `docs/NAMING-CONVENTIONS.md` - naming standard.
- `docs/RUNBOOK.md` - operational runbook.

## Keep The Repo Clean

Generated Terraform and local test files are intentionally ignored:
`.terraform/`, `.terraform.lock.hcl`, `terraform.tfstate*`, `*.tfplan`,
local `terraform.tfvars`, `.codex-local/`, and `.claude/`.

The validation playbook normally cleans generated Terraform artifacts for you.
For manual cleanup:

```bash
find . -name ".terraform" -type d -prune -exec rm -rf {} +
find . -name ".terraform.lock.hcl" -type f -delete
find . -name "terraform.tfstate*" -type f -delete
find . -name ".DS_Store" -type f -delete
rm -rf .codex-local
rm -rf .claude
```

## Release Notes For Maintainers

Blueprint module sources are pinned to release tags such as `v0.1.0`. When a new
release is cut, update blueprint source refs deliberately in the same tagged
commit. Avoid `?ref=main` for customer-facing architecture folders because it
can change module behavior without review.

## License

This project is licensed under the Apache License 2.0. See `LICENSE` for
details.
