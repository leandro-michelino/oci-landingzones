# Azure + OCI Dual Connectivity Hardening

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this page as the operator guide for
`blueprints/networking/azure-oci-dual-connectivity`. It explains what the
blueprint deploys, which inputs matter, how to run Terraform and local Ansible
sessions, and where to review the detailed Architecture.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/networking/azure-oci-dual-connectivity` |
| Best fit | OCI-primary dual-connectivity pattern with IPSec/BGP first, plus optional Interconnect (ExpressRoute + FastConnect) enablement at final cutover. |
| Terraform shape | `oci_core_vcn.primary`, `oci_core_route_table.primary`, `oci_core_security_list.primary_hub`, `oci_core_subnet.primary_hub`, `oci_core_drg.primary`, `oci_core_drg_attachment.primary`, `oci_core_cpe.azure`, `oci_core_ipsec.azure`, `terraform_data.connectivity_contract`, `terraform_data.ipsec_fallback_contract`, `terraform_data.routing_contract`, `terraform_data.dns_contract`, `terraform_data.runbook_contract` |
| Inputs to settle first | `connectivity_mode`, `fastconnect_virtual_circuit_id`, `expressroute_circuit_id`, `enable_ipsec_fallback`, `azure_cpe_public_ip`, `azure_network_cidrs`, `private_dns_zone_fqdn` |
| Outputs to hand off | `blueprint_name`, `name_prefix`, `resource_ids`, `connectivity_contract`, `ipsec_fallback_contract`, `routing_contract`, `dns_contract`, `runbook_contract` |
| Local runner | `terraform plan` for fast iteration; `ansible/plan.yml` and guarded `ansible/apply.yml` for repo-standard execution. |

## Deployment Purpose

Implements a hardened cross-cloud connectivity baseline where OCI stays primary,
IPSec/BGP is enabled first for validation and early traffic, and Interconnect
can be enabled in the final cutover stage.

## When To Use This Deployment

- OCI must remain the primary connectivity and routing control plane.
- Azure workloads need private connectivity to OCI with IPSec/BGP bring-up first.
- Operations require a deterministic IPSec/BGP fallback posture.
- Teams need explicit contracts for routing, DNS, and failover runbooks.

## Practical Use Cases

- **Azure to OCI private baseline:** Use IPSec/BGP first so the team can validate routing before committing production traffic to a private circuit.
- **Interconnect cutover planning:** Keep ExpressRoute plus FastConnect details in the same operating model without pretending the dedicated path exists too early.
- **Fallback design:** Document the path preference and recovery steps before a circuit outage makes everyone improvise.
- **Cross-cloud DNS and probes:** Record resolver endpoints and health probes so failover checks are repeatable.

## What This Deploys

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Resource | `oci_core_vcn.primary`, `oci_core_route_table.primary`, `oci_core_security_list.primary_hub`, `oci_core_subnet.primary_hub` | Optional deploy-and-use OCI network resources with wired route and security controls. |
| Resource | `oci_core_drg.primary`, `oci_core_drg_attachment.primary` | OCI DRG primary hub and optional VCN attachment. |
| Resource | `oci_core_cpe.azure`, `oci_core_ipsec.azure` | Optional fallback IPSec resources. |
| Resource | `oci_ons_notification_topic.connectivity_alert` | Optional connectivity operations topic. |
| Resource | `terraform_data.oci_network_contract` | OCI network and DRG hand-off contract. |
| Resource | `terraform_data.connectivity_contract` | Connectivity contract with IPSec-first and optional interconnect mode. |
| Resource | `terraform_data.ipsec_fallback_contract` | IPSec/BGP fallback hardening contract. |
| Resource | `terraform_data.routing_contract` | Route exchange and path preference contract. |
| Resource | `terraform_data.dns_contract` | Optional DNS forwarding and health-probe contract. |
| Resource | `terraform_data.runbook_contract` | Failover/failback runbook sequencing contract. |

## Folder Contract

```text
blueprints/networking/azure-oci-dual-connectivity/
|-- README.md                  Operator guide for this deployment
|-- architecture/README.md     Detailed Architecture for this deployment
|-- main.tf                    Terraform resources and contracts
|-- variables.tf               Input contract
|-- outputs.tf                 Deployment hand-off values
|-- providers.tf               OCI provider configuration
|-- versions.tf                Terraform and provider constraints
|-- terraform.tfvars.example   Example input shape
|-- hello-world/index.html     Sample status page for connectivity walkthroughs
|-- azure/
|   |-- main.bicep             Azure fallback edge deployment template
|   |-- parameters.example.json Example Azure deployment parameters
|   `-- README.md              Azure session guide
`-- ansible/
    |-- plan.yml               Local init, validate, and plan
    |-- apply.yml              Guarded init, validate, plan, and apply
    |-- destroy.yml            Guarded destroy
    |-- azure-plan.yml         Azure what-if session for fallback edge
    |-- azure-apply.yml        Azure apply session for fallback edge
    |-- azure-destroy.yml      Azure destroy session for fallback edge
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

### Connectivity Hardening Decisions

| Input | What To Decide |
| --- | --- |
| `connectivity_mode` | `without-interconnect` for IPSec-first rollout or `interconnect` for final dedicated-circuit cutover. |
| `enable_oci_primary_network` | `true` to create OCI VCN resources in this blueprint, or `false` to reuse an existing VCN. |
| `existing_oci_primary_vcn_id` | Existing OCI VCN OCID when `enable_oci_primary_network=false`. |
| `existing_oci_primary_drg_id` | Existing OCI DRG OCID when DRG reuse is required (quota-aware runs). |
| `attach_oci_primary_vcn_to_drg` | Keep `true` for new VCNs. Set `false` when reusing a VCN that is already attached. |
| `fastconnect_virtual_circuit_id` | FastConnect virtual circuit OCID for interconnect mode. |
| `expressroute_circuit_id` | ExpressRoute circuit resource ID for interconnect mode. |
| `enable_ipsec_fallback` | Enable fallback path resources in OCI. |
| `azure_cpe_public_ip` | Azure VPN public endpoint IP for OCI CPE when fallback is enabled. |
| `azure_network_cidrs` | Approved Azure CIDR ranges exchanged with OCI routing policy. |
| `azure_bgp_asn` | Azure ASN value used in route contracts. |
| `bgp_keepalive_seconds` / `bgp_hold_seconds` | BGP timer assumptions documented for operations hardening. |
| `private_dns_zone_fqdn` | Private DNS zone used in cross-cloud resolution contracts. |
| `health_probe_fqdn` | Probe FQDN used by runbooks to validate path health. |

## Outputs And Hand-Off

| Output | Hand-Off Meaning |
| --- | --- |
| `resource_ids` | Map of all core resource and contract identifiers from this blueprint. |
| `connectivity_contract` | Interconnect primary-path contract details. |
| `ipsec_fallback_contract` | IPSec/BGP fallback details for operational runbooks. |
| `routing_contract` | Routing intent, CIDR exchange, and path preference policy. |
| `dns_contract` | DNS forwarding and probe metadata used during failover/failback. |
| `runbook_contract` | Ordered operational steps for fallback activation and restoration. |

## Terraform And Ansible Workflow

```bash
cd blueprints/networking/azure-oci-dual-connectivity
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

```bash
cd blueprints/networking/azure-oci-dual-connectivity
ansible-playbook -i localhost, ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, ansible/apply.yml
CONFIRM_DESTROY=true ansible-playbook -i localhost, ansible/destroy.yml
```

Azure full deployment session (fallback edge side):

```bash
cd blueprints/networking/azure-oci-dual-connectivity
ansible-playbook -i localhost, ansible/azure-plan.yml
CONFIRM_AZURE_APPLY=true ansible-playbook -i localhost, ansible/azure-apply.yml
CONFIRM_AZURE_DESTROY=true ansible-playbook -i localhost, ansible/azure-destroy.yml
```

For required Azure variables and parameters, review `azure/README.md`.

IPSec validation and optional ping test from Azure VM:

```bash
cd blueprints/networking/azure-oci-dual-connectivity
export OCI_AZURE_IPSEC_CONNECTION_ID="ocid1.ipsecconnection.oc1..example"
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
connectivity reviews.

```bash
cd blueprints/networking/azure-oci-dual-connectivity
ansible-playbook -i localhost, ansible/serve-hello-world.yml
# open http://127.0.0.1:8092
ansible-playbook -i localhost, ansible/stop-hello-world.yml
```

## Deployment Steps

1. Set OCI profile and run low-cost mode with IPSec first:
```bash
export OCI_PROFILE=JNB
export OCI_CLI_PROFILE=JNB
```
2. Keep `connectivity_mode="without-interconnect"` during tests, and leave `fastconnect_virtual_circuit_id` and `expressroute_circuit_id` as `null`.
3. Run Azure apply:
```bash
cd blueprints/networking/azure-oci-dual-connectivity
CONFIRM_AZURE_APPLY=true ansible-playbook -i localhost, ansible/azure-apply.yml
```
4. If Azure returns `ResourceAvailabilityZonesCannotBeModified`, destroy the test resource group and rerun apply:
```bash
CONFIRM_AZURE_DESTROY=true ansible-playbook -i localhost, ansible/azure-destroy.yml
CONFIRM_AZURE_APPLY=true ansible-playbook -i localhost, ansible/azure-apply.yml
```
5. Run optional IPSec and ping checks:
```bash
export OCI_AZURE_IPSEC_CONNECTION_ID="ocid1.ipsecconnection.oc1..example"
# Optional ping inputs:
# export AZURE_TEST_VM_RESOURCE_GROUP="rg-test"
# export AZURE_TEST_VM_NAME="vm-test"
# export OCI_PING_TARGET_IP="10.58.10.10"
ansible-playbook -i localhost, ansible/azure-ipsec-verify.yml
```
6. Destroy immediately after tests:
```bash
CONFIRM_AZURE_DESTROY=true ansible-playbook -i localhost, ansible/azure-destroy.yml
```

## What Good Looks Like

- The selected connectivity mode matches the Azure and OCI resources that actually exist.
- IPSec fallback has a real Azure public endpoint when enabled.
- Route and DNS contracts show the expected Azure CIDRs, probes, and convergence target.
- Runbook outputs explain what to check before failover and before restoration.
