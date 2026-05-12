# Networking Deployment Blueprints

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This folder contains the OCI networking deployment patterns used by the landing zone
project. Each deployment folder is self-contained: it has Terraform files, a local
README, and an `architecture/` folder for the diagram source and exported image.

## What It Does

This is the networking pattern catalog. It helps choose between a quick standalone VCN,
a private-only design, hub-spoke, hybrid connectivity, inspection, DNS, DR, multicloud,
and shared-services models without pretending one topology fits every customer.

## Why Use It

Use this folder when the main design question is traffic: where it enters, where it
leaves, how it is inspected, how DNS works, and how many VCNs or regions are involved.

## When To Use It

- Start with standalone when the workload is simple.
- Move to hub-spoke when more than one workload, team, or connectivity path appears.
- Pick firewall, NVA, VPN, FastConnect, DNS, or DR variants when that requirement is the
  reason the design exists.

## Catalogue

| Pattern | Folder | Use When |
|---|---|---|
| Internet-only three-tier defaults | `standalone-three-tier-vcn-defaults/` | A simple internet-facing web, app, and database VCN is enough. |
| Custom three-tier VCN | `standalone-three-tier-vcn-custom/` | The customer has specific CIDRs, names, routes, or security rules. |
| Three-tier VCN with ZPR | `standalone-three-tier-vcn-zpr/` | A standalone workload needs segmentation attributes. |
| Private endpoint only | `standalone-private-endpoint-only/` | No direct internet exposure is allowed. |
| Hub-spoke with DRG | `hub-spoke-with-drg-and-three-tier-vcns/` | Multiple VCNs need shared routing through a DRG. |
| Hub-spoke with IPSec | `hub-spoke-with-hub-vcn-ipsec-vpn/` | Private hybrid connectivity is required over VPN. |
| Hub-spoke with FastConnect | `hub-spoke-with-hub-vcn-fastconnect-vc/` | Dedicated private connectivity is required. |
| Hub-spoke with multicloud interconnect | `hub-spoke-with-multicloud-interconnect/` | Private connectivity to another cloud or external provider is required. |
| Hub-spoke with OCI Network Firewall | `hub-spoke-with-hub-vcn-net-firewall/` | Managed centralized inspection is required. |
| Hub-spoke with NVA | `hub-spoke-with-hub-vcn-net-appliance/` | A third-party appliance is required. |
| Hub-spoke with Bastion | `hub-spoke-with-hub-vcn-bastion-jump-host/` | Centralized administrative access is required. |
| Regional prod/nonprod hubs | `regional-prod-nonprod-hubs/` | Production and nonproduction require separate hub routing and inspection boundaries. |
| Private DNS split horizon | `hub-spoke-with-private-dns-split-horizon/` | OCI and on-premises need private DNS coordination. |
| Transit routing NVA HA | `hub-spoke-with-transit-routing-nva-ha/` | HA third-party transit inspection is required. |
| ZPR micro-segmentation | `hub-spoke-with-zpr-micro-segmentation/` | Segmentation spans multiple VCNs and applications. |
| Dual-region DR | `hub-spoke-with-dual-region-dr/` | Primary and secondary region landing-zone networking is required. |
| Multi-tenancy shared services | `multi-tenancy-shared-services/` | Shared services support multiple teams or operating entities. |
| Externally managed VCNs | `externally-managed-vcns/` | Existing VCNs are referenced but not owned by this repo. |

## Folder Contract

Each deployment folder should contain:

- `README.md` with the deployment intent, fit, inputs, and flow.
- `architecture/<deployment>.excalidraw` for the editable diagram source.
- `architecture/<deployment>.png` for the exported architecture image.
- `terraform.tfvars.example` with safe example values.
- Terraform code that composes reusable modules from `modules/`.

## Deployment Rule

Deploy `blueprints/core/` first. Networking blueprints should consume core outputs for
compartments, IAM, tagging, and governance context.
