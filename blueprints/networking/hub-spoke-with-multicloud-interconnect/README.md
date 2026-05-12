# Hub-Spoke With Multicloud Interconnect

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This blueprint is for hub-spoke environments that connect OCI to another cloud or
external provider through private connectivity.

## What It Does

This blueprint connects OCI to another cloud or external provider through a controlled
hub-spoke design. It documents the external attachment, route domains, DNS forwarding,
inspection options, and the shared-services paths that keep multicloud from turning into
a tunnel collection.

## Why Use It

Use this when OCI is one part of a wider cloud estate. It is the pattern for making
multicloud connectivity deliberate instead of a pile of one-off tunnels.

## When To Use It

- OCI must connect privately to another cloud or provider.
- Shared services or workloads span more than one cloud.
- Routing, DNS, and inspection need a single documented model.

## Fit

- OCI plus Azure, AWS, Google Cloud, or partner cloud connectivity.
- Shared services in OCI with workloads spanning more than one provider.
- Hybrid or multicloud routing controlled through the OCI DRG.

## Expected Composition

- Hub VCN and DRG.
- Workload spoke VCNs.
- FastConnect, partner interconnect, or IPSec VPN.
- Route tables and DRG route distributions.
- Private DNS forwarding and split-horizon DNS.
- Optional firewall or network appliance inspection.

## Deployment Notes

Use this when the customer has a real external cloud attachment. For single provider
hybrid connectivity, use the FastConnect or IPSec VPN blueprints.
