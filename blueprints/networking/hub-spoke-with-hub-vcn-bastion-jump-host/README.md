# Hub-Spoke With Bastion Jump Host

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This deployment README belongs only to `blueprints/networking/hub-spoke-with-hub-vcn-bastion-jump-host`. It is the run-facing guide for this blueprint; the detailed ASCII design lives beside it in `architecture/README.md`.

## Deployment Purpose

Adds a bastion access path to a hub-spoke network so privileged access is explicit and reviewable.

## When To Use This Deployment

- Operators need controlled private access.
- Bastion placement must be part of the network design.
- Privileged access should not be hidden in workload subnets.

## What This Deploys

The Terraform in this folder wires the following local components:

- Terraform module `network`
- Terraform module `bastion`

The exact OCI behavior is controlled by `variables.tf` and the values supplied in your local ignored `terraform.tfvars` file.

## Folder Contract

```text
blueprints/networking/hub-spoke-with-hub-vcn-bastion-jump-host/
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
- `bastion_label`
- `bastion_subnet_key`
- `client_cidr_block_allow_list`
- `max_session_ttl_in_seconds`

Important enable flags and switches:
- `enable_bastion`

Review `terraform.tfvars.example` first, then create a local ignored `terraform.tfvars` for real OCIDs, CIDRs, names, recipients, and enable flags.

## Outputs And Hand-Off

This deployment exports the following outputs from `outputs.tf`:

- `blueprint_name`
- `name_prefix`
- `resource_ids`
- `hub_vcn_id`
- `drg_id`
- `hub_subnet_ids`
- `spoke_vcn_ids`
- `bastion_id`
- `bastion_private_endpoint_ip_address`

Use these outputs as the contract for downstream blueprints, runbooks, customer notes, or manual hand-off. If an output name changes, update dependent documentation and consumers in the same change.

## Terraform And Ansible Workflow

Use direct Terraform when you are iterating locally:

```bash
cd blueprints/networking/hub-spoke-with-hub-vcn-bastion-jump-host
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

Use the local Ansible wrapper when you want the same runner shape used across the repo:

```bash
cd blueprints/networking/hub-spoke-with-hub-vcn-bastion-jump-host
ansible-playbook -i localhost, ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, ansible/apply.yml
CONFIRM_DESTROY=true ansible-playbook -i localhost, ansible/destroy.yml
```

`apply.yml` and `destroy.yml` are intentionally guarded. Keep that behavior for customer-facing or shared environments.

## Deployment Order

1. Deploy or identify the target compartment.
2. Review CIDRs, subnets, gateways, route tables, DNS, and inspection choices.
3. Populate `terraform.tfvars` with customer-specific network values.
4. Run plan and review traffic path changes.
5. Apply, then hand VCN, subnet, DRG, DNS, or inspection outputs to workloads and extensions.

## Architecture

The full detailed ASCII architecture is local to this deployment:

```text
architecture/README.md
```

That file documents the ownership boundary, Terraform components, request flow, state and output contract, operational boundaries, review checklist, and the expected Terraform + Ansible output at the end of the deployment.

## Review Before Apply

- Confirm bastion subnet and access policy.
- Review session target assumptions.
- Keep access approvals separate from network deployment.
- Confirm the local `architecture/README.md` still matches `main.tf`, `variables.tf`, and `outputs.tf`.
- Confirm no generated Terraform files, state files, plans, or local tfvars are committed.

## Validation

From the repository root:

```bash
./scripts/validate-all.sh
```

The validator checks Terraform formatting, required deployment README files, required architecture README sections, `terraform init -backend=false`, `terraform validate`, root Ansible syntax, blueprint-local Ansible syntax, optional scanners when installed, and cleanup of generated Terraform artifacts.
