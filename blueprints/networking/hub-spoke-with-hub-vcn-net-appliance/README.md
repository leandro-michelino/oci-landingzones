# Hub-Spoke With Network Appliance

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this deployment when the customer requires a third-party network virtual appliance
for inspection, routing, or security services.

## What It Does

This blueprint puts a third-party network virtual appliance into the hub path. It is for
customers with an existing firewall, routing, or inspection standard where vendor image,
HA model, interfaces, licensing, bootstrap, and management access all matter.

## Why Use It

Use this when the customer has a firewall or routing standard that says a specific
vendor appliance must be in the path. This keeps the landing zone compatible with
existing security operations.

## When To Use It

- A third-party NVA is required.
- Vendor-specific inspection, routing, or licensing matters.
- Network operations already supports that appliance family.

## Pattern

- Hub VCN.
- DRG.
- Network appliance subnet.
- Spoke VCN attachments.
- Route tables steering traffic to the appliance.
- Optional active/passive or active/active appliance design.

## Best Fit

- Customers with existing firewall standards.
- Marketplace NVA deployments.
- Designs that require vendor-specific security functions.
- Environments with advanced routing or inspection needs.

## Inputs To Decide

- Appliance vendor and image.
- HA model.
- Management subnet and access path.
- Trust/untrust interface design.
- Route steering rules.
- Licensing and bootstrap parameters.

## Deployment Flow

1. Deploy `blueprints/core`.
2. Complete the local architecture diagram.
3. Confirm appliance vendor requirements.
4. Populate local tfvars and vendor bootstrap data.
5. Run Terraform validation and plan.
6. Apply after appliance lifecycle and routing are reviewed.

## Architecture Artifacts

- Source diagram: `architecture/hub-spoke-with-hub-vcn-net-appliance.excalidraw`
- Exported image: generate a PNG from the source only when a rendered review artifact is needed.

## Notes

Keep vendor licenses, passwords, and bootstrap secrets out of committed files.
