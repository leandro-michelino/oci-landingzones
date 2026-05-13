# Standalone Three-Tier VCN Custom

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this deployment when the workload still follows the classic web, application, and
database tiers, but the customer needs full control over CIDRs, subnet names, routing,
or security rules.

## What It Does

This blueprint builds a classic three-tier VCN with customer-specific network choices.
It keeps CIDRs, subnet sizes, public/private tier decisions, route rules, gateway
choices, and security controls explicit for workloads that do not fit the starter
defaults.

## Why Use It

Use this when the app is still a normal three-tier workload, but the network team has
opinions. CIDRs, routes, labels, and security rules can be made explicit here.

## When To Use It

- The customer has an approved IP plan.
- Subnet sizes or route behavior differ from defaults.
- Security teams need detailed control over ingress and egress.

## Pattern

- One VCN.
- Public or private web tier, depending on the customer design.
- Private application tier.
- Private database tier.
- Optional internet gateway, NAT gateway, and service gateway.
- Custom route tables and security controls.

## Best Fit

- Customer-defined IP plans.
- Migration projects with existing network ranges.
- Workloads that need non-standard subnet sizing.
- Environments where security teams own detailed ingress and egress rules.

## Inputs To Decide

- VCN CIDR and DNS label.
- Subnet CIDRs for each tier.
- Public versus private web tier.
- Internet gateway requirement.
- NAT and service gateway requirement.
- Route table rules.
- NSG or security list model.

## Deployment Flow

1. Deploy `blueprints/core`.
2. Complete the local architecture diagram.
3. Confirm CIDRs with the customer network team.
4. Populate a local ignored tfvars file.
5. Run `terraform init`, `terraform validate`, and `terraform plan`.
6. Apply after route and security behavior is reviewed.

## Architecture Artifacts

- Architecture notes: `architecture/README.md`

## Notes

Prefer this over the defaults blueprint when customer requirements are already known.
Keep the final CIDR plan in this folder with the diagram.
