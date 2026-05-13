# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
output "blueprint_name" {
  description = "Blueprint identifier."
  value       = local.blueprint_name
}

output "name_prefix" {
  description = "Standard OCI naming prefix for primary-region resources."
  value       = local.name_prefix
}

output "standby_name_prefix" {
  description = "Standard OCI naming prefix for standby-region resources."
  value       = local.standby_name_prefix
}

output "resource_ids" {
  description = "Map of resource identifiers created by this blueprint."
  value = merge(
    var.enable_dr_log_buckets ? {
      primary_log_bucket = oci_objectstorage_bucket.primary_dr_logs[0].id
      standby_log_bucket = oci_objectstorage_bucket.standby_dr_logs[0].id
    } : {},
    var.enable_dr_protection_groups ? {
      primary_dr_protection_group = oci_disaster_recovery_dr_protection_group.primary[0].id
      standby_dr_protection_group = oci_disaster_recovery_dr_protection_group.standby[0].id
    } : {},
    var.enable_dr_plan && var.enable_dr_protection_groups ? {
      primary_dr_plan = oci_disaster_recovery_dr_plan.primary[0].id
    } : {}
  )
}

output "primary_dr_protection_group_id" {
  description = "Primary DR protection group OCID."
  value       = try(oci_disaster_recovery_dr_protection_group.primary[0].id, null)
}

output "standby_dr_protection_group_id" {
  description = "Standby DR protection group OCID."
  value       = try(oci_disaster_recovery_dr_protection_group.standby[0].id, null)
}

output "primary_log_bucket_name" {
  description = "Primary DR log bucket name."
  value       = local.primary_log_bucket_name
}

output "standby_log_bucket_name" {
  description = "Standby DR log bucket name."
  value       = local.standby_log_bucket_name
}

output "primary_dr_plan_id" {
  description = "Primary DR plan OCID."
  value       = try(oci_disaster_recovery_dr_plan.primary[0].id, null)
}
