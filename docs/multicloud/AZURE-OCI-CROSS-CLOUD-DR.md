# Azure + OCI Cross-Cloud Disaster Recovery Design Record

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This document preserves the original architecture design that was later
implemented in `blueprints/disaster-recovery/azure-oci-cross-cloud-dr/`.

Use the blueprint folder as the deployment source of truth. Keep this file as
design history and rationale context.

## Deployment Purpose

Deliver a tested cross-cloud DR pattern between Azure and OCI with clear RTO,
RPO, ownership boundaries, and repeatable runbooks for failover and failback.

## Primary Outcomes

- Cross-cloud resilience for business-critical workloads.
- Explicit RTO and RPO target alignment by application tier.
- Automated or operator-assisted failover runbook.
- DNS and ingress switching model with controlled rollback.
- Recovery evidence for audit and governance.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Primary workload | Azure or OCI (pattern supports either direction) |
| Standby workload | Opposite cloud with warm or pilot-light footprint |
| Replication | Database, object, and configuration replication lanes |
| Failover control | Runbook-driven with approvals and health checks |
| Traffic steering | DNS or global traffic manager cutover |
| Recovery model | Failover to standby, then controlled failback |

## Architecture

```text
+--------------------------------------------------------------------------------------------------+
| Azure + OCI Cross-Cloud DR                                                                       |
+--------------------------------------------------------------------------------------------------+
| [Users / Clients]                                                                                |
|      |                                                                                            |
|      v                                                                                            |
| [Global DNS / Traffic Steering] -- points to --> [Primary Cloud App Endpoint]                    |
|      |                                         (Azure or OCI)                                     |
|      |                                                                                            |
|      `-- failover switch --> [Standby Cloud App Endpoint]                                        |
|                                                                                                  |
| [Data Replication Plane]                                                                          |
|   |-- Database replication (engine-specific)                                                      |
|   |-- Object/data sync                                                                            |
|   `-- Config/secrets/policy sync                                                                  |
|                                                                                                  |
| [DR Orchestration]                                                                                |
|   |-- Health checks and readiness gates                                                           |
|   |-- Approval workflow for failover/failback                                                     |
|   `-- Evidence capture (timestamps, RTO/RPO, test logs)                                           |
+--------------------------------------------------------------------------------------------------+
```

## Recovery Design

### Application Tier

- Keep IaC parity between primary and standby environments.
- Maintain version pinning for application artifacts.
- Validate dependency startup order during DR tests.

### Data Tier

- Select engine-specific replication design per workload.
- Define data consistency mode by business criticality.
- Track lag and replication health in both clouds.

### Control Tier

- Treat failover as an explicit change event with approvals.
- Maintain break-glass procedures for manual override.
- Keep runbook evidence for compliance and post-incident review.

## Inputs To Settle Before Build

- Application RTO/RPO targets by tier.
- Primary and standby cloud designation per workload.
- Replication technology for each data store.
- DNS authority and cutover ownership.
- DR test cadence and sign-off stakeholders.
- Failback tolerances and data reconciliation process.

## Output Contract

The deployable blueprint should return:

```text
primary_service_endpoints
standby_service_endpoints
replication_channel_ids
dr_health_monitor_ids
dns_failover_controls
runbook_execution_contract
audit_evidence_location
```

## Rollout Plan

1. Tier classification:
Classify workloads and assign RTO/RPO targets.
2. Standby enablement:
Stand up standby topology and replication channels.
3. Controlled test:
Run a non-production failover and failback rehearsal.
4. Production readiness:
Approve production runbook, monitoring, and evidence workflow.

## Validation Checklist

- Measured RTO and RPO meet agreed objectives.
- Failover and failback runbooks are executable end-to-end.
- Data consistency checks pass after recovery events.
- DNS or traffic steering cutover is deterministic.
- Audit evidence captures approval, timing, and outcome details.

## Promotion Criteria To Deployable Blueprint

Promote to `blueprints/disaster-recovery/azure-oci-cross-cloud-dr/` when:

- Tiered RTO/RPO policy is approved.
- Replication mechanism and ownership are finalized.
- Runbooks pass at least one full rehearsal.
- Evidence and compliance requirements are documented.
