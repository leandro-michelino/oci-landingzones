# Workload Vending Blueprint

This blueprint is for repeatable application-team onboarding where the platform team
vends a standard compartment, IAM scope, budget, tags, and network attachment.

## What It Does

This blueprint turns workload onboarding into a repeatable platform product. It vends
the standard package an app team needs: compartment, IAM scope, tags, budget, logging,
quota expectations, and the right network attachment.

## Why Use It

Use this when app teams keep asking for cloud space and you want the answer to be a
standard product, not a custom mini-project every time. It is the vending-machine
pattern for compartments and guardrails.

## When To Use It

- New workloads are onboarded frequently.
- Platform teams need a repeatable handoff package.
- Each app team needs compartments, IAM, budget, tags, and network attachment.

## Fit

- Application teams need isolated landing zones.
- Platform teams need repeatable onboarding.
- Network and security controls are shared but workload ownership is delegated.

## Expected Composition

- Workload compartment hierarchy.
- Workload admin, deployer, and reader groups.
- Optional spoke VCN or existing VCN attachment.
- Budget, quota, logging, and event defaults.
- Standard tags and ownership metadata.

## Deployment Notes

Use this repeatedly after core and the selected network foundation are in place. It
should become the day-two onboarding workflow for new workloads.
