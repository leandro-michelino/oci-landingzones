# OCI Landing Zones

Opinionated Terraform landing zone framework for Oracle Cloud Infrastructure
(OCI), designed around a centralized core baseline and modular deployment
blueprints for networking, operating entities, and optional platform
extensions.

This repository is being bootstrapped from the OCI Landing Zone implementation
blueprint and will evolve into deployable Terraform compositions aligned to CIS
OCI Benchmark controls, OCI naming conventions, and GitOps delivery practices.

## Objectives

- Provide a reusable OCI landing zone foundation for greenfield and brownfield
  tenancies.
- Separate mandatory core controls from optional deployment blueprints.
- Keep Terraform modules reusable, composable, and free from remote state.
- Keep each deployable blueprint independently stateful.
- Make diagrams, documentation, validation, and CI/CD first-class project
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
├── .github/
│   └── workflows/
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
│   ├── identity/
│   ├── networking/
│   ├── operating-entity/
│   └── extensions/
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

### Core

| Blueprint | Path | Description |
|---|---|---|
| Core baseline | `blueprints/core/` | Mandatory baseline for compartments, IAM, tagging, logging, Cloud Guard, Security Zones, budgets, events, and Vault. |

### Identity

| Blueprint | Path | Description |
|---|---|---|
| CIS basic | `blueprints/identity/cis-basic/` | Minimal CIS-aligned IAM baseline. |
| Custom identity domain | `blueprints/identity/custom-identity-domain/` | Federate an existing corporate identity provider. |
| New identity domain | `blueprints/identity/new-identity-domain/` | Provision a dedicated OCI Identity Domain. |

### Networking

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
| Hub-spoke with network appliance | `blueprints/networking/hub-spoke-with-hub-vcn-net-appliance/` | Hub-spoke with third-party NVA inspection. |
| Hub-spoke with OCI Network Firewall | `blueprints/networking/hub-spoke-with-hub-vcn-net-firewall/` | Hub-spoke with managed OCI Network Firewall inspection. |

### Operating Entity

| Blueprint | Path | Description |
|---|---|---|
| Operating entity | `blueprints/operating-entity/` | Repeatable onboarding pattern for a business unit, subsidiary, workload, or application team. |

### Extensions

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
- `defined_tags`
- `freeform_tags`

Modules should output stable identifiers such as OCIDs, names, and maps needed
by downstream blueprints. Remote state belongs to deployable blueprints, not
shared modules.

## Diagram Gate

Before implementing Terraform for a blueprint or module, the matching
Excalidraw diagram must exist under `docs/architecture/diagrams/`, be exported
under `docs/architecture/exports/`, and be marked as complete in the diagram
tracker.

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
| `07-cicd-pipeline.excalidraw` | CI/CD workflows | TODO |

## Deployment Flow

1. Bootstrap Terraform state storage and IAM credentials manually.
2. Deploy `blueprints/core/`.
3. Choose and deploy one networking blueprint.
4. Add operating entities as needed.
5. Add optional extensions such as OKE, WAF, Exadata, API Gateway, or Streaming.
6. Run validation, security scanning, and CI/CD checks before merging changes.

## Validation Tooling

The repository should standardize on:

- `terraform fmt`
- `terraform validate`
- `tflint`
- `tfsec`
- `checkov`
- Pre-commit hooks
- GitHub Actions for plan, apply, and scheduled security scans

Terraform `1.12.0` or later is required for the native OCI remote state backend
used by the environment examples.

## Current Status

Project bootstrap is in progress.

Completed:

- Remote repository cloned.
- Apache 2.0 license present.
- Initial README drafted from the implementation blueprint.
- Base repository structure created.
- Initial guardrail and documentation files added.

Next implementation work should create the first architecture diagram
(`00-overview.excalidraw`) and then start the core landing zone Terraform
skeleton.

## License

This project is licensed under the Apache License 2.0. See `LICENSE` for
details.
