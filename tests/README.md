# Tests

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

The active test entry point for this repository is `./scripts/validate-all.sh`.
It discovers every Terraform blueprint, validates the documentation contract,
runs Terraform formatting and validation without remote state, syntax-checks
Ansible playbooks, and removes generated local artifacts.

Future unit or integration tests should live under this folder only when they
add coverage beyond the repository validation role. Empty `.gitkeep` files are
not needed because this README keeps the folder in git and documents the test
contract.
