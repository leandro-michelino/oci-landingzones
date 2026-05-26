# AWS Session - EKS Secondary Deployment

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This folder contains the AWS EKS secondary deployment artifacts for the
`eks-oke-active-passive` blueprint.

## What It Deploys

- AWS VPC with two private EKS subnets across AZs and VPC Flow Logs
- Route table and internet route
- Security group for API and cluster traffic controls
- IAM roles required for EKS control plane and managed node group
- EKS cluster with private API endpoint, control-plane logging, and
  KMS-backed secret encryption
- Managed node group using private subnets by default

## Prerequisites

- AWS CLI logged in (`aws sts get-caller-identity`)
- Correct account and region selected
- Environment variables exported for the Ansible wrappers
- EKS Kubernetes version verified in the target region before apply

## Parameters

Start from `parameters.example.json` and copy to a local file (for example
`parameters.dev.json`) with your cluster name, node size, and CIDR ranges.
Keep `AllowedIngressCidr` scoped to known administrator, VPN, or health-check
source ranges; the example uses `10.0.0.0/8`.
Keep `KubernetesVersion` on the latest minor version that is also supported by
the paired OKE region. The example remains `1.36` as the intended baseline, but
the May 26, 2026 E2E test in `eu-west-1` used `1.35` because EKS did not accept
`1.36` in that region.

## Outputs To Feed Terraform

Use CloudFormation outputs in Terraform tfvars:

- `EksClusterArn` -> `eks_cluster_id`
- `EksClusterName` -> `eks_cluster_name`
- `EksClusterEndpoint` -> `aws_secondary_endpoint`
- `EksVpcId`, `EksSubnetOneId`, `EksSubnetTwoId`, `EksRouteTableId`, and
  `EksSecurityGroupId` for network operations and interconnect runbooks.

## Session Commands

```bash
cd blueprints/extensions/eks-oke-active-passive

export AWS_EKS_STACK_NAME=eks-oci-secondary-dev
export AWS_EKS_REGION=eu-west-1
export AWS_EKS_PARAMETERS_FILE=aws/parameters.example.json

ansible-playbook -i localhost, ansible/aws-plan.yml
CONFIRM_AWS_APPLY=true ansible-playbook -i localhost, ansible/aws-apply.yml
CONFIRM_AWS_DESTROY=true ansible-playbook -i localhost, ansible/aws-destroy.yml
```
