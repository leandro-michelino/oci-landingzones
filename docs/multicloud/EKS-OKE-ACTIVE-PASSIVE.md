# EKS + OKE Active Passive Design Record

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This document preserves the multicloud design rationale for the available
blueprint in `blueprints/extensions/eks-oke-active-passive/`.

Use the blueprint folder as the deployment source of truth. Keep this file as
design history, backlog context, and architecture review material.

## Deployment Purpose

Deliver an OCI-primary active/passive Kubernetes operating pattern where OKE is
the primary cluster target, EKS is the standby cluster target, GitOps handles
multi-cluster rollout, and OCI Traffic Management or an equivalent DNS/GSLB
layer controls application failover.

## Primary Outcomes

- OCI-primary OKE and AWS-standby EKS operating contract.
- Optional OKE network, cluster, and node pool deployment.
- AWS EKS standby deployment through a local CloudFormation session.
- Interconnect-only connectivity posture using Direct Connect + FastConnect
  partner path.
- Explicit GitOps hand-off for Argo CD or Flux.
- OCI Traffic Management failover metadata for OCI primary and AWS standby
  endpoints.
- Active/active is documented as an intentional option when application state,
  data consistency, and weighted GSLB policy are ready for dual serving.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Primary cluster | OKE in OCI |
| Standby cluster | EKS in AWS |
| Connectivity | Direct Connect + FastConnect partner interconnect |
| VPN posture | IPSec backup disabled in this variant |
| Rollout control | GitOps contract for Argo CD or Flux |
| Traffic control | OCI Traffic Management failover policy or equivalent DNS/GSLB layer |

## Architecture

```text
+------------------------------------------------------------------------------------------------+
| EKS + OKE Active Passive                                                                        |
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
|          |   [AWS VPC + EKS standby cluster] --> [AWS ingress endpoint]                |       |
|          |                                                                             |       |
|          `--> [GitOps repo and controller contract] ------------------------------------'       |
|                                                                                                |
| [Clients] -> [OCI Traffic Management failover] -> OCI primary endpoint                        |
|                                                  `-> AWS standby endpoint when primary fails  |
|                                                                                                |
| Guardrail: OCI primary required, interconnect-only path, IPSec backup disabled.                |
+------------------------------------------------------------------------------------------------+
```

## Platform Design

### Cluster Tier

- OKE can be created by this blueprint or supplied as an existing cluster.
- EKS can be created by the AWS CloudFormation session or supplied as an
  existing standby target in Terraform inputs.
- Cluster ownership can be split across OCI and AWS platform teams as long as
  outputs are captured in the same runbook.

### Delivery Tier

- GitOps is the expected application deployment control plane.
- The contract records GitOps tool, repository URL, and branch assumptions.
- Application-specific sync waves, secrets, and image promotion policies remain
  workload decisions.

### Traffic Tier

- OCI is the active primary endpoint.
- AWS is the standby endpoint for failover when the OCI answer is unhealthy.
- OCI Traffic Management can be created by the blueprint when a public DNS zone
  and endpoint answers are supplied. An external DNS/GSLB layer can use the
  same contract metadata when Traffic Management is managed elsewhere.
- Active/active can be enabled deliberately by replacing failover behavior with
  a weighted policy and assigning non-zero traffic to both clouds.

## Inputs To Settle Before Build

- OCI compartment, region, and OKE networking model.
- Whether OKE cluster and node pool creation are enabled.
- AWS EKS stack parameters and target region.
- Latest common Kubernetes minor version available in both selected regions.
  Keep the examples at `1.36` where supported; the May 26, 2026 E2E test used
  EKS `1.35` and OKE `v1.35.2` because AWS `eu-west-1` did not expose `1.36`.
- FastConnect virtual circuit ID and Direct Connect connection ID.
- GitOps tool, repository URL, and branch.
- Application FQDN plus OCI and AWS ingress endpoint values.
- OCI Traffic Management zone, attachment FQDN, health check path, record type,
  and failover operating policy.

## Outputs And Hand-Off

The deployable blueprint should return:

```text
primary_cluster
secondary_cluster
interconnect_contract
gitops_contract
traffic_steering_contract
dns_failover_contract
eks_cluster_arn
eks_cluster_endpoint
oke_cluster_id
operator_summary
```

## Rollout Plan

1. Connectivity approval:
Confirm Direct Connect + FastConnect partner path ownership and IDs.
2. Cluster baseline:
Deploy or reference OKE primary and deploy or reference EKS secondary.
3. GitOps bootstrap:
Register both clusters with the selected GitOps controller.
4. Traffic steering:
Create the OCI Traffic Management failover policy and attachment, or configure
the external DNS/GSLB layer from the contract outputs.
5. Failover rehearsal:
Validate the OCI primary endpoint, force or simulate primary failure, and
confirm DNS moves to the AWS standby endpoint.

## Validation Checklist

- OKE and EKS clusters are reachable from the expected operator network.
- Interconnect IDs match the approved partner path.
- IPSec backup remains disabled for this blueprint variant.
- GitOps can reconcile the same application release to both clusters.
- OCI and AWS ingress endpoints pass workload health checks.
- OCI Traffic Management serves the OCI endpoint while healthy and the AWS
  standby endpoint when primary health fails.
- Direct IP and cloud load balancer tests validate the apps, while browser
  failover tests use a delegated public DNS name attached to Traffic
  Management.
- With the default Traffic Management TTL of 30 seconds, health check interval
  of 30 seconds, and health check timeout of 10 seconds, target 60 to 120
  seconds for both OCI-to-AWS failover and AWS-to-OCI failback. Measure by
  polling the delegated FQDN until the response body changes between
  `Hello World OCI` and `Hello World AWS`.

## Deployment Source

The available design lives in:

```text
blueprints/extensions/eks-oke-active-passive/
```

The AWS-side session lives in:

```text
blueprints/extensions/eks-oke-active-passive/aws/
```
