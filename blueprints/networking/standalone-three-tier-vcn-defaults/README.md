# Standalone Three-Tier VCN Defaults

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this deployment when a team needs a simple internet-facing application VCN with
standard landing-zone defaults.

## What It Does

This blueprint is the simple internet-facing three-tier starter. It gives a team a
public web tier, private application and database tiers, NAT and service gateway paths,
and sane defaults for a normal app that does not need hub-spoke or custom routing yet.

## Why Use It

Use this for the classic web/app/database pattern when speed and sane defaults matter
more than bespoke network design. It is the clean starter VCN for normal internet-facing
apps.

## When To Use It

- The workload is simple or medium complexity.
- Internet ingress is required for a web tier.
- The customer does not yet need a hub-spoke or custom IP plan.

## Pattern

- One VCN.
- Public web tier with internet gateway access.
- Private application tier.
- Private database tier.
- NAT gateway for private outbound access.
- Service gateway for private OCI service access.
- Default route tables, security lists or NSGs, and DNS labels.

## Best Fit

- Small or medium workloads.
- Proofs of concept that should still follow a clean baseline.
- Internet-facing web applications with private application and data tiers.
- Teams that do not need custom CIDR design yet.

## Inputs To Decide

- Parent compartment from `blueprints/core`.
- Workload compartment target.
- VCN CIDR block.
- Public web subnet CIDR.
- Private application subnet CIDR.
- Private database subnet CIDR.
- Allowed ingress sources for web traffic.
- Egress policy for private tiers.

## Deployment Flow

1. Deploy `blueprints/core`.
2. Review `architecture/README.md` and complete the architecture diagram.
3. Copy `terraform.tfvars.example` to a local ignored tfvars file.
4. Run `terraform init`, `terraform validate`, and `terraform plan`.
5. Apply only after the plan matches the expected topology.

## Architecture Artifacts

- Source diagram: `architecture/standalone-three-tier-vcn-defaults.excalidraw`
- Exported image: `architecture/standalone-three-tier-vcn-defaults.png`

## Notes

This is the default internet-only three-tier deployment. For customer-specific CIDRs,
use `standalone-three-tier-vcn-custom`. For private-only workloads, use
`standalone-private-endpoint-only`.
