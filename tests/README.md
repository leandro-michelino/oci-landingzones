# Tests

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

The full test entry point for this repository is `./scripts/validate-all.sh`.
It discovers every Terraform blueprint, validates the documentation contract,
runs Terraform formatting and validation without remote state, syntax-checks
Ansible playbooks, runs optional scanners when installed, and removes generated
local artifacts.

For normal small edits, use `./scripts/validate-changed.sh` first. It compares
the current branch and working tree to `origin/main`, maps changed files to the
nearest blueprint or module Terraform root, and validates only that touched
surface while still running the repository contract guard.

Future unit or integration tests should live under this folder only when they
add coverage beyond the repository validation role. Empty `.gitkeep` files are
not needed because this README keeps the folder in git and documents the test
contract.
