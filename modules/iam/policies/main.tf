resource "oci_identity_policy" "this" {
  for_each = local.policies

  compartment_id = each.value.compartment_id
  name           = each.value.name
  description    = each.value.description
  statements     = each.value.statements
  defined_tags   = var.defined_tags
  freeform_tags  = var.freeform_tags
}
