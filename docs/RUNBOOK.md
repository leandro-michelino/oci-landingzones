# Runbook

Operational procedures will be expanded as Terraform modules are implemented.

## Add A New Operating Entity

1. Confirm the core landing zone is deployed.
2. Confirm a networking blueprint is deployed and its outputs are available.
3. Create or update `docs/architecture/diagrams/06-operating-entity.excalidraw`.
4. Prepare operating entity variables:
   - `oe_name`
   - `cost_center`
   - `owner`
   - `hub_vcn_id`
   - `drg_id`
5. Run `terraform plan` from `blueprints/operating-entity/`.
6. Review compartments, IAM policy scope, budget, and logging outputs.
7. Apply after approval.

## Rotate Terraform Credentials

1. Create replacement OCI API key material.
2. Update the CI/CD secret store.
3. Validate `terraform plan` on a non-production environment.
4. Remove the old API key from OCI IAM.
5. Record the rotation date in the operational log.

## Extend Budgets

1. Confirm the budget owner and cost center.
2. Update the relevant environment variable file.
3. Run `terraform plan`.
4. Confirm notification recipients.
5. Apply after finance or platform owner approval.

## Respond To Critical Cloud Guard Findings

1. Capture finding ID, target compartment, resource OCID, and detector rule.
2. Confirm whether the resource is managed by Terraform.
3. If Terraform-managed, patch the module or blueprint instead of editing OCI
   resources manually.
4. Run plan and review blast radius.
5. Apply remediation and confirm the finding is closed or suppressed with a
   documented reason.
