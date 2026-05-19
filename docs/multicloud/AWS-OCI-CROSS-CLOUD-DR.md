# AWS + OCI Cross-Cloud Disaster Recovery Design Record

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This document preserves the multicloud design rationale for the deployed
blueprint in `blueprints/disaster-recovery/aws-oci-cross-cloud-dr/`.

Use the blueprint folder as the deployment source of truth. Keep this file as
design history, backlog context, and architecture review material.

## Deployment Purpose

Deliver a cross-cloud disaster recovery pattern where OCI remains the primary
application target and AWS provides the standby environment, with DNS failover,
connectivity, evidence capture, and runbook contracts made explicit.

## Primary Outcomes

- OCI-primary application landing point.
- AWS standby deployment through a local CloudFormation session.
- DNS failover metadata with primary and standby endpoint targets.
- RTO, RPO, and drill cadence captured as runbook contract output.
- Optional OCI DR evidence bucket and alert topic.
- Clear hand-off between OCI Terraform resources and AWS standby outputs.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Primary cloud | OCI |
| Standby cloud | AWS |
| OCI resources | Primary VCN, app subnet, route table, security list, evidence bucket, alert topic |
| AWS resources | Standby VPC, subnet, route table, security group, IAM role, EC2 instance |
| Traffic control | DNS or traffic steering layer points to OCI, then switches to AWS during failover |
| Recovery model | Runbook-driven failover and controlled failback |

## Architecture

```text
+------------------------------------------------------------------------------------------------+
| AWS + OCI Cross-Cloud DR                                                                       |
+------------------------------------------------------------------------------------------------+
|                                                                                                |
| [Clients]                                                                                      |
|     |                                                                                          |
|     v                                                                                          |
| [DNS / Traffic Steering] ---- normal mode ----> [OCI Primary App Endpoint]                     |
|           |                                      |                                             |
|           |                                      v                                             |
|           |                              [OCI VCN + app subnet]                               |
|           |                                      |                                             |
|           |                                      +--> [DR evidence bucket + alert topic]       |
|           |                                                                                    |
|           `---- failover mode --> [AWS Standby Endpoint]                                      |
|                                      |                                                         |
|                                      v                                                         |
|                              [AWS VPC + standby instance]                                     |
|                                                                                                |
| Runbook contracts: endpoint targets, TTL, RTO/RPO, drill cadence, and failback steps.         |
+------------------------------------------------------------------------------------------------+
```

## Recovery Design

### Application Tier

- Keep OCI as the normal production target.
- Keep AWS standby capacity sized according to the agreed recovery posture.
- Use the hello-world artifact for lightweight smoke tests and demos, not as a
  replacement for workload-specific health checks.

### Control Tier

- Treat failover as a declared change event with approval and evidence.
- Capture DNS TTL assumptions before production drills.
- Keep OCI and AWS session outputs in the runbook record for every exercise.

### Data Tier

- Use workload-specific replication outside this generic app DR blueprint.
- Pair this pattern with database-specific blueprints when data tier automation
  is required.

## Inputs To Settle Before Build

- OCI primary region, compartment, and CIDR plan.
- AWS standby region and CloudFormation parameter file.
- Application FQDN and DNS authority.
- OCI primary endpoint and AWS standby endpoint.
- Connectivity mode and optional interconnect IDs.
- Target RTO, target RPO, and drill cadence.
- Evidence bucket and alerting ownership.

## Outputs And Hand-Off

The deployable blueprint should return:

```text
primary_target
standby_target
connectivity_contract
dns_failover_contract
runbook_contract
dr_evidence_bucket_name
dr_alert_topic_id
aws_standby_endpoint
aws_standby_instance_id
```

## Rollout Plan

1. Primary baseline:
Deploy or reference OCI primary network and endpoint values.
2. Standby baseline:
Deploy the AWS standby CloudFormation stack and capture outputs.
3. Contract alignment:
Populate Terraform inputs with the endpoint and DNS failover assumptions.
4. DR rehearsal:
Run a non-production failover and failback using the contract outputs.
5. Production readiness:
Approve runbook ownership, evidence capture, and rollback criteria.

## Validation Checklist

- OCI primary endpoint and AWS standby endpoint are both reachable by the
  intended health checks.
- DNS TTL and authority are known before any production failover.
- AWS standby stack outputs are captured in the operations record.
- RTO and RPO targets are approved by application owners.
- Evidence bucket and alert topic ownership are confirmed.
- Failback procedure is tested, not only failover.

## Deployment Source

The deployed implementation lives in:

```text
blueprints/disaster-recovery/aws-oci-cross-cloud-dr/
```

The AWS-side session lives in:

```text
blueprints/disaster-recovery/aws-oci-cross-cloud-dr/aws/
```
