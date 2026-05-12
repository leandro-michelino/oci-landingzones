# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
resource "oci_zpr_configuration" "this" {
  count = var.enable_zpr_configuration ? 1 : 0

  compartment_id = var.compartment_ocid
  zpr_status     = var.zpr_status
  defined_tags   = var.defined_tags
  freeform_tags = merge(
    var.freeform_tags,
    {
      Blueprint = local.module_name
    }
  )
}

resource "oci_zpr_zpr_policy" "this" {
  for_each = var.enable_zpr_policies ? var.zpr_policies : {}

  compartment_id = var.compartment_ocid
  name           = each.value.name
  description    = each.value.description
  statements     = each.value.statements
  defined_tags   = var.defined_tags
  freeform_tags = merge(
    var.freeform_tags,
    {
      Blueprint = local.module_name
    }
  )
}
