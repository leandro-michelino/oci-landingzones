# Oracle Integration Cloud

Start here for `blueprints/extensions/oic`: what it builds, which inputs deserve a careful look, how to run Terraform or the local Ansible wrappers, and where the detailed architecture notes live.

## At A Glance

| Item | Details |
|---|---|
| Folder | `blueprints/extensions/oic` |
| Best fit | Private integration platform for SaaS, ERP, and application connectivity. |
| Terraform shape | `oci_integration_integration_instance.this`, `oci_integration_private_endpoint_outbound_connection.this` |
| Inputs to settle first | Base tenancy values plus the deployment-specific enable flags and service IDs in `variables.tf`. |
| Outputs to hand off | `blueprint_name`, `name_prefix`, `resource_ids`, `integration_instance_id`, `integration_display_name`, `integration_instance_state`, `outbound_connection_id` |
| Local runner | `terraform plan` for quick iteration; `ansible/plan.yml` and guarded `ansible/apply.yml` for the repo-standard flow. |

## Deployment Purpose

Deploys an Oracle Integration Cloud instance with optional private outbound connection.

## When To Use This Deployment

- Private integration platform for SaaS, ERP, and application connectivity.
- You need a reusable, reviewable OCI deployment folder with local Terraform and Ansible runners.
- Outputs from this pattern must be handed off to application, platform, or security teams.

## Use Cases

| Use Case | Why This Blueprint Fits |
|---|---|
| SaaS and ERP integration hub | Creates Oracle Integration Cloud for process, SaaS, ERP, and application connectivity. |
| Private outbound integration | Adds private outbound connection support for integrations that must reach private systems. |
| Application modernization | Gives app teams a managed integration layer instead of point-to-point scripts or custom middleware. |
| B2B or workflow automation | Provides a reviewed OIC instance foundation for business process and partner workflows. |
| Secure integration hand-off | Captures license, compartment, private endpoint, and output decisions before platform hand-off. |

## What This Deploys

Everything needed for this deployment starts in this folder: Terraform composes the OCI resource graph, while the local Ansible files provide the same plan/apply/destroy rhythm everywhere in the repo.

| Kind | Name | Source Or Role |
|---|---|---|
| Resource | `oci_integration_integration_instance.this` | Declared directly in `main.tf` |
| Resource | `oci_integration_private_endpoint_outbound_connection.this` | Declared directly in `main.tf` |

Use `variables.tf` as the input contract, then keep real OCIDs, CIDRs, names, and enable flags in an ignored local `terraform.tfvars`.

## Folder Contract

```text
blueprints/extensions/oic/
|-- README.md
|-- architecture/README.md
|-- main.tf
|-- variables.tf
|-- outputs.tf
|-- providers.tf
|-- versions.tf
|-- terraform.tfvars.example
|-- samples/
`-- ansible/
    |-- plan.yml
    |-- apply.yml
    `-- destroy.yml
```

## Samples

Public-safe samples live in `samples/`:

- `basic-instance.tfvars.example` creates a minimal OIC instance in Sao Paulo
  with one message pack, an identity domain, and no private outbound connection.
- `private-outbound-existing-network.tfvars.example` shows the brownfield
  shape for OIC plus a private outbound connection using existing subnet and
  NSG IDs.

Keep real tenancy, compartment, domain, subnet, NSG, and token values in ignored
local tfvars or a secure pipeline variable store.

## Inputs To Decide

Start with `terraform.tfvars.example`, then create a local ignored `terraform.tfvars` with real OCIDs, names, recipients, and enable flags.

### Base Tenancy And Naming

| Input | What To Decide |
|---|---|
| `tenancy_ocid` | Required base value for naming, provider configuration, or compartment targeting. |
| `current_user_ocid` | Required base value for naming, provider configuration, or compartment targeting. |
| `region` | Required base value for naming, provider configuration, or compartment targeting. |
| `org` | Required base value for naming, provider configuration, or compartment targeting. |
| `environment` | Required base value for naming, provider configuration, or compartment targeting. |
| `region_key` | Required base value for naming, provider configuration, or compartment targeting. |
| `compartment_ocid` | Required base value for naming, provider configuration, or compartment targeting. |
| `defined_tags` | Defined tags applied to resources. |
| `freeform_tags` | Freeform tags applied to resources. |

### Deployment-Specific Decisions

Review every variable after the base section in `variables.tf`, especially enable flags, private endpoint IDs, policy statements, notification recipients, and service-specific sizing values.

| Input | What To Decide |
|---|---|
| `is_byol` | Set true only after the integration owner and commercial team confirm eligible Oracle Integration licensing. |
| `enable_integration_instance` | Create the OIC instance. Keep false for validation-only shape checks. |
| `integration_display_name` | Optional display name override for the OIC instance. |
| `integration_instance_type` | OIC instance type, such as `STANDARDX`, after quota and owner review. Legacy `STANDARD`/`ENTERPRISE` types require entitlement. |
| `shape` | OIC shape such as `DEVELOPMENT` or `PRODUCTION` for newer instance types. |
| `domain_id` / `idcs_access_token` | Required by newer OIC instance types. Use an identity domain OCID or a secure IDCS access token source. |
| `message_packs` | Message pack count. Start small for disposable tests. |
| `enable_private_outbound_connection` | Create the private outbound connection when approved subnet and NSG IDs are available. |

### Enable Flags And Switches

All cost-bearing resources are disabled by default where possible. Turn on only the resources approved for the target environment.

## Outputs And Hand-Off

| Output | Hand-Off Meaning |
|---|---|
| `blueprint_name` | Hand-off value for Oracle Integration Cloud. |
| `name_prefix` | Hand-off value for Oracle Integration Cloud. |
| `resource_ids` | Hand-off value for Oracle Integration Cloud. |
| `integration_instance_id` | Hand-off value for Oracle Integration Cloud. |
| `integration_display_name` | OIC display name used by operators and service owners. |
| `integration_instance_state` | OIC lifecycle state when the instance is created by this blueprint. |
| `outbound_connection_id` | Hand-off value for Oracle Integration Cloud. |

## Terraform And Ansible Workflow

```bash
cd blueprints/extensions/oic
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

```bash
cd blueprints/extensions/oic
ansible-playbook -i localhost, ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, ansible/apply.yml
CONFIRM_DESTROY=true ansible-playbook -i localhost, ansible/destroy.yml
```

## Deployment Order

This extension supports extension-only and base-plus-extension customer paths.
For extension-only use, supply existing compartment, VCN, subnet, NSG, and
private endpoint values in local tfvars and run this folder directly. For
base-plus-extension use, deploy core and networking first, then pass their
outputs here.

1. Confirm the target compartment, network/service dependencies, and ownership model.
2. Confirm service-specific quotas, cost, and dependencies.
3. Populate `terraform.tfvars` with real values from approved sources.
4. Run plan and review optional resource enable flags.
5. Apply only after the platform or service owner approves the output shape.

## Real Lifecycle Test

Use this only for an approved disposable OIC test. It attempts a real OIC
create, verifies the instance with OCI CLI when creation succeeds, then runs
destroy and local state cleanup checks.

```bash
OIC_LIFECYCLE_CONFIRM=true \
  scripts/test-oic-lifecycle.sh \
  --profile YOUR_OCI_PROFILE \
  --region sa-saopaulo-1
```

The runner uses `.leo-local/oic-saopaulo.tfvars` by default. Pass
`--keep-resources` only when the OIC instance must remain available for manual
validation before a later cleanup run.

Real test note: newer OIC types such as `STANDARDX` require `domain_id` or
`idcs_access_token`. Legacy `STANDARD` and `ENTERPRISE` types can fail before
resource creation when the tenancy is not entitled for those instance types.
In that case the lifecycle runner still executes destroy and confirms local
state cleanup.

## Architecture

The full detailed Architecture is local to this deployment:

```text
architecture/README.md
```

## Review Before Apply

- Confirm edition, message packs, `is_byol`, and file server decisions.
- Confirm private outbound subnet and NSGs.
- Confirm IDCS/domain authentication inputs when required by tenancy policy.
- Confirm the local `architecture/README.md` still matches `main.tf`, `variables.tf`, and `outputs.tf`.
- Confirm no generated Terraform files, state files, plans, or local tfvars are committed.

## Validation

From the repository root:

```bash
./scripts/validate-all.sh
```

The validator checks Terraform formatting, required deployment README files, required architecture README sections, `terraform init -backend=false`, `terraform validate`, root Ansible syntax, blueprint-local Ansible syntax, optional scanners when installed, and cleanup of generated Terraform artifacts.
