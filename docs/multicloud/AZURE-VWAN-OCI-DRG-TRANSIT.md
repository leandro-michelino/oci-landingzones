# Azure vWAN + OCI DRG Transit (Design Record)

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

## Interconnect Validation Notes

For public examples, keep validation guidance generic and avoid committing
real lab compartments, run dates, provider-key values, peer IPs, VLANs, or
quota details. Operators should capture those values in the deployment runbook
or pipeline logs for the specific environment.

- Pair the Azure ExpressRoute peering location with the OCI FastConnect region.
- Create Azure Private Peering first, then pass the Azure service key to OCI.
- Read the provider-key values returned by OCI and apply them to Azure Private
  Peering.
- Treat control-plane success and packet-flow validation as separate gates.
- Keep IPSec fallback quotas and limits in environment-specific notes.

## Blueprint Source

- `blueprints/networking/azure-vwan-oci-drg-transit/`
