![OCI Landing Zones architecture banner](docs/assets/oci-landing-zones-banner.png)

# OCI Landing Zones (OCI-Primary Multicloud Blueprint Repository)

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

About:
- OCI is the primary control plane by design.
- Azure and AWS patterns are included as first-class multicloud blueprints.
- The repository focus is deploy-and-use multicloud architecture across networking, security, data, AI, Kubernetes, DR, and FinOps.

## Friendly Disclaimer

This is a personal engineering project, not an official Oracle product or
Oracle-supported package.

## GitHub About (Copy/Paste)

Use this repository description in GitHub About:

```text
OCI-primary multicloud landing zones with Terraform blueprints, Ansible workflows, and Architecture docs for OCI, Azure, and AWS across networking, security, data, AI, Kubernetes, disaster recovery, and FinOps.
```

Suggested GitHub topics:

```text
oracle-cloud
oci
oracle-cloud-infrastructure
multicloud
terraform
ansible
landing-zone
landing-zones
infrastructure-as-code
cloud-architecture
networking
security
cis
oke
genai
autonomous-database
mysql-heatwave
devops
disaster-recovery
finops
cost-optimization
azure
aws
ipsec
bgp
```

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

Azure + OCI transit quick test path (`without-interconnect`):
1. Run OCI plan/apply in `blueprints/networking/azure-vwan-oci-drg-transit/`.
2. Run Azure plan/apply in the same blueprint (`ansible/azure-*.yml`).
3. Create one Linux VM in the OCI transit subnet and one Linux VM in the Azure workload subnet.
4. Add explicit Azure route `OCI_CIDR -> VirtualNetworkGateway`.
5. Allow ICMP and SSH between OCI and Azure CIDRs in Azure NSG and OCI security list.
6. Run `ansible/azure-ipsec-verify.yml` with `AZURE_TEST_VM_RESOURCE_GROUP`, `AZURE_TEST_VM_NAME`, and `OCI_PING_TARGET_IP`.
7. Validate bidirectional traffic, then destroy in reverse order after confirmation.

### AWS + OCI (Available)

| Pattern | Blueprint |
|---|---|
| Hybrid backbone (OCI DRG primary) | [AWS + OCI Hybrid Network Backbone](blueprints/networking/aws-oci-hybrid-network-backbone/) |
| Cross-cloud DR (OCI primary, AWS standby) | [AWS + OCI Cross-Cloud DR](blueprints/disaster-recovery/aws-oci-cross-cloud-dr/) |
| Active/passive Kubernetes failover (OCI-primary OKE, EKS standby) | [EKS + OKE Active Passive](blueprints/extensions/eks-oke-active-passive/) |
| MySQL DR over IPSec (OCI primary) | [OCI + AWS MySQL HeatWave DR](blueprints/data-platform/oci-aws-mysql-heatwave-dr/) |

AWS deployment quick paths:
- Plan only:
  `ansible-playbook -i localhost, blueprints/networking/aws-oci-hybrid-network-backbone/ansible/aws-plan.yml`
- Full lifecycle (create + delete for test):
  `scripts/test-networking-lifecycle.sh --blueprint blueprints/networking/aws-oci-hybrid-network-backbone --providers aws`

All Azure+OCI and AWS+OCI blueprints include:
- deployable cloud-side sessions (`azure-*.yml` or `aws-*.yml`)
- local `hello-world/index.html`
- `ansible/serve-hello-world.yml` and `ansible/stop-hello-world.yml`

Kubernetes multicloud blueprints should use the latest common Kubernetes minor
version supported by all selected providers and regions. The Kubernetes
multicloud extension blueprints use an OCI-primary active/passive failover
model by default, with OCI Traffic Management as the DNS failover layer when a
delegated public zone is available. Direct IPs validate each application
endpoint, while browser failover tests require a real public domain or
subdomain delegated to the OCI DNS zone nameservers. Active/active remains an
intentional option when the application, data layer, and GSLB policy are ready
for dual serving.

Design notes and backlog:
- [Multicloud Notes](docs/multicloud/README.md)

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

## Typical Operator Flow

```text
choose outcome
  |
  v
open blueprint folder
  |
  v
read README + Architecture
  |
  v
copy tfvars example
  |
  v
terraform plan or ansible/plan.yml
  |
  v
review and apply
```

## Local Workflow Options

Use Terraform directly when you are iterating:

```bash
terraform init -backend=false
terraform validate
terraform plan
```

Use the local Ansible wrapper when you want the repo-standard guardrails:

```bash
ansible-playbook -i localhost, ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, ansible/apply.yml
CONFIRM_DESTROY=true ansible-playbook -i localhost, ansible/destroy.yml
```

Cloud-specific wrappers in multicloud blueprints:
- Azure: `ansible/azure-plan.yml`, `ansible/azure-apply.yml`, `ansible/azure-destroy.yml`
- AWS: `ansible/aws-plan.yml`, `ansible/aws-apply.yml`, `ansible/aws-destroy.yml`

Cloud wrapper simulation:

```bash
make simulate-cloud
```

This checks every Azure and AWS wrapper, verifies template and parameter paths,
and exits before any vendor CLI call. Real Azure what-if and AWS CloudFormation
plan sessions still require logged-in `az` or `aws` CLIs.

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

The repo is wired to catch the boring-but-important stuff: missing architecture
files, stale blueprint indexes, bad Markdown links, mutable module refs,
Terraform format or validation errors, scanner findings, and Ansible syntax
drift.

Run checks for changed work:

```bash
./scripts/validate-changed.sh
```

Run checks for the full repository:

```bash
./scripts/validate-all.sh
```

Simulate Azure and AWS deployment wrappers without creating resources:

```bash
./scripts/simulate-cloud-deployments.sh
```

Performance tips:
- Shared Terraform provider cache is enabled by default with `TF_PLUGIN_CACHE_DIR`.
- Validation keeps local `.terraform` workdirs by default for faster reruns.
- Force full cleanup when needed:
  `VALIDATION_CLEAN_TERRAFORM_WORKDIRS=1 ./scripts/validate-all.sh`

Networking lifecycle tests (create then destroy):
- `scripts/test-networking-lifecycle.sh --blueprint blueprints/networking/aws-oci-hybrid-network-backbone --providers oci,aws`
- `scripts/test-networking-lifecycle.sh --all-networking --providers oci` (heavy run)

Maintainer-focused validation details live in [CONTRIBUTING.md](CONTRIBUTING.md).

## Contributing

- Read [CONTRIBUTING.md](CONTRIBUTING.md)
- Keep module sources pinned
- Keep every blueprint deployable and reviewable
- Keep Architecture docs aligned with Terraform
- Keep README files friendly, useful, and public-safe

Issues and PRs work best when they describe the customer outcome, the operating
constraints, and the blueprint shape you want to land.
