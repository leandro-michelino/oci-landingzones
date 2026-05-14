# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name          = "postgresql"
  name_prefix             = lower(join("-", compact([var.org, var.environment, var.region_key, "postgresql"])))
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)
  db_system_display_name  = coalesce(var.db_system_display_name, "${local.name_prefix}-db")
  policy_compartment_ocid = coalesce(var.policy_compartment_ocid, var.tenancy_ocid)
  common_freeform_tags = merge(var.freeform_tags, {
    ManagedBy = "Terraform"
    Blueprint = local.blueprint_name
  })
}
