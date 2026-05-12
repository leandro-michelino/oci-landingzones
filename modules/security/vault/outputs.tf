# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
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

output "resource_ids" {
  description = "Map of resource identifiers created by this module."
  value = merge(
    {
      for key, vault in oci_kms_vault.this : "vault.${key}" => vault.id
    },
    {
      for key, key_resource in oci_kms_key.this : "key.${key}" => key_resource.id
    }
  )
}

output "vault_ids" {
  description = "Map of vault keys to OCIDs."
  value = {
    for key, vault in oci_kms_vault.this : key => vault.id
  }
}

output "vault_names" {
  description = "Map of vault keys to display names."
  value = {
    for key, vault in oci_kms_vault.this : key => vault.display_name
  }
}

output "vault_management_endpoints" {
  description = "Map of vault keys to management endpoints."
  value = {
    for key, vault in oci_kms_vault.this : key => vault.management_endpoint
  }
}

output "vault_crypto_endpoints" {
  description = "Map of vault keys to crypto endpoints."
  value = {
    for key, vault in oci_kms_vault.this : key => vault.crypto_endpoint
  }
}

output "key_ids" {
  description = "Map of KMS key keys to OCIDs."
  value = {
    for key, key_resource in oci_kms_key.this : key => key_resource.id
  }
}
