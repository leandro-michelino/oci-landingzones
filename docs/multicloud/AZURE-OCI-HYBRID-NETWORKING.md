# Azure + OCI Hybrid Networking Design Record

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This design record maps to the deployed blueprint:
`blueprints/networking/azure-oci-dual-connectivity/`.

## Deployment Purpose

Provide deterministic and auditable network connectivity between Azure and OCI
with OCI as primary routing hub, Interconnect as preferred path, and
IPSec/BGP as fallback path.

## Primary Outcomes

- Private cloud-to-cloud connectivity for critical workloads.
- Explicit fallback path with route-policy and runbook contracts.
- Route segmentation by environment and workload class.
- DNS forwarding and health-probe assumptions captured as output contracts.
- Repeatable hand-off for platform and network operations teams.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Blueprint path | `blueprints/networking/azure-oci-dual-connectivity/` |
| Azure side | Azure VNet connectivity edge + optional VPN Gateway resources from `azure/main.bicep` |
| OCI side | OCI primary VCN + DRG + optional CPE/IPSec fallback resources |
| Primary path | ExpressRoute + FastConnect via approved partner |
| Secondary path | IPSec VPN + BGP between Azure VPN edge and OCI DRG |
| Routing model | BGP-oriented route exchange with explicit CIDR contracts |
| DNS model | Private DNS forwarding and health-probe contract metadata |

## Service Region Availability

As of May 23, 2026, Oracle Interconnect for Azure has region-pair constraints.
Always validate official current region support before production placement.

Reference:
- Oracle Interconnect for Azure: `docs.oracle.com/en-us/iaas/Content/Network/Concepts/azure.htm`
- Azure ExpressRoute locations: `learn.microsoft.com/azure/expressroute/`

## Architecture

```text
+--------------------------------------------------------------------------------------------------+
| Azure + OCI Hybrid Networking                                                                    |
+--------------------------------------------------------------------------------------------------+
| {Azure}                                                                                          |
| [Connectivity VNet + route table + NSG] -> [ExpressRoute path] -> (Partner Edge)               |
|                            |                                                                     |
|                            `-> [Azure VPN fallback edge]                                         |
|                                                                                                  |
|                               private primary + encrypted fallback                               |
|                                                                                                  |
| {OCI primary}                                                                                    |
| [DRG primary] <-> [Primary VCN subnet route/security controls]                                  |
|      |                                                                                           |
|      `-> [Optional CPE + IPSec fallback tunnel resources]                                       |
|                                                                                                  |
| Contract outputs: connectivity mode, path preference, CIDR exchange, DNS/probe, runbook steps  |
+--------------------------------------------------------------------------------------------------+
```

## Traffic And Segmentation Model

- Segment route domains by production, nonproduction, and shared services.
- Advertise only approved CIDRs between clouds.
- Keep management and workload subnets separated.
- Use NSGs and route tables to enforce east-west and north-south intent.

## Security Controls

- Encrypt fallback-path traffic using IPSec.
- Prefer private Interconnect for steady-state path.
- Log route and tunnel state and forward to central observability.
- Prevent route leak by filtering broad supernets where not required.

## Inputs To Settle Before Build

- Interconnect circuit ownership and lifecycle model.
- Azure VPN edge endpoint ownership for fallback.
- BGP ASN and timer ownership.
- Approved CIDR ranges and overlap remediation plan.
- DNS resolution ownership and forwarding zones.
- Expected failover and failback objective timing.

## Outputs And Hand-Off

The deployed blueprint publishes:

```text
oci_network_contract
connectivity_contract
ipsec_fallback_contract
routing_contract
dns_contract
runbook_contract
```

These outputs are the source of truth for operations runbooks.

## Validation Checklist

- End-to-end route assumptions match approved CIDRs.
- Non-approved CIDRs are denied by route and security controls.
- Primary and fallback path behavior matches contract outputs.
- DNS forwarding and probe assumptions are deterministic.
- Telemetry is available for route-state and tunnel-state monitoring.
