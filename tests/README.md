# Tests

The full test entry point for this repository is `./scripts/validate-all.sh`.
It discovers every Terraform blueprint, validates the documentation contract,
runs Terraform formatting and validation without remote state, syntax-checks
Ansible playbooks, runs optional scanners when installed, and preserves existing
deployment state, saved plans, and dependency lock files. Set
`VALIDATION_CLEAN_TERRAFORM_WORKDIRS=1` only to remove disposable `.terraform`
provider/module work directories after validation.

For normal small edits, use `./scripts/validate-changed.sh` first. It compares
the current branch and working tree to `origin/main`, maps changed files to the
nearest blueprint or module Terraform root, and validates only that touched
surface while still running the repository contract guard.

OpenSearch fixture samples live under `fixtures/opensearch/`:

- `validation-only.tfvars.example` keeps every cost-bearing flag disabled for
  local shape checks.
- `private-network-cluster.tfvars.example` models the end-to-end managed
  OpenSearch path with a private network, cluster, and snapshot bucket.

The real OpenSearch lifecycle entry point is
`scripts/test-opensearch-lifecycle.sh`. It runs Terraform fmt/init/validate,
plan, apply, OCI verification, destroy, and post-destroy state checks when
`OPENSEARCH_LIFECYCLE_CONFIRM=true` is set.

NoSQL fixture samples live under `fixtures/nosql/`:

- `validation-minimal.tfvars.example` models a small table-only shape for
  local contract checks.
- `table-with-app-network.tfvars.example` models the end-to-end NoSQL path
  with app networking, a secondary index, and an alert topic.

The real NoSQL lifecycle entry point is `scripts/test-nosql-lifecycle.sh`. It
runs Terraform fmt/init/validate, plan, apply, OCI table/index verification,
destroy, and post-destroy state checks when `NOSQL_LIFECYCLE_CONFIRM=true` is
set.

OIC fixture samples live under `fixtures/oic/`:

- `validation-minimal.tfvars.example` keeps all cost-bearing OIC resources
  disabled for local contract checks.
- `basic-instance.tfvars.example` models the disposable OIC instance path with
  an identity domain input for real lifecycle testing.

The real OIC lifecycle entry point is `scripts/test-oic-lifecycle.sh`. It runs
Terraform fmt/init/validate, plan, apply, OCI instance verification when
creation succeeds, destroy, and post-destroy state checks when
`OIC_LIFECYCLE_CONFIRM=true` is set. OIC creation can be blocked by missing
identity domain, regional service limits, tag policy/defaults, or legacy
instance-type entitlement before resources are provisioned.

The OIC lifecycle runner was last proven end to end on 2026-06-02 with a
disposable `STANDARDX` instance in `af-johannesburg-1`: apply completed,
OCI CLI verification returned `ACTIVE`, destroy completed, and the post-destroy
state check found no managed resources.

## Networking lifecycle safety

`scripts/test-networking-lifecycle.sh` targets OCI by default. Real runs require
`NETWORKING_LIFECYCLE_CONFIRM=true`, an isolated disposable workspace, and a
review of the planned services and their costs. The runner refuses existing OCI
managed resources and does not destroy after a failed plan. Never run the
`--all-networking` lifecycle as a cost-free validation check.

## DRG attachment plan regressions

The AWS/OCI backbone and Azure/OCI dual-connectivity blueprints include
`tests/drg-attachment.tftest.hcl`. Run `terraform test` from either initialized
blueprint. The OCI provider is mocked: these checks create no cloud resources.
They require a newly created VCN and DRG to plan their attachment in one step
and verify that the explicit attachment flag can disable creation.

## Firewall and ZPR module regressions

`modules/networking/net-firewall/tests/disabled-mode.tftest.hcl` tests disabled
Firewall plans with and without an existing policy reference.
`modules/networking/zpr/tests/root-scope.tftest.hcl` verifies tenancy-root IDs
for configuration and policies. Initialize the relevant module and run
`terraform test`. OCI is mocked; these tests create no cloud resources.
ZPR activation is not part of the compartment-only live tests.

## Last Successful Validation Comments

Module definitions and blueprint module calls contain English validation metadata: date, provider, test scope, and evidence. A schema validation is not a live deployment. Lifecycle dates apply only to the explicitly recorded reduced blueprint scope. After a functional change or dependency upgrade, rerun the relevant checks before updating the success date. Preserve the previous successful date when a new run fails, and record the failure separately with its cause. Dates describe historical evidence rather than a guarantee of future compatibility.

## AI Configuration Regression Coverage

The AI test files use fully mocked OCI providers. They check distinct fine-tuning/hosting cluster roles, existing-dataset namespace requirements, Streaming/Object Storage connector targets, non-truncated HTTPS gateway URLs, rejection of placeholder deployments, and home-region IAM provider selection. The complete suite now has 17 cases across 8 suites. The [October 2026 repository review](../docs/REPOSITORY-VALIDATION-20261014.md) records static, schema, mock, and publication boundaries.

## Administrative And Database Regression Coverage

The October 14 review established 35 mocked cases in 16 suites. Those cases separate Budget ownership from targets, verify the home provider in Core/Healthcare/Cost Optimization, exercise Function/Streaming Events without ONS topics, test disabled APEX/database plans and secret creation/reuse, reject incompatible Always Free inputs, and keep paid databases absent from network-only plans. See the [CIS/Compliance/database review](../docs/CIS-COMPLIANCE-DATA-REVIEW-20261014.md) for its exact live boundaries and cleanup evidence.

## Data, DevOps, And DR Regression Coverage

The repository contained 93 cases across 26 Terraform test files after that round. The
October 15 round added or revised 58 cases in ten blueprint suites. They check
safe network-only plans, private subnet ingress, endpoint and credential
prerequisites, explicit DR contracts, and FSDR standby plan placement. The
Private Data Platform tests are plan-only because a nested provider configured
at `v0.2.0` was not isolated by an apply-style mock. The [October 15 review](../docs/DATA-DEVOPS-DR-REVIEW-20261015.md)
records the executed cases, reduced OCI lifecycle checks, and test limits.

## Extensions Regression Coverage

The October 17 extensions review adds seven plan-only mocked cases in three
files: CDN default resource safety, ODA default and private-backend network
guards, and Functions container-image source and existing-application wiring.
The repository now has 100 cases across 29 Terraform test files. The
[item-by-item review](../docs/EXTENSIONS-REVIEW-20261017.md) distinguishes
these plans from the reduced ODA live network test and from untested paid
workloads.
