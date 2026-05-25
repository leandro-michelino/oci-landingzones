# AWS + OCI Hybrid Network Backbone Design Record

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This document preserves the multicloud design rationale for the available
blueprint in `blueprints/networking/aws-oci-hybrid-network-backbone/`.

Use the blueprint folder as the deployment source of truth. Keep this file as
design history, backlog context, and architecture review material.

## Deployment Purpose

Deliver an OCI-primary hybrid network backbone where OCI DRG acts as the
primary routing hub and AWS participates through Transit Gateway, optional
site-to-site VPN, and optional Direct Connect + FastConnect partner
interconnect contracts.

## Primary Outcomes

- OCI DRG-primary routing model for AWS + OCI network operations.
- Deploy-and-use OCI backbone VCN option for greenfield tests.
- AWS Transit Gateway and VPC attachment session through CloudFormation.
- Explicit route and connectivity contracts for operations hand-off.
- Optional IPSec path with clear CPE public IP and CIDR inputs.
- Optional interconnect metadata for Direct Connect + FastConnect pairing.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Primary network hub | OCI DRG |
| AWS network side | AWS VPC, subnet, security group, Transit Gateway, and TGW attachment |
| Connectivity modes | `without-interconnect` for IPSec-first rollout tests, or `interconnect` for dedicated-circuit cutover |
| VPN mode | Optional OCI CPE + IPSec toward AWS VPN endpoint |
| Interconnect contract | OCI FastConnect virtual circuit ID plus AWS Direct Connect connection ID |
| Deployment boundary | OCI Terraform plus AWS CloudFormation session |

## Architecture

```text
+------------------------------------------------------------------------------------------------+
| AWS + OCI Hybrid Network Backbone                                                              |
+------------------------------------------------------------------------------------------------+
|                                                                                                |
| [Network Operators / CI]                                                                       |
|          |                                                                                     |
|          +--> OCI Terraform session                                                            |
|          |       |                                                                             |
|          |       v                                                                             |
|          |   [OCI Backbone VCN] ---- [OCI DRG Primary Hub]                                     |
|          |                              |                                                       |
|          |                              +== optional IPSec tunnel ==> [AWS VPN / TGW path]      |
|          |                              |                                                       |
|          |                              `== interconnect contract ==> [DX + FastConnect path]   |
|          |                                                                                     |
|          `--> AWS CloudFormation session                                                       |
|                  |                                                                             |
|                  v                                                                             |
|              [AWS VPC + subnet + SG] ---- [AWS Transit Gateway + attachment]                  |
|                                                                                                |
| Outputs: OCI DRG ID, IPSec ID, AWS TGW IDs, CIDR expectations, and route intent.               |
+------------------------------------------------------------------------------------------------+
```

## Network And Routing Model

- OCI side creates or references the backbone network boundary.
- OCI DRG is the required primary routing point for the pattern.
- AWS side creates the VPC, subnet, route table, security group, Transit
  Gateway, and Transit Gateway attachment through `aws/main.yaml`.
- Route intent is published as contract output rather than hidden in prose.
- CIDR overlap checks and customer-specific route propagation choices remain
  environment decisions before production apply.

## Inputs To Settle Before Build

- OCI tenancy, compartment, region, and naming prefix.
- OCI backbone VCN and subnet CIDRs.
- AWS VPC and subnet CIDRs.
- Connectivity mode: `without-interconnect` for initial rollout tests or `interconnect` for dedicated-circuit cutover.
- Whether IPSec is enabled and the AWS CPE public IP.
- AWS backbone CIDRs expected behind Transit Gateway.
- Direct Connect and FastConnect IDs when interconnect mode is selected.

## Outputs And Hand-Off

The deployable blueprint should return:

```text
oci_drg_id
oci_ipsec_id
oci_network_contract
connectivity_contract
routing_contract
aws_transit_gateway_id
aws_transit_gateway_attachment_id
aws_backbone_vpc_id
```

## Rollout Plan

1. CIDR approval:
Confirm OCI and AWS CIDRs do not overlap with existing enterprise ranges.
2. OCI backbone:
Deploy or reference OCI backbone VCN resources and create the OCI DRG hub.
3. AWS backbone:
Deploy the AWS VPC and Transit Gateway session.
4. Connectivity:
Configure IPSec and/or partner interconnect according to the approved mode.
5. Route validation:
Validate route tables, tunnel health, and expected reachability from both
clouds.

## Validation Checklist

- OCI DRG exists and is attached to the intended OCI backbone network.
- AWS Transit Gateway attachment exists and targets the intended AWS VPC.
- IPSec tunnels are up when VPN is enabled.
- Direct Connect and FastConnect IDs match the approved partner path when
  interconnect mode is used.
- OCI and AWS route tables contain the approved CIDR routes.
- Security rules are scoped to expected operational and workload ranges.

## Deployment Steps

1. Set OCI profile:
```bash
export OCI_PROFILE=JNB
export OCI_CLI_PROFILE=JNB
```
2. Keep `connectivity_mode="without-interconnect"` during test runs.
3. Use isolated stack names per run.
4. Run apply and destroy with the blueprint-local AWS playbooks.
5. If reruns hit Customer Gateway `AlreadyExists`, wait for full deletion and then retry.
6. Keep cleanup immediate after validation to control cost.

## Deployment Source

The available design lives in:

```text
blueprints/networking/aws-oci-hybrid-network-backbone/
```

The AWS-side session lives in:

```text
blueprints/networking/aws-oci-hybrid-network-backbone/aws/
```
