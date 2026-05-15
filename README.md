![OCI Landing Zones architecture banner](docs/assets/oci-landing-zones-banner.png)

# OCI Landing Zones

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Welcome. This repo is a practical Oracle Cloud Infrastructure toolkit: Terraform
blueprints, reusable modules, local Ansible runners, and plain-text architecture
notes for common OCI landing-zone patterns.

It is built for the first useful 10 minutes:

```text
pick a blueprint -> read its README -> review ASCII architecture -> fill tfvars -> plan
```

This is a personal engineering project, not an official Oracle product. Treat it
as a strong accelerator: useful, opinionated, and still something you should
review before pointing at a real tenancy.

## What Is Inside

| You Need | Good Place To Start |
|---|---|
| A clean OCI foundation | [Core Landing Zone](blueprints/core/) |
| CIS-oriented posture | [CIS Level 1](blueprints/cis/level1/) or [CIS Level 2](blueprints/cis/level2/) |
| Enterprise networking | [Hub-Spoke DRG And Three-Tier VCNs](blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns/) |
| A simple VCN | [Standalone Three-Tier VCN Defaults](blueprints/networking/standalone-three-tier-vcn-defaults/) |
| App-team onboarding | [Workload Vending](blueprints/operating-entity/workload-vending/) |
| Cost controls | [Cost Optimization](blueprints/operations/cost-optimization/) |
| Kubernetes | [OKE Extension](blueprints/extensions/oke/) |
| Serverless containers | [Container Instances](blueprints/extensions/container-instances/) |
| Functions and events | [Oracle Functions](blueprints/extensions/functions/) |
| Private GenAI | [OCI Generative AI Private Landing Zone](blueprints/ai/genai-private/) |
| GenAI API front door | [GenAI Multi-Model Gateway](blueprints/ai/genai-gateway/) |
| RAG agents | [AI Agents RAG Landing Zone](blueprints/ai/agents/) |
| Vector search | [OpenSearch](blueprints/data-platform/opensearch/) plus [Embedding Pipeline](blueprints/ai/embedding-pipeline/) |
| Databases | [Autonomous Database](blueprints/data-platform/autonomous-database/), [PostgreSQL](blueprints/data-platform/postgresql/), or [MySQL HeatWave](blueprints/data-platform/mysql-heatwave/) |
| Disaster recovery | [Full Stack DR](blueprints/disaster-recovery/fsdr/) |
| Desktops | [Secure Desktops](blueprints/industry/secure-desktops/) |

For the complete menu, use the
[Deployment Pattern Catalog](docs/DEPLOYMENT-PATTERN-CATALOG.md) or the
[Architecture Index](docs/architecture/README.md).

## Quick Start

Use the repo like a set of workbenches. Open only the one you need, inspect it,
then run a plan from there.

```bash
git clone https://github.com/leandro-michelino/oci-landingzones.git
cd oci-landingzones/blueprints/core
cp terraform.tfvars.example terraform.tfvars
terraform init -backend=false
terraform validate
terraform plan
```

For a single-folder customer hand-off, sparse checkout works well. The blueprint
module sources use pinned Git references, so a deployment folder can be consumed
without cloning the whole project. See
[Using A Single Blueprint](docs/DEPLOYMENT-GUIDE.md#using-a-single-blueprint).

## The Normal Flow

```text
choose outcome
  |
  v
open blueprints/<family>/<deployment>/
  |
  v
read README.md
  |
  v
review architecture/README.md
  |
  v
copy terraform.tfvars.example -> terraform.tfvars
  |
  v
terraform plan or ansible/plan.yml
  |
  v
review, approve, apply
```

The local architecture file matters. It is where the traffic paths, trust
boundaries, Terraform components, and review checklist live.

## Browse By Family

| Family | What You Will Find |
|---|---|
| [core](blueprints/core/) | Shared OCI foundation: compartments, IAM, tagging, logging, Cloud Guard, Vault/KMS, Security Zones, VSS, budgets, events, and monitoring. |
| [cis](blueprints/cis/) | CIS Level 1 and Level 2 landing-zone profiles. |
| [networking](blueprints/networking/) | Standalone VCNs, hub-spoke, DRG, VPN, FastConnect, DNS, firewall, NVA, ZPR, multicloud, and regional hub patterns. |
| [identity](blueprints/identity/) | IAM groups, policies, dynamic groups, and identity domains. |
| [operating-entity](blueprints/operating-entity/) | Business-unit and workload onboarding boundaries. |
| [operations](blueprints/operations/) | Cost optimization, budgets, tags, notifications, and FinOps hand-offs. |
| [extensions](blueprints/extensions/) | OKE, Functions, API Gateway, WAF, Streaming, OAC, OIC, Observability, Redis, Container Instances, and more. |
| [ai](blueprints/ai/) | GenAI, agents, gateway, guardrails, fine-tuning, embeddings, document intelligence, and multi-agent orchestration. |
| [data-platform](blueprints/data-platform/) | Autonomous Database, APEX on ADB, PostgreSQL, MySQL HeatWave, OpenSearch, and private data platform patterns. |
| [compliance](blueprints/compliance/) | SCCA, Zero Trust, Healthcare/PCI, and security posture automation. |
| [disaster-recovery](blueprints/disaster-recovery/) | Full Stack Disaster Recovery wiring. |
| [devops](blueprints/devops/) | OCI DevOps project, repository, build pipeline, deploy pipeline, and notifications. |
| [industry](blueprints/industry/) | Secure Desktops and telco cloud-native landing-zone patterns. |

## Extension-Only Is Fine

You do not need to deploy the whole foundation to use an extension. If a
customer already has compartments, VCNs, subnets, load balancers, gateways,
registries, or databases, open the extension folder and pass those existing
OCIDs in local tfvars.

| Path | When It Fits |
|---|---|
| Extension only | The base OCI estate already exists and you only need one add-on service. |
| Base plus extension | This repo should create the foundation first, then layer on the selected service. |

The longer walkthrough is in the
[Deployment Guide](docs/DEPLOYMENT-GUIDE.md#using-extensions-only).

## Blueprint Shape

Every deployable blueprint follows the same rhythm:

```text
blueprints/<family>/<deployment>/
|-- README.md                  Operator guide
|-- architecture/
|   `-- README.md              Detailed ASCII architecture
|-- main.tf                    Terraform composition
|-- variables.tf               Input contract
|-- outputs.tf                 Hand-off values
|-- providers.tf               Provider setup
|-- versions.tf                Terraform/provider constraints
|-- terraform.tfvars.example   Safe local input example
`-- ansible/
    |-- plan.yml               Local init, validate, and plan
    |-- apply.yml              Guarded apply
    `-- destroy.yml            Guarded destroy
```

Once you learn one folder, the rest should feel familiar. That is deliberate.

## Why ASCII Architecture

The diagrams are text on purpose. They work in GitHub, terminals, pull
requests, customer notes, and screen shares without special tooling.

Each `architecture/README.md` includes:

| Section | Why It Exists |
|---|---|
| Deployment Purpose | What the blueprint is for. |
| Architecture At A Glance | The short design summary. |
| ASCII Architecture | Resource and flow view in plain text. |
| Terraform Components | What `main.tf` actually wires. |
| Request And Deployment Flow | How operator intent becomes infrastructure. |
| Traffic And Trust Boundaries | Where traffic, IAM, and ownership lines sit. |
| Operational Boundaries | What to check before plan/apply/destroy. |
| Review Checklist | The final design-review pass. |

## Local Workflow

Terraform is the infrastructure engine. Ansible is the local runner for people
who want a consistent plan/apply/destroy wrapper.

```bash
# From a blueprint folder
terraform init -backend=false
terraform validate
terraform plan
```

Or:

```bash
ansible-playbook -i localhost, ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, ansible/apply.yml
CONFIRM_DESTROY=true ansible-playbook -i localhost, ansible/destroy.yml
```

Apply and destroy are guarded so risky actions require an explicit confirmation
flag.

## Requirements

| Tool | Why |
|---|---|
| Terraform `1.12.0` or later | Builds and validates the OCI resource graph. |
| OCI CLI | Supplies local OCI authentication and tenancy context. |
| Git | Fetches the repo and pinned module sources. |
| Ansible | Runs local plan/apply/destroy workflows. |
| Optional scanners | `tflint`, `trivy`, `checkov`, `ansible-lint`, and `pre-commit` add extra confidence when installed. |

Optional tooling is optional. The validation scripts skip missing scanners
cleanly.

Recommended local helper setup on macOS:

```bash
brew install trivy
pipx install checkov
pipx install ansible-dev-tools
pipx inject ansible-dev-tools ansible-lint --include-apps --force
pipx install pre-commit
pre-commit install
```

Install `tflint` from the Terraform Linters release for your platform when your
package manager does not provide it.

## Validate Changes

For small edits:

```bash
./scripts/validate-changed.sh
```

For broad changes or release work:

```bash
./scripts/validate-all.sh
```

The validation flow checks naming conventions, documentation contracts,
Terraform formatting, Terraform validation, Ansible syntax, and optional
security scanners when available.

## Repo Map

```text
blueprints/          Deployable architectures
modules/             Reusable Terraform building blocks
ansible/             Local orchestration and validation roles
docs/                Guides, catalog, runbooks, naming, and architecture index
environments/        Example backend and tfvars shapes
scripts/             Repo checks and local workflow helpers
tests/               Validation contract notes and future test home
```

## Useful Docs

| Doc | Use It For |
|---|---|
| [Deployment Guide](docs/DEPLOYMENT-GUIDE.md) | End-to-end deployment flow and operating notes. |
| [Deployment Pattern Catalog](docs/DEPLOYMENT-PATTERN-CATALOG.md) | Full blueprint menu and planned patterns. |
| [Architecture Index](docs/architecture/README.md) | Repository-level ASCII map and every blueprint architecture link. |
| [Naming Conventions](docs/NAMING-CONVENTIONS.md) | OCI naming standard used by generated defaults. |
| [Variables Reference](VARIABLES.md) | Shared variable reference and notable inputs. |
| [BYOL And License Model Matrix](docs/BYOL-LICENSING-MATRIX.md) | License-model guidance for supported service families. |
| [CIS Profiles](docs/CIS-PROFILES.md) | CIS profile behavior. |
| [Runbook](docs/RUNBOOK.md) | Operational flow for maintainers and reviewers. |
| [Roadmap](docs/ROADMAP.md) | Implemented phases and future candidates. |

## Keep Local Runs Tidy

Generated local files are intentionally ignored:

```text
.terraform/
.terraform.lock.hcl
terraform.tfstate*
tfplan
tfplan.*
*.tfplan
terraform.tfvars
.codex-local/
.claude/
```

Cleanup when needed:

```bash
find . -name ".terraform" -type d -prune -exec rm -rf {} +
find . -name ".terraform.lock.hcl" -type f -delete
find . -name "terraform.tfstate*" -type f -delete
find . -name "tfplan*" -type f -delete
find . -name ".DS_Store" -type f -delete
rm -rf .codex-local
rm -rf .claude
```

## Search-Friendly Summary

This repository contains deployable Oracle Cloud Infrastructure landing-zone
patterns for Terraform and Ansible. It covers OCI Core governance, CIS,
networking, identity, operating entities, OKE, Functions, API Gateway, WAF,
OpenSearch, Autonomous Database, MySQL HeatWave, Redis, Secure Desktops,
security posture automation, disaster recovery, DevOps, and AI/GenAI patterns
such as OCI Generative AI, RAG agents, embeddings, guardrails, fine-tuning, and
multi-agent orchestration.

## License

This project is licensed under the Apache License 2.0. See `LICENSE` for
details.
