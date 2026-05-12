# Hub-Spoke With Private DNS Split Horizon

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this deployment when OCI and on-premises networks need coordinated private DNS
resolution across hub and spoke VCNs.

## What It Does

This blueprint makes private DNS part of the network design. It covers resolver rules,
private zones, spoke forwarding, on-premises DNS dependencies, query paths, and
ownership so hybrid or multi-spoke name resolution is not discovered only when apps fail
to start.

## Why Use It

Use this when name resolution is the thing that will break the project if it is treated
as an afterthought. Hybrid and multi-spoke designs need DNS paths drawn clearly.

## When To Use It

- OCI and on-premises need shared private DNS behavior.
- Multiple VCNs need consistent service discovery.
- Conditional forwarding and private zones are part of the design.

## Pattern

- Hub VCN.
- Private DNS resolvers.
- Split-horizon zones.
- Spoke VCN resolver forwarding.
- Optional on-premises forwarding through VPN or FastConnect.
- DRG route support for resolver paths.

## Best Fit

- Hybrid cloud name resolution.
- Shared-services DNS.
- Multi-spoke environments.
- Workloads that need private service discovery.

## Inputs To Decide

- Private DNS zones.
- Resolver forwarding rules.
- On-premises DNS server IPs.
- Spoke resolver behavior.
- Conditional forwarding domains.
- DNS logging and ownership.

## Deployment Flow

1. Deploy `blueprints/core`.
2. Complete the architecture diagram with DNS query paths.
3. Confirm domains and forwarding rules with DNS owners.
4. Populate local tfvars.
5. Run Terraform validation and plan.
6. Apply after DNS and routing are reviewed.

## Architecture Artifacts

- Source diagram: `architecture/hub-spoke-with-private-dns-split-horizon.excalidraw`
- Exported image: generate a PNG from the source only when a rendered review artifact is needed.

## Notes

DNS failures are hard to debug after deployment. Keep resolver paths explicit in the
diagram.
