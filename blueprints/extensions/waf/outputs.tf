# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
output "blueprint_name" {
  description = "Stable blueprint deployment identifier used for reporting, runbooks, and cross-blueprint automation hand-offs."
  value       = local.blueprint_name
}

output "name_prefix" {
  description = "Resolved OCI naming prefix applied to resources and contracts in this blueprint; reuse it for consistent naming in downstream automation."
  value       = local.name_prefix
}

output "resource_ids" {
  description = "Consolidated map of resource and contract identifiers produced by this blueprint; use it as the primary machine-readable hand-off for integration and runbook steps."
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
