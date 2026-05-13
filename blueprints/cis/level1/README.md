# CIS Level 1 Landing Zone Blueprint

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This blueprint is the opt-in CIS Level 1 landing zone profile. Use this folder when a
deployment should explicitly target CIS OCI Benchmark Level 1 behavior.

The general landing zone blueprints do not enable CIS behavior by default. This folder
fixes the intended profile to `level1`, composes the implemented core/IAM foundation,
and enables the Level 1 governance, audit, Cloud Guard, Events, and optional security
controls exposed by the current modules.

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

Architecture notes live in `architecture/README.md`.

## Profile

```hcl
cis_level = "level1"
```

## Scope

- Baseline compartment hierarchy.
- Least-privilege IAM foundation.
- Governance tagging baseline.
- Governance logging groups and tenancy audit retention.
- Cloud Guard enabled with a default landing zone target.
- Optional Vault/KMS and Security Zones when key and recipe decisions are
  approved.
- Optional VSS and Monitoring alarms when scan scope and notification
  destinations are approved.
- Governance Events enabled with default IAM change rules and a default
  notification topic.
- Optional CIS budget creation when `budget_amount` or custom `budgets` are
  supplied.
- CIS profile passed into child modules for control differences.
- Network-specific defaults are selected through the networking blueprint that
  accompanies this profile.
