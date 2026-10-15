# AWS Session Guide - OCI + AWS MySQL HeatWave DR

This folder contains AWS CloudFormation artifacts used by the
`blueprints/data-platform/oci-aws-mysql-heatwave-dr` deployment for standby-side
networking and database endpoint provisioning.

## What This AWS Session Deploys

| Resource Group | Purpose |
| --- | --- |
| VPC + subnets + route table | Private AWS standby network footprint with encrypted VPC Flow Logs. |
| Security group | Restricts MySQL ingress and egress to approved OCI replication CIDR. |
| DB subnet group | Places standby database in dedicated private subnets. |
| Optional MySQL-compatible RDS instance | Provides deployable standby endpoint with storage encryption, IAM database authentication, Performance Insights, and deletion protection. |

This template does not create an AWS VPN gateway, customer gateway, VPN
connection, or routes to OCI. It also does not seed the RDS database, configure
replication, or update application DNS. The VPC and private RDS endpoint alone
do not provide a functional disaster recovery path.

## CloudFormation Files

| File | Purpose |
| --- | --- |
| `main.yaml` | AWS standby stack template. |
| `parameters.example.json` | Example parameters for test and nonproduction sessions. |

## Run AWS Sessions

Plan:

```bash
ansible-playbook -i localhost, ../ansible/aws-plan.yml
```

Apply:

```bash
CONFIRM_AWS_APPLY=true ansible-playbook -i localhost, ../ansible/aws-apply.yml
```

Destroy:

```bash
CONFIRM_AWS_DESTROY=true ansible-playbook -i localhost, ../ansible/aws-destroy.yml
```

## Notes

- Use secure secret injection for `DbMasterUserPassword` in real environments.
- Deletion protection is enabled on the RDS standby; run a controlled stack
  update to disable it before destructive teardown of real test databases.
- For plan-only tests, the shared AWS runner automatically removes temporary
  review stacks created by no-execute changesets.
- Destroy sessions should always be executed after ephemeral tests.
- AWS network, RDS, KMS, Flow Logs, and VPN options can incur charges. Obtain
  cost approval and verify complete cleanup before any live cross-cloud test.
