# SCCA Cloud-Native Landing Zone

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This blueprint is for regulated cloud-native environments that need strong traffic
inspection, centralized auditability, controlled ingress and egress, and a clear
separation between platform, security, and workload responsibilities.

## What It Does

This blueprint turns a cloud-native landing zone into something a regulated customer can
actually review. It pulls together inspected ingress and egress, central logging,
private access paths, security operations hooks, and clear ownership boundaries for
platform and workload teams.

## Why Use It

Use this when the customer says cloud native, but the security model says regulated,
inspected, logged, and reviewable. It packages the controls around modern workloads
without pretending compliance is just a checkbox.

## When To Use It

- Public sector or regulated workloads need a cloud-native foundation.
- Ingress, egress, audit, and inspection paths must be obvious.
- Security operations needs a design they can monitor and explain.

## Fit

- Public sector or regulated workloads.
- Cloud-native applications that need inspected ingress and egress.
- Environments where audit, logging, and segmentation are design drivers.

## Expected Composition

- Core compartments, IAM, and tagging.
- Hub-spoke or regional hub networking.
- Network firewall or approved network appliance.
- Private DNS, service gateways, and private endpoints.
- Centralized logging, events, and monitoring.
- Vault, Cloud Guard, and Vulnerability Scanning.
- Optional OKE, API Gateway, WAF, and Bastion extensions.

## Deployment Notes

Deploy core first, then the selected networking inspection pattern, then this compliance
composition. Keep CIS Level 1 or Level 2 as a separate opt-in choice when the customer
explicitly requires it.

## Architecture

Detailed ASCII architecture notes live in `architecture/README.md`.
