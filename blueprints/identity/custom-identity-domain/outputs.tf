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
  description = "Consolidated map of resource and contract identifiers produced by this blueprint; use it as the primary machine-readable hand-off for integration and runbook steps."
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
