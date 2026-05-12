# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
output "module_name" {
  description = "Module identifier."
  value       = local.module_name
}

output "name_prefix" {
  description = "Standard OCI naming prefix for resources created by this module."
  value       = local.name_prefix
}

output "cis_level" {
  description = "Selected CIS OCI Benchmark profile."
  value       = local.cis_level
}

output "resource_ids" {
  description = "Map of primary resource identifiers created by this module."
  value = {
    policy   = local.policy_id
    firewall = try(oci_network_firewall_network_firewall.this[0].id, null)
  }
}

output "network_firewall_policy_id" {
  description = "OCI Network Firewall policy OCID."
  value       = local.policy_id
}

output "network_firewall_id" {
  description = "OCI Network Firewall OCID."
  value       = try(oci_network_firewall_network_firewall.this[0].id, null)
}

output "network_firewall_private_ip" {
  description = "OCI Network Firewall private IPv4 address."
  value       = try(oci_network_firewall_network_firewall.this[0].ipv4address, null)
}
