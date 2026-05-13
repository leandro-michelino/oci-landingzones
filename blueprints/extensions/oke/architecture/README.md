# OKE Extension Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This is the design view for `blueprints/extensions/oke`. It stays ASCII-first on purpose so
you can review the deployment in GitHub, a terminal, a pull request, or customer notes
without a diagramming tool.

## Deployment Purpose

Adds OCI Container Engine for Kubernetes as a platform extension with cluster, node pool,
subnet, endpoint, IAM, and logging decisions visible.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/extensions/oke` owns this deployment end to end. |
| Terraform components | `oci_containerengine_cluster.this`, `oci_containerengine_node_pool.this` |
| Input source | `terraform.tfvars.example` documents the shape; local ignored tfvars provide real values. |
| Output contract | `blueprint_name`, `name_prefix`, `resource_ids`, `cluster_id`, `node_pool_id` |
| Runner contract | `ansible/plan.yml`, guarded `ansible/apply.yml`, and guarded `ansible/destroy.yml`. |

## Files In This Deployment

```text
blueprints/extensions/oke/
|-- README.md                         Operator guide for this deployment
|-- architecture/README.md            This detailed ASCII architecture
|-- main.tf                           Terraform resource and module wiring
|-- variables.tf                      Input contract and defaults
|-- outputs.tf                        Hand-off values for dependent blueprints
|-- providers.tf                      OCI provider configuration
|-- versions.tf                       Terraform and provider constraints
|-- terraform.tfvars.example          Example local variable shape
`-- ansible/
    |-- plan.yml                      Local guarded plan runner
    |-- apply.yml                     Local guarded apply runner
    `-- destroy.yml                   Local guarded destroy runner
```

## ASCII Architecture

```text
+------------------------------------------------------------------------------------------------------+
| OKE Extension                                                                                        |
| Folder: blueprints/extensions/oke                                                                    |
|                                                                                                      |
| [1] Operator entry                                                                                   |
| Operator, CI job, or local shell reviews README.md and architecture/README.md, copies                |
| terraform.tfvars.example to terraform.tfvars, and chooses either direct Terraform or the local       |
| Ansible wrapper.                                                                                     |
|                                                                                                      |
| [2] Local file contract                                                                              |
| README.md -> run-facing deployment guide.                                                            |
| architecture/README.md -> detailed text architecture and review notes.                               |
| main.tf -> Terraform composition for this deployment.                                                |
| variables.tf -> input contract and defaults.                                                         |
| outputs.tf -> named hand-off values.                                                                 |
| providers.tf + versions.tf -> provider setup and version constraints.                                |
| ansible/plan.yml, apply.yml, destroy.yml -> repeatable local runners with guarded apply and destroy. |
|                                                                                                      |
| [3] Terraform composition from main.tf                                                               |
| 01. resource.oci_containerengine_cluster.this                                                        |
| 02. resource.oci_containerengine_node_pool.this                                                      |
|                                                                                                      |
| [4] OCI/resource planes                                                                              |
| - Control: provider config, tenancy context, naming inputs, and local tfvars.                        |
| - Service extension: optional OCI service resources that attach to an existing landing-zone          |
| foundation.                                                                                          |
| - Consumption: service IDs, endpoints, and names for applications, runbooks, and monitoring.         |
| - Operations: Ansible plan/apply/destroy wrappers, validation, and cleanup.                          |
|                                                                                                      |
| [5] Output hand-off                                                                                  |
| - blueprint_name: Blueprint identifier.                                                              |
| - name_prefix: Standard OCI naming prefix for resources created by this blueprint.                   |
| - resource_ids: Map of resource identifiers created by this blueprint.                               |
| - cluster_id: Created or referenced OKE cluster OCID.                                                |
| - node_pool_id: OKE node pool OCID.                                                                  |
|                                                                                                      |
| [6] Deployment close-out                                                                             |
| terraform output and the Ansible PLAY RECAP are the human and automation hand-off.                   |
| Generated .terraform directories, lock files, plans, state files, and local tfvars stay out of git.  |
+------------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Resource | `oci_containerengine_cluster.this` | Declared directly in `main.tf` |
| Resource | `oci_containerengine_node_pool.this` | Declared directly in `main.tf` |

## Request And Deployment Flow

- Operator confirms the foundation and network dependencies are already available.
- Terraform composes the optional service resources declared by this deployment.
- Outputs expose service IDs, names, and endpoints for applications and runbooks.

## State, Inputs, And Outputs

```text
Input sources
|-- terraform.tfvars.example documents expected values
|-- local *.tfvars files provide tenancy, compartment, CIDR, endpoint, and OCID values
|-- environment variables may provide OCI authentication and guarded Ansible confirms
|
Terraform state
|-- backend is disabled for local validation and plan runners by default
|-- production backends should be configured outside this reusable blueprint folder
|-- generated .terraform directories, lock files, plans, and state files are cleaned by validation
|
Output contract
|-- blueprint_name and name_prefix identify the deployment when declared
|-- resource_ids summarizes primary resources when declared
`-- blueprint-specific outputs expose compartment, VCN, subnet, key, policy, service, or DR IDs
```

## Operational Boundaries

- Keep apply/destroy behind the guarded Ansible runners or equivalent review gates.
- Use local ignored tfvars for OCIDs, notification endpoints, customer CIDRs, and secrets.
- Run ./scripts/validate-all.sh before commits or hand-off.
- Confirm optional service costs and quotas before enabling compute, OKE, WAF, Exadata, or Streaming resources.

## Review Checklist

- Confirm the `README.md` story matches this ASCII architecture.
- Confirm every module/resource listed above is intentional for this deployment.
- Confirm required external IDs are documented before `terraform plan`.
- Confirm enable flags are set deliberately, especially for tenancy-wide, paid, or destructive resources.
- Confirm logging, IAM, security, networking, and operational hand-offs are visible in the diagram.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.

## Validation

```bash
./scripts/validate-all.sh
```

The repository validator checks Terraform formatting, initializes and validates every
blueprint without a backend, syntax-checks the root Ansible playbooks, syntax-checks every
blueprint-local Ansible runner, verifies README coverage, and removes generated Terraform
artifacts afterward.

## When To Update This Architecture

- Terraform modules, resources, data sources, or provider aliases change.
- A subnet, route, trust boundary, region, compartment, or access path changes.
- A new enable flag changes what the deployment can create.
- README usage notes describe behavior that is not represented here.
- A customer review turns an assumption into a reusable pattern.

## Terraform + Ansible Deployment Output

This is the deployment finish line for this blueprint. Terraform owns the OCI resource graph
and named outputs; Ansible gives the local operator a repeatable plan/apply/destroy wrapper
with a clean recap at the end.

```text
$ cd blueprints/extensions/oke
$ terraform init
$ terraform validate
$ terraform plan -out=tfplan
$ terraform apply tfplan

Apply complete! Resources: <added> added, <changed> changed, <destroyed> destroyed.

$ terraform output
blueprint_name = "oke"
name_prefix = "<org>-<env>-<region_key>"
resource_ids = { ... }
cluster_id = "ocid1.<resource>..."
node_pool_id = "ocid1.<resource>..."
```

```text
$ cd blueprints/extensions/oke
$ ansible-playbook -i localhost, ansible/plan.yml

TASK [terraform_runner : Terraform init]      ok
TASK [terraform_runner : Terraform validate]  ok
TASK [terraform_runner : Terraform plan]      ok

PLAY RECAP *********************************************************************
localhost                  : ok=<n> changed=0 unreachable=0 failed=0 skipped=<n> rescued=0 ignored=0

$ CONFIRM_APPLY=true ansible-playbook -i localhost, ansible/apply.yml

TASK [terraform_runner : Terraform init]      ok
TASK [terraform_runner : Terraform validate]  ok
TASK [terraform_runner : Terraform plan]      ok
TASK [terraform_runner : Terraform apply]     changed

PLAY RECAP *********************************************************************
localhost                  : ok=<n> changed=<n> unreachable=0 failed=0 skipped=<n> rescued=0 ignored=0
```

For OKE Extension, the important hand-off values are `blueprint_name`, `name_prefix`,
`resource_ids`, `cluster_id`, `node_pool_id`. Keep those names stable unless a downstream
blueprint, runbook, or customer hand-off is updated at the same time.
