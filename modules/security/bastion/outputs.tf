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
  description = "Map of resource identifiers created by this module."
  value = {
    bastion = try(oci_bastion_bastion.this[0].id, null)
  }
}

output "bastion_id" {
  description = "Bastion OCID."
  value       = try(oci_bastion_bastion.this[0].id, null)
}

output "private_endpoint_ip_address" {
  description = "Bastion private endpoint IP address."
  value       = try(oci_bastion_bastion.this[0].private_endpoint_ip_address, null)
}
