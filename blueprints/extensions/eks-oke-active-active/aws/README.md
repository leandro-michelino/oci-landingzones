# AWS Session - EKS Secondary Deployment

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This folder contains the AWS EKS secondary deployment artifacts for the
`eks-oke-active-active` blueprint.

## What It Deploys

- AWS VPC with two public EKS subnets across AZs
- Route table and internet route
- Security group for API and cluster traffic controls
- IAM roles required for EKS control plane and managed node group
- EKS cluster and managed node group

## Prerequisites

- AWS CLI logged in (`aws sts get-caller-identity`)
- Correct account and region selected
- Environment variables exported for the Ansible wrappers

## Parameters

Start from `parameters.example.json` and copy to a local file (for example
`parameters.dev.json`) with your cluster name, node size, and CIDR ranges.

## Outputs To Feed Terraform

Use CloudFormation outputs in Terraform tfvars:

- `EksClusterArn` -> `eks_cluster_id`
- `EksClusterName` -> `eks_cluster_name`
- `EksClusterEndpoint` -> `aws_secondary_endpoint`
- `EksVpcId`, `EksSubnetOneId`, `EksSubnetTwoId`, `EksRouteTableId`, and
  `EksSecurityGroupId` for network operations and interconnect runbooks.

## Session Commands

```bash
cd blueprints/extensions/eks-oke-active-active

export AWS_EKS_STACK_NAME=eks-oci-secondary-dev
export AWS_EKS_REGION=eu-west-1
export AWS_EKS_PARAMETERS_FILE=aws/parameters.example.json

ansible-playbook -i localhost, ansible/aws-plan.yml
CONFIRM_AWS_APPLY=true ansible-playbook -i localhost, ansible/aws-apply.yml
CONFIRM_AWS_DESTROY=true ansible-playbook -i localhost, ansible/aws-destroy.yml
```
