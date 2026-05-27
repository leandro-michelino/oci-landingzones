resource "oci_identity_group" "this" {
  for_each = local.groups

  compartment_id = var.tenancy_ocid
  name           = each.value.name
  description    = each.value.description
  defined_tags   = var.defined_tags
  freeform_tags  = var.freeform_tags
}
