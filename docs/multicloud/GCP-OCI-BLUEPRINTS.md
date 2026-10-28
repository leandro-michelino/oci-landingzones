# GCP + OCI Blueprint Counterparts: Final Phase

Status: **Planned, not implemented.** Requested by the user on October 28, 2026.

Implement this phase after the current diagram conversion and resource-coverage
work for the original 80 blueprint entry points is complete. Continue that work
in batches of five. At the time of this request, 44 diagrams are converted and
36 remain; the retrospective review of the original 39 is already complete.
These GCP additions do not count toward completion of the original 80.

The request includes deployable infrastructure blueprints and the complete GCP
side of each architecture. It does not authorize cloud provisioning or charges.

## Planned First Batch

Use these existing deployment patterns as structural references. The target
paths below are reserved planning names, not available blueprint folders.

| Outcome | Existing counterpart | Planned target |
| --- | --- | --- |
| GCP + OCI hybrid network backbone | [AWS backbone](../../blueprints/networking/aws-oci-hybrid-network-backbone/README.md), [Azure dual connectivity](../../blueprints/networking/azure-oci-dual-connectivity/README.md) | `blueprints/networking/gcp-oci-hybrid-network-backbone/` |
| GCP + OCI cross-cloud DR | [AWS DR](../../blueprints/disaster-recovery/aws-oci-cross-cloud-dr/README.md), [Azure DR](../../blueprints/disaster-recovery/azure-oci-cross-cloud-dr/README.md) | `blueprints/disaster-recovery/gcp-oci-cross-cloud-dr/` |
| GKE + OKE active/passive | [EKS + OKE](../../blueprints/extensions/eks-oke-active-passive/README.md), [AKS + OKE](../../blueprints/extensions/aks-oke-active-passive/README.md) | `blueprints/extensions/gke-oke-active-passive/` |
| OCI + GCP MySQL DR | [OCI + AWS MySQL HeatWave DR](../../blueprints/data-platform/oci-aws-mysql-heatwave-dr/README.md) | `blueprints/data-platform/oci-gcp-mysql-heatwave-dr/` |
| GCP + OCI AI gateway | [Azure + OCI AI gateway](../../blueprints/ai/azure-oci-ai-gateway/README.md) | `blueprints/ai/gcp-oci-ai-gateway/` |

Adapt each outcome to verified GCP service behavior during implementation.
Do not assume that AWS/Azure gateway, routing, IAM, database replication or AI
endpoint settings translate directly to GCP. Confirm current provider schemas,
service availability and supported integration behavior from official sources
before selecting implementation defaults. Preserve the counterpart's intended
roles and make primary/standby and routing responsibilities explicit.

## Delivery Contract

Each blueprint must have:

- The repository-standard operator README, detailed architecture README,
  Terraform composition, variables, outputs, provider/version constraints,
  safe example inputs and Ansible plan/apply/destroy runners.
- A separately scoped `gcp/` implementation containing the infrastructure
  necessary for that pattern's GCP side, with explicit project, region,
  credentials, state ownership, dependencies and cleanup instructions.
- All relevant network, IAM, workload, storage, encryption, logging, DNS and
  gateway resources represented where the source actually declares them.
  Existing resources and external services remain labelled prerequisites.
- Editable draw.io overviews and paginated resource-detail pages, PNG previews,
  GCP icons where available and a source-to-diagram resource inventory covering
  both OCI and GCP. No ASCII architecture replacement is used for new diagrams.
- Local schema/contract tests and safe plan fixtures, with validation scope and
  provider versions recorded accurately. Live provisioning, traffic, replication
  and recovery results must be tracked separately if later authorized and run.

Keep paid and quota-heavy components disabled in safe validation fixtures.
Inputs, contracts and outputs must distinguish resources actually created from
referenced circuit IDs, endpoint metadata and intended failover behavior.
Do not claim working replication, automatic failover or production readiness
from a foundation deployment or mocked test.

## Completion And Publication

Finish the original diagram queue first. Then implement and validate the five
GCP counterparts as the next batch, update the blueprint catalog/index only as
folders become available, and publish validated changes to `main` without force
push. Verify the remote commit and keep live-test costs and cleanup within any
separately approved scope.
