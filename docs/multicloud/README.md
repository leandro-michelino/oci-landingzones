# Multicloud Notes (Azure + OCI, AWS + OCI)

This folder is the design notebook for multicloud work.
Use it for architecture context, backlog ideas, and decision history.

For current status tracking, use `docs/ROADMAP.md`.

Available patterns live under `blueprints/`.
Docs in this folder stay as design records for available patterns and drafts for
backlog patterns.

## Available Blueprints

| Pattern | Available Path |
| --- | --- |
| Azure + OCI AI gateway | `blueprints/ai/azure-oci-ai-gateway/` |
| AKS + OKE active/passive | `blueprints/extensions/aks-oke-active-passive/` |
| Azure + OCI cross-cloud DR | `blueprints/disaster-recovery/azure-oci-cross-cloud-dr/` |
| Azure + OCI dual connectivity hardening | `blueprints/networking/azure-oci-dual-connectivity/` |
| Azure vWAN + OCI DRG transit backbone | `blueprints/networking/azure-vwan-oci-drg-transit/` |
| AWS + OCI hybrid network backbone | `blueprints/networking/aws-oci-hybrid-network-backbone/` |
| AWS + OCI cross-cloud DR | `blueprints/disaster-recovery/aws-oci-cross-cloud-dr/` |
| EKS + OKE active/passive | `blueprints/extensions/eks-oke-active-passive/` |
| OCI + AWS MySQL HeatWave DR | `blueprints/data-platform/oci-aws-mysql-heatwave-dr/` |

## Available Design Records

| Note | Focus | Target Path |
| --- | --- | --- |
| [Azure + OCI Cross-Cloud DR](AZURE-OCI-CROSS-CLOUD-DR.md) | Historical architecture note retained as design context after delivery. | `blueprints/disaster-recovery/azure-oci-cross-cloud-dr/` |
| [Azure + OCI Hybrid Networking](AZURE-OCI-HYBRID-NETWORKING.md) | OCI-primary hybrid networking design record covering dual-connectivity and vWAN/vHub transit route-domain patterns with Interconnect default when present, IPSec/BGP backup, and test-friendly `without-interconnect` rollout. | `blueprints/networking/azure-oci-dual-connectivity/`, `blueprints/networking/azure-vwan-oci-drg-transit/` |
| [Azure vWAN + OCI DRG Transit](AZURE-VWAN-OCI-DRG-TRANSIT.md) | OCI-primary transit design record with Azure vWAN/vHub route domain, Interconnect default when present, and IPSec/BGP-first testing contracts. | `blueprints/networking/azure-vwan-oci-drg-transit/` |
| [AWS + OCI Hybrid Network Backbone](AWS-OCI-HYBRID-NETWORK-BACKBONE.md) | OCI DRG-primary hybrid backbone with AWS Transit Gateway, optional VPN, and Direct Connect + FastConnect contract metadata. | `blueprints/networking/aws-oci-hybrid-network-backbone/` |
| [AWS + OCI Cross-Cloud DR](AWS-OCI-CROSS-CLOUD-DR.md) | OCI-primary, AWS-standby DR design record with DNS failover, evidence, alerting, and runbook contracts. | `blueprints/disaster-recovery/aws-oci-cross-cloud-dr/` |
| [EKS + OKE Active Passive](EKS-OKE-ACTIVE-PASSIVE.md) | OCI-primary OKE and AWS-standby EKS active/passive design record with GitOps and OCI Traffic Management failover contracts. | `blueprints/extensions/eks-oke-active-passive/` |
| [OCI + AWS MySQL HeatWave DR](OCI-AWS-MYSQL-HEATWAVE-IPSEC-DR.md) | OCI-primary MySQL HeatWave DR over IPSec with AWS standby database, replication, and failover contracts. | `blueprints/data-platform/oci-aws-mysql-heatwave-dr/` |

## Backlog Drafts

| Note | Focus | Target Path |
| --- | --- | --- |
| [Identity Federation](AZURE-OCI-IDENTITY-FEDERATION.md) | Microsoft Entra ID federation into OCI IAM with mapped RBAC and conditional access alignment. | `blueprints/identity/azure-entra-federation/` |
| [AWS Interconnect Multicloud with OCI Preview](AWS-INTERCONNECT-MULTICLOUD-OCI-PREVIEW.md) | Preview-only AWS Interconnect - multicloud with OCI design note and current Limited Availability region pair; OCI support is not treated as production-ready repo automation yet. | `blueprints/networking/aws-interconnect-multicloud-oci/` |

## How To Use This Folder

- Use available blueprint folders as the source of truth for deployment.
- Use available design records for architecture reviews and design rationale.
- Use backlog drafts for refinement before design.
- Promote backlog notes to `blueprints/...` only when each pattern has an
  approved owner, lifecycle, and state boundary.
