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
    opensearch_cluster = try(oci_opensearch_opensearch_cluster.this[0].id, null)
    snapshot_bucket    = try(oci_objectstorage_bucket.snapshots[0].id, null)
    access_policy      = try(oci_identity_policy.access[0].id, null)
  }
}
output "opensearch_cluster_id" {
  description = "OpenSearch cluster OCID."
  value       = try(oci_opensearch_opensearch_cluster.this[0].id, null)
}
output "opensearch_endpoint" {
  description = "OpenSearch FQDN."
  value       = try(oci_opensearch_opensearch_cluster.this[0].opensearch_fqdn, null)
}
output "opendashboard_endpoint" {
  description = "OpenSearch Dashboard FQDN."
  value       = try(oci_opensearch_opensearch_cluster.this[0].opendashboard_fqdn, null)
}
output "snapshot_bucket_name" {
  description = "Snapshot bucket name."
  value       = try(oci_objectstorage_bucket.snapshots[0].name, null)
}
output "access_policy_id" {
  description = "IAM policy OCID for OpenSearch access."
  value       = try(oci_identity_policy.access[0].id, null)
}
