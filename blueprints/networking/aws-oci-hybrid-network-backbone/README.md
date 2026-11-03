# AWS + OCI Hybrid Network Backbone

## Preferred primary path and available regions

Use native Interconnect as the primary path for sustained production traffic in supported locations; retain VPN as an optional, independently engineered alternative or backup. See the [current region matrix and cutover procedure](../../../docs/multicloud/INTERCONNECT-REGIONS.md), reviewed 2026-11-03. Availability, redundancy and activation differ by provider. No on-premises transit through the native cloud-to-cloud service is assumed.

The native managed pair is **OCI `us-ashburn-1` ↔ AWS `us-east-1`**. Prefer [the managed Interconnect root](../aws-oci-managed-interconnect/README.md) for a new isolated private deployment. This hybrid root supports existing managed circuits with `connectivity_mode="managed-interconnect"`, `aws_region`, `fastconnect_virtual_circuit_id` and `aws_interconnect_id`; conventional partner mode remains `interconnect` with `direct_connect_connection_id`. These identifiers are contracts, not resource creation or health checks. The CloudFormation companion still owns a TGW/VPN foundation; DXGW/TGW association and Interconnect attachment are external prerequisites. The managed root instead creates its own VGW foundation; do not apply both roots to the same resources without an explicit state/ownership migration.

Use `interconnect.tfvars.example` as an overlay on a reviewed input file. VPN-only defaults remain compatible with existing configurations; they are not the preferred production topology. With either dedicated mode, remote-prefix subnet routes now remain present even when VPN is disabled.


Start here for `blueprints/networking/aws-oci-hybrid-network-backbone`: what it builds, which inputs deserve a careful look, how to run Terraform or the local Ansible wrappers, and where the detailed architecture notes live.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/networking/aws-oci-hybrid-network-backbone` |
| Best fit | OCI DRG-primary hybrid network backbone with AWS Transit Gateway pairing and native managed Interconnect in supported regions, external partner circuits elsewhere, and optional VPN. |
| Terraform shape | `oci_core_vcn.backbone`, `oci_core_route_table.backbone`, `oci_core_security_list.backbone`, `oci_core_subnet.backbone`, `oci_core_drg.primary`, `oci_core_drg_attachment.backbone`, `oci_core_cpe.aws`, `oci_core_ipsec.aws`, `terraform_data.connectivity_contract`, `terraform_data.routing_contract` |
| Inputs to settle first | `connectivity_mode`, `fastconnect_virtual_circuit_id`, `direct_connect_connection_id`, `enable_site_to_site_vpn`, `aws_cpe_public_ip`, `aws_backbone_cidrs` |
| Outputs to hand off | `blueprint_name`, `name_prefix`, `resource_ids`, `oci_network_contract`, `connectivity_contract`, `routing_contract`, `oci_drg_id` |
| Local runner | `terraform plan` for quick iteration; `ansible/plan.yml` and guarded `ansible/apply.yml` for repo-standard flow. |

## Deployment Purpose

Implements the OCI-primary hybrid network backbone with DRG as the primary
routing core and contract outputs for native managed Interconnect, external partner circuits and
optional independent VPN between OCI and AWS.

## When To Use This Deployment

- OCI must remain the primary network hub across clouds.
- AWS participates through Transit Gateway with native Interconnect preferred where available and optional independent VPN.
- You need deterministic route and connectivity contracts for operations runbooks.
- You want deploy-and-use OCI backbone networking in the same blueprint.

## Practical Use Cases

- **AWS apps with OCI shared services:** Keep AWS workloads connected to OCI databases, directory services, observability, or security services without turning every VPC into a custom snowflake.
- **Dedicated primary and independent VPN:** Prefer managed Interconnect in supported regions; use VPN as a tested backup or when dedicated connectivity is unavailable.
- **OCI as the network anchor:** Use OCI DRG as the primary routing point while AWS Transit Gateway aggregates the AWS side.
- **Migration and coexistence:** Run workloads in both clouds during a phased move, with route intent captured clearly for the teams doing the cutover.

## What This Deploys

Everything needed for this deployment starts in this folder: Terraform composes the
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
| Resource | `terraform_data.connectivity_contract` | Managed/partner Interconnect and optional VPN contract output. |
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
| `connectivity_mode` | Prefer `managed-interconnect` in Ashburn/N. Virginia; `interconnect` for external partner circuits; `without-interconnect` for VPN-only rollout. |
| `fastconnect_virtual_circuit_id` | FastConnect virtual circuit OCID when interconnect mode is used. |
| `direct_connect_connection_id` | Existing conventional Direct Connect ID for partner `interconnect` mode only. |
| `aws_interconnect_id` | Existing activated managed AWS Interconnect ID for `managed-interconnect` mode; no legacy Direct Connect ID is needed. |
| `aws_region` | `us-east-1` with OCI `us-ashburn-1` for the currently documented managed service pair. |
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

## Optional VPN-Only Deployment Steps

1. For the optional VPN-only rollout, set the OCI profile:
```bash
export OCI_PROFILE=DEFAULT
export OCI_CLI_PROFILE=DEFAULT
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
5. If rerun returns Customer Gateway `AlreadyExists`, wait until prior Customer Gateway resources are fully released and rerun:
```bash
aws ec2 describe-customer-gateways --region eu-west-1 \
  --filters Name=ip-address,Values=198.51.100.10 \
  --query "CustomerGateways[].{Id:CustomerGatewayId,State:State}" --output table
```
6. Run optional IPSec and ping checks:
```bash
ansible-playbook -i localhost, ansible/aws-ipsec-verify.yml
```

## What Good Looks Like

- OCI DRG exists or is reused intentionally, and the backbone VCN attachment is clear.
- AWS CIDRs are documented and do not overlap OCI CIDRs.
- VPN or interconnect mode matches the IDs supplied in tfvars.
- Connectivity and routing outputs are useful enough for the AWS and OCI teams to operate from.

## Networking review — 2026-11-03

See the [networking review and validation matrix](../../../docs/NETWORKING-REVIEW-20261103.md) for the source scope, local checks, corrections and remaining external prerequisites. Historical cloud lifecycle evidence is not extended by this local review.

For cross-cloud traffic, prefer a supported native Interconnect or an explicitly reviewed private partner circuit as the primary transport. Use VPN as an independently configured backup, or as the alternative when Interconnect is unavailable or unsuitable. Confirm [current connection locations](../../../docs/multicloud/INTERCONNECT-REGIONS.md), account eligibility, route preference, both return paths and actual failover behavior; an identifier contract alone establishes none of these.
