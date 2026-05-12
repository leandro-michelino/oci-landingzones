# CIS Level 2 Landing Zone Blueprint

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This blueprint is the opt-in CIS Level 2 landing zone profile. Use this folder when a
deployment should explicitly target stricter CIS OCI Benchmark Level 2 behavior.

The general landing zone blueprints do not enable CIS behavior by default. This folder
fixes the intended profile to `level2`, composes the implemented core/IAM foundation,
and will keep adding stricter Level 2 security, governance, and networking defaults as
those modules mature.

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

> [DIAGRAM REQUIRED] `architecture/cis-level2.excalidraw`
>
> Status: TODO - create this diagram before using the blueprint for a production
> customer review.

## Profile

```hcl
cis_level = "level2"
```

## Scope

- Level 1 baseline controls.
- Stricter privilege separation.
- CIS profile passed into child modules for stricter defaults.
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
- Planned next: stronger break-glass posture, private-first networking,
  inspected egress, and stricter governance controls.
