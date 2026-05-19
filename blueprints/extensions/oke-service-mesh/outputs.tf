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
