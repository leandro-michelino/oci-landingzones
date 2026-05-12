# OCI Landing Zones

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

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
| Core baseline | `blueprints/core/` | Mandatory baseline for compartments, IAM, and tagging. Logging, Cloud Guard, Security Zones, budgets, events, and Vault come in later phases. |

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
| Standalone private endpoint only | `blueprints/networking/standalone-private-endpoint-only/` | Private-only VCN with service gateway access and no public ingress by default. |
| Externally managed VCNs | `blueprints/networking/externally-managed-vcns/` | Brownfield pattern for existing VCNs. |
| Hub-spoke with DRG | `blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns/` | OCI-only multi-VCN hub-spoke topology. |
| Hub-spoke with Bastion | `blueprints/networking/hub-spoke-with-hub-vcn-bastion-jump-host/` | Hub-spoke with OCI Bastion for administrative access. |
| Hub-spoke with FastConnect | `blueprints/networking/hub-spoke-with-hub-vcn-fastconnect-vc/` | Hub-spoke with private dedicated connectivity. |
| Hub-spoke with IPSec VPN | `blueprints/networking/hub-spoke-with-hub-vcn-ipsec-vpn/` | Hub-spoke with site-to-site VPN connectivity. |
| Hub-spoke with multicloud interconnect | `blueprints/networking/hub-spoke-with-multicloud-interconnect/` | Hub-spoke with private connectivity to another cloud or external provider. |
| Hub-spoke with network appliance | `blueprints/networking/hub-spoke-with-hub-vcn-net-appliance/` | Hub-spoke with third-party NVA inspection. |
| Hub-spoke with OCI Network Firewall | `blueprints/networking/hub-spoke-with-hub-vcn-net-firewall/` | Hub-spoke with managed OCI Network Firewall inspection. |
| Hub-spoke with private DNS split horizon | `blueprints/networking/hub-spoke-with-private-dns-split-horizon/` | Hub-spoke with private zones and resolver attachments. |
| Hub-spoke with transit routing NVA HA | `blueprints/networking/hub-spoke-with-transit-routing-nva-ha/` | Hub-spoke with optional HA network virtual appliances and route target IPs. |
| Hub-spoke with ZPR micro-segmentation | `blueprints/networking/hub-spoke-with-zpr-micro-segmentation/` | Hub-spoke with optional ZPR configuration and policies. |
| Hub-spoke with dual-region DR | `blueprints/networking/hub-spoke-with-dual-region-dr/` | Primary and secondary regional hub-spoke networks. |
| Multi-tenancy shared services | `blueprints/networking/multi-tenancy-shared-services/` | Shared hub services with private DNS for multiple tenant/workload spokes. |
| Regional prod/nonprod hubs | `blueprints/networking/regional-prod-nonprod-hubs/` | Separate regional hubs and route domains for production and nonproduction isolation. |

Phase 3 implements the reusable networking foundations behind the catalog:
standalone VCNs, private-only VCNs, DRG hub-spoke, Bastion, FastConnect, IPSec,
OCI Network Firewall, NVA, private DNS, ZPR, dual-region DR, multicloud, shared
services, and prod/nonprod hub separation. External or potentially expensive
resources such as IPSec, FastConnect, Bastion, Network Firewall, NVA compute,
resolver endpoints, and ZPR are intentionally optional so local smoke tests can
validate topology without surprising anyone with provider dependencies or cost.

### Operating Entity

Operating entity onboarding has its own local README and architecture folder for
ownership, delegated administration, network attachment, and budget assumptions.

| Blueprint | Path | Description |
|---|---|---|
| Operating entity | `blueprints/operating-entity/` | Repeatable onboarding pattern for one business unit, subsidiary, workload owner, or application team with delegated IAM. |
| Multi-operating-entities | `blueprints/operating-entity/multi-operating-entities/` | Repeatable onboarding for multiple entities with delegated groups, scoped policies, and consistent compartment shapes. |
| Workload vending | `blueprints/operating-entity/workload-vending/` | Application-team onboarding package for workload compartments, delegated IAM, and ownership tags. |

Phase 4 implements the operating-entity foundation behind this catalog: single
entity onboarding, multi-entity onboarding, and workload vending. These
blueprints now create compartments, delegated IAM groups, scoped policies, and
ownership tags. Budgets, logging, quota enforcement, and network attachment are
kept as documented operating-model hooks for the next security and governance
phases.

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
- repository validation across implemented Phase 1-4 blueprints
- controlled Terraform `init`, `validate`, and `plan` execution

Ansible playbooks must stay non-destructive by default. Terraform remains the
source of truth for OCI resource creation.

## Diagram Gate

Placeholder folders and documentation may be created before implementation so
the project map stays visible. Before adding real OCI resources or running
`terraform apply` for a blueprint or module, the
matching Excalidraw diagram must exist either in the shared `docs/architecture/`
area or in the blueprint's own `architecture/` folder. Each diagram should have
an exported image beside it and be marked as complete in the diagram tracker.

Initial required diagrams:

| Diagram | First Consumer | Status |
|---|---|---|
| `00-overview.excalidraw` | `README.md` | TODO |
| `blueprints/core/architecture/core.excalidraw` | `blueprints/core/` | TODO |
| `blueprints/cis/level1/architecture/cis-level1.excalidraw` | CIS Level 1 blueprint | TODO |
| `blueprints/cis/level2/architecture/cis-level2.excalidraw` | CIS Level 2 blueprint | TODO |
| `blueprints/networking/*/architecture/*.excalidraw` | Networking blueprints | TODO |
| `04-security-posture.excalidraw` | Security modules | TODO |
| `05-governance.excalidraw` | Governance modules | TODO |
| `blueprints/operating-entity/architecture/operating-entity.excalidraw` | Single operating entity blueprint | TODO |
| `blueprints/operating-entity/multi-operating-entities/architecture/multi-operating-entities.excalidraw` | Multi-operating-entity blueprint | TODO |
| `blueprints/operating-entity/workload-vending/architecture/workload-vending.excalidraw` | Workload vending blueprint | TODO |

## Deployment Flow

1. Bootstrap Terraform state storage and IAM credentials manually.
2. Deploy `blueprints/core/`.
3. Choose and deploy one networking blueprint.
4. Add operating entities as needed.
5. Add optional extensions such as OKE, WAF, Exadata, API Gateway, or Streaming.
6. Run local validation and security scanning before merging changes.

## Validation Tooling

The main local validation entry point is:

```bash
./scripts/validate-all.sh
```

When Ansible is installed, the script delegates to
`ansible/playbooks/validate.yml`. That playbook runs `terraform fmt`, initializes
and validates the implemented Phase 1-4 blueprints with `-backend=false`, checks
Ansible playbook syntax, runs optional local linters when available, and removes
generated Terraform artifacts afterward.

The repository standardizes on:

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

## Repository Hygiene

Keep generated Terraform and local test files out of the repo. The project
intentionally ignores `.terraform/`, `.terraform.lock.hcl`, `terraform.tfstate*`,
`*.tfplan`, local `terraform.tfvars`, and `.codex-local/` because each blueprint
is validated independently and real test data belongs on the workstation only.

Before committing, clean local generated files if needed:

```bash
find . -name ".terraform" -type d -prune -exec rm -rf {} +
find . -name ".terraform.lock.hcl" -type f -delete
find . -name "terraform.tfstate*" -type f -delete
rm -rf .codex-local
```

The Ansible validation playbook performs this cleanup for generated Terraform
artifacts after validation, but the commands above are useful after manual
Terraform experiments.

## Current Status

Project bootstrap, Phase 1 core structure, Phase 2 IAM foundation, optional CIS
wrappers, Phase 3 networking foundations, and Phase 4 operating entity
onboarding are implemented.

Completed:

- Remote repository cloned.
- Apache 2.0 license present.
- README drafted around the project goals and personal project context.
- Base repository structure created.
- Initial guardrail and documentation files added.
- Dedicated opt-in CIS Level 1 and Level 2 blueprint folders added.
- Core compartment and tagging modules implemented.
- Core IAM groups, dynamic groups, and scoped policies implemented.
- CIS Level 1 and Level 2 wrappers wired to the core/IAM foundation.
- Phase 3 networking modules and deployment blueprints wired with optional
  external or high-cost resources disabled by default.
- Phase 4 operating entity blueprints wired for single entity onboarding,
  multi-entity onboarding, and workload vending.
- Ansible validation wired to run Terraform checks across every implemented
  Phase 1-4 blueprint.
- Deployment folders documented with local READMEs and architecture image
  locations.
- Deployment pattern catalog expanded with operating entity, compliance,
  multicloud, data platform, and industry blueprints.

Next implementation work should continue with security posture and governance
controls such as logging, budgets, events, Cloud Guard, Security Zones, Vault,
and VSS.

## License

This project is licensed under the Apache License 2.0. See `LICENSE` for
details.
