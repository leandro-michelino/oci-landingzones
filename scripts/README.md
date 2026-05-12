# Scripts

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Project automation scripts live here. They are thin entry points around
Terraform and Ansible; the reusable orchestration logic should live in
`ansible/` whenever possible.

Current scripts:

| Script | Purpose |
|---|---|
| `bootstrap.sh` | Delegate bootstrap checks to Ansible when available, with a shell fallback for minimal workstations. |
| `validate-all.sh` | Delegate to the Ansible validation playbook when available, with a shell fallback for minimal workstations. |
| `destroy.sh` | Delegate guarded Terraform destroy to Ansible when available; requires `CONFIRM_DESTROY=true`. |

For apply, plan, and ephemeral tests, call the Ansible playbooks directly from
`ansible/playbooks/`. Shell scripts should remain thin wrappers around Ansible
instead of duplicating orchestration logic.
