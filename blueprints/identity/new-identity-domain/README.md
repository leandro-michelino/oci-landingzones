# New Identity Domain

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this page as the operator guide for `blueprints/identity/new-identity-domain`. It tells
you what the blueprint builds, which inputs deserve a real review, how to run Terraform or
the local Ansible wrappers, and where to find the detailed ASCII design.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/identity/new-identity-domain` |
| Best fit | Creates a new OCI identity domain and optional replicas for a single identity boundary. |
| Terraform shape | `oci_identity_domain.this`, `oci_identity_domain_replication_to_region.replicas` |
| Inputs to settle first | `compartment_ocid`, `domain_display_name`, `domain_description`, `license_type`, `admin_email`, `admin_first_name`, `admin_last_name`, plus 5 more |
| Outputs to hand off | `blueprint_name`, `name_prefix`, `resource_ids`, `identity_domain_id`, `identity_domain_url`, `replica_region_ids` |
| Local runner | `terraform plan` for quick iteration; `ansible/plan.yml` and guarded `ansible/apply.yml` for the repo-standard flow. |

## Deployment Purpose

Creates a new OCI identity domain and optional replicas for a single identity boundary.

## When To Use This Deployment

- A new isolated identity domain is required.
- The domain needs a repeatable Terraform record.
- Replica regions are part of the design.

## What This Deploys

This folder is self-contained at the deployment level: Terraform composes the OCI resource
graph, while the local Ansible files provide the same plan/apply/destroy rhythm everywhere
in the repo.

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Resource | `oci_identity_domain.this` | Declared directly in `main.tf` |
| Resource | `oci_identity_domain_replication_to_region.replicas` | Declared directly in `main.tf` |

The exact OCI behavior is controlled by `variables.tf` and the values supplied in your local
ignored `terraform.tfvars` file.

## Folder Contract

```text
blueprints/identity/new-identity-domain/
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
| `org` | Short organization prefix used in names. |
| `environment` | Deployment environment name. |
| `region_key` | Short OCI region key used in resource names. |
| `defined_tags` | Defined tags applied to resources. |
| `freeform_tags` | Freeform tags applied to resources. |

### Deployment-Specific Decisions

| Input | What To Decide |
| --- | --- |
| `compartment_ocid` | Compartment OCID where the identity domain is created. Defaults to tenancy_ocid. |
| `domain_display_name` | Optional display name for the identity domain. |
| `domain_description` | Description for the identity domain. |
| `license_type` | OCI IAM identity domain license type. |
| `admin_email` | Optional administrator email for the identity domain. |
| `admin_first_name` | Optional administrator first name. |
| `admin_last_name` | Optional administrator last name. |
| `admin_user_name` | Optional administrator user name. |
| `is_hidden_on_login` | Hide the domain on the login page. |
| `is_notification_bypassed` | Bypass identity-domain notification emails. |
| `is_primary_email_required` | Require primary email for domain users. |
| `replica_regions` | Optional identity domain replica regions. |

### Enable Flags And Switches

| Input | What To Decide |
| --- | --- |
| `enable_identity_domain` | Create the identity domain. |

## Outputs And Hand-Off

These outputs are the deployment contract for downstream blueprints, runbooks, customer
notes, or manual hand-off. If an output name changes, update dependent docs and consumers in
the same change.

| Output | Hand-Off Meaning |
| --- | --- |
| `blueprint_name` | Blueprint identifier. |
| `name_prefix` | Standard OCI naming prefix for resources created by this blueprint. |
| `resource_ids` | Map of resource identifiers created by this blueprint. |
| `identity_domain_id` | Created identity domain OCID. |
| `identity_domain_url` | Created identity domain URL. |
| `replica_region_ids` | Identity domain replication resource IDs keyed by replica region. |

## Terraform And Ansible Workflow

Use direct Terraform when you are iterating locally:

```bash
cd blueprints/identity/new-identity-domain
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

Use the local Ansible wrapper when you want the same runner shape used across the repo:

```bash
cd blueprints/identity/new-identity-domain
ansible-playbook -i localhost, ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, ansible/apply.yml
CONFIRM_DESTROY=true ansible-playbook -i localhost, ansible/destroy.yml
```

`apply.yml` and `destroy.yml` are intentionally guarded. Keep that behavior for
customer-facing or shared environments.

## Deployment Order

1. Confirm the target tenancy and identity-domain strategy.
2. Review group, dynamic-group, domain, replica, and policy inputs.
3. Populate `terraform.tfvars` with identity naming and scope values.
4. Run plan and inspect IAM or domain impact.
5. Apply, then hand group, domain, and policy outputs to administrators.

## Architecture

The full detailed ASCII architecture is local to this deployment:

```text
architecture/README.md
```

That file documents the ownership boundary, Terraform components, request flow, state and
output contract, operational boundaries, review checklist, and the expected Terraform +
Ansible output at the end of the deployment.

## Review Before Apply

- Confirm display name, description, and license type.
- Review replica regions and IAM permissions.
- Plan federation and application registration separately.
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
