# Azure vWAN + OCI DRG Transit

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this page as the operator guide for
`blueprints/networking/azure-vwan-oci-drg-transit`. It explains what the
blueprint creates, which inputs matter, how to run Terraform and local Ansible
sessions, and where to review the detailed Architecture.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/networking/azure-vwan-oci-drg-transit` |
| Best fit | OCI-primary transit pattern with Azure Virtual WAN and Virtual Hub on the Azure side, IPSec/BGP first for rollout, and Interconnect as default path when enabled in final cutover. |
| Terraform shape | `oci_core_vcn.primary`, `oci_core_route_table.primary`, `oci_core_security_list.primary_hub`, `oci_core_subnet.primary_hub`, `oci_core_drg.primary`, `oci_core_drg_attachment.primary`, `oci_core_cpe.azure`, `oci_core_ipsec.azure`, `terraform_data.interconnect_contract`, `terraform_data.ipsec_fallback_contract`, `terraform_data.transit_contract`, `terraform_data.dns_contract`, `terraform_data.runbook_contract` |
| Inputs to settle first | `connectivity_mode`, `fastconnect_virtual_circuit_id`, `expressroute_circuit_id`, `azure_virtual_wan_id`, `azure_virtual_hub_id`, `enable_ipsec_fallback`, `azure_cpe_public_ip`, `azure_network_cidrs` |
| Outputs to hand off | `blueprint_name`, `name_prefix`, `resource_ids`, `interconnect_contract`, `ipsec_fallback_contract`, `transit_contract`, `dns_contract`, `runbook_contract` |
| Local runner | `terraform plan` for fast iteration; `ansible/plan.yml` and guarded `ansible/apply.yml` for repo-standard execution. |

## Deployment Purpose

Defines an OCI-primary cross-cloud transit baseline where OCI DRG remains the
primary transit control plane, Azure vWAN and vHub carry Azure-side route
aggregation, IPSec/BGP is used for first rollout tests, and Interconnect
becomes the default path when enabled at final cutover.

## When To Use This Deployment

- OCI must remain the primary transit and routing control plane.
- Azure workloads need centralized transit through Azure Virtual WAN and Virtual Hub.
- Teams need a deterministic path policy where Interconnect is default when present and IPSec is fallback.
- Operations require route segmentation, DNS expectations, and runbook contracts.

## What This Deploys

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Resource | `oci_core_vcn.primary`, `oci_core_route_table.primary`, `oci_core_security_list.primary_hub`, `oci_core_subnet.primary_hub` | Optional deploy-and-use OCI network resources with wired route and security controls. |
| Resource | `oci_core_drg.primary`, `oci_core_drg_attachment.primary` | OCI DRG primary transit hub and optional VCN attachment. |
| Resource | `oci_core_cpe.azure`, `oci_core_ipsec.azure` | Optional fallback IPSec resources. |
| Resource | `oci_ons_notification_topic.transit_alert` | Optional transit operations topic. |
| Resource | `terraform_data.oci_network_contract` | OCI network and DRG hand-off contract. |
| Resource | `terraform_data.interconnect_contract` | Contract that keeps IPSec-first testing and Interconnect-default cutover metadata. |
| Resource | `terraform_data.ipsec_fallback_contract` | IPSec/BGP fallback hardening contract. |
| Resource | `terraform_data.transit_contract` | Transit route segmentation and path policy contract. |
| Resource | `terraform_data.dns_contract` | Optional DNS forwarding and health-probe contract. |
| Resource | `terraform_data.runbook_contract` | Failover/failback runbook sequencing contract. |

## Folder Contract

```text
blueprints/networking/azure-vwan-oci-drg-transit/
|-- README.md                  Operator guide for this deployment
|-- architecture/README.md     Detailed Architecture for this deployment
|-- main.tf                    Terraform resources and contracts
|-- variables.tf               Input contract
|-- outputs.tf                 Deployment hand-off values
|-- providers.tf               OCI provider configuration
|-- versions.tf                Terraform and provider constraints
|-- terraform.tfvars.example   Example input shape
|-- hello-world/index.html     Sample status page for transit walkthroughs
|-- azure/
|   |-- main.bicep             Azure vWAN/vHub session template
|   |-- parameters.example.json Example Azure session parameters
|   `-- README.md              Azure session guide
`-- ansible/
    |-- plan.yml               Local init, validate, and plan
    |-- apply.yml              Guarded init, validate, plan, and apply
    |-- destroy.yml            Guarded destroy
    |-- azure-plan.yml         Azure what-if session for transit edge
    |-- azure-apply.yml        Azure apply session for transit edge
    |-- azure-destroy.yml      Azure destroy session for transit edge
    |-- azure-ipsec-verify.yml Validate IPSec tunnel state and optional ping from Azure VM
    |-- serve-hello-world.yml  Start local hello-world endpoint
    `-- stop-hello-world.yml   Stop local hello-world endpoint
```

## Inputs To Decide

Start with `terraform.tfvars.example`, then create a local ignored
`terraform.tfvars` with real IDs, CIDRs, and operational targets.

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

### Transit Decisions

| Input | What To Decide |
| --- | --- |
| `connectivity_mode` | `without-interconnect` for IPSec-first testing or `interconnect` for final dedicated-circuit cutover. |
| `fastconnect_virtual_circuit_id` | FastConnect virtual circuit OCID for interconnect mode. |
| `expressroute_circuit_id` | ExpressRoute circuit resource ID for interconnect mode. |
| `azure_virtual_wan_id` | Azure Virtual WAN resource ID for contract tracking in interconnect mode. |
| `azure_virtual_hub_id` | Azure Virtual Hub resource ID for contract tracking in interconnect mode. |
| `azure_route_table_name` | Azure vHub route table name expected for transit path policy. |
| `enable_route_segmentation` | Enable or disable segment-level route contract metadata. |
| `transit_segments` | CIDR segmentation map for `prod`, `nonprod`, and `management` lanes. |
| `enable_ipsec_fallback` | Enable fallback path resources in OCI. |
| `azure_cpe_public_ip` | Azure VPN public endpoint IP for OCI CPE when fallback is enabled. |
| `azure_network_cidrs` | Approved Azure CIDR ranges exchanged with OCI routing policy. |
| `azure_bgp_asn` | Azure ASN value used in route contracts. |
| `bgp_keepalive_seconds` / `bgp_hold_seconds` | BGP timer assumptions for operations hardening. |
| `private_dns_zone_fqdn` | Private DNS zone used in cross-cloud resolution contracts. |
| `health_probe_fqdn` | Probe FQDN used by runbooks to validate path health. |

## Outputs And Hand-Off

| Output | Hand-Off Meaning |
| --- | --- |
| `resource_ids` | Map of all core resource and contract identifiers from this blueprint. |
| `interconnect_contract` | Primary-path contract details with Interconnect and vWAN/vHub metadata. |
| `ipsec_fallback_contract` | IPSec/BGP fallback details for operational runbooks. |
| `transit_contract` | Transit intent, route segmentation, CIDR exchange, and path preference policy. |
| `dns_contract` | DNS forwarding and probe metadata used during failover/failback. |
| `runbook_contract` | Ordered operational steps for fallback activation and restoration. |

## Terraform And Ansible Workflow

```bash
cd blueprints/networking/azure-vwan-oci-drg-transit
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

```bash
cd blueprints/networking/azure-vwan-oci-drg-transit
ansible-playbook -i localhost, ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, ansible/apply.yml
CONFIRM_DESTROY=true ansible-playbook -i localhost, ansible/destroy.yml
```

Azure session (vWAN and transit edge side):

```bash
cd blueprints/networking/azure-vwan-oci-drg-transit
ansible-playbook -i localhost, ansible/azure-plan.yml
CONFIRM_AZURE_APPLY=true ansible-playbook -i localhost, ansible/azure-apply.yml
CONFIRM_AZURE_DESTROY=true ansible-playbook -i localhost, ansible/azure-destroy.yml
```

For required Azure variables and parameters, review `azure/README.md`.

IPSec validation and optional ping test from Azure VM:

```bash
cd blueprints/networking/azure-vwan-oci-drg-transit
export OCI_AZURE_TRANSIT_IPSEC_CONNECTION_ID="ocid1.ipsecconnection.oc1..example"
# Optional ping test variables:
# export AZURE_TEST_VM_RESOURCE_GROUP="rg-test"
# export AZURE_TEST_VM_NAME="vm-test"
# export OCI_PING_TARGET_IP="10.58.10.10"
ansible-playbook -i localhost, ansible/azure-ipsec-verify.yml
```

## Architecture

The full detailed Architecture is local to this deployment:

```text
architecture/README.md
```

## Hello World Page

Use `hello-world/index.html` as a lightweight operations handoff page for
transit reviews.

```bash
cd blueprints/networking/azure-vwan-oci-drg-transit
ansible-playbook -i localhost, ansible/serve-hello-world.yml
# open http://127.0.0.1:8094
ansible-playbook -i localhost, ansible/stop-hello-world.yml
```

## Deployment Steps

1. Set OCI profile and keep IPSec-first mode:
```bash
export OCI_PROFILE=JNB
export OCI_CLI_PROFILE=JNB
```
2. Keep `connectivity_mode="without-interconnect"` for tests, with interconnect IDs unset.
3. Run Azure apply for vWAN transit:
```bash
cd blueprints/networking/azure-vwan-oci-drg-transit
CONFIRM_AZURE_APPLY=true ansible-playbook -i localhost, ansible/azure-apply.yml
```
4. Keep Azure address spaces non-overlapping:
   - `vnetCidr=10.88.0.0/16`
   - `virtualHubAddressPrefix=10.89.255.0/24`
5. Use an alphanumeric VPN shared key when pairing with OCI fallback PSKs.
6. If apply fails due legacy zone constraints in reused resources, destroy the test resource group and rerun apply.
7. Run optional IPSec and ping checks:
```bash
export OCI_AZURE_TRANSIT_IPSEC_CONNECTION_ID="ocid1.ipsecconnection.oc1..example"
# Optional ping inputs:
# export AZURE_TEST_VM_RESOURCE_GROUP="rg-test"
# export AZURE_TEST_VM_NAME="vm-test"
# export OCI_PING_TARGET_IP="10.58.10.10"
ansible-playbook -i localhost, ansible/azure-ipsec-verify.yml
```
8. Azure VPN gateway creation can take around 45 to 60 minutes; wait for
   `provisioningState=Succeeded` before validating tunnel health.
9. Destroy immediately after tests:
```bash
CONFIRM_AZURE_DESTROY=true ansible-playbook -i localhost, ansible/azure-destroy.yml
```
