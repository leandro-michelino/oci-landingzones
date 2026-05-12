# Ansible

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Ansible is used for local orchestration around the Terraform landing zone:
bootstrap checks, OCI CLI validation, repository validation, and controlled
Terraform command execution.

The current playbooks are scaffolds. They should remain non-destructive until
the Terraform module implementations are ready.

## Install Collections

```bash
ansible-galaxy collection install -r ansible/requirements.yml
```

## Run Local Validation

```bash
ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook ansible/playbooks/validate.yml
```

## Run Bootstrap Checks

```bash
ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook -i ansible/inventories/dev/hosts.yml ansible/playbooks/bootstrap.yml
```
