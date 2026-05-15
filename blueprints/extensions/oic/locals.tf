# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name          = "oic"
  name_prefix             = "${var.org}-${var.environment}-${var.region_key}"
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)
  common_freeform_tags = merge(var.freeform_tags, {
    ManagedBy = "Terraform"
    Blueprint = local.blueprint_name
  })
  integration_display_name = coalesce(var.integration_display_name, "${local.name_prefix}-oic")
  integration_instance_id  = var.enable_integration_instance ? oci_integration_integration_instance.this[0].id : var.existing_integration_instance_id
}
