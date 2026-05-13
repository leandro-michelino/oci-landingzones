# Exadata Extension Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This architecture page documents the `blueprints/extensions/exadata` deployment. It is intentionally text-first and ASCII-only so it can be reviewed in terminals, pull requests, and customer notes without a diagramming tool.

## Deployment Purpose

This blueprint provides optional Exadata cloud infrastructure extension for database
platform landing zones.

## Files In This Deployment

```text
blueprints/extensions/exadata/
|-- README.md                         Human-friendly deployment notes
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
+----------------------------------------------------------------------------------------------+
| Exadata Extension                                                                            |
| blueprints/extensions/exadata                                                                |
+----------------------------------------------------------------------------------------------+
| Operator / CI / local shell                                                                  |
|   |                                                                                          |
|   v                                                                                          |
+----------------------------------------------------------------------------------------------+
| Blueprint folder contract                                                                    |
|   README.md                                                                                  |
|   architecture/README.md                                                                     |
|   main.tf + variables.tf + outputs.tf + providers.tf + versions.tf                           |
|   ansible/plan.yml + apply.yml + destroy.yml                                                 |
+----------------------------------------------------------------------------------------------+
|   |                                                                                          |
|   v                                                                                          |
+----------------------------------------------------------------------------------------------+
| Terraform composition and OCI resources                                                      |
|  01. resource oci_database_cloud_exadata_infrastructure.this   (main.tf)                     |
+----------------------------------------------------------------------------------------------+
|   |                                                                                          |
|   v                                                                                          |
+----------------------------------------------------------------------------------------------+
| Architecture layers                                                                          |
|   - Control plane: Terraform provider and extension variables                                |
|   - Dependency plane: existing compartment, subnet, VCN, key, or backend IDs supplied by tfva|
|   - Service plane: extension-specific OCI resources                                          |
|   - Operations plane: IDs and endpoints consumed by workloads and runbooks                   |
+----------------------------------------------------------------------------------------------+
|   |                                                                                          |
|   v                                                                                          |
+----------------------------------------------------------------------------------------------+
| Outputs and hand-off                                                                         |
|   resource_ids plus blueprint-specific IDs                                                   |
|   tfvars reviewed before apply                                                               |
|   generated Terraform artifacts cleaned after validation                                     |
+----------------------------------------------------------------------------------------------+
```

## Terraform Components

- `resource oci_database_cloud_exadata_infrastructure.this` in `main.tf`: creates Exadata cloud infrastructure.

## Request And Deployment Flow

- Operator supplies existing compartment, subnet, VCN, backend, or key dependencies.
- Terraform creates the optional OCI service extension only when enable flags allow it.
- The extension attaches to the supplied network or backend boundary.
- Outputs expose service IDs and endpoint IDs for workloads and runbooks.

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
|-- blueprint_name and name_prefix identify the deployment
|-- resource_ids summarizes primary resources in a machine-friendly map
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

The repository validator checks Terraform formatting, initializes and validates every blueprint without a backend, syntax-checks the root Ansible playbooks, syntax-checks every blueprint-local Ansible runner, and removes generated Terraform artifacts afterward.

## When To Update This Architecture

- Terraform modules, resources, data sources, or provider aliases change.
- A subnet, route, trust boundary, region, compartment, or access path changes.
- A new enable flag changes what the deployment can create.
- README usage notes describe behavior that is not represented here.
- A customer review turns an assumption into a reusable pattern.

## Terraform + Ansible Deployment Output

This is the deployment finish line for this blueprint. Terraform owns the OCI resource graph and named outputs; Ansible gives the local operator a repeatable plan/apply/destroy wrapper with a clean recap at the end.

```text
$ cd blueprints/extensions/exadata
$ terraform init
$ terraform validate
$ terraform plan -out=tfplan
$ terraform apply tfplan

Apply complete! Resources: <added> added, <changed> changed, <destroyed> destroyed.

$ terraform output
blueprint_name = "exadata"
name_prefix = "<org>-<env>-<region_key>"
resource_ids = { ... }
cloud_exadata_infrastructure_id = "ocid1.<resource>..."
```

```text
$ cd blueprints/extensions/exadata
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

For Exadata, the important hand-off values are `blueprint_name`, `name_prefix`, `resource_ids`, `cloud_exadata_infrastructure_id`. Keep those names stable unless a downstream blueprint, runbook, or customer hand-off is updated at the same time.
