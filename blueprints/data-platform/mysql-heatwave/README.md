# MySQL HeatWave Landing Zone

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this blueprint when an application or analytics team needs a private MySQL
DB System with optional HeatWave analytics and Lakehouse-ready Object Storage
handoff. It keeps the database, analytics cluster, lakehouse bucket, and IAM
policy in one reviewable deployment surface.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/data-platform/mysql-heatwave` |
| Best fit | Private MySQL with HeatWave analytics, ML, or Lakehouse options. |
| Terraform shape | MySQL DB System, HeatWave cluster, Object Storage lakehouse bucket, IAM policy. |
| Default posture | DB and HeatWave creation are disabled until subnet, shape, HA, and credential decisions are ready. |
| Customer paths | Extension-only with an existing DB System, or base-plus-extension after Core and Networking. |

## What This Deploys

| Resource | Enable Flag |
| --- | --- |
| MySQL DB System | `create_db_system` |
| HeatWave cluster | `create_heatwave_cluster` |
| Lakehouse Object Storage bucket | `create_lakehouse_bucket` |
| IAM policy shell | `policy_statements` not empty |

## Inputs To Decide

| Input | What To Decide |
| --- | --- |
| `availability_domain`, `subnet_id`, `nsg_ids` | Private placement and allowed app access. |
| `db_shape_name`, `data_storage_size_in_gb` | MySQL capacity and storage baseline. |
| `is_highly_available` | Whether this is standalone or HA. |
| `heatwave_shape_name`, `heatwave_cluster_size` | Analytics capacity. |
| `enable_heatwave_lakehouse` | Whether Object Storage lakehouse integration is part of day one. |

## Deployment Order

This blueprint supports extension-only and base-plus-extension paths. For
extension-only use, set `db_system_id` and optionally create only HeatWave or
the lakehouse bucket. For base-plus-extension use, deploy Core and Networking,
then pass compartment, subnet, NSG, KMS, and IAM values here.

1. Confirm database owner, backup window, HA posture, and maintenance window.
2. Confirm subnet, NSG, and private access from app and analytics tiers.
3. Decide whether HeatWave and Lakehouse are enabled now or later.
4. Run `terraform plan` or `ansible-playbook ansible/plan.yml`.
5. Apply only after credentials are supplied through local ignored tfvars or a secure pipeline.

## Outputs

| Output | Meaning |
| --- | --- |
| `mysql_db_system_id` | MySQL DB System OCID. |
| `heatwave_cluster_id` | HeatWave cluster identifier. |
| `mysql_endpoints` | Endpoint metadata when Terraform creates the DB System. |
| `lakehouse_bucket_name` | Lakehouse bucket name. |
| `access_policy_id` | Optional IAM policy OCID. |

## Validation

```bash
terraform fmt -check
terraform init -backend=false
terraform validate
ansible-playbook ansible/plan.yml
```

Review `architecture/README.md` before customer design approval.
