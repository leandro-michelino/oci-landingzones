# CIS Level 2 Landing Zone Blueprint

This blueprint is the opt-in CIS Level 2 landing zone profile. Use this folder when a
deployment should explicitly target stricter CIS OCI Benchmark Level 2 behavior.

The general landing zone blueprints do not enable CIS behavior by default. This folder
fixes the intended profile to `level2` and will compose the core, security, governance,
and networking modules with stricter Level 2 defaults as the implementation matures.

## What It Does

This is the stricter CIS path, intentionally kept out of the default flow. It adds
stronger separation, tighter governance, private-first thinking, and more operational
discipline for customers that really need the higher-control posture.

## Why Use It

Use Level 2 when the customer really means high security. This is the stricter path for
regulated, sensitive, or heavily audited environments where convenience takes second
place to control.

## When To Use It

- The workload is regulated or highly sensitive.
- Private-first networking and inspected egress are preferred.
- The customer accepts stronger separation, tighter IAM, and more operational friction.

## Use Cases

- Regulated or high-security environments with stronger control expectations.
- Customers that need stricter break-glass, credential, and network posture.
- Landing zones where private-only access and inspected egress are preferred.
- Projects that must show which resources are intended to support CIS Level 2.

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
