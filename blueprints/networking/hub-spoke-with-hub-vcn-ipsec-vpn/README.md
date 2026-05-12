# Hub-Spoke With IPSec VPN

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this deployment when OCI spokes need private connectivity to an on-premises or
third-party network over site-to-site IPSec VPN.

## What It Does

This blueprint connects OCI spokes to on-premises or partner networks over site-to-site
IPSec VPN. It covers CPE details, tunnel redundancy, static or BGP routing,
shared-secret handling, on-premises CIDRs, and optional private DNS forwarding.

## Why Use It

Use this when private connectivity is needed now and VPN is the practical path. It is
often the quickest bridge between OCI and customer networks while bigger connectivity
plans mature.

## When To Use It

- On-premises or partner networks must reach OCI privately.
- FastConnect is not ready or not justified.
- Redundant IPSec tunnels are acceptable for the workload.

## Pattern

- Hub VCN.
- DRG.
- IPSec connection to customer-premises equipment.
- Spoke VCN attachments.
- Route tables for on-premises, hub, and spoke traffic.
- Optional private DNS forwarding.

## Best Fit

- Hybrid cloud with VPN connectivity.
- Early-stage connectivity before FastConnect is available.
- Branch or partner connectivity.
- Customer environments where redundant VPN tunnels are acceptable.

## Inputs To Decide

- Customer-premises equipment public IPs.
- On-premises CIDR ranges.
- Static routing versus BGP.
- Tunnel redundancy requirements.
- Shared secret handling.
- Spoke-to-on-premises route propagation.
- DNS forwarding requirements.

## Deployment Flow

1. Deploy `blueprints/core`.
2. Complete the architecture diagram with on-premises CIDRs and tunnel paths.
3. Confirm CPE details with the customer network team.
4. Populate local tfvars without committing secrets.
5. Run Terraform validation and plan.
6. Apply after routing, tunnel, and security rules are approved.

## Architecture Artifacts

- Source diagram: `architecture/hub-spoke-with-hub-vcn-ipsec-vpn.excalidraw`
- Exported image: `architecture/hub-spoke-with-hub-vcn-ipsec-vpn.png`

## Notes

Keep VPN shared secrets out of committed files. Use local ignored tfvars or a
customer-approved secret process.
