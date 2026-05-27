# Standalone Private Endpoint Only VCN

Start here for `blueprints/networking/standalone-private-endpoint-only`: what it builds, which inputs deserve a careful look, how to run Terraform or the local Ansible wrappers, and where the detailed architecture notes live.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/networking/standalone-private-endpoint-only` |
| Best fit | Creates a private-first VCN shape with private endpoint access and no public application subnet pattern. |
| Terraform shape | `private_vcn` |
| Inputs to settle first | `compartment_ocid`, `vcn_label`, `vcn_dns_label`, `vcn_cidr_block`, `subnets`, `route_tables`, `security_lists` |
| Outputs to hand off | `blueprint_name`, `name_prefix`, `resource_ids`, `vcn_id`, `subnet_ids`, `route_table_ids`, `gateway_ids` |
| Local runner | `terraform plan` for quick iteration; `ansible/plan.yml` and guarded `ansible/apply.yml` for the repo-standard flow. |

## Deployment Purpose

Creates a private-first VCN shape with private endpoint access and no public application
subnet pattern.

## When To Use This Deployment

- The workload should not expose public subnets.
- Private endpoints and service access drive the network design.
- A compact private network is enough for the deployment.

## Practical Use Cases

- **Private service VCN:** Create a minimal private-first network for workloads that should not expose public application subnets.
- **Private endpoint tests:** Validate service access through private endpoints before connecting to a larger hub.
- **Small controlled workload:** Give a team a compact network shape with fewer moving parts than hub-spoke.
- **Security-first demo:** Show private access patterns without building a full landing zone.

## What This Deploys

Everything needed for this deployment starts in this folder: Terraform composes the OCI resource
graph, while the local Ansible files provide the same plan/apply/destroy rhythm everywhere
in the repo.

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Module | `private_vcn` | `modules/networking/spoke-vcn @ v0.2.0` |

Use `variables.tf` as the input contract, then keep real OCIDs, CIDRs, names, and enable flags in an ignored local `terraform.tfvars`.

## Folder Contract

```text
blueprints/networking/standalone-private-endpoint-only/
|-- README.md                  Operator guide for this deployment
|-- architecture/README.md     Detailed Architecture for this deployment
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
| `compartment_ocid` | Compartment OCID where the private VCN is available. Defaults to tenancy_ocid for simple tests. |
| `vcn_label` | Short label for the private VCN. |
| `vcn_dns_label` | DNS label for the private VCN. |
| `vcn_cidr_block` | CIDR block for the private VCN. |
| `subnets` | Private subnet map. |
| `route_tables` | Route tables keyed by logical name. |
| `security_lists` | Security lists keyed by logical name. |

### Enable Flags And Switches

| Input | What To Decide |
| --- | --- |
| `enable_nat_gateway` | Allow controlled outbound internet access through NAT. Disabled by default for private-only deployments. |

## Outputs And Hand-Off

These outputs are the deployment contract for downstream blueprints, runbooks, customer
notes, or manual hand-off. If an output name changes, update dependent docs and consumers in
the same change.

| Output | Hand-Off Meaning |
| --- | --- |
| `blueprint_name` | Blueprint identifier. |
| `name_prefix` | Standard OCI naming prefix for resources created by this blueprint. |
| `resource_ids` | Map of resource identifiers created by this blueprint. |
| `vcn_id` | Private VCN OCID. |
| `subnet_ids` | Subnet OCIDs keyed by role. |
| `route_table_ids` | Route table OCIDs keyed by role. |
| `gateway_ids` | Gateway OCIDs keyed by type. |

## Terraform And Ansible Workflow

Use direct Terraform when you are iterating locally:

```bash
cd blueprints/networking/standalone-private-endpoint-only
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

Use the local Ansible wrapper when you want the same runner shape used across the repo:

```bash
cd blueprints/networking/standalone-private-endpoint-only
ansible-playbook -i localhost, ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, ansible/apply.yml
CONFIRM_DESTROY=true ansible-playbook -i localhost, ansible/destroy.yml
```

`apply.yml` and `destroy.yml` are intentionally guarded. Keep that behavior for
customer or shared environments.

## Deployment Order

1. Deploy or identify the target compartment.
2. Review CIDRs, subnets, gateways, route tables, DNS, and inspection choices.
3. Populate `terraform.tfvars` with customer-specific network values.
4. Run plan and review traffic path changes.
5. Apply, then hand VCN, subnet, DRG, DNS, or inspection outputs to workloads and extensions.

## Architecture

The full detailed Architecture is local to this deployment:

```text
architecture/README.md
```

That file documents the ownership boundary, Terraform components, request flow, state and
output contract, operational boundaries, review checklist, and the expected Terraform +
Ansible output at the end of the deployment.

## What Good Looks Like

- No unintended public application path exists.
- Private endpoint subnets and security lists match the service requirements.
- Route tables send traffic only where intended.
- Connectivity tests run from inside the private network.

## Review Before Apply

- Confirm NAT and service gateway choices.
- Review private endpoint subnet and DNS behavior.
- Validate no public route slips into the design.
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
