# Runbook

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Operational procedures will be expanded as Terraform modules are implemented.

## Add A New Operating Entity

1. Confirm the core landing zone is deployed.
2. Confirm the required networking blueprint is deployed if this entity needs a
   network attachment.
3. Create or update the local diagram in
   `blueprints/operating-entity/architecture/`.
4. Prepare operating entity variables:
   - `entity_code`
   - `entity_name`
   - `parent_compartment_ocid`
   - `workload_compartments`
   - `admin_group_name`
   - `auditor_group_name`
   - `defined_tags`
   - `freeform_tags`
5. Run `terraform plan` from `blueprints/operating-entity/`.
6. Review compartments, delegated groups, IAM policy scope, and tag outputs.
7. Apply after approval.

## Rotate Terraform Credentials

1. Create replacement OCI API key material.
2. Update the local or approved external secret store.
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
