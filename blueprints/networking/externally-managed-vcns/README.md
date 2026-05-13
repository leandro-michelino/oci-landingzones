# Externally Managed VCNs

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this deployment when VCNs already exist or are managed by another platform, but the
landing zone still needs to reference them for governance, routing, or integration.

## What It Does

This blueprint lets the landing zone work with VCNs it does not own. It accepts existing
network IDs and documents the boundary between Terraform-managed landing-zone pieces and
networks owned by another team, platform, or migration track.

## Why Use It

Use this when the landing zone is arriving after the network already exists. It lets the
repo integrate with VCNs owned somewhere else without pretending Terraform owns
everything.

## When To Use It

- Brownfield VCNs already exist.
- Another team or platform owns network lifecycle.
- This repo should reference, attach, or govern without replacing.

## Pattern

- Existing VCNs are treated as external dependencies.
- Terraform reads or accepts external VCN IDs.
- Landing-zone resources integrate without taking ownership of the VCNs.
- Policies, routing references, DNS, or attachments can be layered around them.

## Best Fit

- Brownfield OCI environments.
- Customer-owned network platforms.
- Migration projects.
- Cases where central landing-zone code must not recreate network resources.

## Inputs To Decide

- Existing VCN OCIDs.
- Existing subnet OCIDs.
- Ownership and change-control boundary.
- Route table and security ownership.
- DNS integration requirements.
- Whether the landing zone may attach or only reference resources.

## Deployment Flow

1. Deploy or identify `blueprints/core`.
2. Complete the architecture diagram with clear ownership boundaries.
3. Inventory existing VCNs and subnets.
4. Populate local tfvars with existing OCIDs.
5. Run Terraform validation and plan.
6. Apply only after confirming no external resource ownership will be violated.

## Architecture Artifacts

- Architecture notes: `architecture/README.md`

## Notes

This blueprint is for integration, not replacement. Keep ownership boundaries plain and
explicit.
