# Architecture Index

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This folder is the repository-level architecture index. The authoritative
architecture for a deployable pattern still lives beside that pattern at
`blueprints/<family>/<deployment>/architecture/README.md`.

## Repository Architecture

```text
+--------------------------------------------------------------------------------+
|                         OCI Landing Zones Repository                            |
+--------------------------------------------------------------------------------+
|                                                                                |
|  Operator / CI                                                                 |
|      |                                                                         |
|      v                                                                         |
|  scripts/validate-all.sh                                                       |
|      |                                                                         |
|      +--> ansible/playbooks/validate.yml                                       |
|      |       |                                                                 |
|      |       +--> Terraform fmt, init -backend=false, validate                 |
|      |       +--> README and ASCII architecture contract checks                |
|      |       +--> Ansible syntax checks                                        |
|      |       `--> generated artifact cleanup                                  |
|      |                                                                         |
|      +--> fallback shell checks when Ansible is unavailable                    |
|                                                                                |
|  Deployable blueprints                                                         |
|      |                                                                         |
|      +--> blueprints/core                                                      |
|      +--> blueprints/cis/*                                                     |
|      +--> blueprints/networking/*                                              |
|      +--> blueprints/identity/*                                                |
|      +--> blueprints/operating-entity/*                                        |
|      +--> blueprints/compliance/*                                              |
|      +--> blueprints/extensions/*                                              |
|      +--> blueprints/data-platform/*                                           |
|      +--> blueprints/disaster-recovery/*                                       |
|      `--> blueprints/industry/*                                                |
|              |                                                                 |
|              v                                                                 |
|      reusable modules under modules/                                           |
|              |                                                                 |
|              v                                                                 |
|      OCI resources in the selected tenancy and region                          |
|                                                                                |
+--------------------------------------------------------------------------------+
```

## Architecture Contract

Each deployable blueprint must include:

| Artifact | Purpose |
|---|---|
| `README.md` | Operator-facing deployment purpose, inputs, outputs, workflow, validation, and review notes. |
| `architecture/README.md` | Detailed ASCII architecture, Terraform components, request flow, design notes, and review checklist. |
| `main.tf` | The Terraform composition that matches the documented architecture. |
| `terraform.tfvars.example` | Safe input shape without real tenancy secrets or OCIDs. |
| `ansible/plan.yml`, `ansible/apply.yml`, `ansible/destroy.yml` | Local orchestration entry points for the blueprint. |

Deployable blueprint Terraform sources must use pinned Git module references,
not local `../` paths. That keeps a customer able to sparse-checkout only one
blueprint, such as `blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns/`,
and still run `terraform init` from that folder.

## Review Flow

```text
choose blueprint
  |
  v
sparse-checkout only that blueprint folder
  |
  v
read blueprint README.md
  |
  v
review blueprint architecture/README.md
  |
  v
copy terraform.tfvars.example to ignored terraform.tfvars
  |
  v
terraform init -backend=false && terraform validate
  |
  v
terraform plan or ansible/plan.yml
```

## Maintenance Notes

- Keep this file focused on repository-level structure.
- Keep pattern-specific diagrams in the local blueprint architecture folder.
- Run `./scripts/validate-all.sh` after adding or changing a blueprint; validation
  checks that the blueprint README and ASCII architecture sections are present.
