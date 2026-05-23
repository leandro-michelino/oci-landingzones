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
| Best fit | OCI-primary dual-connectivity pattern with Interconnect (ExpressRoute + FastConnect) as primary path and IPSec/BGP as fallback path. |
| Terraform shape | `oci_core_vcn.primary`, `oci_core_route_table.primary`, `oci_core_security_list.primary_hub`, `oci_core_subnet.primary_hub`, `oci_core_drg.primary`, `oci_core_drg_attachment.primary`, `oci_core_cpe.azure`, `oci_core_ipsec.azure`, `terraform_data.connectivity_contract`, `terraform_data.ipsec_fallback_contract`, `terraform_data.routing_contract`, `terraform_data.dns_contract`, `terraform_data.runbook_contract` |
| Inputs to settle first | `connectivity_mode`, `fastconnect_virtual_circuit_id`, `expressroute_circuit_id`, `enable_ipsec_fallback`, `azure_cpe_public_ip`, `azure_network_cidrs`, `private_dns_zone_fqdn` |
| Outputs to hand off | `blueprint_name`, `name_prefix`, `resource_ids`, `connectivity_contract`, `ipsec_fallback_contract`, `routing_contract`, `dns_contract`, `runbook_contract` |
| Local runner | `terraform plan` for fast iteration; `ansible/plan.yml` and guarded `ansible/apply.yml` for repo-standard execution. |

## Deployment Purpose

Implements a hardened cross-cloud connectivity baseline where OCI stays primary,
Interconnect is preferred for steady-state traffic, and IPSec/BGP fallback is
predefined for controlled failover and failback.

## When To Use This Deployment

- OCI must remain the primary connectivity and routing control plane.
- Azure workloads need a private primary path to OCI through Interconnect.
- Operations require a deterministic IPSec/BGP fallback posture.
- Teams need explicit contracts for routing, DNS, and failover runbooks.

## What This Deploys

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Resource | `oci_core_vcn.primary`, `oci_core_route_table.primary`, `oci_core_security_list.primary_hub`, `oci_core_subnet.primary_hub` | Optional deploy-and-use OCI network resources with wired route and security controls. |
| Resource | `oci_core_drg.primary`, `oci_core_drg_attachment.primary` | OCI DRG primary hub and optional VCN attachment. |
| Resource | `oci_core_cpe.azure`, `oci_core_ipsec.azure` | Optional fallback IPSec resources. |
| Resource | `oci_ons_notification_topic.connectivity_alert` | Optional connectivity operations topic. |
| Resource | `terraform_data.oci_network_contract` | OCI network and DRG hand-off contract. |
| Resource | `terraform_data.connectivity_contract` | Primary interconnect-mode contract. |
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
| `connectivity_mode` | `interconnect` for primary private path or `without-interconnect` when interconnect is intentionally absent. |
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
