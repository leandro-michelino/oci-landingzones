# Deployment Guide

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

Use the changed-scope validation entry point while iterating:

```bash
./scripts/validate-changed.sh
```

This first runs a fast repository contract guard, then maps changed files to the
nearest touched Terraform root and local Ansible playbook. It validates only
that changed surface and cleans generated Terraform artifacts, plan files, and
`.DS_Store` files even when a validation step fails.

Run the full validation entry point before broad refactors, release work, or
changes to shared validation behavior:

```bash
./scripts/validate-all.sh
```

The full validator auto-discovers Terraform blueprints under `blueprints/`,
validates them without a remote backend, runs optional scanners when installed,
syntax-checks Ansible playbooks, and cleans generated artifacts. Blueprint
folders with scaffold markers fail validation, because every architecture is
expected to have real Terraform wiring.

For quick feedback while editing docs or blueprint wrappers, run only the
contract guard:

```bash
./scripts/check-repo-contracts.sh
```

It blocks repeated documentation fragments, missing blueprint files, and local
Ansible runners that drift away from their Terraform working directory or
action.

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
Use `docs/BYOL-LICENSING-MATRIX.md` before enabling BYOL, BYOI,
license-included, or customer-image options for databases, Windows instances,
Red Hat images, analytics, integration, middleware, or VMware-related patterns.
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

## Using Extensions Only

Use this path when the customer already has the base landing-zone pieces and
only wants one extension from this repository. In this mode, the extension
blueprint is the whole deployment. It does not need the core blueprint to run,
as long as the customer supplies the existing OCI identifiers the extension
requires.

Typical extension-only inputs are existing compartment OCIDs, VCN IDs, subnet
IDs, NSG IDs, load balancer IDs, gateway IDs, registry image URLs, database
OCIDs, certificate IDs, identity group names, and policy scope decisions. Keep
those values in ignored local `terraform.tfvars` or approved pipeline variables.

```text
existing customer tenancy
  |
  |-- existing compartments / IAM / tags
  |-- existing VCNs / subnets / NSGs / gateways
  |-- existing service dependencies, when required
  |
  `-- selected extension folder
        |-- terraform.tfvars.example -> terraform.tfvars
        |-- terraform init && terraform plan
        `-- optional ansible/plan.yml and guarded ansible/apply.yml
```

Sparse-checkout just the extension and, if Ansible is needed, the shared runner
role:

```bash
git clone --filter=blob:none --sparse https://github.com/leandro-michelino/oci-landingzones.git
cd oci-landingzones

git sparse-checkout set \
  blueprints/extensions/functions \
  ansible/roles/terraform_runner

cd blueprints/extensions/functions
cp terraform.tfvars.example terraform.tfvars
```

Review the extension README for the exact brownfield hand-off. For example,
Functions needs application subnet IDs, image URLs, optional API Gateway values,
Events conditions, and IAM statements; WAF needs an existing load balancer or
web application target; OKE needs VCN and subnet IDs.

## Using Base Plus Extensions

Use this path when the customer wants this repository to create the foundation
and then add services on top. In this mode, deploy the base first and pass its
outputs into the extension tfvars. The hand-off is explicit: outputs from one
blueprint become reviewed inputs to the next one.

```text
Core or CIS baseline
  |
  v
Networking blueprint
  |
  v
Operating Entity / Workload Vending, when ownership boundaries matter
  |
  v
Operations, when cost ownership and notifications matter
  |
  v
Selected extensions
```

Typical base-plus-extension hand-offs:

| Source | Values The Extension Usually Needs |
|---|---|
| Core or CIS | Tenancy, home region, compartments, governance tags, IAM policy scope. |
| Networking | VCN IDs, subnet IDs, NSG IDs, gateway or route context, private endpoint decisions. |
| Operating Entity | Workload compartment OCIDs and delegated group names. |
| Operations | Budget, alerting, notification, and cost-owner context. |
| Service blueprint | Database OCIDs, load balancer OCIDs, registry image URLs, certificates, or endpoint outputs. |

Remote state can be used by a customer pipeline, but the reusable blueprint
folders do not force a production backend. That keeps sparse-checkout and local
review simple while still allowing a full deployment pipeline to wire outputs
through a controlled state or variable hand-off.

## Choosing Deployment Boundaries

Use a full deployable blueprint when the folder represents a customer outcome
with its own lifecycle, owner, approval path, state boundary, or architecture
review. Good examples are a core governance baseline, a CIS profile, a hub-spoke
network, an OKE cluster foundation, a Functions platform, a secure desktop
landing zone, or an industry-specific platform.

Keep subtopics inside the owning blueprint when they only support that outcome.
Examples include one notification topic, event rule, alarm family, NSG decision,
private endpoint, API route group, service connector, or optional IAM policy.
Splitting those into independent Terraform roots makes customer review,
state management, validation, and documentation harder without creating a
clearer outcome.

When repeated implementation appears in more than one blueprint, promote the
shared resource graph into `modules/` and keep the blueprint folder as the
customer-facing wrapper. The wrapper owns the operator README, architecture
diagram, input defaults, outputs, Ansible runners, and sparse-checkout contract;
the module owns reusable Terraform behavior.

Curated full landing-zone bundles should be added only for common journeys that
customers recognize as one deployable pattern. Compose them from existing base,
networking, operations, and extension decisions, and avoid creating one bundle
per minor feature toggle.

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

| Family | Terraform Entry Points | Ansible Coverage |
|---|---|---|
| Core | `blueprints/core/` | Initialized and validated without backend; local plan/apply/destroy runners are syntax-checked. |
| CIS and compliance | `blueprints/cis/*` and `blueprints/compliance/*` | CIS, SCCA, Zero Trust, Healthcare PCI, and Security Posture Automation are validated with the rest of the catalog. |
| Identity and operating entity | `blueprints/identity/*` and `blueprints/operating-entity/*` | Identity domain, CIS basic identity, single entity, multi-entity, and workload vending entry points are validated. |
| Networking | `blueprints/networking/*` | Every standalone, hub-spoke, DNS, firewall, NVA, ZPR, multicloud, NLB, and regional networking blueprint is validated. |
| Operations and extensions | `blueprints/operations/*` and `blueprints/extensions/*` | Cost Optimization plus API Gateway, Container Instances, Event-Driven Platform, Exadata, Functions, OAC, Observability, OIC, OKE, OKE Service Mesh, Redis Cache, Streaming, and WAF are validated. |
| Data, AI, DevOps, DR, and industry | `blueprints/data-platform/*`, `blueprints/ai/*`, `blueprints/devops/*`, `blueprints/disaster-recovery/*`, and `blueprints/industry/*` | Service-specific blueprints are initialized and validated without backend and must keep local ASCII architecture notes. |

The full catalog currently contains 65 deployable blueprint entry points across
13 families. The complete architecture inventory is in
`docs/architecture/README.md`.

## Phase 5 - Operations

Operations blueprints sit after core and before most workload add-ons. They
help the landing zone stay understandable after resources start to multiply.

Implemented Phase 5 operations entry points:

- `blueprints/operations/cost-optimization/` creates cost-tracking tags, optional
  tag defaults, budgets, budget alert rules, FinOps ONS notifications, optional
  Monitoring alarms, optional Optimizer profiles, and optional FinOps IAM
  policy statements.

Keep real budget amounts, recipients, webhook targets, Optimizer enrollment IDs,
and IAM group names in local ignored tfvars files.

## Phase 6 - Extensions

Extensions support two customer paths. For extension-only brownfield use,
identify the existing compartment, network, service, and IAM values and run the
extension folder directly. For base-plus-extension use, deploy core and the
required networking foundation first, then pass their outputs into the extension
tfvars. Each extension must include its own architecture notes.

Implemented Phase 6 extension entry points:

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
- `blueprints/extensions/container-instances/` creates a private serverless
  container runtime with VNIC, NSGs, optional pull secrets, volumes, and IAM
  policy statements.
- `blueprints/extensions/functions/` creates optional OCIR repository,
  Functions application, functions from approved images, API Gateway routes,
  Events triggers, and IAM policy statements.
- `blueprints/extensions/event-driven-platform/` creates optional event archive
  storage, stream pool, streams, notification topic, Events rules, Service
  Connector, and IAM policy statements for async app and AI automation patterns.
- `blueprints/extensions/redis-cache/` creates optional private OCI Cache with
  Redis endpoint hand-offs, alarm hooks, Vault hand-off, and IAM controls.

Additional service blueprints now cover Autonomous Database, APEX on Autonomous
Database, OpenSearch, MySQL HeatWave, OCI Generative AI, GenAI gateway,
fine-tuning, guardrails, document intelligence, embedding pipelines, AI Agents
RAG, multi-agent orchestration, OCI AI Services, OCI DevOps, Redis Cache,
Security Posture Automation, Network Load Balancer, Secure Desktops, and
Healthcare / PCI guardrails. They follow the same local README, ASCII
architecture, Terraform, tfvars, and Ansible runner contract.

Keep real subnet, VCN, load balancer, availability domain, image, event filter,
and SSH values in local ignored tfvars files. The committed examples show the
shape only.

## Ansible Orchestration

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
