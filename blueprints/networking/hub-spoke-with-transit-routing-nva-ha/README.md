# Hub-Spoke With Transit Routing NVA HA

Use this deployment when the customer needs high-availability transit routing through
network virtual appliances.

## What It Does

This blueprint is the heavier enterprise NVA pattern: transit routing through redundant
appliances. It documents active/passive or active/active behavior, interfaces, health
checks, route steering, failover assumptions, licensing, and management access.

## Why Use It

Use this when traffic inspection needs both vendor appliances and high availability. It
is the heavier enterprise pattern for customers who care deeply about failure behavior.

## When To Use It

- Transit inspection must survive appliance or domain failure.
- The customer requires NVA HA instead of managed firewall.
- Routing and failover need explicit review.

## Pattern

- Hub VCN.
- DRG.
- Redundant network virtual appliances.
- Transit route tables.
- Spoke VCN attachments.
- Failure-domain or availability-domain placement.
- Optional north-south and east-west inspection.

## Best Fit

- Enterprise security appliance standards.
- High-availability inspection.
- Advanced routing requirements.
- Vendor-specific transit firewall patterns.

## Inputs To Decide

- NVA vendor and image.
- Active/passive or active/active design.
- Appliance interface layout.
- Health check and failover approach.
- Transit route tables.
- Management access model.
- Licensing and bootstrap inputs.

## Deployment Flow

1. Deploy `blueprints/core`.
2. Complete the architecture diagram with HA and failover paths.
3. Confirm vendor design requirements.
4. Populate local tfvars and secret-free bootstrap inputs.
5. Run Terraform validation and plan.
6. Apply after failover, route steering, and lifecycle ownership are reviewed.

## Architecture Artifacts

- Source diagram: `architecture/hub-spoke-with-transit-routing-nva-ha.excalidraw`
- Exported image: `architecture/hub-spoke-with-transit-routing-nva-ha.png`

## Notes

This blueprint should clearly document failure behavior. Do not hide HA assumptions in
Terraform variables only.
