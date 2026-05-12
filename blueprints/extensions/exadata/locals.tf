# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name          = "extensions-exadata"
  name_prefix             = "${var.org}-${var.environment}-${var.region_key}"
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)
  infrastructure_name     = "${local.name_prefix}-exadata-${var.exadata_label}"
  common_freeform_tags = merge(
    var.freeform_tags,
    {
      Blueprint = local.blueprint_name
    }
  )
}
