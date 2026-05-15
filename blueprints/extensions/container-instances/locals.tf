# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name          = "container-instances"
  name_prefix             = "${var.org}-${var.environment}-${var.region_key}"
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)
  display_name            = coalesce(var.display_name, "${local.name_prefix}-ci")
  hostname_label          = coalesce(var.hostname_label, replace(local.display_name, "-", ""))
  policy_compartment_ocid = coalesce(var.policy_compartment_ocid, var.tenancy_ocid)
  common_freeform_tags = merge(var.freeform_tags, {
    ManagedBy = "Terraform"
    Blueprint = local.blueprint_name
  })
}
