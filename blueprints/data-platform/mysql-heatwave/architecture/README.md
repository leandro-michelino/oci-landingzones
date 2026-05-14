# MySQL HeatWave Landing Zone Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

## Deployment Purpose

This blueprint provides a repeatable OCI landing-zone pattern for MySQL
HeatWave. It covers a private MySQL endpoint, optional HeatWave analytics
cluster, optional Lakehouse bucket, backup posture, encryption, and IAM handoff.

## Architecture At A Glance

| Layer | Components |
| --- | --- |
| Data serving | MySQL DB System in a private subnet. |
| Analytics | HeatWave cluster attached to the DB System. |
| Lakehouse | Object Storage bucket for external tables or exports. |
| Protection | Backup policy, KMS option, NSGs, and no public endpoint by default. |
| Governance | IAM policy shell, tags, and reviewed credential flow. |

## ASCII Architecture

```text
+--------------------------------------------------------------------------------+
|                         MySQL HeatWave Landing Zone                             |
+--------------------------------------------------------------------------------+
|                                                                                |
|  Application Subnet                                                            |
|      |                                                                         |
|      | 3306 / 33060 through NSG-approved flows                                 |
|      v                                                                         |
|  MySQL DB System                                                               |
|      |                                                                         |
|      +--> Private endpoint                                                     |
|      +--> Backup policy and retention window                                   |
|      +--> Optional HA placement                                                |
|      +--> Optional KMS encryption key                                          |
|      |                                                                         |
|      v                                                                         |
|  HeatWave Cluster                                                              |
|      |                                                                         |
|      +--> In-memory analytics nodes                                            |
|      +--> Optional Lakehouse acceleration                                      |
|      |                                                                         |
|      v                                                                         |
|  Lakehouse Object Storage Bucket                                               |
|      |                                                                         |
|      +--> External data hand-off                                               |
|      +--> Versioning and lifecycle owner review                                |
|      `--> Audit / analytics export path                                        |
|                                                                                |
|  Governance Lane                                                               |
|      |                                                                         |
|      +--> DBA group and app group IAM policy statements                        |
|      +--> Tags for environment, owner, and cost center                         |
|      `--> Credential handling through local ignored tfvars or secure CI        |
+--------------------------------------------------------------------------------+
```

## Terraform Components

| File | Purpose |
| --- | --- |
| `main.tf` | Creates MySQL DB System, HeatWave cluster, Lakehouse bucket, and optional IAM policy. |
| `variables.tf` | Captures subnet, shape, HA, backup, HeatWave, Lakehouse, and IAM choices. |
| `outputs.tf` | Exposes DB System, HeatWave, endpoint, bucket, and policy outputs. |
| `terraform.tfvars.example` | Shows safe placeholders for local deployment inputs. |

## Request And Deployment Flow

1. Database owner chooses MySQL version, shape, storage, and HA posture.
2. Network owner provides private subnet and NSG identifiers.
3. Security owner confirms credential, KMS, and backup requirements.
4. Terraform creates or references the MySQL DB System.
5. Terraform optionally attaches HeatWave and enables Lakehouse support.
6. App owners consume the private endpoint and IAM hand-off outputs.

## Traffic And Trust Boundaries

- Database access is private-subnet and NSG controlled.
- Admin credentials must not be committed; use local ignored tfvars or CI secret injection.
- HeatWave attaches to the DB System and should inherit the same data owner review.
- Lakehouse bucket data is a governed data platform boundary, not temporary scratch.
- IAM statements should separate DBAs, analytics operators, app users, and auditors.

## Detailed Architecture Notes

- `create_db_system` and `create_heatwave_cluster` are separate so customers can
  add HeatWave to an existing DB System.
- The lakehouse bucket can be created even when the DB System is referenced.
- `backup_policy` is included by default when the DB System is created.
- `kms_key_id` can encrypt both bucket and DB data when customer-managed keys are required.
- The blueprint intentionally avoids public endpoint assumptions.
- Maintenance and advanced MySQL configuration can be layered through existing OCI configuration IDs.

## Operational Boundaries

- Terraform does not create schemas, users, grants, or application tables.
- Terraform does not load Lakehouse data or run analytics jobs.
- Password rotation must be handled by the customer secret workflow.
- HeatWave sizing should be validated against workload data volume.
- Backup restore testing belongs in the operations runbook, not only Terraform.

## Review Checklist

- Subnet and NSG access are approved by network and security owners.
- DB shape, storage, and HA posture match the workload tier.
- Backup retention and window are documented.
- Admin credentials are supplied outside git.
- HeatWave and Lakehouse cost impact is approved.
- IAM policy statements are scoped to groups, not broad tenancy administrators.
- Outputs are handed to app and analytics teams after apply.
