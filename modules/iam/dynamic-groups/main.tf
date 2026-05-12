# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
resource "oci_identity_dynamic_group" "this" {
  for_each = local.dynamic_groups

  compartment_id = var.tenancy_ocid
  name           = each.value.name
  description    = each.value.description
  matching_rule  = each.value.matching_rule
  defined_tags   = var.defined_tags
  freeform_tags  = var.freeform_tags
}
