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
removes generated Terraform artifacts afterward. Cleanup is in an Ansible
`always` block, so generated `.terraform/`, lock, state, and plan files are
removed even when validation fails.

The shell helper delegates to this playbook when Ansible is installed:

```bash
./scripts/validate-all.sh
```

## Run Bootstrap Checks

```bash
ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook -i ansible/inventories/dev/hosts.yml ansible/playbooks/bootstrap.yml
```

The shell helper delegates to this playbook when Ansible is installed:

```bash
./scripts/bootstrap.sh --org acme --env dev --region eu-frankfurt-1
```

## Run Terraform Plan

Terraform plan uses `terraform init -backend=false` by default so local checks do
not require remote state. Pass `terraform_working_dir` to target a specific
blueprint. When `terraform_environment_dir` contains a local
`terraform.tfvars`, the runner passes it to `terraform plan` and
`terraform destroy`; committed `.tfvars.example` files are templates only.

```bash
ANSIBLE_CONFIG=ansible/ansible.cfg \
  ansible-playbook -i ansible/inventories/dev/hosts.yml \
  ansible/playbooks/terraform-plan.yml \
  -e "terraform_working_dir=$PWD/blueprints/core"
```

## Run Guarded Apply

Terraform apply is opt-in and requires `CONFIRM_APPLY=true`. Production applies
are blocked from Ansible for now.

```bash
CONFIRM_APPLY=true \
ANSIBLE_CONFIG=ansible/ansible.cfg \
  ansible-playbook -i ansible/inventories/dev/hosts.yml \
  ansible/playbooks/terraform-apply.yml \
  -e "terraform_working_dir=$PWD/blueprints/core"
```

## Run Guarded Destroy

Terraform destroy is opt-in and requires `CONFIRM_DESTROY=true`. Production
destroys are also blocked by the Terraform runner role.

```bash
CONFIRM_DESTROY=true \
ANSIBLE_CONFIG=ansible/ansible.cfg \
  ansible-playbook -i ansible/inventories/dev/hosts.yml \
  ansible/playbooks/terraform-destroy.yml \
  -e "terraform_working_dir=$PWD/blueprints/core"
```

The shell helper delegates to this playbook when Ansible is installed:

```bash
CONFIRM_DESTROY=true ./scripts/destroy.sh
```

## Run Ephemeral Test

The ephemeral test playbook runs an approved local apply with
`terraform init -backend=false`, then runs destroy in an `always` block. It is
intended for approved test compartments only.

```bash
CONFIRM_APPLY=true CONFIRM_DESTROY=true \
ANSIBLE_CONFIG=ansible/ansible.cfg \
  ansible-playbook -i ansible/inventories/dev/hosts.yml \
  ansible/playbooks/ephemeral-test.yml \
  -e "terraform_working_dir=$PWD/blueprints/core"
```
