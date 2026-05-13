# API Gateway Extension

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This deployment README belongs only to `blueprints/extensions/apigw`. It is the run-facing guide for this blueprint; the detailed ASCII design lives beside it in `architecture/README.md`.

## Deployment Purpose

Adds OCI API Gateway resources to an existing landing zone so API exposure, routing, and deployment outputs are managed consistently.

## When To Use This Deployment

- Applications need managed API ingress.
- Gateway subnet placement and endpoint exposure require review.
- API deployment endpoints must be handed off to app teams.

## What This Deploys

The Terraform in this folder wires the following local components:

- Terraform resource `oci_apigateway_gateway.this`
- Terraform resource `oci_apigateway_deployment.this`

The exact OCI behavior is controlled by `variables.tf` and the values supplied in your local ignored `terraform.tfvars` file.

## Folder Contract

```text
blueprints/extensions/apigw/
|-- README.md                  This deployment guide
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

Base tenancy and naming inputs:
- `tenancy_ocid`
- `current_user_ocid`
- `region`
- `home_region`
- `oci_config_profile`
- `org`
- `environment`
- `region_key`
- `defined_tags`
- `freeform_tags`

Deployment-specific inputs to review:
- `compartment_ocid`
- `create_gateway`
- `gateway_id`
- `gateway_label`
- `endpoint_type`
- `subnet_id`
- `network_security_group_ids`
- `certificate_id`
- `deployment_label`
- `path_prefix`
- `routes`

Important enable flags and switches:
- `enable_gateway`
- `enable_deployment`

Review `terraform.tfvars.example` first, then create a local ignored `terraform.tfvars` for real OCIDs, CIDRs, names, recipients, and enable flags.

## Outputs And Hand-Off

This deployment exports the following outputs from `outputs.tf`:

- `blueprint_name`
- `name_prefix`
- `resource_ids`
- `gateway_id`
- `deployment_id`
- `deployment_endpoint`

Use these outputs as the contract for downstream blueprints, runbooks, customer notes, or manual hand-off. If an output name changes, update dependent documentation and consumers in the same change.

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

`apply.yml` and `destroy.yml` are intentionally guarded. Keep that behavior for customer-facing or shared environments.

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

That file documents the ownership boundary, Terraform components, request flow, state and output contract, operational boundaries, review checklist, and the expected Terraform + Ansible output at the end of the deployment.

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

The validator checks Terraform formatting, required deployment README files, required architecture README sections, `terraform init -backend=false`, `terraform validate`, root Ansible syntax, blueprint-local Ansible syntax, optional scanners when installed, and cleanup of generated Terraform artifacts.
