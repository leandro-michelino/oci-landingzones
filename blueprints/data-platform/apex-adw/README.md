# Oracle APEX On Autonomous Database

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this page as the operator guide for `blueprints/data-platform/apex-adw`.
It tells you what the blueprint builds, which inputs deserve a real review, how
to run Terraform or the local Ansible wrappers, and where to find the detailed
ASCII design.

## At A Glance

| Item | Details |
|---|---|
| Folder | `blueprints/data-platform/apex-adw` |
| Best fit | Private APEX/ORDS ingress and operator hand-off for an existing Autonomous Database. |
| Terraform shape | `data.oci_database_autonomous_database.this`, `oci_load_balancer_load_balancer.this`, `oci_load_balancer_backend_set.ords`, `oci_load_balancer_backend.ords`, `oci_load_balancer_listener.https`, `oci_vault_secret.apex_admin` |
| Inputs to settle first | Existing ADB OCID, ADB private endpoint IP behavior, load balancer subnet/NSGs, listener certificate, DNS name, APEX workspace/admin names, and secret storage model. |
| Outputs to hand off | `blueprint_name`, `name_prefix`, `resource_ids`, `apex_direct_url`, `ords_direct_url`, `apex_private_url`, `load_balancer_id`, `backend_set_name`, `listener_name`, `admin_secret_id`, `apex_details` |
| Local runner | `terraform plan` for quick iteration; `ansible/plan.yml` and guarded `ansible/apply.yml` for the repo-standard flow. |

## Deployment Purpose

Adds a private APEX access layer for an existing Autonomous Database. The
blueprint reads the ADB APEX/ORDS URLs, optionally creates a private flexible
load balancer, wires backend set/listener resources toward ORDS, optionally
stores bootstrap/admin material in Vault, and exposes clean outputs for app,
DBA, and platform teams.

## When To Use This Deployment

- APEX/ORDS is hosted by an existing Autonomous Database.
- Users should access APEX through a private load balancer or internal DNS name.
- APEX admin and workspace bootstrap material needs a Vault-backed hand-off.
- App teams need a repeatable deployment folder instead of manually stitching
  ADB URLs, load balancer backends, certificates, DNS, and secrets together.

## What This Deploys

This folder is self-contained at the deployment level: Terraform composes the
OCI resource graph, while the local Ansible files provide the same
plan/apply/destroy rhythm everywhere in the repo.

| Kind | Name | Source Or Role |
|---|---|---|
| Data source | `data.oci_database_autonomous_database.this` | Reads ADB APEX/ORDS URLs, APEX version details, and private endpoint IP. |
| Resource | `oci_load_balancer_load_balancer.this` | Optional private flexible load balancer. |
| Resource | `oci_load_balancer_backend_set.ords` | Backend set for ORDS traffic. |
| Resource | `oci_load_balancer_backend.ords` | ORDS backend IPs, usually the ADB private endpoint IP. |
| Resource | `oci_load_balancer_listener.https` | HTTPS listener for private APEX access. |
| Resource | `oci_vault_secret.apex_admin` | Optional Vault secret for APEX admin or bootstrap payload. |

APEX workspace creation itself is a database-side operation. This blueprint
keeps that boundary explicit: it stores the approved bootstrap material and
exposes the APEX/ORDS hand-off, while the DBA/APEX owner runs the workspace
bootstrap using the approved customer process.

## Folder Contract

```text
blueprints/data-platform/apex-adw/
|-- README.md                  Operator guide for this deployment
|-- architecture/README.md     Detailed ASCII architecture for this deployment
|-- main.tf                    Terraform resources and data sources
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
`terraform.tfvars` with real OCIDs, certificates, DNS names, and secret content.

### Base Tenancy And Naming

| Input | What To Decide |
|---|---|
| `tenancy_ocid` | OCI tenancy OCID. |
| `current_user_ocid` | OCI user OCID used for local execution or bootstrap. |
| `region` | OCI region name. |
| `home_region` | OCI tenancy home region. |
| `oci_config_profile` | Optional OCI CLI config profile for local execution. |
| `org` | Short organization prefix used in names. |
| `environment` | Deployment environment name. |
| `region_key` | Short OCI region key used in names. |
| `compartment_ocid` | Compartment for APEX support resources; defaults to the ADB compartment when available. |
| `defined_tags` | Defined tags applied to resources. |
| `freeform_tags` | Freeform tags applied to resources. |

### Deployment-Specific Decisions

| Input | What To Decide |
|---|---|
| `autonomous_database_id` | Existing ADB OCID from the `autonomous-database` blueprint or another approved source. |
| `autonomous_database_private_endpoint_ip` | Optional backend IP override when the ADB data source cannot infer it. |
| `apex_workspace_name`, `apex_admin_username` | Workspace and admin hand-off names. |
| `apex_fqdn`, `apex_path` | Internal DNS name and path used for the private APEX URL output. |
| `enable_load_balancer` | Create or configure private LB resources. Disabled by default for safe validation. |
| `load_balancer_subnet_ids`, `load_balancer_network_security_group_ids` | Private LB placement and access control. |
| `listener_certificate_ids` or `listener_certificate_name` | HTTPS certificate source for the listener. |
| `ords_backend_ip_addresses` | Explicit ORDS backend IPs when not using the ADB private endpoint IP. |
| `enable_admin_secret`, `vault_id`, `key_id`, `admin_secret_content_base64` | Vault-backed secret handling for bootstrap/admin material. |

### Enable Flags And Switches

The load balancer and Vault secret are disabled by default. Turn them on only
after subnet, NSG, certificate, DNS, and secret ownership decisions are approved.

## Outputs And Hand-Off

These outputs are the deployment contract for downstream blueprints, runbooks,
customer notes, or manual hand-off. If an output name changes, update dependent
docs and consumers in the same change.

| Output | Hand-Off Meaning |
|---|---|
| `blueprint_name` | Blueprint identifier. |
| `name_prefix` | Standard OCI naming prefix. |
| `resource_ids` | Map of resource identifiers created or referenced by this blueprint. |
| `autonomous_database_id` | ADB OCID hosting APEX. |
| `autonomous_database_private_endpoint_ip` | ADB private endpoint IP used for backend routing. |
| `apex_workspace_name` | Workspace name for the DBA/APEX bootstrap hand-off. |
| `apex_admin_username` | Admin username for the DBA/APEX bootstrap hand-off. |
| `apex_direct_url` | Direct ADB APEX URL from OCI or override. |
| `ords_direct_url` | Direct ADB ORDS URL from OCI or override. |
| `apex_private_url` | Private DNS URL for APEX when `apex_fqdn` is supplied. |
| `load_balancer_id` | Created or referenced load balancer OCID. |
| `backend_set_name` | ORDS backend set name. |
| `listener_name` | Listener name. |
| `ords_backend_ip_addresses` | Backend IPs attached to the ORDS backend set. |
| `admin_secret_id` | Vault secret OCID for bootstrap/admin material. |
| `apex_details` | APEX and ORDS version details returned by ADB. |

## Terraform And Ansible Workflow

Use direct Terraform when you are iterating locally:

```bash
cd blueprints/data-platform/apex-adw
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

Use the local Ansible wrapper when you want the same runner shape used across
the repo:

```bash
cd blueprints/data-platform/apex-adw
ansible-playbook -i localhost, ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, ansible/apply.yml
CONFIRM_DESTROY=true ansible-playbook -i localhost, ansible/destroy.yml
```

`apply.yml` and `destroy.yml` are intentionally guarded. Keep that behavior for
customer-facing or shared environments.

## Deployment Order

1. Deploy or identify the Autonomous Database first.
2. Confirm APEX/ORDS is enabled and reachable through the ADB private endpoint.
3. Confirm private load balancer subnet, NSGs, certificate, and DNS name.
4. Confirm APEX workspace/admin naming and where bootstrap material is stored.
5. Populate local ignored tfvars with real values.
6. Run plan and review backend IPs, certificate wiring, secret behavior, and
   outputs.
7. Apply only after DBA, application, and platform owners approve the shape.

## Architecture

The full detailed ASCII architecture is local to this deployment:

```text
architecture/README.md
```

## Review Before Apply

- Confirm the ADB OCID and private endpoint IP are correct.
- Confirm load balancer subnets and NSGs allow only approved app/admin paths.
- Confirm HTTPS listener certificates and DNS ownership.
- Confirm backend SSL verification behavior is intentional.
- Confirm Vault secret content is supplied only from local ignored tfvars or
  secure pipeline variables.
- Confirm APEX workspace creation is covered by the DBA/APEX bootstrap process.
- Confirm no generated Terraform files, state files, plans, or local tfvars are
  committed.

## Validation

From the repository root:

```bash
./scripts/validate-changed.sh
```

Use `./scripts/validate-all.sh` before release work or broad shared changes.
The validator checks Terraform formatting, required deployment README files,
required architecture README sections, `terraform init -backend=false`,
`terraform validate`, Ansible syntax, optional scanners when installed, and
cleanup of generated Terraform artifacts.
