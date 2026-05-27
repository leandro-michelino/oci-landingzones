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
    vcn                = try(oci_core_vcn.opensearch[0].id, null)
    subnet             = try(oci_core_subnet.opensearch[0].id, null)
    nsg                = try(oci_core_network_security_group.opensearch[0].id, null)
    opensearch_cluster = try(oci_opensearch_opensearch_cluster.this[0].id, null)
    snapshot_bucket    = try(oci_objectstorage_bucket.snapshots[0].id, null)
    access_policy      = try(oci_identity_policy.access[0].id, null)
  }
}
output "private_network" {
  description = "Optional private network resources created by this blueprint."
  value = {
    vcn_id    = try(oci_core_vcn.opensearch[0].id, null)
    subnet_id = try(oci_core_subnet.opensearch[0].id, null)
    nsg_id    = try(oci_core_network_security_group.opensearch[0].id, null)
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
