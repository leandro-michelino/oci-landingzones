output "resource_ids" {
  description = "Created OCI identifiers only, not a working transport or migration proof."
  value       = { sddc = module.ocvs.resource_ids.sddc, drg = try(oci_core_drg.this[0].id, null), attachment = try(oci_core_drg_attachment.ocvs[0].id, null), circuits = { for k, c in oci_core_virtual_circuit.site : k => c.id } }
}
output "management_endpoints" {
  description = "Management FQDNs, without passwords."
  value       = module.ocvs.management_endpoints
}
output "network_references" {
  description = "Existing network references, not adopted resources."
  value       = module.ocvs.network_references
}
