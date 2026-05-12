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
| `destroy.sh` | Guarded Terraform destroy helper for the current blueprint or environment directory. |
