# Multicloud Blueprint Drafts (Azure + OCI)

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This folder captures concrete Azure + OCI blueprint drafts before they become
full deployable folders under `blueprints/`.

These drafts are architecture-first: clear scope, control boundaries, rollout
plans, and hand-off contracts. They are intended to reduce design risk before
Terraform implementation starts.

## Draft Blueprint Menu

| Draft | Focus | Target Deployable Path |
| --- | --- | --- |
| [Identity Federation](AZURE-OCI-IDENTITY-FEDERATION.md) | Microsoft Entra ID federation into OCI IAM with mapped RBAC and conditional access alignment. | `blueprints/identity/azure-entra-federation/` |
| [Hybrid Networking](AZURE-OCI-HYBRID-NETWORKING.md) | Azure hub/vWAN to OCI DRG with private + encrypted paths, route governance, and DNS integration. | `blueprints/networking/azure-oci-hybrid-networking/` |
| [Cross-Cloud DR](AZURE-OCI-CROSS-CLOUD-DR.md) | Active/passive application disaster recovery between Azure and OCI with DNS failover and recovery runbook controls. | `blueprints/disaster-recovery/azure-oci-cross-cloud-dr/` |

## How To Use These Drafts

- Use these documents in architecture reviews and customer workshops.
- Confirm identity, network, and recovery ownership boundaries.
- Freeze key inputs and outputs before creating Terraform scaffolding.
- Promote to `blueprints/...` only when each pattern has an approved owner,
  lifecycle, and state boundary.
