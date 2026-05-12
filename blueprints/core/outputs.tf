# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
output "blueprint_name" {
  description = "Blueprint identifier."
  value       = local.blueprint_name
}

output "name_prefix" {
  description = "Standard OCI naming prefix for resources created by this blueprint."
  value       = local.name_prefix
}

output "cis_level" {
  description = "Selected CIS OCI Benchmark profile, when this core is wrapped by a CIS blueprint."
  value       = var.cis_level == null ? null : lower(var.cis_level)
}

output "root_compartment_id" {
  description = "OCID of the landing zone root compartment."
  value       = module.compartments.root_compartment_id
}

output "compartment_ids" {
  description = "Map of landing zone compartment keys to OCIDs."
  value       = module.compartments.compartment_ids
}

output "network_compartment_id" {
  description = "OCID of the landing zone network compartment."
  value       = module.compartments.compartment_ids["network"]
}

output "security_compartment_id" {
  description = "OCID of the landing zone security compartment."
  value       = module.compartments.compartment_ids["security"]
}

output "governance_compartment_id" {
  description = "OCID of the landing zone governance compartment."
  value       = module.compartments.compartment_ids["governance"]
}

output "workloads_compartment_id" {
  description = "OCID of the landing zone workloads compartment."
  value       = module.compartments.compartment_ids["workloads"]
}

output "compartment_names" {
  description = "Map of landing zone compartment keys to display names."
  value       = module.compartments.compartment_names
}

output "tag_namespace_id" {
  description = "OCID of the landing zone tag namespace."
  value       = module.tagging.tag_namespace_id
}

output "tag_namespace_name" {
  description = "Name of the landing zone tag namespace."
  value       = module.tagging.tag_namespace_name
}

output "tag_definition_ids" {
  description = "Map of landing zone tag names to tag definition OCIDs."
  value       = module.tagging.tag_definition_ids
}

output "log_group_ids" {
  description = "Map of governance log group keys to OCIDs."
  value       = module.logging.log_group_ids
}

output "log_group_names" {
  description = "Map of governance log group keys to display names."
  value       = module.logging.log_group_names
}

output "service_log_ids" {
  description = "Map of governance service log keys to OCIDs."
  value       = module.logging.service_log_ids
}

output "logging_saved_search_ids" {
  description = "Map of logging saved search keys to OCIDs."
  value       = module.logging.saved_search_ids
}

output "audit_configuration_id" {
  description = "OCID of the tenancy audit configuration when managed by the core blueprint."
  value       = module.logging.audit_configuration_id
}

output "cloud_guard_configuration_id" {
  description = "OCID of the Cloud Guard configuration when managed by the core blueprint."
  value       = module.cloud_guard.cloud_guard_configuration_id
}

output "cloud_guard_target_ids" {
  description = "Map of Cloud Guard target keys to OCIDs."
  value       = module.cloud_guard.target_ids
}

output "cloud_guard_target_names" {
  description = "Map of Cloud Guard target keys to display names."
  value       = module.cloud_guard.target_names
}

output "vault_ids" {
  description = "Map of vault keys to OCIDs."
  value       = module.vault.vault_ids
}

output "vault_management_endpoints" {
  description = "Map of vault keys to management endpoints."
  value       = module.vault.vault_management_endpoints
}

output "vault_crypto_endpoints" {
  description = "Map of vault keys to crypto endpoints."
  value       = module.vault.vault_crypto_endpoints
}

output "vault_key_ids" {
  description = "Map of KMS key keys to OCIDs."
  value       = module.vault.key_ids
}

output "security_zone_ids" {
  description = "Map of Security Zone keys to OCIDs."
  value       = module.security_zones.security_zone_ids
}

output "security_zone_names" {
  description = "Map of Security Zone keys to display names."
  value       = module.security_zones.security_zone_names
}

output "security_zone_target_ids" {
  description = "Map of Security Zone keys to target OCIDs."
  value       = module.security_zones.security_zone_target_ids
}

output "budget_ids" {
  description = "Map of budget keys to OCIDs."
  value       = module.budgets.budget_ids
}

output "budget_names" {
  description = "Map of budget keys to display names."
  value       = module.budgets.budget_names
}

output "budget_alert_rule_ids" {
  description = "Map of budget alert rule keys to OCIDs."
  value       = module.budgets.budget_alert_rule_ids
}

output "event_notification_topic_ids" {
  description = "Map of event notification topic keys to OCIDs."
  value       = module.events.notification_topic_ids
}

output "event_notification_topic_names" {
  description = "Map of event notification topic keys to names."
  value       = module.events.notification_topic_names
}

output "event_subscription_ids" {
  description = "Map of event subscription keys to OCIDs."
  value       = module.events.subscription_ids
}

output "event_rule_ids" {
  description = "Map of event rule keys to OCIDs."
  value       = module.events.event_rule_ids
}

output "event_rule_names" {
  description = "Map of event rule keys to display names."
  value       = module.events.event_rule_names
}

output "group_ids" {
  description = "Map of IAM group keys to OCIDs."
  value       = module.groups.group_ids
}

output "group_names" {
  description = "Map of IAM group keys to names."
  value       = module.groups.group_names
}

output "dynamic_group_ids" {
  description = "Map of dynamic group keys to OCIDs."
  value       = module.dynamic_groups.dynamic_group_ids
}

output "dynamic_group_names" {
  description = "Map of dynamic group keys to names."
  value       = module.dynamic_groups.dynamic_group_names
}

output "policy_ids" {
  description = "Map of IAM policy keys to OCIDs."
  value       = module.policies.policy_ids
}

output "policy_names" {
  description = "Map of IAM policy keys to names."
  value       = module.policies.policy_names
}

output "resource_ids" {
  description = "Map of resource identifiers created by this blueprint."
  value = {
    compartments   = module.compartments.resource_ids
    dynamic_groups = module.dynamic_groups.resource_ids
    groups         = module.groups.resource_ids
    policies       = module.policies.resource_ids
    tag_namespace  = module.tagging.tag_namespace_id
    tags           = module.tagging.tag_definition_ids
    logging        = module.logging.resource_ids
    cloud_guard    = module.cloud_guard.resource_ids
    vault          = module.vault.resource_ids
    security_zones = module.security_zones.resource_ids
    budgets        = module.budgets.resource_ids
    events         = module.events.resource_ids
  }
}
