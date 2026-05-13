![OCI Landing Zones architecture banner](docs/assets/oci-landing-zones-banner.svg)

# OCI Landing Zones

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This repo is a practical OCI landing-zone toolkit: Terraform modules, ready-to-use
blueprints, local Ansible automation, and plain-text architecture notes for the OCI patterns
that come up again and again.

It is meant to be useful in real work: clone it, pick a blueprint, review the ASCII
architecture, run a plan, and adapt the inputs to your tenancy. It is a personal engineering
project, not an official Oracle product, so treat it as a solid accelerator that you still
review, test, and harden before production.

## Quick Navigation

| I Want To... | Start Here |
|---|---|
| See the full deployment menu | [Blueprint Families](#blueprint-families) |
| Try one architecture quickly | [Use One Blueprint](#use-one-blueprint) |
| Build a fuller landing zone | [Use The Full Landing Zone](#use-the-full-landing-zone) |
| Understand the folder contract | [Every Blueprint Is End-To-End](#every-blueprint-is-end-to-end) |
| Check the ASCII diagrams | [Architecture Experience](#architecture-experience) |
| Validate everything locally | [Validation](#validation) |

## What You Get

| Area | What Is Included |
|---|---|
| Core governance | Compartments, IAM, tagging, logging, monitoring, budgets, Cloud Guard, Vault/KMS, Security Zones, VSS, Events, and related controls. |
| Networking | Standalone VCNs, hub-spoke, DRG, VPN, FastConnect, DNS, firewall, network appliance, ZPR, multicloud, and regional patterns. |
| Operating model | Operating entity and workload vending patterns for team, business unit, or application ownership boundaries. |
| Extensions | Optional OKE, WAF, Exadata, API Gateway, and Streaming blueprints. |
| Compliance and industry | CIS, Zero Trust, SCCA-style, private data platform, FSDR, and telco cloud-native shapes. |
| Automation | Terraform for infrastructure and Ansible for local plan/apply/destroy orchestration. |
| Documentation | Each deployment has its own README, detailed ASCII architecture, and TF + Ansible output section. |

## Repo Map

```text
blueprints/    Deployable architectures. Pick from here when you want a working pattern.
modules/       Reusable Terraform building blocks used by the blueprints.
ansible/       Shared roles, inventories, validation, and Terraform orchestration.
docs/          Guides, catalog, runbooks, naming conventions, and standards.
environments/  Example backend and tfvars shapes for dev, uat, and prod.
scripts/       Thin wrappers for validation and common local workflows.
tests/         Test scaffolding.
```

## Requirements

| Tool | Why You Need It |
|---|---|
| Terraform `1.12.0` or later | Builds and validates the OCI resource graph. |
| OCI CLI | Supplies local OCI authentication and tenancy context. |
| Git | Fetches the repo and pinned module sources. |
| Ansible | Runs repo-wide validation and blueprint-local plan/apply/destroy workflows. |
| Optional scanners | `tflint`, `tfsec`, `checkov`, `ansible-lint`, and `pre-commit` are used when installed. |

The optional scanners are nice to have, not mandatory. Validation skips them cleanly when
they are not installed.

## Fastest Safe Check

If you are only exploring, start here:

```bash
git clone https://github.com/leandro-michelino/oci-landingzones.git
cd oci-landingzones

./scripts/validate-all.sh
```

That command checks Terraform formatting, verifies every implemented blueprint, runs root
and blueprint-local Ansible syntax checks, and removes generated Terraform artifacts
afterward.

## Use One Blueprint

Blueprints are designed to stand on their own. You can clone the repo normally, or
sparse-checkout a single deployment folder and still let Terraform fetch the shared modules
through pinned Git module sources.

Example: run only the default standalone three-tier VCN blueprint.

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

You can also use the blueprint-local Ansible wrapper:

```bash
cd blueprints/networking/standalone-three-tier-vcn-defaults
cp terraform.tfvars.example terraform.tfvars

ansible-playbook -i localhost, ansible/plan.yml
```

For a single networking blueprint, set `compartment_ocid` to the workload compartment where
resources should land. That compartment can come from `blueprints/core/`, another
landing-zone process, or an existing tenancy.

## Use The Full Landing Zone

For a fuller environment, deploy only what you actually need. A sensible order usually looks
like this:

| Step | Deployment |
|---|---|
| 1 | Bootstrap remote state, OCI CLI access, and tenancy prerequisites. |
| 2 | Deploy `blueprints/core/` for the shared governance baseline. |
| 3 | Deploy one networking blueprint for the traffic model. |
| 4 | Add operating entity or workload vending patterns when ownership boundaries matter. |
| 5 | Add optional extensions such as OKE, WAF, Exadata, API Gateway, or Streaming. |
| 6 | Run validation and security checks before merge or apply. |

The longer walkthrough lives in `docs/DEPLOYMENT-GUIDE.md`.

## Blueprint Families

| Family | Good For | Folders |
|---|---|---|
| Core | Shared IAM, governance, security, logging, and operations baseline. | `blueprints/core/` |
| CIS | Dedicated CIS Level 1 or Level 2 landing-zone behavior. | `blueprints/cis/level1/`, `blueprints/cis/level2/` |
| Identity | Identity domains, federation, groups, and policy scope. | `blueprints/identity/` |
| Networking | VCNs, hub-spoke, DRG, VPN, FastConnect, DNS, firewall, NVA, ZPR, multicloud, and regional designs. | `blueprints/networking/` |
| Operating Entity | Business unit, subsidiary, workload owner, or app-team onboarding. | `blueprints/operating-entity/` |
| Extensions | Optional service add-ons after the foundation is ready. | `blueprints/extensions/` |
| Compliance | Stricter regulated-environment landing-zone shapes. | `blueprints/compliance/` |
| Data Platform | Private data and analytics landing-zone pattern. | `blueprints/data-platform/` |
| Disaster Recovery | OCI Full Stack Disaster Recovery patterns. | `blueprints/disaster-recovery/` |
| Industry | Industry-oriented variants, such as telco cloud-native. | `blueprints/industry/` |

For the complete pattern catalog, see `docs/DEPLOYMENT-PATTERN-CATALOG.md`.

## Good First Folders

| If You Are Thinking... | Try This |
|---|---|
| I need the baseline first | `blueprints/core/` |
| I just need a clean VCN example | `blueprints/networking/standalone-three-tier-vcn-defaults/` |
| I need custom subnet or routing shape | `blueprints/networking/standalone-three-tier-vcn-custom/` |
| I need hub-spoke with DRG | `blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns/` |
| I need a stricter CIS build | `blueprints/cis/level1/` or `blueprints/cis/level2/` |
| I need app-team onboarding | `blueprints/operating-entity/workload-vending/` |
| I need Kubernetes on top | `blueprints/extensions/oke/` |

## How To Read A Deployment

Every deployment README now follows the same operator-friendly shape:

| Section | What You Should Get From It |
|---|---|
| At A Glance | The quick fit, Terraform shape, key decisions, outputs, and runner path. |
| What This Deploys | The actual modules, resources, or data sources wired in `main.tf`. |
| Inputs To Decide | Base tenancy inputs, deployment-specific choices, and enable flags. |
| Outputs And Hand-Off | The named values another blueprint, runbook, or customer note can consume. |
| Architecture | The local `architecture/README.md` with the detailed ASCII resource flow. |
| Review Before Apply | The short list to check before a real plan or apply. |

## Every Blueprint Is End-To-End

Each deployable blueprint folder has the same working shape:

```text
blueprints/<family>/<deployment>/
|-- README.md                  Human-friendly deployment notes
|-- architecture/
|   `-- README.md              Detailed, individual ASCII architecture
|-- main.tf                    Terraform composition for this deployment
|-- variables.tf               Input contract
|-- outputs.tf                 Named hand-off values
|-- providers.tf               OCI provider configuration
|-- versions.tf                Terraform/provider constraints
|-- terraform.tfvars.example   Local input example
`-- ansible/
    |-- plan.yml               Local init, validate, and plan
    |-- apply.yml              Guarded init, validate, plan, and apply
    `-- destroy.yml            Guarded destroy
```

This matters because every architecture is reviewable and runnable from its own folder. The
docs are not a shared generic diagram pasted everywhere; each architecture page reflects
that folder's Terraform components, request flow, outputs, and local Ansible workflow.

## Architecture Experience

Every `architecture/README.md` is intentionally text-first. You should be able to review it
in GitHub, a terminal, a pull request, or customer notes without needing a diagramming tool.

Each architecture page includes:

| Section | Why It Is There |
|---|---|
| Deployment purpose | Plain-language reason this blueprint exists. |
| Files in this deployment | The local TF + Ansible file contract. |
| ASCII architecture | Detailed resource, boundary, and flow view in plain text. |
| Terraform components | Real modules/resources wired in `main.tf`. |
| Request and deployment flow | How inputs move into resources and outputs. |
| State, inputs, and outputs | What comes from tfvars, what lands in state, and what gets handed off. |
| Operational boundaries | Things to check before plan/apply/destroy. |
| Review checklist | What to inspect before trusting the deployment. |
| Terraform + Ansible deployment output | The expected `terraform output` shape and Ansible recap for that folder. |

## Terraform + Ansible Workflow

The usual local workflow is intentionally boring, which is exactly what you want for
infrastructure:

```text
review README.md
  |
  v
review architecture/README.md
  |
  v
copy terraform.tfvars.example -> terraform.tfvars
  |
  v
terraform init / validate / plan
  |
  v
ansible/plan.yml or guarded ansible/apply.yml
  |
  v
terraform outputs and Ansible recap become the hand-off
```

Apply and destroy are guarded:

```bash
CONFIRM_APPLY=true ansible-playbook -i localhost, ansible/apply.yml
CONFIRM_DESTROY=true ansible-playbook -i localhost, ansible/destroy.yml
```

At the end of each architecture page, the `Terraform + Ansible Deployment Output` section
shows the folder-specific output names from `outputs.tf`, plus a clean example of the
Ansible plan/apply recap.

## CIS Profiles

Generic blueprints do not turn on CIS behavior by default. If you need a CIS-aligned landing
zone, start from one of these folders:

```text
blueprints/cis/level1/
blueprints/cis/level2/
```

The current CIS contract lives in `docs/CIS-PROFILES.md`.

## Module Shape

Reusable modules try to keep a familiar interface where it makes sense:

```text
tenancy_ocid
compartment_ocid
region
org
environment
region_key
cis_level
defined_tags
freeform_tags
```

Modules should output stable identifiers such as OCIDs, names, and maps that blueprints can
compose. Remote state belongs to deployable blueprints, not shared modules.

## Validation

Use this before committing, reviewing, or trusting a local change:

```bash
./scripts/validate-all.sh
```

The validator checks:

- Terraform format across the repo.
- Every blueprint has `README.md`.
- Every blueprint has `architecture/README.md`.
- Every deployment README includes at-a-glance guidance, inputs, outputs, workflow, review,
  and validation sections.
- Every architecture includes ASCII design, Terraform components, deployment
  flow, review checklist, and TF + Ansible output sections.
- Every implemented blueprint runs `terraform init -backend=false` and
  `terraform validate`.
- Root Ansible playbooks pass syntax checks.
- Blueprint-local `ansible/plan.yml`, `ansible/apply.yml`, and
  `ansible/destroy.yml` pass syntax checks.
- Optional scanners run when available.
- Generated Terraform artifacts are cleaned afterward.

## Useful Docs

| Doc | Use It For |
|---|---|
| `docs/DEPLOYMENT-GUIDE.md` | Deployment sequence and operating notes. |
| `docs/DEPLOYMENT-PATTERN-CATALOG.md` | Blueprint catalog and selection notes. |
| `docs/CIS-PROFILES.md` | CIS profile behavior. |
| `docs/ARCH-MAPPING-CIS.md` | CIS mapping notes. |
| `docs/NAMING-CONVENTIONS.md` | Naming standard. |
| `docs/RUNBOOK.md` | Operational runbook. |

## Keep The Repo Clean

Generated Terraform and local test files are intentionally ignored:

```text
.terraform/
.terraform.lock.hcl
terraform.tfstate*
*.tfplan
terraform.tfvars
.codex-local/
.claude/
```

The validation playbook normally cleans generated Terraform artifacts for you. For manual
cleanup:

```bash
find . -name ".terraform" -type d -prune -exec rm -rf {} +
find . -name ".terraform.lock.hcl" -type f -delete
find . -name "terraform.tfstate*" -type f -delete
find . -name ".DS_Store" -type f -delete
rm -rf .codex-local
rm -rf .claude
```

## Maintainer Notes

Blueprint module sources are pinned to release tags such as `v0.2.0`. When a new release is
cut, update blueprint source refs deliberately in the same tagged commit. Avoid `?ref=main`
for customer-facing architecture folders because it can change module behavior without
review.

## License

This project is licensed under the Apache License 2.0. See `LICENSE` for details.
