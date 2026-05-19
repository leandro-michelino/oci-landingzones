# EKS + OKE Active Active Design Record

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This document preserves the multicloud design rationale for the deployed
blueprint in `blueprints/extensions/eks-oke-active-active/`.

Use the blueprint folder as the deployment source of truth. Keep this file as
design history, backlog context, and architecture review material.

## Deployment Purpose

Deliver an OCI-primary active/active Kubernetes operating pattern where OKE is
the primary cluster target, EKS is the secondary cluster target, GitOps handles
multi-cluster rollout, and weighted traffic steering controls application
distribution.

## Primary Outcomes

- OCI-primary OKE and AWS-secondary EKS operating contract.
- Optional OKE network, cluster, and node pool deployment.
- AWS EKS secondary deployment through a local CloudFormation session.
- Interconnect-only connectivity posture using Direct Connect + FastConnect
  partner path.
- Explicit GitOps hand-off for Argo CD or Flux.
- Weighted traffic steering metadata for OCI primary and AWS secondary
  endpoints.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Primary cluster | OKE in OCI |
| Secondary cluster | EKS in AWS |
| Connectivity | Direct Connect + FastConnect partner interconnect |
| VPN posture | IPSec backup disabled in this variant |
| Rollout control | GitOps contract for Argo CD or Flux |
| Traffic control | Weighted DNS or global traffic manager policy |

## Architecture

```text
+------------------------------------------------------------------------------------------------+
| EKS + OKE Active Active                                                                        |
+------------------------------------------------------------------------------------------------+
|                                                                                                |
| [Platform Operators / CI]                                                                      |
|          |                                                                                     |
|          +--> OCI Terraform session                                                            |
|          |       |                                                                             |
|          |       v                                                                             |
|          |   [OCI VCN + OKE subnets] --> [OKE primary cluster] --> [OCI ingress endpoint]      |
|          |                                                                             ^       |
|          |                                                                             |       |
|          +--> AWS CloudFormation session                                               |       |
|          |       |                                                                     |       |
|          |       v                                                                     |       |
|          |   [AWS VPC + EKS secondary cluster] --> [AWS ingress endpoint]              |       |
|          |                                                                             |       |
|          `--> [GitOps repo and controller contract] ------------------------------------'       |
|                                                                                                |
| [Clients] -> [DNS/GTM weighted steering] -> OCI primary endpoint and AWS secondary endpoint    |
|                                                                                                |
| Guardrail: OCI primary required, interconnect-only path, IPSec backup disabled.                |
+------------------------------------------------------------------------------------------------+
```

## Platform Design

### Cluster Tier

- OKE can be created by this blueprint or supplied as an existing cluster.
- EKS can be created by the AWS CloudFormation session or supplied as an
  existing secondary target in Terraform inputs.
- Cluster ownership can be split across OCI and AWS platform teams as long as
  outputs are captured in the same runbook.

### Delivery Tier

- GitOps is the expected application deployment control plane.
- The contract records GitOps tool, repository URL, and branch assumptions.
- Application-specific sync waves, secrets, and image promotion policies remain
  workload decisions.

### Traffic Tier

- OCI starts as the primary weighted endpoint.
- AWS receives the remaining weight from `oci_primary_traffic_percent`.
- DNS or global traffic manager implementation remains outside the Terraform
  resource graph and is represented as contract metadata.

## Inputs To Settle Before Build

- OCI compartment, region, and OKE networking model.
- Whether OKE cluster and node pool creation are enabled.
- AWS EKS stack parameters and target region.
- FastConnect virtual circuit ID and Direct Connect connection ID.
- GitOps tool, repository URL, and branch.
- Application FQDN plus OCI and AWS ingress endpoint values.
- Initial traffic weight and failover operating policy.

## Outputs And Hand-Off

The deployable blueprint should return:

```text
primary_cluster
secondary_cluster
interconnect_contract
gitops_contract
traffic_steering_contract
eks_cluster_arn
eks_cluster_endpoint
oke_cluster_id
```

## Rollout Plan

1. Connectivity approval:
Confirm Direct Connect + FastConnect partner path ownership and IDs.
2. Cluster baseline:
Deploy or reference OKE primary and deploy or reference EKS secondary.
3. GitOps bootstrap:
Register both clusters with the selected GitOps controller.
4. Traffic steering:
Create weighted records or global traffic manager policy outside this folder
using the contract outputs.
5. Active/active rehearsal:
Shift traffic weights gradually and validate application health from both
clouds.

## Validation Checklist

- OKE and EKS clusters are reachable from the expected operator network.
- Interconnect IDs match the approved partner path.
- IPSec backup remains disabled for this blueprint variant.
- GitOps can reconcile the same application release to both clusters.
- OCI and AWS ingress endpoints pass workload health checks.
- Weighted traffic steering behaves as expected during traffic shifts.

## Deployment Source

The deployed implementation lives in:

```text
blueprints/extensions/eks-oke-active-active/
```

The AWS-side session lives in:

```text
blueprints/extensions/eks-oke-active-active/aws/
```
