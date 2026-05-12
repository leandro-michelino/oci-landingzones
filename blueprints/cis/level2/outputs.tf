# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
output "blueprint_name" {
  description = "Blueprint identifier."
  value       = local.blueprint_name
}

output "cis_level" {
  description = "Fixed CIS OCI Benchmark profile for this blueprint."
  value       = local.cis_level
}

output "name_prefix" {
  description = "Standard OCI naming prefix for resources created by this blueprint."
  value       = local.name_prefix
}

output "resource_ids" {
  description = "Map of resource identifiers created by this blueprint."
  value       = module.core.resource_ids
}

output "root_compartment_id" {
  description = "OCID of the CIS landing zone root compartment."
  value       = module.core.root_compartment_id
}

output "compartment_ids" {
  description = "Map of CIS landing zone compartment keys to OCIDs."
  value       = module.core.compartment_ids
}

output "group_names" {
  description = "Map of IAM group keys to names."
  value       = module.core.group_names
}

output "policy_names" {
  description = "Map of IAM policy keys to names."
  value       = module.core.policy_names
}

output "vault_ids" {
  description = "Map of vault keys to OCIDs."
  value       = module.core.vault_ids
}

output "vault_key_ids" {
  description = "Map of KMS key keys to OCIDs."
  value       = module.core.vault_key_ids
}

output "security_zone_ids" {
  description = "Map of Security Zone keys to OCIDs."
  value       = module.core.security_zone_ids
}

output "vss_host_scan_target_ids" {
  description = "Map of VSS host scan target keys to OCIDs."
  value       = module.core.vss_host_scan_target_ids
}

output "budget_ids" {
  description = "Map of budget keys to OCIDs."
  value       = module.core.budget_ids
}

output "event_rule_ids" {
  description = "Map of event rule keys to OCIDs."
  value       = module.core.event_rule_ids
}

output "event_notification_topic_ids" {
  description = "Map of event notification topic keys to OCIDs."
  value       = module.core.event_notification_topic_ids
}

output "monitoring_alarm_ids" {
  description = "Map of monitoring alarm keys to OCIDs."
  value       = module.core.monitoring_alarm_ids
}
