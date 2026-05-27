# Oracle Digital Assistant

Use this page as the operator guide for `blueprints/extensions/digital-assistant`.
It tells you what the blueprint builds, which inputs deserve a real review, how
to run Terraform or local Ansible wrappers, and where to find the detailed
Architecture design.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/extensions/digital-assistant` |
| Best fit | Oracle Digital Assistant landing zone with optional deploy-and-use private endpoint network, ODA instance, private endpoint attachment, and IAM/alert contracts. |
| Terraform shape | `oci_core_vcn.oda`, `oci_core_route_table.oda`, `oci_core_security_list.oda`, `oci_core_subnet.oda`, `oci_core_network_security_group.oda`, `oci_oda_oda_instance.this`, `oci_oda_oda_private_endpoint.this`, `oci_oda_oda_private_endpoint_attachment.this`, `oci_ons_notification_topic.alert`, `terraform_data.oda_network_contract`, `terraform_data.oda_contract` |
| Inputs to settle first | `compartment_ocid`, `create_oda_instance`, `oda_shape_name`, `create_oda_private_endpoint`, `attach_private_endpoint_to_instance`, `enable_oda_network`, `oda_ingress_allowed_cidr`, `oda_egress_allowed_cidr` |
| Outputs to hand off | `blueprint_name`, `name_prefix`, `resource_ids`, `oda_instance_id`, `oda_instance_connector_url`, `oda_private_endpoint_id`, `oda_network_contract`, `oda_operational_contract` |
| Local runner | `terraform plan` for quick iteration; `ansible/plan.yml` and guarded `ansible/apply.yml` for the repo-standard flow. |

## Deployment Purpose

Implements an Oracle Digital Assistant platform blueprint with private endpoint
networking, optional attachment wiring, and operational hand-off contracts for
bot/channel operations.

## When To Use This Deployment

- You need Oracle Digital Assistant in an OCI tenancy.
- You want predictable network and security wiring for private endpoint access.
- You want lifecycle separation between ODA instance and endpoint attachment.
- You need explicit operator outputs for integration runbooks and channel setup.

## Use Cases

| Use Case | Why This Blueprint Fits |
| --- | --- |
| Customer-service virtual assistant | Creates the ODA instance and hand-off outputs needed for bot/channel setup. |
| Private enterprise chatbot | Adds private endpoint wiring so assistant integrations can stay on approved network paths. |
| HR, finance, or IT self-service | Gives internal teams a repeatable assistant platform with clear endpoint and access contracts. |
| Channel integration foundation | Separates ODA instance, endpoint, attachment, alerting, and IAM decisions for review. |
| Conversational AI operations | Produces outputs for operators to manage connector URLs, endpoint IDs, and runbook steps. |

## What This Deploys

This folder is self-contained at the deployment level: Terraform composes the
ODA resource graph and contracts, while local Ansible files provide the same
plan/apply/destroy rhythm used across the repo.

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Resource | `oci_core_vcn.oda`, `oci_core_route_table.oda`, `oci_core_security_list.oda`, `oci_core_subnet.oda`, `oci_core_network_security_group.oda` | Optional deploy-and-use network resources for ODA private endpoint placement. |
| Resource | `oci_oda_oda_instance.this` | ODA instance resource with role-based access and identity-domain options. |
| Resource | `oci_oda_oda_private_endpoint.this` | ODA private endpoint resource. |
| Resource | `oci_oda_oda_private_endpoint_attachment.this` | Optional attachment between ODA instance and ODA private endpoint. |
| Resource | `oci_ons_notification_topic.alert` | Optional alert topic for ODA operations and integrations. |
| Resource | `oci_identity_policy.access` | Optional policy shell for ODA admins/developers/integration callers. |
| Resource | `terraform_data.oda_network_contract` | Network output contract for ODA endpoint placement. |
| Resource | `terraform_data.oda_contract` | ODA instance and endpoint operational contract. |

The exact behavior is controlled by `variables.tf` and values supplied in your
local ignored `terraform.tfvars` file.

## Folder Contract

```text
blueprints/extensions/digital-assistant/
|-- README.md                  Operator guide for this deployment
|-- architecture/README.md     Detailed Architecture for this deployment
|-- main.tf                    Terraform resources and contracts
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

Start with `terraform.tfvars.example`, then create a local ignored
`terraform.tfvars` with real IDs, endpoint decisions, and access policies.

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
| `compartment_ocid` | Compartment OCID for ODA resources. |
| `enable_oda_network` | Create VCN/subnet/route/security resources for private endpoint. |
| `oda_vcn_cidr` and `oda_subnet_cidr` | CIDRs for ODA network resources. |
| `oda_ingress_allowed_cidr` | Allowed source CIDR to private endpoint HTTPS. |
| `oda_egress_allowed_cidr` | Allowed destination CIDR for private endpoint HTTPS egress. |
| `create_oda_instance` | Create ODA instance in this deployment. |
| `oda_shape_name` | ODA shape/edition selection. |
| `oda_identity_domain` | Optional identity domain override. |
| `oda_is_role_based_access` | Enable role-based access mode. |
| `create_oda_private_endpoint` | Create ODA private endpoint. |
| `oda_private_endpoint_subnet_id` | Existing subnet OCID when not creating network resources. |
| `oda_private_endpoint_additional_nsg_ids` | Additional NSG OCIDs for private endpoint. |
| `attach_private_endpoint_to_instance` | Attach endpoint to ODA instance. |
| `create_alert_topic` | Create ODA operations alert topic. |
| `policy_statements` | Optional IAM policy statements for ODA roles. |

## Outputs And Hand-Off

These outputs are the deployment contract for downstream blueprints, runbooks,
customer notes, or manual hand-off. If an output name changes, update dependent
docs and consumers in the same change.

| Output | Hand-Off Meaning |
| --- | --- |
| `blueprint_name` | Blueprint identifier. |
| `name_prefix` | Standard OCI naming prefix for resources created by this blueprint. |
| `resource_ids` | Map of resource IDs created by this blueprint. |
| `oda_instance_id` | ODA instance OCID. |
| `oda_instance_state` | Current ODA instance lifecycle state. |
| `oda_instance_web_app_url` | ODA console URL for operator access. |
| `oda_instance_connector_url` | Connector URL for integration channels. |
| `oda_private_endpoint_id` | ODA private endpoint OCID. |
| `oda_private_endpoint_state` | Private endpoint lifecycle state. |
| `oda_network_contract` | Network hand-off for endpoint placement. |
| `oda_operational_contract` | ODA shape/access/attachment contract. |
| `alert_topic_name` | ODA alert notifications topic name. |

## Terraform And Ansible Workflow

Use direct Terraform when you are iterating locally:

```bash
cd blueprints/extensions/digital-assistant
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

Use the local Ansible wrapper when you want the same runner shape used across
the repo:

```bash
cd blueprints/extensions/digital-assistant
ansible-playbook -i localhost, ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, ansible/apply.yml
CONFIRM_DESTROY=true ansible-playbook -i localhost, ansible/destroy.yml
```

`apply.yml` and `destroy.yml` are intentionally guarded.

## Architecture

The full detailed Architecture is local to this deployment:

```text
architecture/README.md
```

That file documents the ownership boundary, Terraform components, request flow,
traffic boundaries, detailed notes, and review checklist expected for this
blueprint.

## Review Before Apply

- Confirm ODA shape and identity-domain decisions with platform owners.
- Confirm whether private endpoint should be created and attached in this run.
- Confirm endpoint subnet and NSG wiring if using existing network resources.
- Confirm ingress and egress CIDR allowlists are intentionally scoped.
- Confirm policy statements map to intended ODA admin/developer/caller groups.
- Confirm `architecture/README.md` matches `main.tf`, `variables.tf`, and `outputs.tf`.
- Confirm no generated Terraform files, state files, plans, or local tfvars are committed.

## Validation

From the repository root:

```bash
./scripts/validate-all.sh
```

The validator checks Terraform formatting, required deployment README files,
required architecture README sections, `terraform init -backend=false`,
`terraform validate`, root Ansible syntax, blueprint-local Ansible syntax,
optional scanners when installed, and cleanup of generated Terraform artifacts.
