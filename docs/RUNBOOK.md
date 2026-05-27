# Runbook

Use this runbook for local repository operations and common landing-zone change
flows. Pattern-specific design checks live in each blueprint's local
`architecture/README.md`.

## Validate The Repository

1. Confirm the working tree only contains intended changes.
2. Run `./scripts/validate-changed.sh` for a focused iteration check.
3. Run `./scripts/validate-all.sh` from the repository root before broad
   refactors, release cuts, or final merge/push when shared behavior changed.
4. Fix any repository contract guard failures before investigating slower
   Terraform or Ansible failures.
5. Review Terraform fmt/init/validate output for failed blueprint directories.
6. Review Ansible syntax-check output for shared and blueprint-local playbooks.
7. Confirm generated artifacts are either intentionally retained for local
   Terraform speed or cleaned when required:
   - `.terraform/`
   - `.terraform.lock.hcl`
   - `terraform.tfstate*`
   - `tfplan` and `*.tfplan`
   - `.DS_Store`
8. Re-run validation after fixing any Terraform, Ansible, README, or Architecture
   architecture contract failures.

## Validate Only Changed Work

Use this while iterating on a small architecture, blueprint, module, or local
Ansible runner:

```bash
./scripts/validate-changed.sh
```

The changed-scope validator compares committed, staged, unstaged, and untracked
files against `origin/main`, then maps changed files to the nearest deployable
Terraform root. It always runs `scripts/check-repo-contracts.sh`, but only runs
Terraform `fmt/init/validate`, blueprint-local Ansible syntax checks, and
TFLint for the touched roots.

To compare against another branch or commit:

```bash
./scripts/validate-changed.sh --base main
VALIDATE_CHANGED_BASE=origin/release ./scripts/validate-changed.sh
```

Escalate to `./scripts/validate-all.sh` when shared modules, shared Ansible
roles, validation scripts, scanner configs, or repo-wide docs changed enough
that a focused check would miss the blast radius.

## Ephemeral Networking Tests (OCI, Azure, AWS)

Use this when networking components should be created for testing and released
immediately afterward.

```bash
scripts/test-networking-lifecycle.sh \
  --blueprint blueprints/networking/aws-oci-hybrid-network-backbone \
  --providers oci,aws
```

Run against all networking blueprints (careful: this can create many resources):

```bash
scripts/test-networking-lifecycle.sh --all-networking --providers oci
```

Behavior:
- Runs `plan -> apply -> destroy` per provider lifecycle playbooks.
- Always attempts provider destroy after apply attempts.
- Uses explicit confirmation env vars internally (`CONFIRM_*`).

## Ephemeral Industry Tests

Use this when an industry blueprint needs a real OCI check without turning on
every expensive or quota-sensitive service.

Recommended low-cost paths:
- Secure Desktops: keep `create_desktop_pool = false` and validate monitoring
  alarms or IAM policy wiring before creating desktop pools.
- Telco Cloud Native: validate the hub-spoke network foundation first, then
  enable Vault, OKE, monitoring, and OS Management only after quota and owner
  review.

Checklist:
1. Create a temporary compartment or an explicitly approved test compartment.
2. Keep local `terraform.tfvars` ignored.
3. Run `terraform init`, `terraform validate`, and `terraform plan`.
4. Apply the staged path.
5. Read back the key resources with OCI CLI, such as VCNs, subnets, DRGs,
   alarms, policies, or service-specific outputs.
6. Run a second `terraform plan -detailed-exitcode` to check drift.
7. Destroy disposable resources and verify the compartment or test scope is
   clean.

## Multicloud E2E Evidence

Use this checklist for real Azure/AWS/OCI E2E runs that create disposable cloud
resources.

Capture:
- Cloud account, subscription, tenancy profile, and AWS profile used.
- Regions, Kubernetes/database/model versions, and selected instance classes.
- Resource group, stack, and Terraform name prefixes.
- Public URLs, private endpoints, generated commands, and output contract IDs.
- Direct endpoint test result for each cloud side.
- DNS, Traffic Management, or GSLB FQDN results where the blueprint owns DNS.
- Failover/failback timing, RTO/RPO comparison, and known caveats.
- Explicit destroy confirmation and post-destroy validation.

Known E2E findings:
- AKS + OKE active/passive and EKS + OKE active/passive were previously tested
  with temporary resources and destroyed after validation.
- Azure Container Apps can fail with regional AKS capacity errors; destroy the
  failed resource group and retry in another approved region.
- OCI API Gateway HTTP backend URLs should not include query strings. Put API
  version parameters on client/sample requests.
- AWS DR EC2 bootstrap needs outbound HTTPS and a reachable public path during
  first boot when using the included hello-world test.
- AWS RDS MySQL E2E may need `DbBackupRetentionPeriod=0` and
  `DbPerformanceInsightsEnabled=false` for small/free-tier-compatible instance
  classes. Keep `DbDeletionProtection=true` for long-lived environments and set
  it to `false` only for disposable E2E stacks.

## Simulate Azure And AWS Wrappers

Use this before real cloud-side plan sessions, or whenever shared Azure/AWS
runner behavior changes:

```bash
./scripts/simulate-cloud-deployments.sh
```

The helper discovers every `ansible/azure-plan.yml` and `ansible/aws-plan.yml`
under `blueprints/`, syntax-checks each provider-specific plan/apply/destroy
playbook, then runs the plan wrapper with simulation enabled. Simulation checks
template and parameter paths and exits before any `az` or `aws` command.

Real provider plans still use the normal wrappers:

```bash
ansible-playbook -i localhost, ansible/azure-plan.yml
ansible-playbook -i localhost, ansible/aws-plan.yml
```

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
4. Update `architecture/README.md` with a detailed Architecture diagram, Terraform
   components, deployment flow, architecture notes, and review checklist.
5. Add or update local `ansible/plan.yml`, `ansible/apply.yml`, and
   `ansible/destroy.yml` when the blueprint is deployable.
6. Run `./scripts/validate-changed.sh` for a focused contract, Terraform, and
   Ansible check.
7. Run `./scripts/validate-all.sh` before final release or when shared
   behavior changed.
8. Update `docs/DEPLOYMENT-PATTERN-CATALOG.md`, `docs/ROADMAP.md`,
   `docs/DEPLOYMENT-GUIDE.md`, `VARIABLES.md`, `RELEASE-NOTES.md`, and the
   root `README.md` when the blueprint should be visible in the deployment
   menu or introduces new operator-facing inputs.

## Read Terraform And Ansible Outputs Clearly

Use the following output categories consistently in blueprint operations:

1. `blueprint_name`:
Treat as the stable deployment identifier for reports and automation.
2. `name_prefix`:
Use for deterministic naming across follow-on resources and scripts.
3. `resource_ids`:
Treat as the machine-readable hand-off map for integration, import, and cleanup.
4. `*_contract` outputs:
Use these as runbook contracts (connectivity, routing, failover, traffic, or GitOps intent).
5. provider-runner summaries:
AWS and Azure runners now emit explicit plan/apply/destroy summaries and JSON outputs so operators can capture results without parsing raw CLI output.

## Plan Extension Adoption

Use this when a customer asks whether they can consume only an extension or
should deploy the full base first.

1. Choose extension-only when compartments, IAM boundaries, VCNs, subnets, NSGs,
   service dependencies, and policy ownership already exist outside this repo.
2. Choose base-plus-extension when this repo should create the shared
   governance, networking, ownership, and operations foundation before the
   add-on service.
3. For extension-only, sparse-checkout the extension folder, add
   `ansible/roles/terraform_runner` only when local Ansible runners are needed,
   and populate local tfvars with existing OCIDs and service values.
4. For base-plus-extension, deploy Core or CIS, Networking, optional Operating
   Entity or Workload Vending, optional Operations, then pass reviewed outputs
   into the extension tfvars.
5. Review the extension `architecture/README.md` before apply so trust
   boundaries, public exposure, IAM statements, DNS, certificates, image tags,
   and event triggers are intentional.
6. Keep remote state and cross-blueprint output wiring in the customer pipeline
   or environment layer, not as committed local tfvars.

## Clean Generated Files

1. Validation keeps local `.terraform/` and `.terraform.lock.hcl` by default
   for faster reruns. Force cleanup when required:

   ```bash
   VALIDATION_CLEAN_TERRAFORM_WORKDIRS=1 ./scripts/validate-all.sh
   VALIDATION_CLEAN_TERRAFORM_WORKDIRS=1 ./scripts/validate-changed.sh
   ```
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

1. Confirm the core landing zone is available.
2. Confirm the required networking blueprint is available if this entity needs a
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
