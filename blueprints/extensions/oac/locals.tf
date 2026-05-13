# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name          = "oac"
  name_prefix             = lower(join("-", compact([var.org, var.environment, var.region_key, "oac"])))
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)
  common_freeform_tags = merge(var.freeform_tags, {
    ManagedBy = "Terraform"
    Blueprint = local.blueprint_name
  })
  analytics_instance_name     = coalesce(var.analytics_instance_name, "${local.name_prefix}-oac")
  analytics_instance_id       = var.enable_analytics_instance ? oci_analytics_analytics_instance.this[0].id : var.existing_analytics_instance_id
  private_access_channel_name = coalesce(var.private_access_channel_name, "${local.name_prefix}-pac")
}
