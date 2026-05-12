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
  value = merge(
    { for key, appliance in oci_core_instance.appliance : "appliance_${key}" => appliance.id },
    { for key, private_ip in oci_core_private_ip.route_target : "route_target_private_ip_${key}" => private_ip.id }
  )
}

output "appliance_instance_ids" {
  description = "NVA compute instance OCIDs keyed by logical appliance name."
  value       = { for key, appliance in oci_core_instance.appliance : key => appliance.id }
}

output "appliance_private_ips" {
  description = "NVA primary private IP addresses keyed by logical appliance name."
  value       = { for key, appliance in oci_core_instance.appliance : key => appliance.private_ip }
}

output "reserved_route_target_private_ip_ids" {
  description = "Reserved private IP OCIDs keyed by route target name."
  value       = { for key, private_ip in oci_core_private_ip.route_target : key => private_ip.id }
}

output "route_target_private_ip_ids" {
  description = "Route target private IP OCIDs, including existing and module-created targets."
  value       = merge(var.existing_route_target_private_ip_ids, { for key, private_ip in oci_core_private_ip.route_target : key => private_ip.id })
}
