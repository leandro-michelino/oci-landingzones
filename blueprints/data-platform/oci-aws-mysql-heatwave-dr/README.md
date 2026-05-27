# OCI + AWS MySQL HeatWave DR (OCI Primary over IPSec)

Use this page as the operator guide for
`blueprints/data-platform/oci-aws-mysql-heatwave-dr`. It explains what is
built, which inputs matter most, how to run Terraform and Ansible sessions, and
where to find the detailed Architecture.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/data-platform/oci-aws-mysql-heatwave-dr` |
| Best fit | OCI-primary MySQL HeatWave with AWS standby endpoint and IPSec-only cross-cloud replication lane. |
| Terraform shape | `oci_core_vcn.primary`, `oci_core_route_table.primary_db`, `oci_core_security_list.primary_db`, `oci_core_subnet.primary_db`, `oci_core_drg.primary`, `oci_core_cpe.aws`, `oci_core_ipsec.aws`, `oci_mysql_mysql_db_system.primary`, `oci_mysql_heat_wave_cluster.primary`, `terraform_data.*_contract` |
| Inputs to settle first | `enable_ipsec_connectivity`, `aws_cpe_public_ip`, `aws_replication_cidr`, `create_db_system`, `create_heatwave_cluster`, `oci_primary_endpoint`, `aws_secondary_endpoint`, `target_rto_minutes`, `target_rpo_minutes` |
| Outputs to hand off | `resource_ids`, `oci_network_contract`, `connectivity_contract`, `replication_contract`, `dns_failover_contract`, `runbook_contract` |
| Local runner | `terraform plan` for iteration, `ansible/plan.yml` and guarded `ansible/apply.yml` for standard flow |

## Deployment Purpose

Deploy an OCI-first MySQL HeatWave DR pattern where OCI remains the primary
write location and AWS acts as the secondary standby endpoint, with encrypted
IPSec connectivity and explicit replication/failover contracts.

## When To Use This Deployment

- OCI must stay primary for write traffic and governance.
- AWS is required as a standby cloud target.
- Database failover and failback must be operationally documented.
- Cross-cloud data transport must be private and encrypted.

## Use Cases

| Use Case | Why This Blueprint Fits |
| --- | --- |
| OCI-primary cross-cloud DR | Keeps the production write path in OCI while preparing AWS as a standby endpoint. |
| DR tabletop and runbook validation | Produces replication, DNS, connectivity, and runbook contracts that can be used in exercises before a real incident. |
| Regulated cross-cloud replication lane | Uses DRG, CPE, and IPSec resources so replication traffic has an explicit encrypted path. |
| MySQL HeatWave resilience pattern | Combines OCI MySQL HeatWave primary resources with AWS standby artifacts in one reviewable folder. |
| Evidence and operations hand-off | Optional bucket, alert topic, endpoint contracts, and RTO/RPO values support audit and operations teams. |

## What This Deploys

| Kind | Name | Purpose |
| --- | --- | --- |
| OCI networking | `oci_core_vcn.primary`, `oci_core_subnet.primary_db`, `oci_core_route_table.primary_db`, `oci_core_security_list.primary_db` | Deploy-and-use primary database network foundation. |
| OCI connectivity | `oci_core_drg.primary`, `oci_core_cpe.aws`, `oci_core_ipsec.aws`, `oci_core_drg_attachment.primary_db` | IPSec connectivity plumbing between OCI and AWS. |
| OCI database | `oci_mysql_mysql_db_system.primary`, `oci_mysql_heat_wave_cluster.primary` | Primary MySQL HeatWave service components. |
| OCI operations | `oci_objectstorage_bucket.lakehouse`, `oci_ons_notification_topic.dr_alert` | Optional lakehouse/evidence storage and alerting surface. |
| Contracts | `terraform_data.oci_network_contract`, `terraform_data.connectivity_contract`, `terraform_data.replication_contract`, `terraform_data.dns_failover_contract`, `terraform_data.runbook_contract` | Machine-readable runbook and integration metadata. |

AWS standby deployment artifacts are under `aws/` and executed through
`ansible/aws-plan.yml`, `ansible/aws-apply.yml`, and `ansible/aws-destroy.yml`.

## Folder Contract

```text
blueprints/data-platform/oci-aws-mysql-heatwave-dr/
|-- README.md
|-- architecture/README.md
|-- main.tf
|-- variables.tf
|-- outputs.tf
|-- providers.tf
|-- versions.tf
|-- terraform.tfvars.example
|-- hello-world/index.html
|-- aws/
|   |-- main.yaml
|   |-- parameters.example.json
|   `-- README.md
`-- ansible/
    |-- plan.yml
    |-- apply.yml
    |-- destroy.yml
    |-- aws-plan.yml
    |-- aws-apply.yml
    |-- aws-destroy.yml
    |-- serve-hello-world.yml
    `-- stop-hello-world.yml
```

## Inputs To Decide

Start from `terraform.tfvars.example`, then fill a local ignored
`terraform.tfvars` with real OCI, AWS, and endpoint values.

### Base Tenancy And Naming

| Input | What To Decide |
| --- | --- |
| `tenancy_ocid` | OCI tenancy OCID. |
| `current_user_ocid` | OCI user OCID used for local execution or bootstrap. |
| `region` | OCI region for primary resources. |
| `home_region` | OCI tenancy home region. |
| `oci_config_profile` | Optional OCI CLI profile. |
| `org` | Organization naming prefix. |
| `environment` | Environment name. |
| `region_key` | Short region key used in naming. |

### Deployment-Specific Decisions

| Input | What To Decide |
| --- | --- |
| `oci_is_primary` | Must remain `true` in this blueprint variant. |
| `enable_oci_primary_network` | Build OCI network resources in this deployment. |
| `enable_ipsec_connectivity` | Build DRG/CPE/IPSec resources in this deployment. |
| `aws_cpe_public_ip` | AWS VPN endpoint public IP for OCI CPE. |
| `aws_replication_cidr` | AWS CIDR allowed for replication path. |
| `create_db_system` | Build OCI MySQL DB System now or reference an existing one. |
| `create_heatwave_cluster` | Build HeatWave cluster now or reference an existing one. |
| `oci_primary_endpoint` | Primary DB endpoint used in replication and DNS contracts. |
| `aws_secondary_endpoint` | Secondary DB endpoint used in replication and DNS contracts. |
| `replication_channel_name` | Logical replication channel identifier for runbooks. |
| `target_rto_minutes` | RTO objective for failover readiness. |
| `target_rpo_minutes` | RPO objective for replication lag tolerance. |

## Outputs And Hand-Off

| Output | Meaning |
| --- | --- |
| `resource_ids` | Complete resource/contract ID map for integration and cleanup automation. |
| `oci_network_contract` | OCI network topology hand-off metadata. |
| `connectivity_contract` | IPSec connectivity details and expected cross-cloud CIDR scope. |
| `replication_contract` | Replication channel expectations (endpoints, TLS, target RPO). |
| `dns_failover_contract` | DNS cutover contract for OCI primary to AWS secondary switch. |
| `runbook_contract` | Failover/failback sequence and objective metadata. |
| `oci_mysql_primary_endpoints` | OCI DB endpoint metadata when DB System is created here. |

## Terraform And Ansible Workflow

Terraform direct:

```bash
cd blueprints/data-platform/oci-aws-mysql-heatwave-dr
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

Ansible wrappers:

```bash
cd blueprints/data-platform/oci-aws-mysql-heatwave-dr
ansible-playbook -i localhost, ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, ansible/apply.yml
CONFIRM_DESTROY=true ansible-playbook -i localhost, ansible/destroy.yml
```

AWS standby sessions:

```bash
cd blueprints/data-platform/oci-aws-mysql-heatwave-dr
ansible-playbook -i localhost, ansible/aws-plan.yml
CONFIRM_AWS_APPLY=true ansible-playbook -i localhost, ansible/aws-apply.yml
CONFIRM_AWS_DESTROY=true ansible-playbook -i localhost, ansible/aws-destroy.yml
```

The AWS CloudFormation template supports E2E-safe RDS overrides:

- `DbDeletionProtection=false` for disposable test stacks that are short-lived.
- `DbBackupRetentionPeriod=0` for accounts or plans that reject seven-day
  retention during short-lived tests.
- `DbPerformanceInsightsEnabled=false` for small instance classes or regions
  that do not support Performance Insights.
- Stack-scoped names are used for VPC, subnet group, security group, and RDS
  tags so repeated E2E runs do not collide with earlier stacks.

Known-good E2E shape:

```text
AWS region: eu-west-1
Engine: mysql
Instance class: db.t4g.micro
Deletion protection: false
Backup retention: 0
Performance Insights: false
Publicly accessible: false
```

After AWS apply, feed `AwsStandbyEndpoint` and `AwsStandbyPort` back into
Terraform as `aws_secondary_endpoint` so OCI-side replication, DNS, and runbook
contracts reference the real RDS standby endpoint.

## Architecture

Detailed Architecture is in:

```text
architecture/README.md
```

## Hello World Page

Use the sample page to present the application path and DR intent in technical
walkthroughs:

```bash
cd blueprints/data-platform/oci-aws-mysql-heatwave-dr
ansible-playbook -i localhost, ansible/serve-hello-world.yml
# open http://127.0.0.1:18083
ansible-playbook -i localhost, ansible/stop-hello-world.yml
```

## Review Before Apply

- Confirm OCI remains primary and AWS remains standby.
- Confirm IPSec CIDR and CPE public IP values are correct.
- Confirm MySQL credential handling is secure and not committed.
- Confirm endpoints for replication and DNS contracts are accurate.
- Confirm RDS deletion protection is disabled only for disposable E2E runs and
  enabled for long-lived environments.
- Confirm backup retention and Performance Insights settings match the AWS
  account, region, instance class, and cost model.
- Confirm architecture/README.md still matches Terraform and Ansible behavior.

## Validation

From repository root:

```bash
./scripts/validate-changed.sh
./scripts/validate-all.sh
```
