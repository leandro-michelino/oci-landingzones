# Hub-Spoke With DRG And Three-Tier VCNs

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this deployment when the customer needs a central hub VCN, a DRG, and one or more
spoke VCNs that follow the three-tier workload pattern.

## What It Does

This is the base enterprise hub-spoke network. It creates the shared routing center with
a hub VCN and DRG, then attaches three-tier spoke VCNs for workload teams that need
separation but still depend on common routing, DNS, or future hybrid connectivity.

## Why Use It

Use this when one VCN is no longer enough and the customer needs a proper shared routing
center. This is the base enterprise network shape for many OCI landing zones.

## When To Use It

- Multiple applications or teams need separate spokes.
- A DRG is needed for routing growth.
- Future VPN, FastConnect, firewall, or DR patterns are likely.

## Pattern

- Hub VCN for shared routing and central services.
- DRG for VCN attachments and future on-premises connectivity.
- One or more spoke VCNs.
- Three-tier subnet layout inside each spoke.
- Centralized routing between spokes through the DRG.
- Optional internet egress from hub or spokes, depending on design.

## Best Fit

- Multi-application landing zones.
- Shared-services network models.
- Customers expecting growth beyond one VCN.
- Environments that may add FastConnect, IPSec, firewall inspection, or DR later.

## Inputs To Decide

- Hub VCN CIDR.
- Spoke VCN CIDRs.
- DRG attachment model.
- Route distribution and import/export rules.
- Internet egress pattern.
- Inspection requirement.
- DNS resolution model.

## Deployment Flow

1. Deploy `blueprints/core`.
2. Complete the architecture notes for the hub, DRG, and spokes.
3. Confirm the customer IP plan has no overlaps.
4. Populate local tfvars.
5. Run Terraform validation and plan.
6. Apply after routing and security rules are reviewed.

## Architecture Artifacts

- Architecture notes: `architecture/README.md`

## Notes

This is the base hub-spoke pattern. Use the more specific hub-spoke folders when the
design requires VPN, FastConnect, managed firewall, NVA inspection, or DR.
