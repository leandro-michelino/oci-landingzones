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
    service_mesh_addon = try(oci_containerengine_addon.service_mesh[0].id, null)
    apm_domain         = try(oci_apm_apm_domain.tracing[0].id, null)
  }
}
output "service_mesh_addon_id" {
  description = "OKE service mesh add-on OCID."
  value       = try(oci_containerengine_addon.service_mesh[0].id, null)
}
output "apm_domain_id" {
  description = "APM tracing domain OCID."
  value       = try(oci_apm_apm_domain.tracing[0].id, null)
}
