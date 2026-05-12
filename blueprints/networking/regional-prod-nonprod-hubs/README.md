# Regional Prod/Nonprod Hubs

This blueprint separates production and nonproduction traffic into distinct regional hub
networks while keeping shared governance and operations consistent.

## What It Does

This blueprint gives production and nonproduction their own regional hub networks. It is
for customers who need different routing, inspection, DNS, and shared-services rules for
prod and nonprod instead of relying on compartments alone.

## Why Use It

Use this when production and nonproduction should not share the same network blast
radius. It is more structure than a simple compartment split, and that is the point.

## When To Use It

- Production isolation is a hard requirement.
- Prod and nonprod need different inspection or routing rules.
- Shared services exist but must cross boundaries carefully.

## Fit

- Customers with strict production isolation.
- Separate routing and inspection policies for prod and nonprod.
- Shared services with explicit route and DNS boundaries.

## Expected Composition

- Production hub VCN and DRG route domain.
- Nonproduction hub VCN and DRG route domain.
- Separate firewall or appliance policies.
- Shared DNS with controlled forwarding.
- Workload spokes attached to the correct route domain.

## Deployment Notes

Use this when production isolation is stronger than a simple compartment boundary. Pair
with operating entity or workload vending patterns.
