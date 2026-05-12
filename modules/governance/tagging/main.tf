resource "oci_identity_tag_namespace" "this" {
  count = var.enable_tagging ? 1 : 0

  compartment_id = var.compartment_ocid
  description    = var.tag_namespace_description
  name           = local.namespace
  is_retired     = false
  defined_tags   = var.defined_tags
  freeform_tags  = var.freeform_tags
}

resource "oci_identity_tag" "this" {
  for_each = var.enable_tagging ? var.tag_definitions : {}

  tag_namespace_id = oci_identity_tag_namespace.this[0].id
  name             = each.key
  description      = each.value.description
  is_cost_tracking = try(each.value.is_cost_tracking, false)
  is_retired       = false
}

resource "oci_identity_tag_default" "this" {
  for_each = var.enable_tagging && var.enable_tag_defaults ? local.tag_defaults : {}

  compartment_id    = each.value.compartment_id
  tag_definition_id = oci_identity_tag.this[each.value.tag_name].id
  value             = each.value.value
  is_required       = each.value.is_required
}
