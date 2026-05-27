# OCI + AWS MySQL HeatWave DR Design Record (OCI Primary over IPSec)

This document preserves the multicloud design rationale for the available
blueprint in `blueprints/data-platform/oci-aws-mysql-heatwave-dr/`.

Use the blueprint folder as the deployment source of truth. Keep this file as
design history, backlog context, and architecture review material.

## Deployment Purpose

Deliver a cross-cloud database disaster recovery pattern for MySQL HeatWave with
clear ownership of failover, replication health, and network controls, while
keeping OCI as the default primary production system.

## Primary Outcomes

- OCI MySQL HeatWave as primary write endpoint.
- MySQL HeatWave on AWS as warm standby read replica target.
- Private, encrypted cloud-to-cloud replication path over IPSec.
- Deterministic failover and failback runbooks with DNS switching control.
- Audit-ready evidence for RTO, RPO, and DR drills.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Primary database | OCI MySQL HeatWave (DB System + HeatWave cluster) |
| Secondary database | MySQL HeatWave on AWS (standby DB System + HeatWave cluster) |
| Connectivity | IPSec VPN between OCI DRG and AWS Transit Gateway |
| Replication model | MySQL asynchronous replication from OCI primary to AWS secondary |
| Traffic control | App DNS write endpoint points to OCI, failover runbook switches to AWS |
| Security model | NSG/Security List + AWS Security Group allowlist for MySQL replication and admin flows |

## Architecture

```text
+--------------------------------------------------------------------------------------------------+
| OCI + AWS MySQL HeatWave DR (OCI Primary, IPSec-Connected)                                      |
+--------------------------------------------------------------------------------------------------+
|                                                                                                  |
|   [Application Clients]                                                                          |
|            |                                                                                     |
|            v                                                                                     |
|   [DB DNS CNAME: mysql-primary.example.internal]                                                 |
|            |                                                                                     |
|            +--> normal mode --> [OCI MySQL HeatWave Primary]                                    |
|            |                         |                                                           |
|            |                         | MySQL replication stream                                  |
|            |                         v                                                           |
|            |                  [OCI DRG] == IPSec Tunnel A/B == [AWS Transit Gateway]            |
|            |                                                   |                                 |
|            |                                                   v                                 |
|            |                                      [AWS MySQL HeatWave Secondary]                |
|            |                                                   |                                 |
|            |                                                   v                                 |
|            `--> failover mode --> [DB DNS CNAME switched to AWS standby endpoint]               |
|                                                                                                  |
|   Observability and Control                                                                       |
|   - OCI Logging / Monitoring and AWS CloudWatch metrics                                           |
|   - Replication lag alarms and tunnel health alarms                                               |
|   - DR runbook evidence storage (tickets, timestamps, RTO/RPO reports)                           |
+--------------------------------------------------------------------------------------------------+
```

## Network And Routing Model

- OCI side:
- Hub VCN or database VCN attached to OCI DRG.
- IPSec connection with two tunnels (A/B) to AWS.
- Route tables forward AWS CIDRs to DRG.
- Security Lists and NSGs allow only required MySQL and management flows.

- AWS side:
- VPC attached to AWS Transit Gateway.
- Site-to-Site VPN from Transit Gateway to OCI DRG.
- Route tables forward OCI CIDRs to Transit Gateway.
- Security Groups and NACLs scoped to replication sources and operators.

- Path behavior:
- Replication traffic uses IPSec primary tunnel and automatically uses secondary
  tunnel if primary tunnel fails.
- No public internet database endpoints in steady state.

## Replication And DR Model

- Primary write flow:
- Applications write to OCI MySQL HeatWave primary endpoint.

- Replication flow:
- OCI MySQL binlog feeds AWS MySQL HeatWave secondary asynchronously.
- Secondary remains read-only under normal operation.

- Failover flow:
1. Confirm OCI primary outage or declared DR event.
2. Freeze writes or enforce application write-stop control.
3. Validate latest replicated transaction on AWS secondary.
4. Promote AWS secondary to writable role.
5. Switch DNS `mysql-primary.example.internal` to AWS endpoint.
6. Repoint dependent applications and validate health checks.

- Failback flow:
1. Recover OCI primary environment.
2. Re-establish replication in reverse direction temporarily.
3. Drain writes from AWS and promote OCI primary.
4. Switch DNS back to OCI endpoint.
5. Resume standard OCI-primary replication posture.

## Security And Governance Controls

- Encrypt in transit with IPSec and TLS for MySQL client sessions.
- Encrypt at rest with OCI Vault-managed keys and AWS KMS keys.
- Use least-privilege IAM policies for operators, runbook automation, and
  observability agents.
- Restrict security rules to explicit source CIDRs and ports.
- Capture DR execution evidence and approval trail for governance.

## Inputs To Settle Before Build

- OCI and AWS regions for primary and standby placement.
- CIDR plan and overlap remediation for OCI VCN and AWS VPC.
- RTO and RPO objectives for the database tier.
- Replication user model and secret rotation strategy.
- DNS authority and failover ownership.
- Planned DR test cadence and sign-off process.

## Outputs And Hand-Off

The deployment hand-off should include:

```text
oci_mysql_primary_endpoint
aws_mysql_secondary_endpoint
oci_drg_id
aws_transit_gateway_id
ipsec_tunnel_ids
replication_channel_identifier
replication_lag_alarm_ids
dns_failover_record_ids
dr_runbook_evidence_location
```

## Rollout Plan

1. Network baseline:
Deploy OCI DRG, AWS Transit Gateway attachment, and IPSec tunnels with route
validation.
2. Database baseline:
Deploy OCI primary MySQL HeatWave and AWS secondary MySQL HeatWave.
3. Replication enablement:
Configure asynchronous replication and lag monitoring.
4. DR rehearsal:
Execute failover/failback drill and record evidence.

## Validation Checklist

- IPSec tunnels are up and route exchange is stable.
- Replication lag is within approved RPO thresholds.
- Planned failover completes within target RTO.
- DNS cutover and rollback are deterministic.
- Post-failover data consistency checks pass.
- Evidence artifacts are stored and reviewable.

## Deployment Source

The available design lives in:

```text
blueprints/data-platform/oci-aws-mysql-heatwave-dr/
```

The AWS-side session lives in:

```text
blueprints/data-platform/oci-aws-mysql-heatwave-dr/aws/
```
