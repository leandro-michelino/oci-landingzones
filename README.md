![OCI Landing Zones architecture banner](docs/assets/oci-landing-zones-banner.png)

# OCI Landing Zones

[![License: Apache-2.0](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)
![Terraform >= 1.12.0](https://img.shields.io/badge/terraform-%3E%3D1.12.0-844FBA.svg)
![Validation: validate-all](https://img.shields.io/badge/validation-validate--all-brightgreen.svg)
![Security: TFLint Trivy Checkov](https://img.shields.io/badge/security-tflint%20%7C%20trivy%20%7C%20checkov-2f855a.svg)

Build OCI-primary multicloud landing zones for OCI, Azure, and AWS with clear architecture and real deploy flows.

This repo is a practical multicloud toolkit: Terraform blueprints, reusable
modules, and local Ansible wrappers for plan/apply/destroy sessions.

It is built for real platform work:
- OCI stays primary by design.
- Azure and AWS integrations are first-class.
- Every blueprint is organized to be easy to read, review, and operate.

Simple approach:
`pick the outcome -> review Architecture -> plan -> apply -> verify`

## Friendly Disclaimer

This is a personal engineering project, not an official Oracle product or
Oracle-supported package.

## Start Here (2 Minutes)

```text
pick a blueprint -> read README -> review architecture -> fill tfvars -> plan
```

```bash
git clone https://github.com/leandro-michelino/oci-landingzones.git
cd oci-landingzones/blueprints/core
cp terraform.tfvars.example terraform.tfvars
terraform init -backend=false
terraform validate
terraform plan
```

That is the normal rhythm everywhere in the repo. Each deployable blueprint has
the same basic shape, so once one folder makes sense, the rest feel familiar.

If you are browsing first, open the [Blueprint Index](BLUEPRINTS.md). If you are
ready to test the baseline, start with [Core Landing Zone](blueprints/core/).

## What You Can Deploy

| If you need... | Start here |
|---|---|
| A full OCI baseline | [Core Landing Zone](blueprints/core/) |
| CIS controls | [CIS Level 1](blueprints/cis/level1/) or [CIS Level 2](blueprints/cis/level2/) |
| Kubernetes platform | [OKE Extension](blueprints/extensions/oke/) |
| Network inspection with FortiGate HA | [Hub-Spoke With FortiGate HA](blueprints/networking/hub-spoke-with-fortigate-ha/) |
| DR pattern | [Full Stack DR](blueprints/disaster-recovery/fsdr/) |
| Data platform foundations | [Autonomous DB](blueprints/data-platform/autonomous-database/), [PostgreSQL](blueprints/data-platform/postgresql/), [MySQL HeatWave](blueprints/data-platform/mysql-heatwave/), [OCI NoSQL](blueprints/data-platform/nosql/), [OCI + AWS MySQL HeatWave DR](blueprints/data-platform/oci-aws-mysql-heatwave-dr/) |
| AI workloads | [GenAI Private](blueprints/ai/genai-private/), [GenAI Gateway](blueprints/ai/genai-gateway/), [AI Agents](blueprints/ai/agents/) |
| Industry patterns | [Secure Desktops](blueprints/industry/secure-desktops/) or [Telco Cloud Native](blueprints/industry/telco-cloud-native/) |
| Conversational AI | [Oracle Digital Assistant](blueprints/extensions/digital-assistant/) |

Full inventory:
- [Blueprint Index](BLUEPRINTS.md)
- [Deployment Pattern Catalog](docs/DEPLOYMENT-PATTERN-CATALOG.md)
- [Architecture Index](docs/architecture/README.md)

## How The Repo Thinks

The repo is intentionally boring in the useful way:

- Blueprints are complete deployment entry points.
- Modules are reusable building blocks.
- Every deployable blueprint has a README, an Architecture file, Terraform
  files, safe example inputs, and local Ansible runners.
- Customer-specific values stay out of git. Use ignored `terraform.tfvars`,
  environment variables, or your pipeline secret store.
- Public docs stay generic, English-only, and safe to share.

The goal is not to hide complexity. The goal is to put it in predictable places.

## Multicloud (OCI Primary)

### Azure + OCI (Available)

| Pattern | Blueprint |
|---|---|
| AI gateway routing by region, cost, or residency | [Azure + OCI AI Gateway](blueprints/ai/azure-oci-ai-gateway/) |
| Active/passive Kubernetes failover (OCI-primary OKE, AKS standby) | [AKS + OKE Active Passive](blueprints/extensions/aks-oke-active-passive/) |
| Cross-cloud DR (OCI primary, Azure standby) | [Azure + OCI Cross-Cloud DR](blueprints/disaster-recovery/azure-oci-cross-cloud-dr/) |
| Dual connectivity hardening (OCI DRG primary, Interconnect default when present + IPSec/BGP backup, testable without Interconnect) | [Azure + OCI Dual Connectivity Hardening](blueprints/networking/azure-oci-dual-connectivity/) |
| vWAN transit backbone (OCI DRG primary, vWAN/vHub route domain, Interconnect default when present, IPSec-first test mode) | [Azure vWAN + OCI DRG Transit](blueprints/networking/azure-vwan-oci-drg-transit/) |
| Hub-spoke via Azure vWAN ExpressRoute (OCI hub/spokes mapped to Azure VNets) | [Hub-Spoke With Azure vWAN ExpressRoute](blueprints/networking/hub-spoke-with-azure-vwan-expressroute/) |

### AWS + OCI (Available)

| Pattern | Blueprint |
|---|---|
| Hybrid backbone (OCI DRG primary) | [AWS + OCI Hybrid Network Backbone](blueprints/networking/aws-oci-hybrid-network-backbone/) |
| Cross-cloud DR (OCI primary, AWS standby) | [AWS + OCI Cross-Cloud DR](blueprints/disaster-recovery/aws-oci-cross-cloud-dr/) |
| Active/passive Kubernetes failover (OCI-primary OKE, EKS standby) | [EKS + OKE Active Passive](blueprints/extensions/eks-oke-active-passive/) |
| MySQL DR over IPSec (OCI primary) | [OCI + AWS MySQL HeatWave DR](blueprints/data-platform/oci-aws-mysql-heatwave-dr/) |

Detailed multicloud deployment notes live in [Multicloud Notes](docs/multicloud/README.md)
and in each blueprint README.

## Blueprint Shape

```text
blueprints/<family>/<deployment>/
|-- README.md
|-- architecture/README.md
|-- main.tf
|-- variables.tf
|-- outputs.tf
|-- providers.tf
|-- versions.tf
|-- terraform.tfvars.example
`-- ansible/
    |-- plan.yml
    |-- apply.yml
    `-- destroy.yml
```

The consistency is deliberate. It keeps review simple and makes sparse checkout
usable when you only need one deployment pattern.

## Pick By Family

| Family | What it covers |
|---|---|
| [core](blueprints/core/) | Tenancy foundation (IAM, tagging, logging, security, budgets, monitoring). |
| [cis](blueprints/cis/) | CIS-aligned baseline profiles. |
| [networking](blueprints/networking/) | VCN, DRG, DNS, firewall, hub-spoke, and multicloud connectivity patterns. |
| [identity](blueprints/identity/) | IAM group/policy and identity domain baselines. |
| [operating-entity](blueprints/operating-entity/) | Ownership and delegated administration boundaries. |
| [operations](blueprints/operations/) | Cost controls and FinOps guardrails. |
| [extensions](blueprints/extensions/) | OKE, Functions, API Gateway, WAF, ODA, Redis, Observability, and more. |
| [ai](blueprints/ai/) | GenAI, agents, embedding pipelines, guardrails, and gateway patterns. |
| [data-platform](blueprints/data-platform/) | Database and data platform patterns. |
| [compliance](blueprints/compliance/) | SCCA, Zero Trust, Healthcare/PCI, and security posture automation. |
| [disaster-recovery](blueprints/disaster-recovery/) | OCI and multicloud DR patterns. |
| [devops](blueprints/devops/) | OCI DevOps CI/CD foundation. |
| [industry](BLUEPRINTS.md#industry) | Vertical patterns (telco, secure desktops). |

## Quality Checks

The repo is wired to catch missing architecture files, stale blueprint indexes,
bad Markdown links, mutable module refs, Terraform format or validation errors,
scanner findings, and Ansible syntax drift.

Run checks for changed work:

```bash
./scripts/validate-changed.sh
```

Run checks for the full repository:

```bash
./scripts/validate-all.sh
```

Lifecycle tests, provider-specific simulations, and maintainer-focused
validation details live in [tests/README.md](tests/README.md),
[docs/RUNBOOK.md](docs/RUNBOOK.md), and [CONTRIBUTING.md](CONTRIBUTING.md).

## Contributing

- Read [CONTRIBUTING.md](CONTRIBUTING.md)
- Keep module sources pinned
- Keep every blueprint deployable and reviewable
- Keep Architecture docs aligned with Terraform
- Keep README files friendly, useful, and public-safe

Issues and PRs work best when they describe the customer outcome, the operating
constraints, and the blueprint shape you want to land.
