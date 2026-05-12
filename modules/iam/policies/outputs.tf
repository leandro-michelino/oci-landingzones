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

output "policy_ids" {
  description = "Map of IAM policy keys to OCIDs."
  value = {
    for key, policy in oci_identity_policy.this : key => policy.id
  }
}

output "policy_names" {
  description = "Map of IAM policy keys to names."
  value = {
    for key, policy in oci_identity_policy.this : key => policy.name
  }
}

output "policy_statements" {
  description = "Map of IAM policy keys to policy statements."
  value = {
    for key, policy in oci_identity_policy.this : key => policy.statements
  }
}

output "resource_ids" {
  description = "Map of resource identifiers created by this module."
  value = {
    for key, policy in oci_identity_policy.this : key => policy.id
  }
}
