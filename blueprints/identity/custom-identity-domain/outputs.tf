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
    {
      for key, domain in oci_identity_domain.this : "identity_domain.${key}" => domain.id
    },
    {
      for key, replica in oci_identity_domain_replication_to_region.replicas : "replica.${key}" => replica.id
    }
  )
}

output "identity_domain_ids" {
  description = "Identity domain OCIDs keyed by logical name."
  value = {
    for key, domain in oci_identity_domain.this : key => domain.id
  }
}

output "identity_domain_urls" {
  description = "Identity domain URLs keyed by logical name."
  value = {
    for key, domain in oci_identity_domain.this : key => domain.url
  }
}

output "replica_region_ids" {
  description = "Identity domain replication resource IDs keyed by domain and region."
  value = {
    for key, replica in oci_identity_domain_replication_to_region.replicas : key => replica.id
  }
}
