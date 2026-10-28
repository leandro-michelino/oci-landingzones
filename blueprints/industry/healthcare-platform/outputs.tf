output "blueprint_name" {
  description = "Stable healthcare infrastructure blueprint identifier."
  value       = local.blueprint_name
}
output "name_prefix" {
  description = "Resolved project naming prefix."
  value       = local.name_prefix
}
output "resource_ids" {
  description = "Created resources only; existing KMS, DRG and backup-policy references are not adopted."
  value = merge(
    { vcn = try(oci_core_vcn.this[0].id, null), load_balancer = try(oci_load_balancer_load_balancer.private[0].id, null), database = try(oci_database_autonomous_database.clinical[0].id, null), documents = try(oci_objectstorage_bucket.documents[0].id, null), log_group = try(oci_logging_log_group.network[0].id, null) },
    { for key, subnet in oci_core_subnet.private : "subnet.${key}" => subnet.id },
    { for key, instance in oci_core_instance.application : "instance.${key}" => instance.id }
  )
}
output "application_private_ips" {
  description = "Private application addresses; backend TLS, health and clinical behavior remain unverified."
  value       = { for key, instance in oci_core_instance.application : key => instance.private_ip }
}
output "database_private_endpoint" {
  description = "Private database endpoint; wallets, users, schemas and application integration remain external."
  value       = try(oci_database_autonomous_database.clinical[0].private_endpoint, null)
}
