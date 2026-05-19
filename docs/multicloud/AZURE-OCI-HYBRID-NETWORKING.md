# Azure + OCI Hybrid Networking Blueprint Draft

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This document defines a concrete hybrid networking blueprint draft that links
Azure hub networking with OCI hub-spoke networking for private multicloud
application traffic and controlled failover.

## Deployment Purpose

Provide deterministic and auditable network connectivity between Azure and OCI
using a primary private path and an encrypted backup path, with explicit route,
DNS, and inspection boundaries.

## Primary Outcomes

- Private cloud-to-cloud connectivity for critical workloads.
- Backup encrypted path for resilience.
- Route segmentation by environment and workload class.
- Consistent network inspection and logging controls.
- Repeatable hand-off contract for application teams.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Azure side | Azure vWAN hub or regional hub VNet |
| OCI side | OCI hub VCN + DRG + spoke VCN attachments |
| Primary path | ExpressRoute + FastConnect via approved partner |
| Secondary path | IPSec VPN between Azure VPN Gateway and OCI DRG |
| Routing model | BGP-based route exchange with explicit route filtering |
| DNS model | Private DNS forwarding and split-horizon controls |

## Service Region Availability

As per today date, 19/May/26, the documented Oracle Interconnect for Azure
region availability is:

Oracle Interconnect for Azure is available only in the OCI regions and Azure
ExpressRoute locations shown below. Use these pairs as hard placement
constraints before selecting a customer target region.

### Asia Pacific (APAC)

| OCI Region | OCI Key | Azure ExpressRoute Location |
| --- | --- | --- |
| Japan East (Tokyo) | `NRT` | Tokyo |
| Singapore (Singapore) | `SIN` | Singapore |
| South Korea Central (Seoul) | `ICN` | Seoul |

### Europe, Middle East, Africa (EMEA)

| OCI Region | OCI Key | Azure ExpressRoute Location |
| --- | --- | --- |
| Germany Central (Frankfurt) | `FRA` | Frankfurt and Frankfurt2 |
| Netherlands Northwest (Amsterdam) | `AMS` | Amsterdam2 |
| UK South (London) | `LHR` | London |
| South Africa Central (Johannesburg) | `JNB` | Johannesburg |

### Latin America (LATAM)

| OCI Region | OCI Key | Azure ExpressRoute Location |
| --- | --- | --- |
| Brazil Southeast (Vinhedo) | `VCP` | Campinas |

### North America (NA)

| OCI Region | OCI Key | Azure ExpressRoute Location |
| --- | --- | --- |
| Canada Southeast (Toronto) | `YYZ` | Toronto and Toronto2 |
| US East (Ashburn) | `IAD` | Washington DC and Washington DC2 |
| US West (Phoenix) | `PHX` | Phoenix |
| US West (San Jose) | `SJC` | Silicon Valley |

## Architecture

```text
+--------------------------------------------------------------------------------------------------+
| Azure + OCI Hybrid Networking                                                                    |
+--------------------------------------------------------------------------------------------------+
| {Azure}                                                                                          |
| [Spoke VNets] -> [Azure Hub/vWAN] -> [ExpressRoute GW] -> (Provider Edge)                        |
|        |                              |                                                           |
|        |                              `-> [Azure VPN Gateway]                                    |
|        |                                                                                         |
|        +------------------------------ private + backup -------------------------------+         |
|                                                                                          |       |
|                                                                                          v       |
| {OCI}                                                                                    [DRG]   |
|                                                                                           |      |
|                                                                                [Hub VCN + NSGs]  |
|                                                                                           |      |
|                                                                                 [Spoke VCNs]     |
|                                                                                           |      |
|                                                                          [Apps / Data Services]  |
|                                                                                                  |
| Traffic policy: primary over private circuit, controlled failover to IPSec backup path.         |
+--------------------------------------------------------------------------------------------------+
```

## Traffic And Segmentation Model

- Segment route domains by production, nonproduction, and shared services.
- Advertise only approved CIDRs between clouds.
- Keep management and workload subnets separated.
- Use NSGs and route tables to enforce east-west and north-south intent.

## Security Controls

- Encrypt all backup-path traffic using IPSec.
- Place inspection points in hub networks for regulated workloads.
- Log flow telemetry in both Azure and OCI and centralize to SIEM.
- Prevent route leak by filtering default and broad supernets where not required.

## Inputs To Settle Before Build

- Azure hub architecture choice: vWAN or classic hub VNet.
- OCI hub-spoke baseline and DRG attachment design.
- BGP ASN allocation and route policy ownership.
- Approved CIDR ranges and overlap remediation plan.
- DNS resolution ownership and forwarding zones.
- Expected throughput and latency SLOs by workload tier.

## Outputs And Hand-Off

The future deployment hand-off should include:

```text
azure_hub_connection_ids
oci_drg_id
interconnect_virtual_circuit_ids
ipsec_tunnel_ids
advertised_route_sets
dns_forwarding_endpoints
network_observability_endpoints
```

## Rollout Plan

1. Foundation:
Confirm CIDR strategy, BGP ownership, and target route domains.
2. Primary path:
Enable ExpressRoute/FastConnect private interconnect and validate route exchange.
3. Backup path:
Add IPSec VPN and test failover with controlled traffic sets.
4. Operational hardening:
Enable full flow logging, SIEM forwarding, and periodic path failover drills.

## Validation Checklist

- End-to-end connectivity tests pass for approved CIDRs.
- Non-approved CIDRs are denied by route and security controls.
- Primary and backup failover behavior matches design.
- DNS resolution is deterministic across both clouds.
- Telemetry is available for path, tunnel, and route-state monitoring.

## Promotion Criteria

Promote to `blueprints/networking/azure-oci-hybrid-networking/` when:

- Interconnect providers and circuit ownership are confirmed.
- Route policy and CIDR contracts are approved.
- Security review signs off on inspection and logging design.
- Application onboarding model is documented.
