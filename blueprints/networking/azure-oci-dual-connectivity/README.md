# Azure + OCI Dual Connectivity Hardening

## Preferred primary path and available regions

Use native Interconnect as the primary path for sustained production traffic in supported locations; retain VPN as an optional, independently engineered alternative or backup. See the [current region matrix and cutover procedure](../../../docs/multicloud/INTERCONNECT-REGIONS.md), reviewed 2026-11-03. Availability, redundancy and activation differ by provider. No on-premises transit through the native cloud-to-cloud service is assumed.

The native service is documented at **12 OCI connection locations**, including **Johannesburg ↔ ExpressRoute Johannesburg** (nearby Azure region: South Africa North). Peering locations and Azure regions are distinct. Use `connectivity_mode="interconnect"` and the reviewed existing FastConnect/ExpressRoute IDs; see `interconnect.tfvars.example`. The supplied Bicep provisions the VPN edge, not an ExpressRoute circuit or ExpressRoute VNet gateway. Provision those externally for this VNet; the separate vWAN/ExpressRoute blueprint is a different hub design. Subnet routes to Azure remain present when VPN fallback is disabled. DNS and route-weight contracts remain metadata.


Start here for `blueprints/networking/azure-oci-dual-connectivity`: what it builds, which inputs deserve a careful look, how to run Terraform or the local Ansible wrappers, and where the detailed architecture notes live.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/networking/azure-oci-dual-connectivity` |
| Best fit | OCI-primary native Interconnect (ExpressRoute + FastConnect) with optional independently configured VPN fallback. |
| Terraform shape | `oci_core_vcn.primary`, `oci_core_route_table.primary`, `oci_core_security_list.primary_hub`, `oci_core_subnet.primary_hub`, `oci_core_drg.primary`, `oci_core_drg_attachment.primary`, `oci_core_cpe.azure`, `oci_core_ipsec.azure`, `terraform_data.connectivity_contract`, `terraform_data.ipsec_fallback_contract`, `terraform_data.routing_contract`, `terraform_data.dns_contract`, `terraform_data.runbook_contract` |
| Inputs to settle first | `connectivity_mode`, `fastconnect_virtual_circuit_id`, `expressroute_circuit_id`, `enable_ipsec_fallback`, `azure_cpe_public_ip`, `azure_network_cidrs`, `private_dns_zone_fqdn` |
| Outputs to hand off | `blueprint_name`, `name_prefix`, `resource_ids`, `connectivity_contract`, `ipsec_fallback_contract`, `routing_contract`, `dns_contract`, `runbook_contract` |
| Local runner | `terraform plan` for fast iteration; `ansible/plan.yml` and guarded `ansible/apply.yml` for repo-standard execution. |

## Deployment Purpose

Implements a hardened cross-cloud connectivity baseline where OCI stays primary,
Native FastConnect/ExpressRoute is the preferred primary path in supported locations.
IPSec is an optional rollout or backup path; tunnel BGP and route policy require separate configuration.

## When To Use This Deployment

- OCI must remain the primary connectivity and routing control plane.
- Azure workloads need native private connectivity to OCI in supported locations.
- Operations require a deterministic IPSec/BGP fallback posture.
- Teams need explicit contracts for routing, DNS, and failover runbooks.

## Practical Use Cases

- **Azure to OCI private baseline:** Prefer native FastConnect/ExpressRoute, validate both redundant BGP sessions and use optional independent VPN when required.
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
| Resource | `terraform_data.connectivity_contract` | Connectivity contract with Interconnect primary and optional VPN. |
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
| `connectivity_mode` | Prefer `interconnect` with existing activated circuits; use `without-interconnect` for VPN-only rollout. |
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

## Optional VPN-Only Deployment Steps

1. For the optional VPN-only rollout, set the OCI profile:
```bash
export OCI_PROFILE=DEFAULT
export OCI_CLI_PROFILE=DEFAULT
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

## Networking review — 2026-11-03

See the [networking review and validation matrix](../../../docs/NETWORKING-REVIEW-20261103.md) for the source scope, local checks, corrections and remaining external prerequisites. Historical cloud lifecycle evidence is not extended by this local review.

For cross-cloud traffic, prefer a supported native Interconnect or an explicitly reviewed private partner circuit as the primary transport. Use VPN as an independently configured backup, or as the alternative when Interconnect is unavailable or unsuitable. Confirm [current connection locations](../../../docs/multicloud/INTERCONNECT-REGIONS.md), account eligibility, route preference, both return paths and actual failover behavior; an identifier contract alone establishes none of these.

## Repository-wide transport review — 2026-11-04

Prefer a supported native Interconnect or reviewed private partner circuit for private cross-cloud workload traffic. VPN is a separately configured backup or alternative when dedicated connectivity cannot be used. FastConnect/Interconnect and VPN must use separate connectors and transport segments; application replication/API arrows describe a different relationship. This design preference does not create missing gateways, circuits, VPN peers, route policy or automatic failover; prerequisites shown as external remain operator-owned.

See the [repository review](../../../docs/REPOSITORY-REVIEW-20261104.md) and [dated commercial region matrix](../../../docs/multicloud/INTERCONNECT-REGIONS.md). Availability, activation, permissions and traffic need separate acceptance.
