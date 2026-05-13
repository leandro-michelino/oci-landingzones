# Hub-Spoke With OCI Network Firewall

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this deployment when traffic between spokes, internet, and private networks must be
inspected by OCI Network Firewall.

## What It Does

This blueprint uses OCI Network Firewall as the managed inspection point for hub, spoke,
internet, and private traffic flows. It makes firewall policy, route steering, logging,
north-south and east-west inspection, and asymmetric routing risks part of the design.

## Why Use It

Use this when the customer wants managed centralized inspection without running firewall
appliances themselves. OCI Network Firewall becomes the main checkpoint for hub, spoke,
and external flows.

## When To Use It

- Central inspection is mandatory.
- The customer prefers managed firewall operations.
- North-south or east-west traffic needs policy enforcement and logging.

## Pattern

- Hub VCN.
- DRG.
- OCI Network Firewall subnet.
- Spoke VCN attachments.
- Route tables steering traffic through the firewall.
- Optional internet, VPN, or FastConnect paths.

## Best Fit

- Centralized inspection.
- Regulated workloads.
- Shared egress and ingress control.
- Customers that prefer managed firewall services over self-managed appliances.

## Inputs To Decide

- Firewall policy model.
- Inspection traffic flows.
- Hub and spoke CIDRs.
- North-south and east-west routing.
- Internet egress requirement.
- Logging and alerting requirements.

## Deployment Flow

1. Deploy `blueprints/core`.
2. Complete the architecture notes with inspection paths.
3. Confirm firewall policy ownership.
4. Populate local tfvars.
5. Run Terraform validation and plan.
6. Apply after route steering and firewall rules are reviewed.

## Architecture Artifacts

- Architecture notes: `architecture/README.md`

## Notes

Firewall route steering should be reviewed carefully. The diagram must make asymmetric
routing risks visible.
