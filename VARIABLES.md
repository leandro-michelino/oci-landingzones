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
| `client_cidr_block_allow_list` | `list(string)` | For Bastion hub-spoke | Client CIDR blocks allowed to open bastion sessions. Required when Bastion is enabled; world-open CIDRs are rejected. |
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

## Operating Entities

| Variable | Type | Required | Description |
|---|---|---:|---|
| `entity_code` | `string` | For single entity | Short operating entity code used in names, such as `fin`, `hr`, or `latam`. |
| `entity_name` | `string` | No | Human-readable operating entity name. |
| `root_compartment_name` | `string` | No | Optional root compartment display-name override for operating entity or workload vending blueprints. |
| `root_compartment_description` | `string` | No | Description used for the generated root compartment. |
| `enable_delete` | `bool` | No | Allows Terraform destroy to delete compartments created by the blueprint. |
| `workload_compartments` | `map(object)` | For single entity | Child compartments created under one operating entity root. |
| `default_workload_compartments` | `map(object)` | For multi-entity | Default child compartments used for entities that do not override their own structure. |
| `operating_entities` | `map(object)` | For multi-entity | Operating entities keyed by stable logical name, with optional code, name, parent, policy compartment, group names, and child compartments. |
| `workload_code` | `string` | For workload vending | Short workload code used in names. |
| `workload_name` | `string` | No | Human-readable workload name. |
| `child_compartments` | `map(object)` | For workload vending | Child compartments created under the workload root, defaulting to app, data, and ops. |
| `admin_group_name` | `string` | No | Optional admin group name override. |
| `operator_group_name` | `string` | No | Optional operator group name override for workload vending. |
| `auditor_group_name` | `string` | No | Optional auditor group name override. |
| `policy_compartment_ocid` | `string` | No | Compartment where delegated policies are attached. Defaults to the parent compartment. |

## Extensions

| Variable | Type | Required | Description |
|---|---|---:|---|
| `enable_cluster` | `bool` | For OKE | Creates an OKE cluster when explicitly enabled. Disabled by default. |
| `enable_node_pool` | `bool` | For OKE | Creates an OKE node pool when explicitly enabled. Disabled by default. |
| `vcn_id` | `string` | For OKE | VCN OCID for the OKE cluster. |
| `endpoint_subnet_id` | `string` | For OKE | Optional subnet OCID for the Kubernetes API endpoint. |
| `node_subnet_ids` | `set(string)` | For OKE | Worker node subnet OCIDs. |
| `enable_gateway` | `bool` | For API Gateway | Creates an API Gateway when explicitly enabled. Disabled by default. |
| `enable_deployment` | `bool` | For API Gateway | Creates an API Gateway deployment and routes when explicitly enabled. |
| `routes` | `list(object)` | For API Gateway | API route definitions including path, methods, backend type, and backend URL. |
| `enable_streaming` | `bool` | For Streaming | Creates Streaming resources when explicitly enabled. Disabled by default. |
| `create_stream_pool` | `bool` | For Streaming | Creates a stream pool instead of using `stream_pool_id`. |
| `streams` | `map(object)` | For Streaming | Streams keyed by logical name, with partitions and optional retention. |
| `enable_waf_policy` | `bool` | For WAF | Creates an OCI WAF policy when explicitly enabled. Disabled by default. |
| `enable_web_app_firewall` | `bool` | For WAF | Attaches a Web App Firewall to a load balancer when explicitly enabled. |
| `load_balancer_id` | `string` | For WAF | Load balancer OCID protected by WAF. |
| `enable_exadata_infrastructure` | `bool` | For Exadata | Creates Exadata Cloud Infrastructure when explicitly enabled. Disabled by default. |
| `availability_domain` | `string` | For Exadata | Availability domain for Exadata placement. |
| `shape` | `string` | For Exadata | Exadata infrastructure shape. |
| `enable_container_repository` | `bool` | For Oracle Functions | Creates an Artifact Registry container repository for function images. Disabled by default. |
| `repository_name` | `string` | For Oracle Functions | Repository leaf name used by the default Functions image repository path. |
| `repository_display_name` | `string` | For Oracle Functions | Optional full repository display name, including slash-separated paths when needed. |
| `repository_url` | `string` | For Oracle Functions | Existing OCIR-compatible repository URL when Terraform does not create the repository. |
| `repository_is_immutable` | `bool` | For Oracle Functions | Makes function image tags immutable when the repository is created by Terraform. |
| `repository_is_public` | `bool` | For Oracle Functions | Makes the repository public. Keep this disabled unless public image access is intentional. |
| `enable_application` | `bool` | For Oracle Functions | Creates or references a Functions application. Disabled by default. |
| `create_application` | `bool` | For Oracle Functions | Creates the Functions application instead of using `application_id`. |
| `application_id` | `string` | For Oracle Functions | Existing Functions application OCID used when `create_application` is false. |
| `application_subnet_ids` | `list(string)` | For Oracle Functions | Subnet OCIDs used by the Functions application runtime. Required when creating the application. |
| `application_network_security_group_ids` | `set(string)` | For Oracle Functions | NSG OCIDs attached to the Functions application. |
| `application_config` | `map(string)` | For Oracle Functions | Application-level configuration values exposed to functions. |
| `image_policy_enabled` | `bool` | For Oracle Functions | Enables signed image policy for the Functions application. |
| `image_policy_kms_key_ids` | `set(string)` | For Oracle Functions | KMS key OCIDs trusted by the signed image policy. |
| `enable_functions` | `bool` | For Oracle Functions | Creates function resources from approved image URLs. Disabled by default. |
| `functions` | `map(object)` | For Oracle Functions | Functions keyed by logical name, including image URL, memory, timeout, config, tracing, concurrency, and async destinations. |
| `enable_api_gateway` | `bool` | For Oracle Functions | Creates or references an API Gateway for function routes. Disabled by default. |
| `create_gateway` | `bool` | For Oracle Functions | Creates the API Gateway instead of using `gateway_id`. |
| `gateway_id` | `string` | For Oracle Functions | Existing API Gateway OCID used when `create_gateway` is false. |
| `gateway_endpoint_type` | `string` | For Oracle Functions | API Gateway endpoint type, `PRIVATE` or `PUBLIC`. Defaults to `PRIVATE`. |
| `gateway_subnet_id` | `string` | For Oracle Functions | Subnet OCID for API Gateway placement when creating a gateway. |
| `gateway_network_security_group_ids` | `set(string)` | For Oracle Functions | NSG OCIDs for the API Gateway. |
| `enable_api_gateway_deployment` | `bool` | For Oracle Functions | Creates an API Gateway deployment that routes to functions. Disabled by default. |
| `default_api_function_key` | `string` | For Oracle Functions | Function key used to create the default route. Must match a key in `functions`. |
| `api_routes` | `map(object)` | For Oracle Functions | API Gateway routes keyed by logical name, each pointing at exactly one `function_key` or `function_id`. |
| `enable_event_rules` | `bool` | For Oracle Functions | Creates OCI Events rules that invoke functions. Disabled by default. |
| `event_rules` | `map(object)` | For Oracle Functions | Events rules keyed by logical name, with FAAS actions pointing at `function_key` or `function_id`. |
| `policy_statements` | `list(string)` | For Oracle Functions | Optional IAM policy statements for Functions, repository, gateway, Events, deployers, and invokers. |

## Security And Governance

| Variable | Type | Required | Description |
|---|---|---:|---|
| `enable_logging` | `bool` | No | Create governance log groups and optional service logs. |
| `log_groups` | `map(object)` | No | Additional or overriding governance log groups keyed by logical name. |
| `service_logs` | `map(object)` | No | OCI service logs keyed by logical name; requires source resource OCIDs. |
| `vcn_flow_logs` | `map(object)` | No | Convenience VCN flow log definitions keyed by logical name. |
| `logging_saved_searches` | `map(object)` | No | OCI Logging saved searches keyed by logical name. |
| `enable_audit_retention` | `bool` | No | Configure tenancy audit retention. Generic core disables this by default; CIS wrappers enable it by default. |
| `audit_retention_period_days` | `number` | No | Tenancy audit retention in days when audit retention is managed. |
| `cloud_guard_enabled` | `bool` | No | Enable Cloud Guard configuration and a default landing zone target. |
| `cloud_guard_detector_recipe_ids` | `set(string)` | No | Detector recipe OCIDs attached to the default Cloud Guard target. |
| `cloud_guard_responder_recipe_ids` | `set(string)` | No | Responder recipe OCIDs attached to the default Cloud Guard target. |
| `cloud_guard_targets` | `map(object)` | No | Additional Cloud Guard targets keyed by logical name. |
| `vault_enabled` | `bool` | No | Create OCI Vault and KMS keys. Disabled by default. |
| `vaults` | `map(object)` | No | Additional OCI Vaults keyed by logical name. |
| `vault_keys` | `map(object)` | No | KMS keys keyed by logical name. |
| `security_zones_enabled` | `bool` | No | Create OCI Security Zones. Disabled by default because Security Zones enforce guardrails on protected compartments. |
| `default_security_zone_recipe_id` | `string` | No | Security recipe OCID used by the default landing zone Security Zone. |
| `security_zones` | `map(object)` | No | Additional Security Zones keyed by logical name. |
| `vss_enabled` | `bool` | No | Create Vulnerability Scanning Service host and container scan resources. Disabled by default. |
| `host_scan_recipes` | `map(object)` | No | VSS host scan recipes keyed by logical name. |
| `host_scan_targets` | `map(object)` | No | VSS host scan targets keyed by logical name. |
| `container_scan_recipes` | `map(object)` | No | VSS container image scan recipes keyed by logical name. |
| `container_scan_targets` | `map(object)` | No | VSS container image scan targets keyed by logical name. |
| `enable_budgets` | `bool` | No | Create OCI Budgets resources. Generic core disables this by default; CIS wrappers create budgets only when thresholds are supplied. |
| `default_budget_amount` | `number` | No | Amount for the default landing zone budget. Leave null to skip default budget creation. |
| `default_budget_alert_recipients` | `set(string)` | No | Email recipients for the default budget alert rule. |
| `budgets` | `map(object)` | No | Additional OCI Budgets and alert rules keyed by logical name. |
| `enable_events` | `bool` | No | Create OCI Events and Notifications resources. Generic core disables this by default; CIS wrappers enable default governance events. |
| `event_notification_topics` | `map(object)` | No | ONS notification topics keyed by logical name. |
| `event_subscriptions` | `map(object)` | No | ONS subscriptions keyed by logical name; endpoints should stay in local ignored tfvars. |
| `event_rules` | `map(object)` | No | Additional or overriding OCI Events rules keyed by logical name. |
| `monitoring_enabled` | `bool` | No | Create Monitoring alarms and optional notification resources. Disabled by default. |
| `monitoring_subscriptions` | `map(object)` | No | ONS subscriptions for Monitoring alarms; endpoints should stay in local ignored tfvars. |
| `monitoring_alarms` | `map(object)` | No | OCI Monitoring alarms keyed by logical name. |
| `budget_amount` | `number` | CIS wrappers | Optional default CIS budget threshold. |
| `budget_alert_recipients` | `set(string)` | CIS wrappers | Email recipients for the default CIS budget alert rule. |
