# Private Data Platform Landing Zone Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This is the design view for `blueprints/data-platform/private-data-platform`. It stays
ASCII-first on purpose so you can review the deployment in GitHub, a terminal, a pull
request, or customer notes without a diagramming tool.

## Deployment Purpose

Builds a private data-platform pattern with network placement, vault/KMS, object storage,
private endpoint, and streaming hooks.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/data-platform/private-data-platform` owns this deployment end to end. |
| Terraform components | `network`, `vault`, `streaming`, `oci_objectstorage_bucket.data`, `oci_objectstorage_private_endpoint.data`, `data.oci_objectstorage_namespace.this` |
| Input source | `terraform.tfvars.example` documents the shape; local ignored tfvars provide real values. |
| Output contract | `blueprint_name`, `name_prefix`, `resource_ids`, `vcn_id`, `subnet_ids`, `vault_ids`, `vault_key_ids`, `data_bucket_name`, plus 3 more |
| Runner contract | `ansible/plan.yml`, guarded `ansible/apply.yml`, and guarded `ansible/destroy.yml`. |

## Files In This Deployment

```text
blueprints/data-platform/private-data-platform/
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
| Private Data Platform Landing Zone                                                                   |
| Folder: blueprints/data-platform/private-data-platform                                               |
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
| 01. module.network -> ../../../blueprints/networking/standalone-private-endpoint-only                |
| 02. module.vault -> ../../../modules/security/vault                                                  |
| 03. module.streaming -> ../../../blueprints/extensions/streaming                                     |
| 04. resource.oci_objectstorage_bucket.data                                                           |
| 05. resource.oci_objectstorage_private_endpoint.data                                                 |
| 06. data.oci_objectstorage_namespace.this                                                            |
|                                                                                                      |
| [4] OCI/resource planes                                                                              |
| - Control: provider config, tenancy context, naming inputs, and local tfvars.                        |
| - Data platform: private data, analytics, network, security, and service endpoints required by the   |
| blueprint.                                                                                           |
| - Consumption: data, network, and security outputs for data engineering and operations teams.        |
| - Operations: Ansible plan/apply/destroy wrappers, validation, and cleanup.                          |
|                                                                                                      |
| [5] Output hand-off                                                                                  |
| - blueprint_name: Blueprint identifier.                                                              |
| - name_prefix: Standard OCI naming prefix for resources created by this blueprint.                   |
| - resource_ids: Map of resource identifiers created by this blueprint.                               |
| - vcn_id: Private data platform VCN OCID.                                                            |
| - subnet_ids: Private data platform subnet OCIDs keyed by role.                                      |
| - vault_ids: Vault OCIDs keyed by logical name.                                                      |
| - vault_key_ids: KMS key OCIDs keyed by logical name.                                                |
| - data_bucket_name: Private data platform Object Storage bucket name.                                |
| - object_storage_private_endpoint_id: Object Storage private endpoint OCID.                          |
| - stream_pool_id: Streaming stream pool OCID.                                                        |
| - stream_ids: Stream OCIDs keyed by logical name.                                                    |
|                                                                                                      |
| [6] Deployment close-out                                                                             |
| terraform output and the Ansible PLAY RECAP are the human and automation hand-off.                   |
| Generated .terraform directories, lock files, plans, state files, and local tfvars stay out of git.  |
+------------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Module | `network` | `../../../blueprints/networking/standalone-private-endpoint-only` |
| Module | `vault` | `../../../modules/security/vault` |
| Module | `streaming` | `../../../blueprints/extensions/streaming` |
| Resource | `oci_objectstorage_bucket.data` | Declared directly in `main.tf` |
| Resource | `oci_objectstorage_private_endpoint.data` | Declared directly in `main.tf` |
| Data source | `data.oci_objectstorage_namespace.this` | Read during plan/apply |

## Request And Deployment Flow

- Operator reviews the local tfvars contract and chooses the plan/apply runner.
- Terraform composes the OCI resources declared in `main.tf`.
- Outputs become the deployment hand-off contract for runbooks and downstream blueprints.
- Validation checks formatting, init, validate, Ansible syntax, documentation coverage, and cleanup.

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
- Confirm no-public-access bucket settings and private endpoint subnet placement.
- Confirm KMS ownership and stream retention before production use.

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
$ cd blueprints/data-platform/private-data-platform
$ terraform init
$ terraform validate
$ terraform plan -out=tfplan
$ terraform apply tfplan

Apply complete! Resources: <added> added, <changed> changed, <destroyed> destroyed.

$ terraform output
blueprint_name = "private-data-platform"
name_prefix = "<org>-<env>-<region_key>"
resource_ids = { ... }
vcn_id = "ocid1.<resource>..."
subnet_ids = { ... }
vault_ids = { ... }
vault_key_ids = { ... }
data_bucket_name = "<name>"
object_storage_private_endpoint_id = "ocid1.<resource>..."
stream_pool_id = "ocid1.<resource>..."
stream_ids = { ... }
```

```text
$ cd blueprints/data-platform/private-data-platform
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

For Private Data Platform Landing Zone, the important hand-off values are `blueprint_name`,
`name_prefix`, `resource_ids`, `vcn_id`, `subnet_ids`, `vault_ids`, `vault_key_ids`,
`data_bucket_name`, `object_storage_private_endpoint_id`, `stream_pool_id`, plus 1 more.
Keep those names stable unless a downstream blueprint, runbook, or customer hand-off is
updated at the same time.
