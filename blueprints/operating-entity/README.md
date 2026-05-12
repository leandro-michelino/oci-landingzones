# Operating Entity Deployment

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this deployment to onboard a business unit, subsidiary, application team, or
workload owner into the landing zone.

## What It Does

This blueprint packages an operating entity into the landing zone: a business unit,
subsidiary, agency, application group, or workload owner with its own compartment shape,
delegated IAM, tags, budgets, logging assumptions, and optional network attachment.

## Why Use It

Use this when the real problem is ownership. It packages a business unit, application
group, or subsidiary into a clean OCI operating boundary with IAM, budgets, tags, and
optional network attachment.

## When To Use It

- A team needs its own cloud space but not its own tenancy.
- Delegated administration is required.
- Chargeback, ownership, and access boundaries matter.

## Pattern

- Operating entity compartment structure.
- Optional workload compartments.
- IAM groups and policies scoped to the entity.
- Tagging, budget, and logging assumptions.
- Optional networking attachment to an existing blueprint.

## Best Fit

- Multi-team landing zones.
- Business-unit onboarding.
- Customer environments with delegated administration.
- Repeatable workload onboarding.

## Inputs To Decide

- Operating entity name and short code.
- Parent compartment.
- Workload compartments.
- Entity administrators and auditors.
- Budget owner and alert recipients.
- Network attachment model.
- Required platform extensions.

## Deployment Flow

1. Deploy `blueprints/core`.
2. Choose or deploy the required networking blueprint.
3. Complete the local architecture diagram.
4. Populate local ignored tfvars.
5. Run Terraform validation and plan.
6. Apply after ownership, budget, and access scope are reviewed.

## Architecture Artifacts

- Source diagram: `architecture/operating-entity.excalidraw`
- Exported image: `architecture/operating-entity.png`
