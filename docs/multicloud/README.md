# Multicloud Notes (Azure + OCI, AWS + OCI)

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This folder is the design notebook for multicloud work.
Use it for architecture context, backlog ideas, and decision history.

For current status tracking, use `docs/ROADMAP.md`.

Implemented patterns live under `blueprints/`.
Docs in this folder stay as design records and backlog notes.

## Implemented Blueprints

| Pattern | Implemented Path |
| --- | --- |
| Azure + OCI AI gateway | `blueprints/ai/azure-oci-ai-gateway/` |
| AKS + OKE active/active | `blueprints/extensions/aks-oke-active-active/` |
| Azure + OCI cross-cloud DR | `blueprints/disaster-recovery/azure-oci-cross-cloud-dr/` |
| AWS + OCI hybrid network backbone | `blueprints/networking/aws-oci-hybrid-network-backbone/` |
| AWS + OCI cross-cloud DR | `blueprints/disaster-recovery/aws-oci-cross-cloud-dr/` |
| EKS + OKE active/active | `blueprints/extensions/eks-oke-active-active/` |

## Backlog and Design Notes

| Note | Focus | Target Path |
| --- | --- | --- |
| [Identity Federation](AZURE-OCI-IDENTITY-FEDERATION.md) | Microsoft Entra ID federation into OCI IAM with mapped RBAC and conditional access alignment. | `blueprints/identity/azure-entra-federation/` |
| [Hybrid Networking](AZURE-OCI-HYBRID-NETWORKING.md) | Azure hub/vWAN to OCI DRG with private + encrypted paths, route governance, and DNS integration. | `blueprints/networking/azure-oci-hybrid-networking/` |
| [Cross-Cloud DR (design record)](AZURE-OCI-CROSS-CLOUD-DR.md) | Historical architecture draft retained as design context after implementation. | `blueprints/disaster-recovery/azure-oci-cross-cloud-dr/` |
| [OCI + AWS MySQL HeatWave DR (OCI primary over IPSec)](OCI-AWS-MYSQL-HEATWAVE-IPSEC-DR.md) | OCI-primary MySQL HeatWave with standby MySQL HeatWave on AWS, asynchronous replication, and DNS-driven failover runbooks. | `blueprints/data-platform/oci-aws-mysql-heatwave-dr/` |

## How To Use This Folder

- Use implemented blueprint folders as the source of truth for deployment.
- Use these notes for architecture reviews, backlog refinement, and design
  rationale.
- Promote backlog notes to `blueprints/...` only when each pattern has an
  approved owner, lifecycle, and state boundary.
