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
    { private_view = try(oci_dns_view.private[0].id, null) },
    { for key, zone in oci_dns_zone.private : "zone_${key}" => zone.id },
    { for key, endpoint in oci_dns_resolver_endpoint.this : "resolver_endpoint_${key}" => endpoint.id }
  )
}

output "private_view_id" {
  description = "Private DNS view OCID."
  value       = try(oci_dns_view.private[0].id, null)
}

output "private_zone_ids" {
  description = "Private DNS zone OCIDs keyed by logical zone name."
  value       = { for key, zone in oci_dns_zone.private : key => zone.id }
}

output "vcn_resolver_ids" {
  description = "VCN resolver OCIDs keyed by VCN key."
  value       = { for key, resolver in data.oci_core_vcn_dns_resolver_association.this : key => resolver.dns_resolver_id }
}

output "resolver_endpoint_ids" {
  description = "DNS resolver endpoint OCIDs keyed by endpoint key."
  value       = { for key, endpoint in oci_dns_resolver_endpoint.this : key => endpoint.id }
}
