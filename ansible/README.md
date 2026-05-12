# Ansible

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Ansible is used for local orchestration around the Terraform landing zone:
bootstrap checks, OCI CLI validation, repository validation, and controlled
Terraform command execution.

The playbooks stay non-destructive by default. Terraform remains the source of
truth for OCI resources, while Ansible handles repeatable local checks and
safe command orchestration.

## Install Collections

```bash
ansible-galaxy collection install -r ansible/requirements.yml
```

## Run Local Validation

```bash
ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook ansible/playbooks/validate.yml
```

The validation playbook runs `terraform fmt`, auto-discovers implemented
Terraform blueprints, initializes and validates them without a backend, runs
optional local linters when installed, checks Ansible playbook syntax, and
removes generated Terraform artifacts afterward. It also uses a Terraform plugin
cache and command timeout so repeated local validation is much quicker and does
not hang indefinitely on provider downloads.

The shell helper delegates to this playbook when Ansible is installed:

```bash
./scripts/validate-all.sh
```

## Run Bootstrap Checks

```bash
ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook -i ansible/inventories/dev/hosts.yml ansible/playbooks/bootstrap.yml
```
