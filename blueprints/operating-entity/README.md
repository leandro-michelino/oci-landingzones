# Operating Entity Deployment

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this deployment to onboard a business unit, subsidiary, application team, or
workload owner into the landing zone.

## What It Does

This blueprint packages an operating entity into the landing zone: a business unit,
subsidiary, agency, application group, or workload owner with its own compartment
shape and delegated IAM.

It creates the practical foundation: one root compartment, child workload
compartments, admin and auditor groups, scoped IAM policies, and ownership tags.
Budget, logging, quota, and network attachment are documented operating-model
hooks; this blueprint does not create those resources directly.

## Why Use It

Use this when the real problem is ownership. It packages a business unit, application
group, or subsidiary into a clean OCI operating boundary with IAM, budgets, tags, and
optional network attachment.

## When To Use It

- A team needs its own cloud space but not its own tenancy.
- Delegated administration is required.
- Chargeback, ownership, and access boundaries matter.

## Pattern

- Operating entity root compartment.
- Optional workload child compartments.
- Delegated admin and auditor groups.
- IAM policies scoped to the entity root and child compartment paths.
- Defined and freeform tags for ownership and chargeback metadata.
- Documented budget, logging, quota, and network attachment handoff assumptions.

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
3. Complete or update the local architecture diagram.
4. Populate a local ignored `terraform.tfvars`.
5. Run Terraform validation and plan.
6. Apply after ownership and access scope are reviewed.

## Terraform Example

```bash
terraform init
terraform validate
terraform plan -var-file=terraform.tfvars
```

Keep real OCIDs, customer names, and test compartment values in local ignored files.
The committed `terraform.tfvars.example` is only a starter shape.

## Architecture Artifacts

- Source diagram: `architecture/operating-entity.excalidraw`
- Exported image: generate a PNG from the source only when a rendered review artifact is needed.
