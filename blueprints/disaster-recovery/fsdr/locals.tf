# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name           = "fsdr"
  name_prefix              = "${var.org}-${var.environment}-${var.region_key}"
  standby_name_prefix      = "${var.org}-${var.environment}-${var.standby_region_key}"
  primary_compartment_ocid = coalesce(var.primary_compartment_ocid, var.compartment_ocid, var.tenancy_ocid)
  standby_compartment_ocid = coalesce(var.standby_compartment_ocid, var.compartment_ocid, var.tenancy_ocid)
  primary_log_bucket_name  = coalesce(var.primary_log_bucket_name, "${local.name_prefix}-fsdr-logs")
  standby_log_bucket_name  = coalesce(var.standby_log_bucket_name, "${local.standby_name_prefix}-fsdr-logs")

  common_freeform_tags = merge(
    var.freeform_tags,
    {
      Blueprint = local.blueprint_name
      Pattern   = "FullStackDisasterRecovery"
    }
  )
}
