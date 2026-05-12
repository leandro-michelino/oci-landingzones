# Standalone Private Endpoint Only

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this deployment when workloads should have no direct internet exposure and only
communicate through private endpoints or private connectivity.

## What It Does

This blueprint creates a private-only workload network. It avoids public subnets and
internet ingress, then uses private endpoints, service gateways, private connectivity,
optional controlled egress, and DNS planning to keep the workload reachable only through
approved paths.

## Why Use It

Use this when public ingress is not part of the story. This is for private workloads
that talk through private endpoints, service gateways, VPN, FastConnect, or a shared
hub.

## When To Use It

- The workload is internal-only.
- Regulated controls forbid direct internet exposure.
- Access comes from private connectivity or shared services.

## Pattern

- One private VCN.
- Private subnets only.
- No public subnet.
- No internet gateway.
- Optional NAT gateway for controlled outbound updates.
- Service gateway for OCI services.
- Private endpoints for supported platform services.

## Best Fit

- Internal applications.
- Regulated workloads.
- Private service access patterns.
- Environments where inbound access comes from VPN, FastConnect, Bastion, or a
  shared-services hub.

## Inputs To Decide

- VCN and private subnet CIDRs.
- Required private endpoints.
- Whether NAT egress is allowed.
- OCI service access requirements.
- Administrative access path.
- DNS resolution path.

## Deployment Flow

1. Deploy `blueprints/core`.
2. Complete the local architecture diagram.
3. Confirm there is no required public ingress.
4. Populate local tfvars.
5. Run Terraform validation and plan.
6. Apply after private access and DNS are reviewed.

## Architecture Artifacts

- Source diagram: `architecture/standalone-private-endpoint-only.excalidraw`
- Exported image: `architecture/standalone-private-endpoint-only.png`

## Notes

This is the private-only alternative to the internet-facing three-tier blueprints.
