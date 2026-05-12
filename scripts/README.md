# Scripts

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Project automation scripts live here. They are thin entry points around
Terraform and Ansible; the reusable orchestration logic should live in
`ansible/` whenever possible.

Current scripts:

| Script | Purpose |
|---|---|
| `bootstrap.sh` | Validate bootstrap inputs and print the manual prerequisites for remote state and local tooling. |
| `validate-all.sh` | Delegate to the Ansible validation playbook when available, with a shell fallback for minimal workstations. |

Planned scripts:

- `destroy.sh` - controlled teardown helper for non-production environments.
