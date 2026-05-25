# AWS + OCI Hybrid Network Backbone

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this page as the operator guide for
`blueprints/networking/aws-oci-hybrid-network-backbone`. It tells you what the
blueprint builds, which inputs deserve a real review, how to run Terraform or
local Ansible wrappers, and where to find the detailed Architecture design.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/networking/aws-oci-hybrid-network-backbone` |
| Best fit | OCI DRG-primary hybrid network backbone with AWS Transit Gateway pairing and IPSec first, plus optional Direct Connect + FastConnect partner interconnect at final cutover. |
| Terraform shape | `oci_core_vcn.backbone`, `oci_core_route_table.backbone`, `oci_core_security_list.backbone`, `oci_core_subnet.backbone`, `oci_core_drg.primary`, `oci_core_drg_attachment.backbone`, `oci_core_cpe.aws`, `oci_core_ipsec.aws`, `terraform_data.connectivity_contract`, `terraform_data.routing_contract` |
| Inputs to settle first | `connectivity_mode`, `fastconnect_virtual_circuit_id`, `direct_connect_connection_id`, `enable_site_to_site_vpn`, `aws_cpe_public_ip`, `aws_backbone_cidrs` |
| Outputs to hand off | `blueprint_name`, `name_prefix`, `resource_ids`, `oci_network_contract`, `connectivity_contract`, `routing_contract`, `oci_drg_id` |
| Local runner | `terraform plan` for quick iteration; `ansible/plan.yml` and guarded `ansible/apply.yml` for repo-standard flow. |

## Deployment Purpose

Implements the OCI-primary hybrid network backbone with DRG as the primary
routing core and contract outputs for IPSec-first rollout and optional partner
interconnect cutover between OCI and AWS.

## When To Use This Deployment

- OCI must remain the primary network hub across clouds.
- AWS participates through Transit Gateway with site-to-site VPN first, and Direct Connect + FastConnect optional at final cutover.
- You need deterministic route and connectivity contracts for operations runbooks.
- You want deploy-and-use OCI backbone networking in the same blueprint.

## What This Deploys

This folder is self-contained at the deployment level: Terraform composes the
OCI resource graph and connectivity contracts, while local Ansible files
provide the same plan/apply/destroy rhythm used across the repo.

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Resource | `oci_core_vcn.backbone`, `oci_core_route_table.backbone`, `oci_core_security_list.backbone`, `oci_core_subnet.backbone` | Optional OCI backbone network resources. |
| Resource | `oci_core_drg.primary` | OCI DRG primary hub for cross-cloud routing. |
| Resource | `oci_core_drg_attachment.backbone` | Optional DRG attachment to OCI backbone VCN. |
| Resource | `oci_core_cpe.aws`, `oci_core_ipsec.aws` | Optional VPN resources for OCI-to-AWS connectivity. |
| Resource | `oci_ons_notification_topic.backbone_alert` | Optional hybrid backbone operations alerts topic. |
| Resource | `terraform_data.oci_network_contract` | OCI backbone network IDs and routing primitives output. |
| Resource | `terraform_data.connectivity_contract` | IPSec-first and optional interconnect contract output. |
| Resource | `terraform_data.routing_contract` | DRG and CIDR routing contract output. |

## Folder Contract

```text
blueprints/networking/aws-oci-hybrid-network-backbone/
|-- README.md                  Operator guide for this deployment
|-- architecture/README.md     Detailed Architecture for this deployment
|-- main.tf                    Terraform resources and contracts
|-- variables.tf               Input contract
|-- outputs.tf                 Deployment hand-off values
|-- providers.tf               OCI provider configuration
|-- versions.tf                Terraform and provider constraints
|-- terraform.tfvars.example   Example input shape
|-- hello-world/index.html     Sample status page for network walkthroughs
|-- aws/
|   |-- main.yaml              AWS backbone CloudFormation template
|   |-- parameters.example.json Example AWS deployment parameters
|   `-- README.md              AWS session guide
`-- ansible/
    |-- plan.yml               Local init, validate, and plan
    |-- apply.yml              Guarded init, validate, plan, and apply
    |-- destroy.yml            Guarded destroy
    |-- aws-plan.yml           AWS CloudFormation plan session
    |-- aws-apply.yml          AWS CloudFormation apply session
    |-- aws-destroy.yml        AWS CloudFormation destroy session
    |-- aws-ipsec-verify.yml   Validate IPSec tunnel state and optional ping from AWS test instance
    |-- serve-hello-world.yml  Start local hello-world endpoint
    `-- stop-hello-world.yml   Stop local hello-world endpoint
```

## Inputs To Decide

Start with `terraform.tfvars.example`, then create a local ignored
`terraform.tfvars` with real IDs, CIDRs, connectivity mode, and routing intent.

### Base Tenancy And Naming

| Input | What To Decide |
| --- | --- |
| `tenancy_ocid` | OCI tenancy OCID. |
| `current_user_ocid` | OCI user OCID used for local execution or bootstrap. |
| `region` | OCI region name. |
| `home_region` | OCI tenancy home region. |
| `oci_config_profile` | Optional OCI CLI config profile for local execution. |
| `org` | Short organization prefix used in names. |
| `environment` | Deployment environment name. |
| `region_key` | Short OCI region key used in resource names. |
| `defined_tags` | Defined tags applied to resources. |
| `freeform_tags` | Freeform tags applied to resources. |

### Deployment-Specific Decisions

| Input | What To Decide |
| --- | --- |
| `oci_is_primary` | Must remain `true` in this blueprint variant. |
| `enable_oci_backbone_network` | Create OCI VCN/subnet/route/security resources for backbone operations. |
| `existing_oci_backbone_vcn_id` | Existing OCI VCN OCID when `enable_oci_backbone_network=false`. |
| `existing_oci_primary_drg_id` | Existing OCI DRG OCID when DRG reuse is required (quota-aware runs). |
| `attach_oci_backbone_vcn_to_drg` | Keep `true` for new VCNs. Set `false` when reusing a VCN that is already attached. |
| `oci_backbone_vcn_cidr` | CIDR for OCI backbone VCN. |
| `oci_backbone_subnet_cidr` | CIDR for OCI backbone subnet. |
| `connectivity_mode` | Select `without-interconnect` for IPSec-first rollout or `interconnect` for final dedicated-circuit cutover. |
| `fastconnect_virtual_circuit_id` | FastConnect virtual circuit OCID when interconnect mode is used. |
| `direct_connect_connection_id` | AWS Direct Connect connection ID when interconnect mode is used. |
| `enable_site_to_site_vpn` | Enable OCI CPE and IPSec resources for VPN path. |
| `aws_cpe_public_ip` | AWS VPN endpoint public IP when VPN is enabled. |
| `aws_backbone_cidrs` | AWS CIDRs expected across backbone route contracts. |

## Outputs And Hand-Off

| Output | Hand-Off Meaning |
| --- | --- |
| `blueprint_name` | Blueprint identifier. |
| `name_prefix` | Standard OCI naming prefix for resources created by this blueprint. |
| `resource_ids` | Map of resource IDs created by this blueprint. |
| `oci_network_contract` | OCI backbone network contract output. |
| `connectivity_contract` | Interconnect and VPN operating contract output. |
| `routing_contract` | DRG and CIDR route governance contract output. |
| `oci_drg_id` | OCI DRG OCID used as primary hub. |
| `oci_ipsec_id` | OCI IPSec OCID when VPN is enabled. |

## Terraform And Ansible Workflow

```bash
cd blueprints/networking/aws-oci-hybrid-network-backbone
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

```bash
cd blueprints/networking/aws-oci-hybrid-network-backbone
ansible-playbook -i localhost, ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, ansible/apply.yml
CONFIRM_DESTROY=true ansible-playbook -i localhost, ansible/destroy.yml
```

AWS full deployment session:

```bash
cd blueprints/networking/aws-oci-hybrid-network-backbone
ansible-playbook -i localhost, ansible/aws-plan.yml
CONFIRM_AWS_APPLY=true ansible-playbook -i localhost, ansible/aws-apply.yml
CONFIRM_AWS_DESTROY=true ansible-playbook -i localhost, ansible/aws-destroy.yml
```

IPSec validation and optional ping test from AWS test instance:

```bash
cd blueprints/networking/aws-oci-hybrid-network-backbone
# Optional, when not reading from CloudFormation stack outputs:
# export AWS_VPN_CONNECTION_ID="vpn-xxxxxxxx"
# Optional ping test variables:
# export AWS_TEST_INSTANCE_ID="i-xxxxxxxx"
# export OCI_PING_TARGET_IP="10.54.10.10"
ansible-playbook -i localhost, ansible/aws-ipsec-verify.yml
```

## Architecture

The full detailed Architecture is local to this deployment:

```text
architecture/README.md
```

## Hello World Page

Use the sample page at `hello-world/index.html` as a lightweight reference for
network design walkthroughs and operations demos.

```bash
cd blueprints/networking/aws-oci-hybrid-network-backbone
ansible-playbook -i localhost, ansible/serve-hello-world.yml
# open http://127.0.0.1:18082
ansible-playbook -i localhost, ansible/stop-hello-world.yml
```

## Deployment Steps

1. Set OCI profile and keep IPSec-first mode:
```bash
export OCI_PROFILE=JNB
export OCI_CLI_PROFILE=JNB
```
2. Keep `connectivity_mode="without-interconnect"` for tests, with dedicated-circuit IDs unset.
3. Use isolated stack names for repeated test loops:
```bash
export AWS_BACKBONE_STACK_NAME=oci-aws-hybrid-backbone-test1
```
4. Run apply and then destroy:
```bash
cd blueprints/networking/aws-oci-hybrid-network-backbone
CONFIRM_AWS_APPLY=true ansible-playbook -i localhost, ansible/aws-apply.yml
CONFIRM_AWS_DESTROY=true ansible-playbook -i localhost, ansible/aws-destroy.yml
```
5. If rerun returns Customer Gateway `AlreadyExists`, wait until prior Customer Gateway resources are fully deleted and rerun:
```bash
aws ec2 describe-customer-gateways --region eu-west-1 \
  --filters Name=ip-address,Values=198.51.100.10 \
  --query "CustomerGateways[].{Id:CustomerGatewayId,State:State}" --output table
```
6. Run optional IPSec and ping checks:
```bash
ansible-playbook -i localhost, ansible/aws-ipsec-verify.yml
```
