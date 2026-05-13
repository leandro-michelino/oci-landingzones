# Deployment Guide

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This guide describes the intended deployment sequence. Every blueprint has real
Terraform wiring now; use the enable flags and tfvars examples to decide which
resources should be created in a specific tenancy.

## Phase 0 - Bootstrap

Bootstrap verifies local prerequisites and records the manual decisions needed
before a real `terraform apply`: OCI CLI access, tenancy context, remote state,
and secrets handling. Remote state provisioning remains a manual or
customer-specific step until the backend contract is finalized.

```bash
bash scripts/bootstrap.sh --org acme --env prod --region eu-frankfurt-1
oci iam tenancy get --tenancy-id "$TENANCY_OCID"
pre-commit install
```

`scripts/bootstrap.sh` delegates to `ansible/playbooks/bootstrap.yml` when
Ansible is available. The shell fallback only validates arguments and prints
the prerequisite checklist.

Local validation can create `.terraform/`, `.terraform.lock.hcl`, plans, and
state files in many blueprint folders. They are intentionally ignored and should
be removed from the workspace before committing.

Use the Ansible-backed validation entry point before commits:

```bash
./scripts/validate-all.sh
```

This auto-discovers Terraform blueprints under `blueprints/`,
validates them without a remote backend, runs Ansible syntax checks, and cleans
generated Terraform artifacts, plan files, and `.DS_Store` files even when a
validation step fails. Blueprint
folders with scaffold markers now fail validation, because every architecture is
expected to have real Terraform wiring. Blueprint-local Ansible playbooks are
syntax-checked for every
architecture folder. The Ansible role uses a local Terraform plugin cache and a
bounded timeout per Terraform command so repeated checks stay predictable.

The default Ansible plan artifact is `tfplan.tfplan`. It is ignored and removed
by validation cleanup, along with older `tfplan` artifacts from previous runs.

The generic landing zone deployment does not enable CIS behavior by default. To
deploy a CIS landing zone, start from one of the dedicated folders instead:

```bash
cd blueprints/cis/level1
# or
cd blueprints/cis/level2
```

Each deployable blueprint folder should be readable on its own. Review the local
`README.md` and `architecture/README.md` before planning or applying that
blueprint. The architecture README contains the canonical ASCII diagram for the
pattern and the review checklist for ownership, dependency, traffic, DNS, IAM,
logging, and monitoring assumptions.

Each blueprint folder also includes local Ansible runners:

```text
ansible/plan.yml
ansible/apply.yml
ansible/destroy.yml
```

These call the shared `ansible/roles/terraform_runner` role while setting
`terraform_working_dir` to the blueprint folder. Use `-i localhost,` when
running them directly from a blueprint:

```bash
ansible-playbook -i localhost, ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, ansible/apply.yml
CONFIRM_DESTROY=true ansible-playbook -i localhost, ansible/destroy.yml
```

Use `docs/DEPLOYMENT-PATTERN-CATALOG.md` as the selection menu before choosing
a blueprint. The catalog includes core, CIS, identity, operating entity,
networking, compliance, data platform, industry, and extension patterns.
The repository-level ASCII map lives in `docs/architecture/README.md`; use each
blueprint's local `architecture/README.md` for implementation and traffic-flow
review.

## Using A Single Blueprint

Blueprints are deployable Terraform entry points. Their module sources are
pinned Git sources, so each architecture folder can be copied or checked out by
itself and still fetch the shared modules from the repository release.

Use this path for customer work when the customer wants one outcome, such as a
hub-spoke deployment, and should not download or review the whole repository.

For Terraform-only use, sparse-checkout only the selected blueprint path:

```bash
git clone --filter=blob:none --sparse https://github.com/leandro-michelino/oci-landingzones.git
cd oci-landingzones

git sparse-checkout set blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns

cd blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns
cp terraform.tfvars.example terraform.tfvars
```

For blueprint-local Ansible runners, include the shared Terraform runner role
as the only extra path:

```bash
git clone --filter=blob:none --sparse https://github.com/leandro-michelino/oci-landingzones.git
cd oci-landingzones

git sparse-checkout set \
  blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns \
  ansible/roles/terraform_runner

cd blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns
cp terraform.tfvars.example terraform.tfvars
```

The checked-out working tree stays small:

```text
blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns/
|-- README.md
|-- architecture/README.md
|-- main.tf
|-- variables.tf
|-- outputs.tf
|-- providers.tf
|-- versions.tf
|-- terraform.tfvars.example
`-- ansible/
    |-- plan.yml
    |-- apply.yml
    `-- destroy.yml

ansible/roles/terraform_runner/   optional, only for Ansible plan/apply/destroy
```

After editing `terraform.tfvars` with real OCI values, run Terraform directly:

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

Or, when the sparse checkout includes `ansible/roles/terraform_runner`, run:

```bash
ansible-playbook -i localhost, ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, ansible/apply.yml
```

For review or CI checks that should not configure remote state, use
`terraform init -backend=false` before `terraform validate` or `terraform plan`.
For production use, configure state deliberately before apply.

Validation blocks local `../` Terraform module sources in deployable blueprints.
This keeps every blueprint portable for sparse-checkout customers.

When cutting a new repository release, update blueprint Git source refs to the
new release tag in the same commit that will be tagged. Avoid `?ref=main` for
customer-facing blueprints because it makes copied architecture folders change
under users without review.

## Phase 1 - Core Structure

Deploy the core blueprint first. The implemented foundation creates the landing
zone compartment structure and baseline governance tagging required by later
blueprints.

Architecture notes live in `blueprints/core/architecture/README.md`.

For ephemeral tests, set `parent_compartment_ocid` in a local ignored
`terraform.tfvars` file. Do not commit real tenancy or compartment OCIDs.
Set `home_region` to the tenancy home region for Identity operations when it
differs from the workload `region`.

OCI Identity tag deletes are asynchronous and can take several minutes per tag
definition after Terraform removes tag defaults. For fast ephemeral tests that
do not need defined tags, set `enable_tagging = false`. For tests that need tag
definitions but not tag defaults, set `enable_tag_defaults = false`.

Expected module order:

1. `iam/compartments`
2. `governance/tagging`
3. `governance/logging`
4. `security/cloud-guard`
5. `security/vault`
6. `security/security-zones`
7. `security/vss`
8. `governance/budgets`
9. `governance/events`
10. `operations/monitoring`
11. `iam/groups`
12. `iam/dynamic-groups`
13. `iam/policies`

Core creates audit, network, service, and security log groups by default in the
governance compartment. VCN flow logs, Object Storage logs, Load Balancer logs,
and other service logs are wired through `vcn_flow_logs` and `service_logs`
once the source resource OCIDs exist. Generic core keeps tenancy audit retention
opt-in because it is a tenancy-wide setting; CIS wrappers enable it by default.

Cloud Guard is also wired through core. Generic core keeps it disabled by
default because it manages tenancy-wide service configuration. CIS Level 1 and
Level 2 enable Cloud Guard by default and create a target for the landing zone
root compartment. Attach approved detector and responder recipes through
`cloud_guard_detector_recipe_ids` and `cloud_guard_responder_recipe_ids`.

Vault/KMS is wired through core but remains opt-in because key ownership,
protection mode, and rotation settings are customer decisions. Enable
`vault_enabled` for the default landing zone vault and key, or use `vaults` and
`vault_keys` for explicit definitions.

Security Zones are wired through core but remain opt-in because they enforce
hard guardrails on the protected compartment tree. Enable
`security_zones_enabled` only after approving the security recipe OCID or
display-name lookup used for the landing zone root compartment.

Vulnerability Scanning Service is wired through core but remains opt-in because
scan scope should be approved per environment. Enable `vss_enabled` to create
the default host scan recipe and target for the workloads compartment, or use
the host/container scan maps for explicit scope.

Governance budgets are wired through core but remain opt-in because each
environment needs approved spend thresholds and notification recipients. Enable
`enable_budgets` and set `default_budget_amount` for the default landing zone
budget, or use `budgets` for multiple compartment-specific budgets.

Governance Events and Notifications are wired through core. Generic core keeps
them disabled by default; CIS wrappers enable the default governance event topic
and IAM change rules by default. Add `event_subscriptions` from local ignored
tfvars so real email, HTTPS, or other endpoints are not committed.

Monitoring alarms are wired through core but remain opt-in because metric
queries and notification destinations are environment-specific. Add
`monitoring_subscriptions` and `monitoring_alarms` from local ignored tfvars
when alarms should notify platform teams.

## Phase 2 - IAM Foundation

The core IAM foundation creates landing zone administrator, network
administrator, security administrator, governance administrator, workload
administrator, and auditor groups. Default policies are scoped to the generated
landing zone compartment paths and can be overridden or extended with
`iam_policies`.

Tenancies with many existing groups or dynamic groups may hit OCI Identity
service limits during test deployments. In those cases, disable only the
quota-constrained defaults in local ignored test variable files:
`enable_default_iam_groups = false`,
`enable_default_dynamic_groups = false`, or
`enable_default_iam_policies = false`.

Implemented module order:

1. `iam/groups`
2. `iam/dynamic-groups`
3. `iam/policies`

## Phase 3 - Networking

Choose one networking blueprint and deploy it after core.
Each networking deployment folder has a local README and `architecture/` folder
with the expected ASCII architecture notes and review artifact guidance.

Networking blueprints can also be used directly against an existing workload
compartment. In that mode, set `compartment_ocid` to the target compartment.
The blueprint's pinned Git module sources fetch the required networking modules
during `terraform init`.

Each networking blueprint keeps its diagram scope and update guidance in its
local `architecture/` folder.

## Phase 4 - Operating Entities

Use operating entity blueprints when the main question is ownership: who can
administer the environment, where workloads live, and how access stays scoped.

Available Phase 4 blueprints:

- `blueprints/operating-entity/` creates one operating entity root compartment,
  child workload compartments, admin and auditor groups, and scoped IAM policies.
- `blueprints/operating-entity/multi-operating-entities/` repeats that pattern
  for several business units, subsidiaries, agencies, or major portfolios.
- `blueprints/operating-entity/workload-vending/` vends a standard app-team
  package with workload compartments, admin/operator/auditor groups, and scoped
  manage/use/read policies.

These blueprints are intentionally focused on compartments, delegated IAM, and
ownership metadata first. Budgets, logging, events, quotas, and network
attachments are the next governance/security layers, so keep those assumptions
visible in the local README and architecture notes.

Architecture notes live in each operating-entity blueprint's
`architecture/README.md`.

## Implemented Blueprint Wiring Check

| Phase | Terraform Entry Points | Ansible Coverage |
|---|---|---|
| Phase 1 - Core | `blueprints/core/` | `validate.yml` runs fmt/init/validate and cleanup through Ansible. |
| Phase 2 - IAM | Reusable IAM modules composed by `blueprints/core/` and CIS wrappers | Covered through core, CIS Level 1, and CIS Level 2 validation. |
| Phase 3 - Networking | All implemented folders under `blueprints/networking/` | Each implemented networking blueprint is initialized and validated without backend. |
| Phase 4 - Operating entities | `blueprints/operating-entity/` and child onboarding patterns | Single entity, multi-entity, and workload vending are initialized and validated without backend. |
| Phase 5 - Extensions | `blueprints/extensions/oke`, `apigw`, `streaming`, `waf`, `exadata`, `observability`, `oic`, `oac`, and `oke-service-mesh` | Each extension blueprint is initialized and validated without backend. |
| Phase 6 - Data, AI, DevOps, and regulated services | `blueprints/data-platform/autonomous-database`, `blueprints/ai/genai-private`, `blueprints/devops/oci-devops-pipeline`, and `blueprints/compliance/healthcare-pci` | Service-specific blueprints are initialized and validated without backend. |

Identity, compliance, data platform, disaster recovery, and industry folders are
now included in automated Terraform validation with the rest of the blueprint
catalog.

## Phase 5 - Extensions

Deploy extensions only after core and the required networking foundation exist.
Each extension must include its own architecture notes.

Implemented Phase 5 extension entry points:

- `blueprints/extensions/oke/` creates an optional OKE cluster and optional node
  pool. Both are disabled by default.
- `blueprints/extensions/apigw/` creates an optional API Gateway and optional
  deployment with routes. Both are disabled by default.
- `blueprints/extensions/streaming/` creates an optional stream pool and streams.
  Creation is disabled by default.
- `blueprints/extensions/waf/` creates an optional WAF policy and optional web
  application firewall attachment to a load balancer. Both are disabled by
  default.
- `blueprints/extensions/exadata/` creates optional Exadata Cloud Infrastructure.
  Creation is disabled by default because it is high-cost and quota-sensitive.
- `blueprints/extensions/observability/` creates optional Log Analytics, APM,
  and Operations Insights private endpoint foundations.
- `blueprints/extensions/oic/` creates optional Oracle Integration Cloud and
  private outbound connectivity.
- `blueprints/extensions/oac/` creates optional Oracle Analytics Cloud and a
  private access channel.
- `blueprints/extensions/oke-service-mesh/` creates an optional OKE service mesh
  add-on shell and optional APM tracing domain.

Additional service blueprints now cover Autonomous Database, OCI Generative AI,
OCI DevOps, and Healthcare / PCI guardrails. They follow the same local README,
ASCII architecture, Terraform, tfvars, and Ansible runner contract.

Keep real subnet, VCN, load balancer, availability domain, image, and SSH values
in local ignored tfvars files. The committed examples show the shape only.

## Phase 6 - Ansible Orchestration

Ansible is the local orchestration layer for bootstrap checks, repository
validation, Terraform plan, guarded apply, guarded destroy, and ephemeral test
deployments. Terraform remains the source of truth for OCI resources.

Use plan for non-destructive checks. It initializes without a backend by
default. If the selected inventory's `terraform_environment_dir` contains a
local `terraform.tfvars`, Ansible passes that file to `terraform plan`; the
committed `terraform.tfvars.example` files are templates only:

```bash
ANSIBLE_CONFIG=ansible/ansible.cfg \
  ansible-playbook -i ansible/inventories/dev/hosts.yml \
  ansible/playbooks/terraform-plan.yml \
  -e "terraform_working_dir=$PWD/blueprints/core"
```

Apply is guarded. It requires an explicit confirmation and production applies
are blocked from Ansible for now:

```bash
CONFIRM_APPLY=true \
ANSIBLE_CONFIG=ansible/ansible.cfg \
  ansible-playbook -i ansible/inventories/dev/hosts.yml \
  ansible/playbooks/terraform-apply.yml \
  -e "terraform_working_dir=$PWD/blueprints/core"
```

Destroy is also guarded:

```bash
CONFIRM_DESTROY=true \
ANSIBLE_CONFIG=ansible/ansible.cfg \
  ansible-playbook -i ansible/inventories/dev/hosts.yml \
  ansible/playbooks/terraform-destroy.yml \
  -e "terraform_working_dir=$PWD/blueprints/core"
```

The ephemeral test playbook applies with a local backend-free state and then
destroys in an Ansible `always` block. Use it only with approved test
compartments and ignored local `terraform.tfvars` values:

```bash
CONFIRM_APPLY=true CONFIRM_DESTROY=true \
ANSIBLE_CONFIG=ansible/ansible.cfg \
  ansible-playbook -i ansible/inventories/dev/hosts.yml \
  ansible/playbooks/ephemeral-test.yml \
  -e "terraform_working_dir=$PWD/blueprints/core"
```

## Specialized Patterns

Some deployments are cross-cutting and should be selected based on the customer
operating model rather than a simple phase number:

- Use operating entity patterns for delegated ownership and repeatable
  application-team onboarding.
- Use compliance patterns for Zero Trust, SCCA-style, or regulator-driven
  control sets.
- Use data platform and industry patterns when workload behavior needs its own
  landing zone conventions.
- Use multicloud and regional hub patterns when routing, inspection, or
  connectivity boundaries drive the architecture.
