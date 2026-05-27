output "module_name" {
  description = "Module identifier."
  value       = local.module_name
}

output "name_prefix" {
  description = "Standard OCI naming prefix for resources created by this module."
  value       = local.name_prefix
}

output "cis_level" {
  description = "Selected CIS OCI Benchmark profile."
  value       = local.cis_level
}

output "tag_namespace_id" {
  description = "OCID of the landing zone tag namespace."
  value       = try(oci_identity_tag_namespace.this[0].id, null)
}

output "tag_namespace_name" {
  description = "Name of the landing zone tag namespace."
  value       = try(oci_identity_tag_namespace.this[0].name, null)
}

output "tag_definition_ids" {
  description = "Map of tag names to tag definition OCIDs."
  value = {
    for tag_name, tag in oci_identity_tag.this : tag_name => tag.id
  }
}

output "tag_default_ids" {
  description = "Map of tag default keys to tag default OCIDs."
  value = {
    for key, tag_default in oci_identity_tag_default.this : key => tag_default.id
  }
}

output "resource_ids" {
  description = "Map of resource identifiers created by this module."
  value = merge(
    var.enable_tagging ? {
      tag_namespace = oci_identity_tag_namespace.this[0].id
    } : {},
    {
      for tag_name, tag in oci_identity_tag.this : "tag.${tag_name}" => tag.id
    },
    {
      for key, tag_default in oci_identity_tag_default.this : "tag_default.${key}" => tag_default.id
    }
  )
}
