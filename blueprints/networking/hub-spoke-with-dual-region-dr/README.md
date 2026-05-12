# Hub-Spoke With Dual-Region DR

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this deployment when the landing zone needs a primary and secondary region network
pattern for disaster recovery.

## What It Does

This blueprint duplicates the landing-zone network shape across primary and standby
regions. It focuses on regional hubs, peering, routing, DNS behavior, shared services,
and the failover paths that need to exist before workload DR can be taken seriously.

## Why Use It

Use this when disaster recovery starts at the network layer. It gives both regions a
matching routing foundation before workload-level DR is layered on top.

## When To Use It

- Primary and standby regions are required.
- Regional routing and peering must be standardized.
- The workload has RTO/RPO targets and a test process.

## Pattern

- Primary region hub and spokes.
- Secondary region hub and spokes.
- DRG and remote peering between regions.
- Region-local routing and failover routes.
- Optional replicated DNS and security services.

## Best Fit

- Production workloads with DR requirements.
- Active/passive regional designs.
- Customers standardizing regional landing-zone topology.
- Workloads with explicit RTO and RPO targets.

## Inputs To Decide

- Primary and secondary regions.
- CIDR plan per region.
- Remote peering strategy.
- Failover routing behavior.
- DNS failover model.
- Shared services required in both regions.
- DR test procedure.

## Deployment Flow

1. Deploy `blueprints/core` in the primary region context.
2. Complete the dual-region architecture diagram.
3. Confirm regional CIDRs and peering.
4. Populate local tfvars for both regions.
5. Run Terraform validation and plan.
6. Apply after DR ownership and test process are reviewed.

## Architecture Artifacts

- Source diagram: `architecture/hub-spoke-with-dual-region-dr.excalidraw`
- Exported image: `architecture/hub-spoke-with-dual-region-dr.png`

## Notes

The diagram should include failover behavior, not only steady-state topology.
