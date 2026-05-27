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
    cluster   = try(oci_containerengine_cluster.this[0].id, null)
    node_pool = try(oci_containerengine_node_pool.this[0].id, null)
  }
}

output "cluster_id" {
  description = "Created or referenced OKE cluster OCID."
  value       = local.cluster_id
}

output "node_pool_id" {
  description = "OKE node pool OCID."
  value       = try(oci_containerengine_node_pool.this[0].id, null)
}
