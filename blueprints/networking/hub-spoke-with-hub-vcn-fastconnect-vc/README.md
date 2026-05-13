# Hub-Spoke With FastConnect Virtual Circuit

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this deployment when the landing zone needs private dedicated connectivity between
OCI and customer networks through FastConnect.

## What It Does

This blueprint adds dedicated private connectivity to the hub-spoke model. It captures
the FastConnect virtual circuit, BGP details, customer CIDRs, redundancy, DNS
forwarding, and route distribution choices that usually involve both OCI and the
customer network provider.

## Why Use It

Use this when connectivity is serious enough to deserve dedicated private links.
FastConnect is the right move when bandwidth, latency, and predictable routing matter.

## When To Use It

- Production hybrid connectivity is required.
- Large data flows or low latency paths are expected.
- The customer has provider, colocation, BGP, and redundancy details ready.

## Pattern

- Hub VCN.
- DRG.
- FastConnect virtual circuit.
- Spoke VCN attachments.
- Private routing to customer networks.
- Optional DNS forwarding between OCI and on-premises.

## Best Fit

- Production hybrid cloud.
- High-throughput private connectivity.
- Low-latency network paths.
- Customer data centers or colocation environments.

## Inputs To Decide

- FastConnect provider or colocation model.
- Virtual circuit type and bandwidth.
- BGP ASN and peering IPs.
- Customer network CIDRs.
- Route distribution rules.
- Redundancy model.
- DNS forwarding model.

## Deployment Flow

1. Deploy `blueprints/core`.
2. Complete the architecture diagram with FastConnect path and BGP details.
3. Confirm provider, ASN, and peering information.
4. Populate local tfvars.
5. Run Terraform validation and plan.
6. Apply after network and provider readiness are confirmed.

## Architecture Artifacts

- Architecture notes: `architecture/README.md`

## Notes

FastConnect often has external provider dependencies. Track those assumptions in this
folder before applying.
