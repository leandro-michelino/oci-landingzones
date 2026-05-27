# MySQL HeatWave Landing Zone

Use this page as the operator guide for
`blueprints/data-platform/mysql-heatwave`. It tells you what the blueprint
builds, which inputs deserve a real review, how to run Terraform or the local
Ansible wrappers, and where to find the detailed Architecture design.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/data-platform/mysql-heatwave` |
| Best fit | Private MySQL with HeatWave analytics, ML, or Lakehouse options. |
| Terraform shape | Optional private VCN/subnet/NSG, `oci_mysql_mysql_db_system.this`, optional HeatWave cluster, optional Object Storage lakehouse bucket, optional IAM policy. |
| Inputs to settle first | Private network mode, AD, MySQL shape, admin password, backup policy, HeatWave sizing, Lakehouse bucket, and IAM statements. |
| Outputs to hand off | `blueprint_name`, `name_prefix`, `resource_ids`, `private_network`, `mysql_db_system_id`, `mysql_endpoints`, `heatwave_cluster_id`, `lakehouse_bucket_name`, `access_policy_id` |
| Local runner | `terraform plan` for quick iteration; `ansible/plan.yml` and guarded `ansible/apply.yml` for the repo-standard flow. |

## Deployment Purpose

Deploys a private MySQL HeatWave foundation for application and analytics teams.
The blueprint can create the MySQL DB System, attach a HeatWave cluster, create a
Lakehouse-ready Object Storage bucket, and publish optional IAM policy
statements in one reviewable deployment surface.

## When To Use This Deployment

- App teams need a managed MySQL database in a private subnet.
- Analytics teams need HeatWave acceleration or a future Lakehouse hand-off.
- Platform teams need DB, backup, HeatWave, network, and IAM decisions captured
  before apply.
- Outputs from this pattern must be handed off to app, DBA, analytics, or
  security teams.

## Deployment Modes

| Mode | Use It When | Main Inputs |
| --- | --- | --- |
| Private DB system with new network | Fastest complete deployment for demos, tests, or isolated app landing zones. | `create_private_network = true`, `create_db_system = true`, `availability_domain` |
| Private DB system with existing network | Production or shared environments already have approved network foundations. | `subnet_id`, `nsg_ids`, `create_private_network = false` |
| HeatWave extension | A MySQL DB System already exists and only analytics needs to be added. | `db_system_id`, `create_db_system = false`, `create_heatwave_cluster = true` |
| Lakehouse extension | A bucket and IAM hand-off are needed without changing the DB system. | `create_lakehouse_bucket = true`, `policy_statements` |
| Validation only | You want CI or local validation without creating cost-bearing resources. | `create_db_system = false`, `create_heatwave_cluster = false`, `create_lakehouse_bucket = false` |

## Quick Start

For a complete private deployment, start with the example file and fill in
approved compartment, AD, network, sizing, and credential values:

```bash
cd blueprints/data-platform/mysql-heatwave
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

For a smoke deployment through the local Ansible wrapper, keep the password
outside committed files:

```bash
cd blueprints/data-platform/mysql-heatwave
export TF_VAR_admin_password='<secure-password-from-your-vault-or-shell>'
ansible-playbook -i localhost, -c local ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, -c local ansible/apply.yml
CONFIRM_DESTROY=true ansible-playbook -i localhost, -c local ansible/destroy.yml
```

## What This Deploys

| Resource | Enable Flag |
| --- | --- |
| Optional private VCN/subnet/NSG | `create_private_network` |
| MySQL DB System | `create_db_system` |
| HeatWave cluster | `create_heatwave_cluster` |
| Lakehouse Object Storage bucket | `create_lakehouse_bucket` |
| IAM policy shell | `policy_statements` not empty |

## Inputs To Decide

| Input | What To Decide |
| --- | --- |
| `availability_domain`, `subnet_id`, `nsg_ids` | Private placement and allowed app access. |
| `db_shape_name`, `data_storage_size_in_gb` | MySQL capacity and storage baseline. |
| `admin_username`, `admin_password` | Credential source and rotation ownership. |
| `is_highly_available` | Whether this is standalone or HA. |
| `backup_window_start_time`, `backup_retention_in_days`, `enable_point_in_time_recovery` | Backup posture and recovery window. |
| `heatwave_shape_name`, `heatwave_cluster_size` | Analytics capacity. |
| `enable_heatwave_lakehouse` | Whether Object Storage lakehouse integration is part of day one. |
| `policy_statements` | Optional IAM statements for DBAs, operators, analytics users, or app groups. |

## Deployment Order

1. Confirm database owner, backup window, HA posture, and maintenance window.
2. Confirm whether this blueprint creates the private network or consumes an
   approved subnet and NSGs.
3. Review MySQL shape availability in the target region; avoid retired shapes.
4. Decide whether HeatWave and Lakehouse are enabled now or later.
5. Populate `terraform.tfvars` with real values from approved sources.
6. Run plan and review endpoints, private IPs, backup policy, and IAM scope.
7. Apply only after credentials are supplied through local ignored tfvars or a
   secure pipeline.

## Outputs

| Output | Meaning |
| --- | --- |
| `mysql_db_system_id` | MySQL DB System OCID. |
| `heatwave_cluster_id` | HeatWave cluster identifier. |
| `mysql_endpoints` | Endpoint metadata when Terraform creates the DB System. |
| `lakehouse_bucket_name` | Lakehouse bucket name. |
| `access_policy_id` | Optional IAM policy OCID. |

## Architecture

The full detailed Architecture is local to this deployment:

```text
architecture/README.md
```

## Review Before Apply

- Confirm the target region supports the selected MySQL shape and HeatWave shape.
- Confirm the executing OCI principal has MySQL, networking, Object Storage, and IAM policy permissions required by the enabled resources.
- Confirm private subnet, NSGs, optional created network CIDRs, and app access paths.
- Confirm admin password handling uses a secure variable source and is not committed.
- Confirm backup retention, PITR, deletion policy, and HA expectations.
- Confirm HeatWave and Lakehouse settings match analytics ownership and cost approval.
- Confirm no generated Terraform files, state files, plans, or local tfvars are committed.

## Validation

```bash
terraform fmt -check
terraform init -backend=false
terraform validate
ansible-playbook -i localhost, -c local ansible/plan.yml
```

Review `architecture/README.md` before customer design approval.
