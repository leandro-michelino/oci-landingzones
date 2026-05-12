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
