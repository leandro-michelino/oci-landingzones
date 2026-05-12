# CIS Level 1 Landing Zone Blueprint

This blueprint is the opt-in CIS Level 1 landing zone profile. Use this folder
when a deployment should explicitly target CIS OCI Benchmark Level 1 behavior.

The general landing zone blueprints do not enable CIS behavior by default. This
folder fixes the intended profile to `level1` and will compose the core,
security, governance, and networking modules with Level 1 defaults as the
implementation matures.

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

