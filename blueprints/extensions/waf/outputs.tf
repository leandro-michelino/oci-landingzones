# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
output "blueprint_name" {
  description = "Blueprint identifier."
  value       = local.blueprint_name
}

output "name_prefix" {
  description = "Standard OCI naming prefix for resources created by this blueprint."
  value       = local.name_prefix
}

output "resource_ids" {
  description = "Map of resource identifiers created by this blueprint."
  value = {
    waf_policy       = try(oci_waf_web_app_firewall_policy.this[0].id, null)
    web_app_firewall = try(oci_waf_web_app_firewall.this[0].id, null)
  }
}

output "waf_policy_id" {
  description = "Created or referenced WAF policy OCID."
  value       = local.waf_policy_id
}

output "web_app_firewall_id" {
  description = "Web App Firewall OCID."
  value       = try(oci_waf_web_app_firewall.this[0].id, null)
}
