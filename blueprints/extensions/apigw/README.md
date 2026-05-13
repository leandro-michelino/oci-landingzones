# API Gateway Extension

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this page as the operator guide for `blueprints/extensions/apigw`. It tells you what the
blueprint builds, which inputs deserve a real review, how to run Terraform or the local
Ansible wrappers, and where to find the detailed ASCII design.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/extensions/apigw` |
| Best fit | Adds OCI API Gateway resources to an existing landing zone so API exposure, routing, and deployment outputs are managed consistently. |
| Terraform shape | `oci_apigateway_gateway.this`, `oci_apigateway_deployment.this` |
| Inputs to settle first | `compartment_ocid`, `create_gateway`, `gateway_id`, `gateway_label`, `endpoint_type`, `subnet_id`, `network_security_group_ids`, plus 4 more |
| Outputs to hand off | `blueprint_name`, `name_prefix`, `resource_ids`, `gateway_id`, `deployment_id`, `deployment_endpoint` |
| Local runner | `terraform plan` for quick iteration; `ansible/plan.yml` and guarded `ansible/apply.yml` for the repo-standard flow. |

## Deployment Purpose

Adds OCI API Gateway resources to an existing landing zone so API exposure, routing, and
deployment outputs are managed consistently.

## When To Use This Deployment

- Applications need managed API ingress.
- Gateway subnet placement and endpoint exposure require review.
- API deployment endpoints must be handed off to app teams.

## What This Deploys

This folder is self-contained at the deployment level: Terraform composes the OCI resource
graph, while the local Ansible files provide the same plan/apply/destroy rhythm everywhere
in the repo.

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Resource | `oci_apigateway_gateway.this` | Declared directly in `main.tf` |
| Resource | `oci_apigateway_deployment.this` | Declared directly in `main.tf` |

The exact OCI behavior is controlled by `variables.tf` and the values supplied in your local
ignored `terraform.tfvars` file.

## Folder Contract

```text
blueprints/extensions/apigw/
|-- README.md                  Operator guide for this deployment
|-- architecture/README.md     Detailed ASCII architecture for this deployment
|-- main.tf                    Terraform modules, resources, and data sources
|-- variables.tf               Input contract
|-- outputs.tf                 Deployment hand-off values
|-- providers.tf               OCI provider configuration
|-- versions.tf                Terraform and provider constraints
|-- terraform.tfvars.example   Example input shape
`-- ansible/
    |-- plan.yml               Local init, validate, and plan
    |-- apply.yml              Guarded init, validate, plan, and apply
    `-- destroy.yml            Guarded destroy
```

## Inputs To Decide

Start with `terraform.tfvars.example`, then create a local ignored `terraform.tfvars` with
real OCIDs, CIDRs, names, recipients, and enable flags.

### Base Tenancy And Naming

| Input | What To Decide |
| --- | --- |
| `tenancy_ocid` | OCI tenancy OCID. |
| `current_user_ocid` | OCI user OCID used for local execution or bootstrap. |
| `region` | OCI region name. |
| `home_region` | OCI tenancy home region. |
| `oci_config_profile` | Optional OCI CLI config profile for local execution. |
| `org` | Short organization prefix used in names. |
| `environment` | Deployment environment name. |
| `region_key` | Short OCI region key used in resource names. |
| `defined_tags` | Defined tags applied to resources. |
| `freeform_tags` | Freeform tags applied to resources. |

### Deployment-Specific Decisions

| Input | What To Decide |
| --- | --- |
| `compartment_ocid` | Compartment OCID where API Gateway resources are created. Defaults to tenancy_ocid for validation-only tests. |
| `create_gateway` | Create a gateway when enable_gateway is true. Disable when deploying to an existing gateway. |
| `gateway_id` | Existing API Gateway OCID used when create_gateway is false or for deployments on an existing gateway. |
| `gateway_label` | Short API Gateway label used in names. |
| `endpoint_type` | API Gateway endpoint type, usually PUBLIC or PRIVATE. |
| `subnet_id` | Subnet OCID for the API Gateway. |
| `network_security_group_ids` | Optional NSG OCIDs for the API Gateway. |
| `certificate_id` | Optional certificate OCID for the API Gateway. |
| `deployment_label` | Short API deployment label used in names. |
| `path_prefix` | API deployment path prefix. |
| `routes` | API routes created when enable_deployment is true. |

### Enable Flags And Switches

| Input | What To Decide |
| --- | --- |
| `enable_gateway` | Create an API Gateway. Disabled by default to avoid accidental public ingress. |
| `enable_deployment` | Create an API Gateway deployment. Disabled by default until routes and backends are reviewed. |

## Outputs And Hand-Off

These outputs are the deployment contract for downstream blueprints, runbooks, customer
notes, or manual hand-off. If an output name changes, update dependent docs and consumers in
the same change.

| Output | Hand-Off Meaning |
| --- | --- |
| `blueprint_name` | Blueprint identifier. |
| `name_prefix` | Standard OCI naming prefix for resources created by this blueprint. |
| `resource_ids` | Map of resource identifiers created by this blueprint. |
| `gateway_id` | Created or referenced API Gateway OCID. |
| `deployment_id` | API Gateway deployment OCID. |
| `deployment_endpoint` | API Gateway deployment endpoint. |

## Terraform And Ansible Workflow

Use direct Terraform when you are iterating locally:

```bash
cd blueprints/extensions/apigw
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

Use the local Ansible wrapper when you want the same runner shape used across the repo:

```bash
cd blueprints/extensions/apigw
ansible-playbook -i localhost, ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, ansible/apply.yml
CONFIRM_DESTROY=true ansible-playbook -i localhost, ansible/destroy.yml
```

`apply.yml` and `destroy.yml` are intentionally guarded. Keep that behavior for
customer-facing or shared environments.

## Deployment Order

1. Deploy core and the required network foundation first.
2. Confirm service-specific quotas, cost, and dependencies.
3. Populate `terraform.tfvars` with subnet, compartment, and service values.
4. Run plan and review optional resource enable flags.
5. Apply only after the platform or service owner approves the output shape.

## Architecture

The full detailed ASCII architecture is local to this deployment:

```text
architecture/README.md
```

That file documents the ownership boundary, Terraform components, request flow, state and
output contract, operational boundaries, review checklist, and the expected Terraform +
Ansible output at the end of the deployment.

## Review Before Apply

- Confirm public versus private gateway posture.
- Review route definitions and backend integration.
- Coordinate WAF, DNS, auth, and certificates outside the gateway itself.
- Confirm the local `architecture/README.md` still matches `main.tf`, `variables.tf`, and `outputs.tf`.
- Confirm no generated Terraform files, state files, plans, or local tfvars are committed.

## Validation

From the repository root:

```bash
./scripts/validate-all.sh
```

The validator checks Terraform formatting, required deployment README files, required
architecture README sections, `terraform init -backend=false`, `terraform validate`, root
Ansible syntax, blueprint-local Ansible syntax, optional scanners when installed, and
cleanup of generated Terraform artifacts.
