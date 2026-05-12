# OCI Landing Zones

This is a personal project I have been shaping over the years while working
with Oracle Cloud Infrastructure customers.

It started as the kind of thing you keep rebuilding from notes, diagrams,
customer workshops, lessons learned, and "we should standardize this next time"
moments. The goal here is to turn those recurring landing-zone requirements into
a practical, reusable Terraform and Ansible framework for OCI.

It is intentionally opinionated, but not meant to be rigid. Different customers
need different levels of governance, networking, security, and operational
control, so this repository keeps a small mandatory core and then adds optional
blueprints for the patterns that show up again and again in real environments.

This is not an official product. It is a personal engineering project, built in
the open, reflecting requirements and patterns I have seen across customer
engagements over time.

## What This Is

At a high level, this repository provides an OCI landing zone framework designed
around:

- a centralized core baseline
- reusable Terraform modules
- independently deployable blueprints
- local Ansible orchestration
- optional CIS Level 1 and Level 2 landing zone profiles
- practical defaults that can be adapted for real customer requirements

## Objectives

- Provide a reusable OCI landing zone foundation for greenfield and brownfield
  tenancies.
- Separate mandatory core controls from optional deployment blueprints.
- Keep Terraform modules reusable, composable, and free from remote state.
- Keep each deployable blueprint independently stateful.
- Provide dedicated opt-in CIS landing zone blueprints for Level 1 and Level 2.
- Use Ansible for local orchestration, bootstrap checks, validation, and
  controlled Terraform command execution.
- Make diagrams, documentation, and local validation first-class project
  artifacts.
- Align security, governance, IAM, and networking patterns with CIS OCI
  Benchmark guidance.

## Architecture Approach

The landing zone is organized in layers:

| Layer | Purpose | Deploy Order |
|---|---|---|
| Layer 0 - IAM Foundation | Compartments, groups, policies, dynamic groups, baseline tagging | First |
| Layer 1 - Networking | Standalone VCN, hub-spoke, DRG, DNS, VPN, FastConnect, firewalls | After core |
| Layer 2 - Security Controls | Cloud Guard, Security Zones, VSS, Bastion, Vault | After core/networking as required |
| Layer 3 - Governance & Operations | Budgets, logging, events, monitoring, OS Management Hub | After core |

The default pattern is a centralized core baseline followed by one or more
blueprints that compose the reusable modules under `modules/`.

## Target Repository Structure

```text
.
├── docs/
│   ├── architecture/
│   │   ├── diagrams/
│   │   └── exports/
│   ├── ARCH-MAPPING-CIS.md
│   ├── DEPLOYMENT-GUIDE.md
│   ├── NAMING-CONVENTIONS.md
│   └── RUNBOOK.md
├── modules/
│   ├── iam/
│   ├── networking/
│   ├── security/
│   ├── governance/
│   └── operations/
├── blueprints/
│   ├── core/
│   ├── cis/
│   ├── compliance/
│   ├── data-platform/
│   ├── disaster-recovery/
│   ├── identity/
│   ├── industry/
│   ├── networking/
│   ├── operating-entity/
│   └── extensions/
├── ansible/
│   ├── inventories/
│   ├── playbooks/
│   └── roles/
├── environments/
│   ├── nonprod/
│   └── prod/
├── tests/
│   ├── unit/
│   └── integration/
├── scripts/
├── .pre-commit-config.yaml
├── CONTRIBUTING.md
├── LICENSE
├── README.md
├── RELEASE-NOTES.md
├── SECURITY.md
└── VARIABLES.md
```

## Blueprint Catalogue

Each deployable blueprint folder is intended to be self-contained. The local
`README.md` explains the pattern, fit, inputs, and deployment flow, while the
local `architecture/` folder defines the editable diagram source and exported
architecture image names.

### Core

| Blueprint | Path | Description |
|---|---|---|
| Core baseline | `blueprints/core/` | Mandatory baseline for compartments, IAM, tagging, logging, Cloud Guard, Security Zones, budgets, events, and Vault. |

### CIS Landing Zones

| Blueprint | Path | Description |
|---|---|---|
| CIS Level 1 landing zone | `blueprints/cis/level1/` | Optional CIS Level 1 profile for baseline CIS-aligned landing zone controls. |
| CIS Level 2 landing zone | `blueprints/cis/level2/` | Optional CIS Level 2 profile for stricter regulated or high-security environments. |

### Identity

Identity deployments also include local README and architecture folders so the
customer identity model, group mapping, and federation assumptions stay close to
the Terraform code.

| Blueprint | Path | Description |
|---|---|---|
| CIS basic | `blueprints/identity/cis-basic/` | Minimal CIS-aligned IAM baseline. |
| Custom identity domain | `blueprints/identity/custom-identity-domain/` | Federate an existing corporate identity provider. |
| New identity domain | `blueprints/identity/new-identity-domain/` | Provision a dedicated OCI Identity Domain. |

### Networking

Each networking deployment folder includes its own README and local
`architecture/` folder for the editable diagram and exported image.

| Blueprint | Path | Description |
|---|---|---|
| Standalone three-tier VCN defaults | `blueprints/networking/standalone-three-tier-vcn-defaults/` | Single VCN using standard CIDR defaults. |
| Standalone three-tier VCN custom | `blueprints/networking/standalone-three-tier-vcn-custom/` | Single VCN with fully parameterized CIDRs and rules. |
| Standalone three-tier VCN with ZPR | `blueprints/networking/standalone-three-tier-vcn-zpr/` | Single VCN using Zero Packet Routing attributes. |
| Externally managed VCNs | `blueprints/networking/externally-managed-vcns/` | Brownfield pattern for existing VCNs. |
| Hub-spoke with DRG | `blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns/` | OCI-only multi-VCN hub-spoke topology. |
| Hub-spoke with Bastion | `blueprints/networking/hub-spoke-with-hub-vcn-bastion-jump-host/` | Hub-spoke with OCI Bastion for administrative access. |
| Hub-spoke with FastConnect | `blueprints/networking/hub-spoke-with-hub-vcn-fastconnect-vc/` | Hub-spoke with private dedicated connectivity. |
| Hub-spoke with IPSec VPN | `blueprints/networking/hub-spoke-with-hub-vcn-ipsec-vpn/` | Hub-spoke with site-to-site VPN connectivity. |
| Hub-spoke with multicloud interconnect | `blueprints/networking/hub-spoke-with-multicloud-interconnect/` | Hub-spoke with private connectivity to another cloud or external provider. |
| Hub-spoke with network appliance | `blueprints/networking/hub-spoke-with-hub-vcn-net-appliance/` | Hub-spoke with third-party NVA inspection. |
| Hub-spoke with OCI Network Firewall | `blueprints/networking/hub-spoke-with-hub-vcn-net-firewall/` | Hub-spoke with managed OCI Network Firewall inspection. |
| Regional prod/nonprod hubs | `blueprints/networking/regional-prod-nonprod-hubs/` | Separate regional hubs and route domains for production and nonproduction isolation. |

### Operating Entity

Operating entity onboarding has its own local README and architecture folder for
ownership, delegated administration, network attachment, and budget assumptions.

| Blueprint | Path | Description |
|---|---|---|
| Operating entity | `blueprints/operating-entity/` | Repeatable onboarding pattern for a business unit, subsidiary, workload, or application team. |
| Multi-operating-entities | `blueprints/operating-entity/multi-operating-entities/` | Repeatable onboarding for multiple entities with delegated IAM, budgets, and network attachment. |
| Workload vending | `blueprints/operating-entity/workload-vending/` | Application-team onboarding package for compartments, IAM, budgets, tags, quotas, and network attachment. |

### Compliance

Compliance deployment folders add stricter control layouts where the design is
driven by auditability, traffic inspection, or regulator expectations.

| Blueprint | Path | Description |
|---|---|---|
| SCCA cloud native | `blueprints/compliance/scca-cloud-native/` | Regulated cloud-native landing zone with inspected ingress, egress, logging, and security boundaries. |
| Zero Trust | `blueprints/compliance/zero-trust/` | Identity-aware segmented landing zone using ZPR, private access, and inspected traffic paths. |

### Data Platform

| Blueprint | Path | Description |
|---|---|---|
| Private data platform | `blueprints/data-platform/private-data-platform/` | Private analytics and data platform landing zone with private endpoints, encryption, and controlled data access. |

### Disaster Recovery

| Blueprint | Path | Description |
|---|---|---|
| Full Stack Disaster Recovery | `blueprints/disaster-recovery/fsdr/` | OCI FSDR pattern for orchestrated failover and switchover across the application stack. |

### Industry

| Blueprint | Path | Description |
|---|---|---|
| Telco cloud native | `blueprints/industry/telco-cloud-native/` | Telco-oriented cloud-native landing zone with OKE, segmentation, private connectivity, and operations controls. |

### Extensions

Each extension folder includes local deployment notes and an `architecture/`
folder for the service-specific diagram and exported image.

| Extension | Path |
|---|---|
| OKE | `blueprints/extensions/oke/` |
| WAF | `blueprints/extensions/waf/` |
| Exadata | `blueprints/extensions/exadata/` |
| API Gateway | `blueprints/extensions/apigw/` |
| Streaming | `blueprints/extensions/streaming/` |

## Naming Convention

Resources follow this naming pattern:

```text
<org>-<env>-<region-key>-<resource-type>[-<description>[-<index>]]
```

Example:

```text
acme-prod-fra-cmp-network
acme-prod-fra-vcn-hub
acme-prod-fra-drg
acme-prod-fra-nfw-hub
acme-prod-fra-cmp-oe-finance
```

Rules:

- Use lowercase names.
- Use hyphens as delimiters.
- Do not use underscores.
- Keep names below 100 characters.
- Use a short organization prefix, environment name, OCI region key, and resource
  type abbreviation.

## Terraform Module Contract

Every reusable module should expose a consistent interface:

- `tenancy_ocid`
- `compartment_ocid`
- `region`
- `org`
- `environment`
- `region_key`
- `cis_level`
- `defined_tags`
- `freeform_tags`

Modules should output stable identifiers such as OCIDs, names, and maps needed
by downstream blueprints. Remote state belongs to deployable blueprints, not
shared modules.

## CIS Landing Zones

No CIS profile is enabled by default in the generic blueprints. Users who want
CIS-specific landing zone behavior should start from one of the dedicated
folders:

- `blueprints/cis/level1/`
- `blueprints/cis/level2/`

See `docs/CIS-PROFILES.md` for the CIS landing zone contract and planned
behavior.

## Ansible Contract

Ansible content lives under `ansible/` and is used for local orchestration only:

- bootstrap prerequisite checks
- OCI CLI validation
- repository validation
- controlled Terraform `init`, `validate`, and `plan` execution

Ansible playbooks must stay non-destructive by default. Terraform remains the
source of truth for OCI resource creation.

## Diagram Gate

Terraform and Ansible scaffold files may be created first. Before adding real
OCI resources or running `terraform apply` for a blueprint or module, the
matching Excalidraw diagram must exist under `docs/architecture/diagrams/`, be
exported under `docs/architecture/exports/`, and be marked as complete in the
diagram tracker.

Initial required diagrams:

| Diagram | First Consumer | Status |
|---|---|---|
| `00-overview.excalidraw` | `README.md` | TODO |
| `01-iam-compartments.excalidraw` | `blueprints/core/` | TODO |
| `02-hub-spoke-drg.excalidraw` | Hub-spoke DRG blueprint | TODO |
| `03-standalone-vcn.excalidraw` | Standalone VCN blueprints | TODO |
| `04-security-posture.excalidraw` | Security modules | TODO |
| `05-governance.excalidraw` | Governance modules | TODO |
| `06-operating-entity.excalidraw` | Operating entity blueprint | TODO |

## Deployment Flow

1. Bootstrap Terraform state storage and IAM credentials manually.
2. Deploy `blueprints/core/`.
3. Choose and deploy one networking blueprint.
4. Add operating entities as needed.
5. Add optional extensions such as OKE, WAF, Exadata, API Gateway, or Streaming.
6. Run local validation and security scanning before merging changes.

## Validation Tooling

The repository should standardize on:

- `terraform fmt`
- `terraform validate`
- `tflint`
- `tfsec`
- `checkov`
- `ansible-lint`
- Pre-commit hooks
Automated workflows and GitHub Actions are intentionally out of scope for now.

Terraform `1.12.0` or later is required for the native OCI remote state backend
used by the environment examples.

## Current Status

Project bootstrap, Phase 1 core structure, and Phase 2 IAM foundation are
implemented locally.

Completed:

- Remote repository cloned.
- Apache 2.0 license present.
- README drafted around the project goals and personal project context.
- Base repository structure created.
- Initial guardrail and documentation files added.
- Dedicated opt-in CIS Level 1 and Level 2 blueprint folders added.
- Core compartment and tagging modules implemented.
- Core IAM groups, dynamic groups, and scoped policies implemented.
- Deployment folders documented with local READMEs and architecture image
  locations.
- Deployment pattern catalog expanded with operating entity, compliance,
  multicloud, data platform, and industry blueprints.

Next implementation work should continue the core baseline with logging,
budgets, events, and security posture controls.

## License

This project is licensed under the Apache License 2.0. See `LICENSE` for
details.
