# Workload Vending Blueprint

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This blueprint is for repeatable application-team onboarding where the platform team
vends a standard compartment, IAM scope, budget, tags, and network attachment.

## What It Does

This blueprint turns workload onboarding into a repeatable platform product. It vends
the standard package an app team needs: workload compartments, delegated IAM scope, and
ownership tags.

It creates the deployable core of that package: one workload root compartment,
child compartments for app/data/ops by default, admin/operator/auditor groups,
and policies scoped to those compartment paths. Budget, logging, quota, and
network attachment expectations are documented as part of the handoff model but
are not created directly by this blueprint.

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

## Implemented Composition

- Workload compartment hierarchy.
- Workload admin, operator, and auditor groups.
- Workload-scoped manage, use, and read policies.
- Standard tags and ownership metadata.
- Documented hooks for a spoke VCN, existing VCN attachment, budget, quota, logging, and
  event defaults.

## Deployment Notes

Use this repeatedly after core and the selected network foundation are in place. It
should become the day-two onboarding workflow for new workloads.

This is the one to reach for when the platform team wants a clean answer to "Can my app
team have a place to build?" without turning every request into a custom Terraform
project.

## Terraform Example

```bash
terraform init
terraform validate
terraform plan -var-file=terraform.tfvars
```
