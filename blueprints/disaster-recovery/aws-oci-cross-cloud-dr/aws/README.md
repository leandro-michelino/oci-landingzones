# AWS Session - DR Standby Deployment

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This folder contains the AWS standby deployment artifacts for the
`aws-oci-cross-cloud-dr` blueprint.

## What It Deploys

- AWS VPC and public standby subnet
- Route table with default internet route
- Security group for HTTP and HTTPS ingress
- EC2 instance with a real hello-world standby endpoint
- Stack outputs used by DNS failover contracts and DR runbooks

The output `AwsStandbyEndpoint` is a real HTTP endpoint that can be used as the
AWS standby target in DNS failover drills.

## Prerequisites

- AWS CLI logged in (`aws sts get-caller-identity`)
- Correct account and region selected
- Environment variables exported for the Ansible wrappers

## Parameters

Start from `parameters.example.json` and copy to a local file (for example
`parameters.dev.json`) with your real network ranges and ingress policy.

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
