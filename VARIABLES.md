# Variables Reference

This file tracks global variables shared by blueprints and modules. Blueprint
READMEs may define additional variables for local behavior.

## Core Identity

| Variable | Type | Required | Description |
|---|---|---:|---|
| `tenancy_ocid` | `string` | Yes | OCI tenancy OCID. |
| `current_user_ocid` | `string` | Yes | User OCID used during bootstrap or local execution. |
| `region` | `string` | Yes | OCI region name, such as `eu-frankfurt-1`. |
| `home_region` | `string` | No | Tenancy home region used for Identity create/update/delete operations when different from `region`. |
| `oci_config_profile` | `string` | No | Optional OCI CLI config profile for local Terraform execution. |
| `parent_compartment_ocid` | `string` | No | Parent compartment for the landing zone root compartment. Defaults to `tenancy_ocid`; use local ignored files for ephemeral test compartments. |

## Organization Context

| Variable | Type | Required | Description |
|---|---|---:|---|
| `org` | `string` | Yes | Short organization prefix used in names and tags. |
| `environment` | `string` | Yes | Deployment environment such as `dev`, `uat`, `prod`, or `dr`. |
| `region_key` | `string` | Yes | Short OCI region key used in resource names. |
| `cis_level` | `string` | Internal | Fixed by dedicated CIS landing zone blueprints. Generic blueprints omit this unless composing CIS behavior explicitly. |

## Tagging

| Variable | Type | Required | Description |
|---|---|---:|---|
| `defined_tags` | `map(string)` | No | Defined tags applied to resources. |
| `freeform_tags` | `map(string)` | No | Freeform tags applied to resources. |
| `tag_namespace_name` | `string` | No | Optional tag namespace name override, useful for ephemeral tests. |
| `enable_tagging` | `bool` | No | Create the landing zone tag namespace, tag definitions, and tag defaults. Disable for fast ephemeral tests. |
| `enable_tag_defaults` | `bool` | No | Create tag defaults for landing zone compartments. Disable for faster tests while keeping tag definitions. |
| `tag_default_values` | `map(string)` | No | Default values for the landing zone tag namespace. |
| `required_tag_defaults` | `set(string)` | No | Tag names whose defaults should be marked required. |
| `enable_default_iam_groups` | `bool` | No | Create default landing zone IAM groups. Disable only for quota-constrained ephemeral tests. |
| `iam_groups` | `map(object)` | No | Additional or overriding IAM groups keyed by logical role. |
| `enable_default_dynamic_groups` | `bool` | No | Create default dynamic groups for platform automation and workload instances. |
| `iam_dynamic_groups` | `map(object)` | No | Additional or overriding dynamic groups keyed by logical role. |
| `enable_default_iam_policies` | `bool` | No | Create default least-privilege IAM policies for the core landing zone. |
| `iam_policies` | `map(object)` | No | Additional or overriding IAM policies keyed by logical role. |
| `cost_center` | `string` | No | Finance or chargeback cost center. |
| `owner` | `string` | No | Owning team or operating entity. |
| `project` | `string` | No | Project or workload identifier. |

## Networking

| Variable | Type | Required | Description |
|---|---|---:|---|
| `hub_vcn_cidr` | `string` | For hub-spoke | CIDR block for the hub VCN. |
| `hub_dmz_cidr` | `string` | For hub-spoke | CIDR block for public or DMZ hub subnet. |
| `hub_fw_cidr` | `string` | For inspected hub-spoke | CIDR block for firewall or inspection subnet. |
| `hub_mgmt_cidr` | `string` | For hub-spoke | CIDR block for management subnet. |
| `spoke_vcns` | `map(object)` | For hub-spoke | Spoke VCN and subnet definitions. |

## Security And Governance

| Variable | Type | Required | Description |
|---|---|---:|---|
| `cloud_guard_enabled` | `bool` | No | Enable Cloud Guard targets and recipes. |
| `security_zones_enabled` | `bool` | No | Enable Security Zone policies. |
| `vss_enabled` | `bool` | No | Enable Vulnerability Scanning Service configuration. |
| `bastion_enabled` | `bool` | No | Enable OCI Bastion resources where supported. |
| `network_firewall_enabled` | `bool` | No | Enable OCI Network Firewall for supported blueprints. |
| `budget_alert_email` | `string` | No | Email destination for budget alerts. |
| `budget_amount` | `number` | No | Monthly or project budget threshold. |
| `log_retention_days` | `number` | No | Retention period for configured logs. |
