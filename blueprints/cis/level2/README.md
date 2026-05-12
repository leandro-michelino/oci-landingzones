# CIS Level 2 Landing Zone Blueprint

This blueprint is the opt-in CIS Level 2 landing zone profile. Use this folder
when a deployment should explicitly target stricter CIS OCI Benchmark Level 2
behavior.

The general landing zone blueprints do not enable CIS behavior by default. This
folder fixes the intended profile to `level2` and will compose the core,
security, governance, and networking modules with stricter Level 2 defaults as
the implementation matures.

> [DIAGRAM REQUIRED] `docs/architecture/diagrams/09-cis-level2.excalidraw`
>
> Status: TODO - scaffold files may exist now; create this diagram before adding
> real OCI resources or applying Terraform.

## Profile

```hcl
cis_level = "level2"
```

## Scope

- Level 1 baseline controls.
- Stricter privilege separation.
- Stronger break-glass and credential posture.
- Private-first networking and inspected-egress defaults where applicable.
- Expanded alerting and monitoring expectations.
- Stricter logging and governance posture for regulated environments.

