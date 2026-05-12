# CIS Level 1 Landing Zone Blueprint

This blueprint is the opt-in CIS Level 1 landing zone profile. Use this folder when a
deployment should explicitly target CIS OCI Benchmark Level 1 behavior.

The general landing zone blueprints do not enable CIS behavior by default. This folder
fixes the intended profile to `level1` and will compose the core, security, governance,
and networking modules with Level 1 defaults as the implementation matures.

## What It Does

This is the friendly CIS Level 1 starting point. It keeps the normal landing zone
flexible, but gives security teams a clear optional folder for baseline controls: IAM
separation, required tags, auditability, safer network defaults, and the evidence trail
people usually ask for in the first security review.

## Why Use It

Use Level 1 when the customer wants a sensible CIS-aligned baseline without turning
every control up to maximum strictness. It is the practical enterprise default when
security wants structure but the platform still needs to move.

## When To Use It

- Security asks for CIS alignment from day one.
- The environment is production or production-like.
- The customer wants guardrails, auditability, and safer network defaults without the
  stricter Level 2 posture.

## Use Cases

- Customers that need a recognizable CIS baseline without the strictest profile.
- Enterprise landing zones where security wants standard guardrails from day one.
- Production foundations that need audit, tagging, IAM separation, and safe network
  defaults.
- Projects that must show which resources are intended to support CIS Level 1.

> [DIAGRAM REQUIRED] `docs/architecture/diagrams/09-cis-level1.excalidraw`
>
> Status: TODO - scaffold files may exist now; create this diagram before adding
> real OCI resources or applying Terraform.

## Profile

```hcl
cis_level = "level1"
```

## Scope

- Baseline compartment hierarchy.
- Least-privilege IAM foundation.
- Cloud Guard and detector recipe baseline.
- Audit, service, and network logging baseline.
- Required tagging, budgets, and monitoring baseline.
- Networking defaults that avoid broad internet ingress.
