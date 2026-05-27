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
