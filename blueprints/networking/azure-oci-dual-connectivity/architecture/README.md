# Azure + OCI Dual Connectivity Hardening Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for
`blueprints/networking/azure-oci-dual-connectivity`. It is Architecture-first
so the design is easy to review in GitHub, terminals, pull requests, runbooks,
and customer notes without a diagramming tool.

## Deployment Purpose

Implements an OCI-primary network connectivity pattern with two explicit paths:
Interconnect as the preferred steady-state path and IPSec/BGP as fallback.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/networking/azure-oci-dual-connectivity` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Build OCI-primary DRG routing baseline and publish interconnect, IPSec/BGP fallback, DNS, and runbook contracts for Azure + OCI operations. |
| Terraform components | `oci_core_vcn.primary`, `oci_core_route_table.primary`, `oci_core_security_list.primary_hub`, `oci_core_subnet.primary_hub`, `oci_core_drg.primary`, `oci_core_drg_attachment.primary`, `oci_core_cpe.azure`, `oci_core_ipsec.azure`, `terraform_data.connectivity_contract`, `terraform_data.ipsec_fallback_contract`, `terraform_data.routing_contract`, `terraform_data.dns_contract`, `terraform_data.runbook_contract` |
| Primary architecture view | The Architecture diagram below shows OCI control-plane ownership, Azure edge assumptions, and the route preference model. |

## Architecture

```text
+----------------------------------------------------------------------------------------------------------------------+
| Azure + OCI Dual Connectivity Hardening                                                                             |
+----------------------------------------------------------------------------------------------------------------------+
| Legend: [managed resource]  (supplied/external)  {trust boundary}  -> traffic/control flow                         |
|                                                                                                                      |
| [Operator / CI] -> [blueprint-local Ansible runner] -> [Terraform OCI provider]                                     |
|         |                    |                         |                                                             |
|         | validates docs      | init/validate/plan      | OCI API calls                                              |
|         v                    v                         v                                                             |
| {OCI primary boundary}                                                                                               |
|   |                                                                                                                  |
|   |-- [Primary VCN + route table + security list + hub subnet] (optional)                                           |
|   |-- [Primary DRG]                                                                                                  |
|   |      `-- [DRG attachment to primary VCN] (optional)                                                              |
|   |-- [CPE + IPSec fallback] (optional)                                                                              |
|   `-- [terraform_data contracts + optional alerts topic]                                                             |
|          |-- interconnect mode + ExpressRoute/FastConnect IDs                                                       |
|          |-- IPSec/BGP fallback policy + approved Azure CIDRs                                                       |
|          |-- routing preference: interconnect primary, fallback secondary                                            |
|          `-- DNS + runbook hand-off metadata                                                                         |
|                                                                                                                      |
| {Azure secondary boundary}                                                                                            |
|   |                                                                                                                  |
|   |-- (ExpressRoute circuit ID and private path)                                                                     |
|   |-- (VPN gateway public endpoint for fallback)                                                                     |
|   `-- (fallback network edge from azure/main.bicep session)                                                          |
|                                                                                                                      |
| Path intent: OCI DRG primary hub <-> Azure CIDRs via interconnect, with controlled IPSec fallback and failback     |
+----------------------------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Resource | `oci_core_vcn.primary`, `oci_core_route_table.primary`, `oci_core_security_list.primary_hub`, `oci_core_subnet.primary_hub` | Optional OCI primary connectivity network with deploy-and-use routing and security controls. |
| Resource | `oci_core_drg.primary` | OCI DRG as primary route control hub. |
| Resource | `oci_core_drg_attachment.primary` | Optional DRG attachment to OCI VCN. |
| Resource | `oci_core_cpe.azure`, `oci_core_ipsec.azure` | Optional IPSec fallback tunnel resources for Azure edge failover. |
| Resource | `oci_ons_notification_topic.connectivity_alert` | Optional operations alerts topic. |
| Resource | `terraform_data.oci_network_contract` | OCI network and DRG contract output. |
| Resource | `terraform_data.connectivity_contract` | Interconnect primary-path contract output. |
| Resource | `terraform_data.ipsec_fallback_contract` | Fallback IPSec/BGP contract output. |
| Resource | `terraform_data.routing_contract` | CIDR exchange and path preference contract output. |
| Resource | `terraform_data.dns_contract` | Optional DNS forwarding and probe contract output. |
| Resource | `terraform_data.runbook_contract` | Failover/failback operational sequence output. |

## Request And Deployment Flow

- Operator defines whether interconnect is active and whether IPSec fallback is enabled.
- Terraform builds optional OCI network resources and always builds primary DRG.
- Terraform optionally builds OCI CPE and IPSec resources for fallback path.
- Terraform publishes interconnect, fallback, routing, DNS, and runbook contracts.
- Azure-side sessions (`ansible/azure-*.yml`) apply the fallback edge resources from `azure/main.bicep`.

## Traffic And Trust Boundaries

- Control plane traffic runs from local workstation/CI to OCI and Azure APIs.
- Data plane prefers Interconnect and only shifts to IPSec fallback through operator-controlled runbook steps.
- Trust boundaries include OCI tenancy ownership, Azure subscription ownership, and partner interconnect ownership.
- Connection IDs, public IP endpoints, and circuit identifiers must stay in ignored local tfvars or secure pipeline variables.

## Detailed Architecture Notes

- OCI remains primary by contract (`oci_is_primary=true`) for this blueprint variant.
- `connectivity_mode=interconnect` enforces both FastConnect and ExpressRoute IDs.
- `connectivity_mode=without-interconnect` enforces null interconnect IDs and keeps fallback logic explicit.
- Fallback IPSec creation is optional and gated by `azure_cpe_public_ip` preconditions.
- Routing contract outputs keep CIDR exchange and path preference visible for approvals and troubleshooting.
- DNS contract output keeps resolver and probe assumptions explicit for failback validation.
- Azure-side resources are provisioned from `azure/main.bicep` and consumed in operations runbooks with Terraform contract outputs.

## Operational Boundaries

- Apply and destroy are approval-gated through guarded Ansible workflows.
- Keep circuit IDs, public endpoint values, and tenancy-specific OCIDs in ignored local tfvars.
- Re-run plan whenever connectivity mode, fallback policy, CIDRs, or BGP timer assumptions change.
- Validate Azure session outputs and Terraform contract inputs stay aligned before production changes.
- Use contract outputs as the source of truth for NOC/SRE runbook handoff.

## Review Checklist

- Confirm the diagram matches `main.tf`: `oci_core_vcn.primary`, `oci_core_route_table.primary`, `oci_core_security_list.primary_hub`, `oci_core_subnet.primary_hub`, `oci_core_drg.primary`, `oci_core_drg_attachment.primary`, `oci_core_cpe.azure`, `oci_core_ipsec.azure`, `terraform_data.connectivity_contract`, `terraform_data.ipsec_fallback_contract`, `terraform_data.routing_contract`, `terraform_data.dns_contract`, `terraform_data.runbook_contract`.
- Confirm OCI remains primary for this environment.
- Confirm interconnect IDs and mode selection are intentional.
- Confirm fallback enablement, Azure endpoint public IP, and CIDR exchange are deliberate.
- Confirm DNS resolver and health-probe assumptions match operations ownership.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
