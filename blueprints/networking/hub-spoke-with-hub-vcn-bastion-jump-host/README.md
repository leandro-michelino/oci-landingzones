# Hub-Spoke With Bastion Jump Host

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this deployment when administrators need controlled private access to hub and spoke
resources without exposing workload hosts directly to the internet.

## What It Does

This blueprint centralizes administrative access through a hub-based bastion or
jump-host path. It keeps admin source ranges, target spokes, route behavior, session logging,
and hardening responsibilities visible instead of scattering SSH or RDP rules across
workloads.

## Why Use It

Use this when administrators need private access but the customer is not ready for a
more polished access pattern. It centralizes the admin door instead of leaving SSH or
RDP scattered around the estate.

## When To Use It

- Private admin access is required quickly.
- OCI Bastion or a jump host is part of the approved model.
- Workload hosts should not expose admin ports directly.

## Pattern

- Hub VCN.
- Bastion or jump-host subnet.
- Spoke VCN attachments.
- Private administrative routes.
- Optional public ingress only to the bastion layer.
- Security rules limiting administrative protocols and sources.

## Best Fit

- Early landing-zone deployments that need admin access quickly.
- Customers not yet ready for a full private access service.
- Workloads where SSH or RDP access must be centralized and audited.

## Inputs To Decide

- Bastion model: OCI Bastion service or compute jump host.
- Allowed administrator source CIDRs.
- Target spoke VCNs and subnets.
- SSH or RDP access rules.
- Logging and session audit expectations.

## Deployment Flow

1. Deploy `blueprints/core`.
2. Complete the architecture diagram with admin paths.
3. Confirm allowed administrator networks.
4. Populate local tfvars.
5. Run Terraform validation and plan.
6. Apply after access controls are reviewed.

## Architecture Artifacts

- Source diagram: `architecture/hub-spoke-with-hub-vcn-bastion-jump-host.excalidraw`
- Exported image: `architecture/hub-spoke-with-hub-vcn-bastion-jump-host.png`

## Notes

Prefer OCI Bastion when possible. If a compute jump host is required, document patching,
hardening, and lifecycle ownership in this folder.
