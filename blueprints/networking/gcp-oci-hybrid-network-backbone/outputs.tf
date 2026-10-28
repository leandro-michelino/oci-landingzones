output "blueprint_name" {
  description = "Stable blueprint identifier."
  value       = "networking-gcp-oci-hybrid-network-backbone"
}

output "vcn_id" {
  description = "Created private VCN ID."
  value       = try(module.network[0].vcn_id, null)
}

output "subnet_ids" {
  description = "Created private subnet IDs."
  value       = try(module.network[0].subnet_ids, {})
}

output "drg_id" {
  description = "DRG ID; subnet routes remain explicit external prerequisites."
  value       = try(oci_core_drg.this[0].id, null)
}

output "ipsec_ids" {
  description = "OCI IPSec IDs for subsequent tunnel discovery; no active sessions implied."
  value       = { for k, v in oci_core_ipsec.gcp : k => v.id }
}
