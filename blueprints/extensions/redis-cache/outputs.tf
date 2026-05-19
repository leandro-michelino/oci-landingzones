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
  description = "Map of resource identifiers created or referenced by this blueprint."
  value = {
    redis_cluster = local.redis_cluster_id
    alarms        = { for key, alarm in oci_monitoring_alarm.this : key => alarm.id }
    access_policy = try(oci_identity_policy.access[0].id, null)
    vault_secret  = var.vault_secret_id
  }
}
output "redis_cluster_id" {
  description = "Redis cluster OCID."
  value       = local.redis_cluster_id
}
output "redis_primary_endpoint" {
  description = "Primary Redis endpoint when Terraform creates the cluster."
  value       = try(oci_redis_redis_cluster.this[0].primary_fqdn, null)
}
output "redis_discovery_endpoint" {
  description = "Redis discovery endpoint when Terraform creates the cluster."
  value       = try(oci_redis_redis_cluster.this[0].discovery_fqdn, null)
}
output "vault_secret_id" {
  description = "Vault secret OCID used by application teams for Redis auth material."
  value       = var.vault_secret_id
}
output "alarm_ids" {
  description = "Monitoring alarm OCIDs keyed by logical name."
  value       = { for key, alarm in oci_monitoring_alarm.this : key => alarm.id }
}
output "access_policy_id" {
  description = "IAM policy OCID for Redis access."
  value       = try(oci_identity_policy.access[0].id, null)
}
