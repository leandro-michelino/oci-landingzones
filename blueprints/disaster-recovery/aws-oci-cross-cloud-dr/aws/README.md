# AWS Session - DR Standby Deployment

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This folder contains the AWS standby deployment artifacts for the
`aws-oci-cross-cloud-dr` blueprint.

## What It Deploys

- AWS VPC and private standby subnet with VPC Flow Logs
- Route table with default internet route
- Security group for approved HTTP and HTTPS ingress
- EC2 instance launched through an IMDSv2-enforced launch template with
  encrypted root volume and Elastic IP association
- Customer-managed KMS key for encrypted VPC Flow Log delivery
- Stack outputs used by DNS failover contracts and DR runbooks

The output `AwsStandbyEndpoint` is a real HTTP endpoint that can be used as the
AWS standby target in DNS failover drills after `AllowedIngressCidr` is scoped
to the tester, load balancer, or DNS health-check source range.

## Prerequisites

- AWS CLI logged in (`aws sts get-caller-identity`)
- Correct account and region selected
- Environment variables exported for the Ansible wrappers

## Parameters

Start from `parameters.example.json` and copy to a local file (for example
`parameters.dev.json`) with your real network ranges and ingress policy. Keep
`AllowedIngressCidr` scoped to known source ranges; the example uses
`10.0.0.0/8` instead of open internet ingress.

## Outputs To Feed Terraform

Use CloudFormation outputs in Terraform tfvars:

- `AwsStandbyEndpoint` -> `aws_standby_endpoint`
- `AwsStandbyVpcId`, `AwsStandbySubnetId`, `AwsStandbyRouteTableId`, and
  `AwsStandbySecurityGroupId` for DR network operations and runbook evidence.

## Session Commands

```bash
cd blueprints/disaster-recovery/aws-oci-cross-cloud-dr

export AWS_DR_STACK_NAME=oci-aws-dr-standby-dev
export AWS_DR_REGION=eu-west-1
export AWS_DR_PARAMETERS_FILE=aws/parameters.example.json

ansible-playbook -i localhost, ansible/aws-plan.yml
CONFIRM_AWS_APPLY=true ansible-playbook -i localhost, ansible/aws-apply.yml
CONFIRM_AWS_DESTROY=true ansible-playbook -i localhost, ansible/aws-destroy.yml
```
