# Runbook

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this runbook for local repository operations and common landing-zone change
flows. Pattern-specific design checks live in each blueprint's local
`architecture/README.md`.

## Validate The Repository

1. Confirm the working tree only contains intended changes.
2. Run `./scripts/validate-all.sh` from the repository root.
3. Fix any repository contract guard failures before investigating slower
   Terraform or Ansible failures.
4. Review Terraform fmt/init/validate output for failed blueprint directories.
5. Review Ansible syntax-check output for shared and blueprint-local playbooks.
6. Confirm generated artifacts were cleaned:
   - `.terraform/`
   - `.terraform.lock.hcl`
   - `terraform.tfstate*`
   - `tfplan` and `*.tfplan`
   - `.DS_Store`
7. Re-run validation after fixing any Terraform, Ansible, README, or ASCII
   architecture contract failures.

## Review The Whole Project

Use this when doing a repository hygiene pass rather than a single blueprint
change.

1. Run `./scripts/check-repo-contracts.sh` to catch missing blueprint files,
   forbidden repeated documentation fragments, and local Ansible runner drift.
2. Confirm no generated artifacts are present with `git status --short` and the
   cleanup patterns in [Clean Generated Files](#clean-generated-files).
3. Search for stale markers before committing:

   ```bash
   rg -n 'T(O)DO|F(I)XME|X(X)X|scaff[o]ld|placeh[o]lder|source\s*=\s*"\.\.?' . \
     --glob "!RELEASE-NOTES.md" \
     --glob "!docs/DEPLOYMENT-GUIDE.md" \
     --glob "!ansible/roles/validation/tasks/main.yml"
   ```

4. Review any broad network defaults such as `0.0.0.0/0` against the blueprint
   purpose. Public web-tier examples may intentionally allow HTTP/HTTPS, but
   administrative access should use specific CIDRs.
5. Run `./scripts/validate-all.sh` for Terraform fmt/init/validate and Ansible
   syntax checks across every deployable blueprint. The validation playbook is
   intentionally not part of its own syntax-check loop; it is parsed at the
   start of the run, which avoids recursive Ansible execution. Terraform
   init/validate and Ansible syntax checks are driven directly by
   `scripts/validate-all.sh`; set `VALIDATE_ALL_ANSIBLE_ROLE=1` only when
   deliberately testing the validation role itself.

### Terraform Registry TLS Behind Corporate Proxies

Prefer installing the corporate root CA so Terraform can verify
`registry.terraform.io` normally. If a managed proxy presents a legacy
Common Name-only certificate and Terraform fails with an `x509` standards
compliance error, use the explicit compatibility switch:

```bash
TERRAFORM_ALLOW_LEGACY_X509_CN=true ./scripts/validate-all.sh
```

The same switch is honored by the Ansible Terraform runner for
plan/apply/destroy. It sets `GODEBUG=x509ignoreCN=0` only for Terraform
commands launched through the repository scripts or Ansible roles.

## Add Or Change A Blueprint

1. Create or update the deployable Terraform files in the blueprint folder.
2. Keep `terraform.tfvars.example` safe: no real OCIDs, secrets, email
   addresses, or customer-specific values.
3. Update the blueprint `README.md` with purpose, inputs, outputs, workflow,
   validation, and review notes.
4. Update `architecture/README.md` with a detailed ASCII diagram, Terraform
   components, deployment flow, architecture notes, and review checklist.
5. Add or update local `ansible/plan.yml`, `ansible/apply.yml`, and
   `ansible/destroy.yml` when the blueprint is deployable.
6. Run `./scripts/check-repo-contracts.sh` for a fast contract check.
7. Run `./scripts/validate-all.sh`.
8. Update `docs/DEPLOYMENT-PATTERN-CATALOG.md` and the root `README.md` when
   the blueprint should be visible in the deployment menu.

## Clean Generated Files

1. Prefer `./scripts/validate-all.sh`; it removes generated artifacts on exit.
2. For manual cleanup, run:

   ```bash
   find . -name ".terraform" -type d -prune -exec rm -rf {} +
   find . -name ".terraform.lock.hcl" -type f -delete
   find . -name "terraform.tfstate*" -type f -delete
   find . -name "tfplan*" -type f -delete
   find . -name ".DS_Store" -type f -delete
   ```

3. Confirm `git status --short` does not show generated local artifacts.

## Add A New Operating Entity

1. Confirm the core landing zone is deployed.
2. Confirm the required networking blueprint is deployed if this entity needs a
   network attachment.
3. Create or update the local architecture notes in
   `blueprints/operating-entity/architecture/README.md`.
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
