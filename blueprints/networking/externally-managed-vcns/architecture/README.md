# Externally Managed VCNs Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for `blueprints/networking/externally-managed-vcns`. It is intentionally ASCII-first so it
is easy to review in GitHub, terminals, pull requests, runbooks, and customer notes without a
diagramming tool.

## Deployment Purpose

Documents and exports existing VCN, subnet, DRG, and route target OCIDs so brownfield networks can participate in the landing-zone output contract.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/networking/externally-managed-vcns` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Documents and exports existing VCN, subnet, DRG, and route target OCIDs so brownfield networks can participate in the landing-zone output contract. |
| Terraform components | `locals.external_resource_ids` only |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and traffic flow for this exact deployment. |
| Output contract | `blueprint_name`, `name_prefix`, `resource_ids`, `vcn_ids`, `subnet_ids`, `drg_id`, `route_target_ids` |
| Runner contract | `ansible/plan.yml`, guarded `ansible/apply.yml`, and guarded `ansible/destroy.yml`. |

## Files In This Deployment

```text
blueprints/networking/externally-managed-vcns/
|-- README.md                         Operator guide for this deployment
|-- architecture/README.md            This deployment-specific ASCII architecture
|-- main.tf                           Terraform module and resource graph
|-- variables.tf                      Input contract and defaults
|-- outputs.tf                        Hand-off values for downstream deployments
|-- providers.tf                      OCI provider configuration
|-- versions.tf                       Terraform and provider constraints
|-- terraform.tfvars.example          Example tfvars shape for this deployment
`-- ansible/
    |-- plan.yml                      Local plan runner
    |-- apply.yml                     Guarded apply runner
    `-- destroy.yml                   Guarded destroy runner
```

## ASCII Architecture

```text
+--------------------------------------------------------------------------------------------------+
| Externally Managed VCNs                                                                           |
|                                                                                                  |
|  Existing OCI network estate                                                                      |
|       |                                                                                          |
|       | supplied as variables                                                                     |
|       v                                                                                          |
|  +----------------------------- Brownfield Inputs -----------------------------+                 |
|  | vcn_ids: logical name -> existing VCN OCID                                  |                 |
|  | subnet_ids: logical name -> existing subnet OCID                            |                 |
|  | drg_id: existing DRG OCID when present                                      |                 |
|  | route_target_ids: firewall, NVA, DRG, or private IP route target OCIDs       |                 |
|  +-------------------------------+---------------------------------------------+                 |
|                                  | normalize into local.external_resource_ids                    |
|                                  v                                                                  |
|  +----------------------------- Output Contract ------------------------------+                 |
|  | resource_ids, vcn_ids, subnet_ids, drg_id, route_target_ids                  |                 |
|  | lets other blueprints consume brownfield resources without creating them      |                 |
|  +----------------------------------------------------------------------------+                 |
|                                                                                                  |
|  Traffic: no packet path is created here; this folder documents and exports already-built paths.   |
+--------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Local output contract | `locals.external_resource_ids` | References existing brownfield resources supplied as variables |

## Request And Deployment Flow

- No OCI network resource is created by this folder.
- Existing VCN, subnet, DRG, and route target OCIDs are normalized into resource_ids.
- Downstream deployments can consume the brownfield output contract without knowing whether the resources were created here.

## Traffic And Trust Boundaries

- Control plane traffic is local operator or CI authentication into the OCI provider and the Ansible Terraform runner.
- Data plane traffic is the packet or service path shown in the ASCII diagram; if this deployment only creates identity or governance resources, the data plane is intentionally permission and signal flow instead of network packets.
- Trust boundaries are the tenancy, compartment, VCN, subnet, DRG, private endpoint, identity domain, or managed service edges shown in the diagram.
- Secrets, OCIDs, customer CIDRs, endpoint URLs, and contact data belong in ignored local tfvars or a secure pipeline variable store, not in committed files.

## State, Inputs, And Outputs

```text
Input sources
|-- terraform.tfvars.example documents expected values for this deployment
|-- local ignored tfvars provide tenancy, compartment, CIDR, endpoint, and service-specific values
|-- environment variables may provide OCI authentication and guarded Ansible confirms
|
Terraform state
|-- backend is disabled for local validation and blueprint-local runners by default
|-- production state backends should be configured outside this reusable blueprint folder
|-- generated .terraform directories, lock files, plans, state files, and local tfvars stay out of git
|
Output contract
|-- blueprint_name
|-- name_prefix
|-- resource_ids
|-- vcn_ids
|-- subnet_ids
|-- drg_id
`-- route_target_ids
```

## Operational Boundaries

- Review enable flags before apply, especially for paid, tenancy-wide, identity, network edge, database, or destructive resources.
- Confirm required external IDs are real and in the intended region and compartment before running `terraform plan`.
- Keep apply and destroy behind the guarded Ansible runners or an equivalent approval gate.
- Treat route tables, firewall policies, ZPR policies, identity policies, and domain replication as change-controlled surfaces.
- Run repository validation before commit or hand-off.

## Review Checklist

- Confirm the diagram matches `main.tf`: `locals.external_resource_ids`.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `terraform output` will expose the hand-off values expected by downstream teams: `blueprint_name`, `name_prefix`, `resource_ids`, `vcn_ids`, `subnet_ids`, `drg_id`, `route_target_ids`.
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

- Terraform modules, resources, data sources, provider aliases, or enable flags change.
- A subnet, route, trust boundary, identity scope, region, compartment, private endpoint, or access path changes.
- A new output becomes part of the contract for downstream deployments or operators.
- README usage notes describe behavior that is not represented in the diagram.

## Terraform + Ansible Deployment Output

This is the expected close-out shape for `blueprints/networking/externally-managed-vcns`. Terraform owns the OCI resource graph and
named outputs; Ansible gives the operator a repeatable plan/apply/destroy wrapper with a
clear recap.

```text
$ cd blueprints/networking/externally-managed-vcns
$ terraform init
$ terraform validate
$ terraform plan -out=tfplan
$ terraform apply tfplan

Apply complete! Resources: <added> added, <changed> changed, <destroyed> destroyed.

$ terraform output
blueprint_name = "<value>"
name_prefix = "<value>"
resource_ids = { ... }
vcn_ids = { ... }
subnet_ids = { ... }
drg_id = "ocid1.<resource>..."
route_target_ids = { ... }
```

```text
$ cd blueprints/networking/externally-managed-vcns
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

For this deployment, keep the output names stable unless the downstream deployment, runbook,
or customer hand-off is updated in the same change.
