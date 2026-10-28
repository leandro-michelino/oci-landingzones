output "blueprint_name" { value = local.blueprint_name }
output "name_prefix" { value = local.name_prefix }
output "resource_ids" {
  value = {
    oci_vcn         = try(oci_core_vcn.this[0].id, null)
    oci_subnet      = try(oci_core_subnet.this[0].id, null)
    oci_drg         = try(oci_core_drg.this[0].id, null)
    gcp_vpc         = try(google_compute_network.this[0].id, null)
    gcp_subnet      = try(google_compute_subnetwork.this[0].id, null)
    gcp_router      = try(google_compute_router.this[0].id, null)
    gcp_attachments = { for key, attachment in google_compute_interconnect_attachment.this : key => attachment.id }
    oci_circuits    = { for key, circuit in oci_core_virtual_circuit.this : key => circuit.id }
  }
}
output "pairing_keys" {
  sensitive = true
  value     = { for key, attachment in google_compute_interconnect_attachment.this : key => attachment.pairing_key }
}
