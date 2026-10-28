output "blueprint_name" {
  description = "Stable blueprint identifier."
  value       = "disaster-recovery-gcp-oci-cross-cloud-dr"
}

output "vcn_id" {
  description = "Created private VCN ID."
  value       = try(module.network[0].vcn_id, null)
}

output "subnet_ids" {
  description = "Created private subnet IDs."
  value       = try(module.network[0].subnet_ids, {})
}

output "backup_bucket" {
  description = "Private source backup bucket; no objects or transfer job are created."
  value       = try(oci_objectstorage_bucket.backup[0].name, null)
}
