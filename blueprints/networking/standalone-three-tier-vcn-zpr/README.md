# Standalone Three-Tier VCN With ZPR

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this deployment when a standalone three-tier VCN should also model Zero Packet
Routing attributes for stronger network isolation.

## What It Does

This blueprint adds ZPR segmentation intent to a standalone three-tier VCN. It keeps
web, app, and database tiers simple while adding attributes and a communication matrix
that prepare the workload for stronger zero-trust style controls.

## Why Use It

Use this when a standalone VCN needs segmentation intent baked in from the start. It is
the small-footprint way to bring ZPR thinking into a three-tier app.

## When To Use It

- The workload is standalone but security wants stronger segmentation.
- ZPR attributes should describe tiers or app boundaries.
- You are preparing for a broader Zero Trust model later.

## Pattern

- One VCN.
- Web, application, and database tiers.
- ZPR attributes for segmentation intent.
- Optional internet, NAT, and service gateways depending on exposure.
- Security rules aligned with tier boundaries.

## Best Fit

- Workloads that need explicit segmentation metadata.
- Environments preparing for ZPR-based governance.
- Teams that want a standalone VCN without a hub-spoke dependency.

## Inputs To Decide

- VCN and subnet CIDRs.
- ZPR namespace and attributes.
- Tier-to-tier communication matrix.
- Internet exposure model.
- Private egress requirements.

## Deployment Flow

1. Deploy `blueprints/core`.
2. Complete the architecture diagram with ZPR attributes.
3. Validate the tier communication matrix with the security team.
4. Populate local tfvars.
5. Run Terraform validation and plan.
6. Apply after ZPR and network rules are reviewed together.

## Architecture Artifacts

- Architecture notes: `architecture/README.md`

## Notes

This blueprint is for segmentation-aware standalone deployments. Use the hub ZPR
blueprint when segmentation spans multiple VCNs.
