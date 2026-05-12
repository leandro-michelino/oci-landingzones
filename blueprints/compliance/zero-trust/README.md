# Zero Trust Landing Zone

This blueprint is for environments where identity, segmentation, continuous inspection,
and least-privilege access drive the architecture.

## What It Does

This blueprint makes the landing zone private, segmented, and identity-aware from the
start. It lines up IAM, ZPR, NSGs, private endpoints, and inspected traffic paths so the
design does not depend on a soft trusted network in the middle.

## Why Use It

Use this when trust needs to be earned at every boundary. The pattern combines identity,
segmentation, private access, and inspected paths so the architecture does not rely on a
soft internal network.

## When To Use It

- High-security workloads need identity-aware segmentation.
- Private access and least privilege are explicit design goals.
- The customer is ready to use ZPR, NSGs, and inspection together.

## Fit

- High-security workloads.
- Private-first application estates.
- Customers adopting ZPR, network security groups, and identity-aware access.

## Expected Composition

- Core IAM and compartment structure.
- ZPR policies and micro-segmentation.
- Private endpoints and service gateways.
- Inspected ingress and egress through firewall or appliance patterns.
- Bastion or approved privileged access path.
- Cloud Guard, Vault, logging, events, and monitoring.

## Deployment Notes

Start with core, then choose the networking pattern that fits the traffic model. Use CIS
Level 2 only when that extra strictness is explicitly selected.
