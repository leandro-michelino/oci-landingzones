# AWS Interconnect Multicloud with OCI Preview Draft

This document defines a preview-only design draft for AWS Interconnect -
multicloud connectivity with Oracle Cloud Infrastructure (OCI).

This is intentionally not a available blueprint. AWS announced OCI support in
public preview, and Oracle documents Interconnect for AWS as Limited
Availability. Treat this note as architecture tracking material until the
service has production-ready availability, regional coverage, automation
surfaces, and operational limits that can be safely codified in this repo.

## Preview Status

| Item | Status |
| --- | --- |
| Repo status | Preview draft only |
| Deployment folder | Not created yet |
| OCI availability | Limited Availability |
| AWS availability for OCI | Public preview |
| Production recommendation | Do not use as a production deployment blueprint yet |
| Promotion gate | Promote only after GA or approved customer preview use with documented limits |

## Service Region Availability

As per today date, 19/May/26, the documented Oracle Interconnect for AWS
region availability is:

Oracle Interconnect for AWS is currently in Limited Availability. The only
publicly documented paired region is listed below. Treat this as a hard
preview constraint and do not generalize the pattern to other regions until
Oracle and AWS publish broader availability.

### North America (NA)

| OCI Region | OCI Region Identifier | OCI Key | AWS Region | AWS Region Code |
| --- | --- | --- | --- | --- |
| US East (Ashburn) | `us-ashburn-1` | `IAD` | US East (N. Virginia) | `us-east-1` |

## Deployment Purpose

Track a future managed AWS-to-OCI private connectivity pattern where AWS
Interconnect - multicloud and Oracle Interconnect for AWS provide a managed
cross-cloud network path between AWS and OCI without relying on public internet
transit or a fully do-it-yourself partner interconnect build.

## Primary Outcomes

- Preview-aware design record for AWS Interconnect - multicloud with OCI.
- Clear warning that this is not production-ready repository automation.
- Future replacement path for some manual Direct Connect + FastConnect hand-off
  steps in AWS + OCI networking patterns.
- Candidate architecture for managed, private AWS VPC to OCI VCN connectivity.
- Explicit backlog gates before a Terraform or Ansible deployment folder is
  created.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| AWS side | AWS VPC connected through AWS Interconnect - multicloud |
| OCI side | OCI VCN attached to DRG and Oracle Interconnect for AWS |
| Expected path | Managed private cross-cloud connection |
| Candidate attachment points | AWS VPC, Transit Gateway, Cloud WAN, OCI DRG, OCI VCN route tables |
| Current limitation | OCI support is preview or Limited Availability, not normal GA |
| Repo action today | Track as backlog draft only |

## Architecture

```text
+------------------------------------------------------------------------------------------------+
| AWS Interconnect - Multicloud with OCI (Preview / Limited Availability)                        |
+------------------------------------------------------------------------------------------------+
|                                                                                                |
| [AWS workload VPC]                                                                             |
|        |                                                                                       |
|        v                                                                                       |
| [AWS networking attachment] -> [AWS Interconnect - multicloud]                                 |
|                                      |                                                         |
|                                      | managed private cross-cloud path                        |
|                                      v                                                         |
|                         [Oracle Interconnect for AWS]                                          |
|                                      |                                                         |
|                                      v                                                         |
|                              [OCI DRG] -> [OCI VCN route tables] -> [OCI workloads/data]       |
|                                                                                                |
| Preview guardrail: keep production routing on existing supported designs until GA readiness.    |
+------------------------------------------------------------------------------------------------+
```

## Network And Routing Model

- AWS remains the initiating network side for AWS Interconnect - multicloud
  workflows.
- OCI uses Oracle Interconnect for AWS and an OCI DRG as the likely routing
  attachment boundary.
- Route tables and security controls must stay explicit on both sides.
- Existing AWS + OCI hybrid network backbone patterns should remain the
  production baseline until this service is generally available and codified.
- The future blueprint should compare this managed path with existing IPSec and
  Direct Connect + FastConnect operating models.

## Inputs To Settle Before Build

- Confirm GA or approved preview participation status.
- Confirm supported AWS and OCI regions for the target customer.
- Confirm AWS-side attachment model: VPC, Transit Gateway, or Cloud WAN.
- Confirm OCI-side attachment model: DRG, VCN, route table, and security list or NSG scope.
- Confirm bandwidth tiers, latency expectations, redundancy model, and quotas.
- Confirm billing ownership and data transfer cost model.
- Confirm Terraform, AWS CLI, OCI CLI, and API support for repeatable automation.
- Confirm operational support boundaries between AWS, Oracle, and the customer.

## Outputs And Hand-Off

The future deployment hand-off should include:

```text
aws_interconnect_id
aws_attachment_id
aws_route_targets
oci_interconnect_id
oci_drg_id
oci_virtual_circuit_id
approved_route_sets
redundancy_model
preview_limitations
support_contacts
```

## Rollout Plan

1. Preview qualification:
Confirm the customer, region, and account or tenancy are approved for preview or
Limited Availability access.
2. Lab-only path:
Build a non-production route path and document every manual step that lacks API
or Terraform coverage.
3. Resilience test:
Validate redundant path behavior, route withdrawal, and failure handling.
4. Security review:
Confirm route filters, security groups, NSGs, and logging controls on both
clouds.
5. Promotion review:
Create a deployable blueprint only after service readiness, automation support,
and operational ownership are approved.

## Validation Checklist

- Service is available in the target AWS and OCI regions.
- Preview or Limited Availability constraints are documented in the customer
  design.
- AWS and OCI route tables contain only approved prefixes.
- The private path does not depend on public internet transit.
- Redundancy behavior and failure modes are tested in non-production.
- Monitoring, logging, support escalation, and cost ownership are assigned.
- Existing production workloads continue to use supported GA connectivity until
  this path is approved.

## Promotion Criteria

Promote to a deployable blueprint only when:

- OCI support is generally available or an approved preview customer exception
  is documented.
- Supported regions, limits, and billing behavior are stable enough for
  customer guidance.
- AWS and OCI APIs or CLIs expose the required lifecycle operations.
- Terraform provider support exists or a reviewed automation wrapper is
  approved.
- Network operations owners approve the route, security, observability, and
  support model.

## Target Deployment Folder

Candidate path after promotion:

```text
blueprints/networking/aws-interconnect-multicloud-oci/
```
