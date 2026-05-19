# OCI + AWS MySQL HeatWave DR Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

## Deployment Purpose

Provide a cross-cloud MySQL disaster recovery architecture where OCI is the
primary write platform with MySQL HeatWave, AWS is the secondary standby target,
and OCI-to-AWS data movement is controlled through IPSec-only connectivity.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Primary database cloud | OCI |
| Secondary database cloud | AWS |
| Primary database service | OCI MySQL HeatWave (DB System + HeatWave cluster) |
| Secondary database endpoint | AWS standby endpoint from CloudFormation session outputs |
| Cross-cloud network | OCI DRG + CPE + IPSec to AWS VPN endpoint |
| Replication style | MySQL asynchronous replication with TLS requirement contract |
| Failover control | DNS cutover contract + runbook contract outputs |

## Architecture

```text
+--------------------------------------------------------------------------------------------------+
| OCI + AWS MySQL HeatWave DR (OCI Primary)                                                       |
+--------------------------------------------------------------------------------------------------+
|                                                                                                  |
| [Application Clients]                                                                            |
|         |                                                                                        |
|         v                                                                                        |
| [mysql-primary.example.internal]                                                                 |
|         |                                                                                        |
|         +--> steady state --> [OCI MySQL DB System + HeatWave Cluster]                          |
|         |                              |                                                         |
|         |                              +--> backups / lakehouse bucket                           |
|         |                              |                                                         |
|         |                              +--> replication channel (TLS)                            |
|         |                                         |                                               |
|         |                                         v                                               |
|         |                              [OCI DRG] == IPSec Tunnel A/B == [AWS VPN/TGW edge]      |
|         |                                                                      |                  |
|         |                                                                      v                  |
|         |                                                [AWS standby database endpoint]          |
|         |                                                                                        |
|         `--> DR failover --> DNS points to AWS standby endpoint                                  |
|                                                                                                  |
| Runbook contracts: connectivity_contract, replication_contract, dns_failover_contract, runbook_contract |
+--------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Component | Purpose |
| --- | --- |
| `oci_core_vcn.primary` | OCI primary network boundary for database resources. |
| `oci_core_subnet.primary_db` | Private subnet for OCI MySQL DB System endpoint. |
| `oci_core_route_table.primary_db` | Route control for default egress and AWS CIDR over DRG. |
| `oci_core_security_list.primary_db` | MySQL ingress policy from app CIDR and AWS replication CIDR. |
| `oci_core_drg.primary` | OCI routing hub for IPSec connectivity to AWS. |
| `oci_core_cpe.aws` | AWS-side customer premises profile used by OCI IPSec. |
| `oci_core_ipsec.aws` | IPSec connection resource with static route to AWS replication CIDR. |
| `oci_mysql_mysql_db_system.primary` | OCI primary MySQL database service resource. |
| `oci_mysql_heat_wave_cluster.primary` | OCI HeatWave analytics cluster on primary database. |
| `oci_objectstorage_bucket.lakehouse` | Optional OCI bucket for lakehouse and DR evidence artifacts. |
| `oci_ons_notification_topic.dr_alert` | Optional DR alert topic for replication and failover events. |
| `terraform_data.*_contract` | Machine-readable contracts for network, replication, DNS, and runbooks. |

## Request And Deployment Flow

1. Operator sets baseline inputs for OCI tenancy, naming, and compartment scope.
2. Operator chooses whether OCI network and IPSec should be created in this run.
3. Operator creates or references OCI MySQL + HeatWave primary resources.
4. Operator sets primary and secondary endpoint values for replication and DNS contracts.
5. Terraform emits contract outputs consumed by operations runbooks and platform automation.
6. AWS standby stack is executed through `ansible/aws-*.yml` sessions and outputs are fed into contracts.

## Traffic And Trust Boundaries

- OCI is the write-primary trust zone for application traffic.
- AWS is the standby trust zone, reachable only through approved DR procedures.
- IPSec is the only intended cross-cloud transport path for replication traffic.
- Security boundaries are enforced by OCI security list rules, AWS security groups,
  and route tables scoped to known replication CIDRs.
- DNS failover is an explicit control-plane action and should require operator approval.

## Detailed Architecture Notes

- This blueprint models OCI as mandatory primary (`oci_is_primary=true`).
- Replication is modeled as asynchronous with explicit RPO contract values.
- AWS standby endpoint values are inputs/outputs for runbooks; exact secondary engine
  delivery is driven by AWS deployment session parameters and standards.
- CloudFormation AWS session includes a MySQL-compatible standby deployment path to keep
  end-to-end DR testing deployable from this repository.
- For production, enforce secure secret injection for MySQL credentials and avoid
  committing any live endpoint or password values in tfvars files.

## Operational Boundaries

- Do not run apply/destroy without explicit approval controls.
- Validate IPSec tunnel health before declaring replication ready.
- Validate replication lag before failover and before failback cutovers.
- Keep DNS TTL aligned with runbook timing assumptions.
- Capture drill evidence (timestamps, approvals, lag checks, validation queries) in
  the configured evidence bucket and runbook systems.

## Review Checklist

- OCI remains primary and AWS remains secondary for this environment.
- IPSec CIDR and route intent match approved network design.
- Security rules allow only required MySQL and operations traffic.
- Replication and DNS contract outputs are complete and accurate.
- Runbook sequencing matches target RTO/RPO and drill cadence.
- AWS standby outputs are captured and handed back into OCI contracts.
- No local secrets or generated Terraform artifacts are committed.
