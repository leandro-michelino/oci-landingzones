# Variables Reference

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

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
| `compartment_ocid` | `string` | For networking blueprints | Compartment where networking resources are deployed. Defaults to `tenancy_ocid` for simple tests. |
| `vcn_label` | `string` | For standalone blueprints | Short semantic label used in VCN, subnet, route table, and gateway names. |
| `vcn_cidr_block` | `string` | For standalone blueprints | CIDR block for the standalone workload VCN. |
| `hub_vcn_cidr_block` | `string` | For hub-spoke | CIDR block for the hub VCN. |
| `hub_subnets` | `map(object)` | For hub-spoke | Hub subnet definitions such as DMZ, firewall, shared services, and management. |
| `spoke_vcns` | `map(object)` | For hub-spoke | Spoke VCN and subnet definitions. |
| `spoke_route_tables` | `map(object)` | For hub-spoke | Shared spoke route table definitions, usually sending non-local traffic to the DRG. |
| `enable_nat_gateway` | `bool` | For private-only | Enables optional outbound NAT in private-only patterns. Disabled by default. |
| `enable_ipsec` | `bool` | For IPSec | Creates CPE and IPSec resources when real customer network details are approved. Disabled by default. |
| `cpe_ip_address` | `string` | For IPSec | Customer-premises equipment IP address. |
| `on_premises_cidr_blocks` | `list(string)` | For IPSec | CIDR blocks routed over the IPSec VPN. |
| `enable_fastconnect` | `bool` | For FastConnect | Creates a FastConnect virtual circuit when provider and BGP details are ready. Disabled by default. |
| `customer_bgp_asn` | `number` | For FastConnect | Customer BGP ASN for private virtual circuits. |
| `provider_service_id` | `string` | For FastConnect | Provider service OCID for partner FastConnect circuits. |
| `provider_service_key_name` | `string` | For FastConnect | Provider service key/name supplied by the FastConnect partner. |
| `enable_network_firewall` | `bool` | For firewall hub-spoke | Creates OCI Network Firewall and policy resources. Disabled by default for low-cost smoke tests. |
| `firewall_subnet_key` | `string` | For firewall hub-spoke | Hub subnet key where OCI Network Firewall is placed. |
| `enable_bastion` | `bool` | For Bastion hub-spoke | Creates OCI Bastion in the hub. Disabled by default. |
| `client_cidr_block_allow_list` | `list(string)` | For Bastion hub-spoke | Client CIDR blocks allowed to open bastion sessions. |
| `enable_private_dns` | `bool` | For DNS blueprints | Creates private DNS view and zones. |
| `private_zones` | `map(object)` | For DNS blueprints | Private DNS zones keyed by logical name. |
| `attach_private_view_to_vcn_resolvers` | `bool` | For DNS blueprints | Attaches the created private DNS view to hub and spoke VCN resolvers. |
| `enable_zpr_configuration` | `bool` | For ZPR blueprints | Enables ZPR configuration when the customer wants that guardrail. Disabled by default. |
| `enable_zpr_policies` | `bool` | For ZPR blueprints | Creates ZPR policies. Disabled by default. |
| `zpr_policies` | `map(object)` | For ZPR blueprints | ZPR policy definitions and statements. |
| `enable_net_appliance` | `bool` | For NVA blueprints | Creates NVA compute instances when image, AD, and route details are ready. Disabled by default. |
| `enable_reserved_route_ips` | `bool` | For NVA blueprints | Creates reserved private IP route targets for customer-managed or HA appliance designs. |
| `existing_route_target_private_ip_ids` | `map(string)` | For NVA blueprints | Existing appliance private IP OCIDs used for route steering. |
| `secondary_region` | `string` | For dual-region DR | Secondary OCI region for DR networking. |
| `secondary_region_key` | `string` | For dual-region DR | Short region key for the DR region. |

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
