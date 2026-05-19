# Multicloud Architecture Notes (Azure + OCI)

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This folder captures Azure + OCI architecture notes and remaining backlog
patterns.

Implemented patterns live under `blueprints/`. Documents in this folder are
kept for design history and for patterns that are not yet implemented.

## Implemented Blueprints

| Pattern | Implemented Path |
| --- | --- | --- |
| AKS + OKE active/active | `blueprints/extensions/aks-oke-active-active/` |
| Azure + OCI cross-cloud DR | `blueprints/disaster-recovery/azure-oci-cross-cloud-dr/` |

## Backlog / Design Notes

| Note | Focus | Target Path |
| --- | --- | --- |
| [Identity Federation](AZURE-OCI-IDENTITY-FEDERATION.md) | Microsoft Entra ID federation into OCI IAM with mapped RBAC and conditional access alignment. | `blueprints/identity/azure-entra-federation/` |
| [Hybrid Networking](AZURE-OCI-HYBRID-NETWORKING.md) | Azure hub/vWAN to OCI DRG with private + encrypted paths, route governance, and DNS integration. | `blueprints/networking/azure-oci-hybrid-networking/` |
| [Cross-Cloud DR (design record)](AZURE-OCI-CROSS-CLOUD-DR.md) | Historical architecture draft retained as design context after implementation. | `blueprints/disaster-recovery/azure-oci-cross-cloud-dr/` |

## How To Use These Notes

- Use implemented blueprint folders as the source of truth for deployment.
- Use these notes for architecture reviews, backlog refinement, and design
  rationale.
- Promote backlog notes to `blueprints/...` only when each pattern has an
  approved owner, lifecycle, and state boundary.
