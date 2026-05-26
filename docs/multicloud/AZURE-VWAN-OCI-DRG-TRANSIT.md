# Azure vWAN + OCI DRG Transit (Design Record)

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This document keeps design rationale for the available
`blueprints/networking/azure-vwan-oci-drg-transit/` blueprint.
Use the blueprint folder as the source of truth for operator workflow,
inputs, contracts, and day-2 runbooks.

## Purpose

Capture an OCI-primary transit pattern where OCI DRG remains the main
cross-cloud routing control plane while Azure Virtual WAN and Virtual Hub
organize Azure-side route domains.

## Scope Summary

| Area | Notes |
| --- | --- |
| Primary control plane | OCI DRG and OCI route policy remain primary. |
| Azure transit domain | Azure Virtual WAN plus Virtual Hub route domain. |
| Default path when present | Interconnect (ExpressRoute + FastConnect). |
| Test and backup path | IPSec + BGP with operator-controlled failover and failback. |
| Route governance | Segment metadata for prod, nonprod, and management lanes. |
| DNS and probes | DNS contract plus probe FQDN for health validation and cutover checks. |

## Architecture Snapshot

```text
OCI DRG (primary transit control)
  |-- OCI VCN route tables and security controls
  |-- Interconnect metadata contract
  |-- IPSec fallback contract
  `-- Runbook + DNS contracts
           |
           v
Azure vWAN + vHub
  |-- vHub route table and VNet connection
  `-- optional VPN fallback resources
```

## Operational Notes

- Keep OCI as primary (`oci_is_primary=true`) for this variant.
- Use `without-interconnect` for rollout tests where dedicated circuits are intentionally not provisioned.
- For `connectivity_mode=interconnect`, provide FastConnect and ExpressRoute IDs.
- Keep vWAN and vHub IDs in local ignored tfvars or secure pipeline variables.
- Use blueprint outputs as the contract source for NOC and SRE handoff.

## Latest London Test Findings

Live validation on 2026-05-26 used Azure `uksouth` with London
ExpressRoute peering and OCI `uk-london-1` in the `Leandro_Michelino`
compartment. The interconnect-first path created both sides of the private
connectivity contract:

- Azure ExpressRoute circuit: `Local_UnlimitedData`, Oracle Cloud FastConnect
  provider, London peering location, `1 Gbps`, Azure Private Peering enabled.
- OCI FastConnect virtual circuit: Microsoft Azure provider service, `1 Gbps`,
  provider state `ACTIVE`, lifecycle state `PROVISIONED`.
- Provider-key values returned by OCI drove the Azure peering values: peer ASN
  `31898`, VLAN `13`, primary pair `10.255.0.1/30` and `10.255.0.2/30`,
  secondary pair `10.255.0.5/30` and `10.255.0.6/30`, and no BGP MD5 shared
  key.

The important operational result is that circuit provisioning succeeded, but
end-to-end data-plane validation did not complete in that run. The Azure vWAN
ExpressRoute Gateway stayed `Updating` through the validation window and only
returned `Succeeded` after teardown had already started, so the vHub gateway
connection was not created. BGP remained `DOWN`, and bidirectional packet tests
were not completed. The IPSec fallback was also attempted, but OCI returned
`ipsec-connection-count` quota exceeded in `uk-london-1`; free or raise that
quota before using London IPSec as the backup path.

## Blueprint Source

- `blueprints/networking/azure-vwan-oci-drg-transit/`
