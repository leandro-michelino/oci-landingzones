# Tests

The full test entry point for this repository is `./scripts/validate-all.sh`.
It discovers every Terraform blueprint, validates the documentation contract,
runs Terraform formatting and validation without remote state, syntax-checks
Ansible playbooks, runs optional scanners when installed, and removes generated
local artifacts.

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
