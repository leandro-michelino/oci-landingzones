# AWS Session - Hybrid Network Backbone

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This folder contains the AWS backbone deployment artifacts for the
`aws-oci-hybrid-network-backbone` blueprint.

## What It Deploys

- AWS VPC and backbone subnet
- Route table with default internet route
- Security group for backbone traffic control
- AWS Transit Gateway and VPC attachment
- Stack outputs used by OCI DRG connectivity contracts and runbooks

## Prerequisites

- AWS CLI logged in (`aws sts get-caller-identity`)
- Correct account and region selected
- Environment variables exported for the Ansible wrappers

## Parameters

Start from `parameters.example.json` and copy to a local file (for example
`parameters.dev.json`) with your CIDRs and ingress policy.

## Outputs To Feed Terraform

Use CloudFormation outputs in Terraform tfvars:

- `AwsTransitGatewayId` -> `aws_transit_gateway_id`
- `AwsTransitGatewayAttachmentId` -> `aws_transit_gateway_attachment_id`
- `AwsBackboneVpcId`, `AwsBackboneSubnetId`, `AwsBackboneRouteTableId`, and
  `AwsBackboneSecurityGroupId` for network operations.

## Session Commands

```bash
cd blueprints/networking/aws-oci-hybrid-network-backbone

export AWS_BACKBONE_STACK_NAME=oci-aws-hybrid-backbone-dev
export AWS_BACKBONE_REGION=eu-west-1
export AWS_BACKBONE_PARAMETERS_FILE=aws/parameters.example.json

ansible-playbook -i localhost, ansible/aws-plan.yml
CONFIRM_AWS_APPLY=true ansible-playbook -i localhost, ansible/aws-apply.yml
CONFIRM_AWS_DESTROY=true ansible-playbook -i localhost, ansible/aws-destroy.yml
```
