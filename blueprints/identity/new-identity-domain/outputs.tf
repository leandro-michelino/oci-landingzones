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
  value = merge(
    var.enable_identity_domain ? {
      identity_domain = oci_identity_domain.this[0].id
    } : {},
    {
      for region, replica in oci_identity_domain_replication_to_region.replicas : "replica.${region}" => replica.id
    }
  )
}

output "identity_domain_id" {
  description = "Created identity domain OCID."
  value       = try(oci_identity_domain.this[0].id, null)
}

output "identity_domain_url" {
  description = "Created identity domain URL."
  value       = try(oci_identity_domain.this[0].url, null)
}

output "replica_region_ids" {
  description = "Identity domain replication resource IDs keyed by replica region."
  value = {
    for region, replica in oci_identity_domain_replication_to_region.replicas : region => replica.id
  }
}
