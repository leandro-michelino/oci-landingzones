# Multicloud Notes (Azure + OCI, AWS + OCI)

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This folder is the design notebook for multicloud work.
Use it for architecture context, backlog ideas, and decision history.

For current status tracking, use `docs/ROADMAP.md`.

Deployed patterns live under `blueprints/`.
Docs in this folder stay as design records for deployed patterns and drafts for
backlog patterns.

## Deployed Blueprints

| Pattern | Deployed Path |
| --- | --- |
| Azure + OCI AI gateway | `blueprints/ai/azure-oci-ai-gateway/` |
| AKS + OKE active/active | `blueprints/extensions/aks-oke-active-active/` |
| Azure + OCI cross-cloud DR | `blueprints/disaster-recovery/azure-oci-cross-cloud-dr/` |
| AWS + OCI hybrid network backbone | `blueprints/networking/aws-oci-hybrid-network-backbone/` |
| AWS + OCI cross-cloud DR | `blueprints/disaster-recovery/aws-oci-cross-cloud-dr/` |
| EKS + OKE active/active | `blueprints/extensions/eks-oke-active-active/` |
| OCI + AWS MySQL HeatWave DR | `blueprints/data-platform/oci-aws-mysql-heatwave-dr/` |

## Deployed Design Records

| Note | Focus | Target Path |
| --- | --- | --- |
| [Azure + OCI Cross-Cloud DR](AZURE-OCI-CROSS-CLOUD-DR.md) | Historical architecture note retained as design context after delivery. | `blueprints/disaster-recovery/azure-oci-cross-cloud-dr/` |
| [AWS + OCI Hybrid Network Backbone](AWS-OCI-HYBRID-NETWORK-BACKBONE.md) | OCI DRG-primary hybrid backbone with AWS Transit Gateway, optional VPN, and Direct Connect + FastConnect contract metadata. | `blueprints/networking/aws-oci-hybrid-network-backbone/` |
| [AWS + OCI Cross-Cloud DR](AWS-OCI-CROSS-CLOUD-DR.md) | OCI-primary, AWS-standby DR design record with DNS failover, evidence, alerting, and runbook contracts. | `blueprints/disaster-recovery/aws-oci-cross-cloud-dr/` |
| [EKS + OKE Active Active](EKS-OKE-ACTIVE-ACTIVE.md) | OCI-primary OKE and AWS-secondary EKS active/active design record with GitOps and weighted traffic steering contracts. | `blueprints/extensions/eks-oke-active-active/` |
| [OCI + AWS MySQL HeatWave DR](OCI-AWS-MYSQL-HEATWAVE-IPSEC-DR.md) | OCI-primary MySQL HeatWave DR over IPSec with AWS standby database, replication, and failover contracts. | `blueprints/data-platform/oci-aws-mysql-heatwave-dr/` |

## Backlog Drafts

| Note | Focus | Target Path |
| --- | --- | --- |
| [Identity Federation](AZURE-OCI-IDENTITY-FEDERATION.md) | Microsoft Entra ID federation into OCI IAM with mapped RBAC and conditional access alignment. | `blueprints/identity/azure-entra-federation/` |
| [Hybrid Networking](AZURE-OCI-HYBRID-NETWORKING.md) | Azure hub/vWAN to OCI DRG with private + encrypted paths, route governance, and DNS integration. | `blueprints/networking/azure-oci-hybrid-networking/` |

## How To Use This Folder

- Use deployed blueprint folders as the source of truth for deployment.
- Use deployed design records for architecture reviews and design rationale.
- Use backlog drafts for refinement before implementation.
- Promote backlog notes to `blueprints/...` only when each pattern has an
  approved owner, lifecycle, and state boundary.
