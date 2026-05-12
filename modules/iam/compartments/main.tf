# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
resource "oci_identity_compartment" "root" {
  compartment_id = var.compartment_ocid
  name           = local.root_name
  description    = var.root_compartment_description
  enable_delete  = var.enable_delete
  defined_tags   = var.defined_tags
  freeform_tags  = var.freeform_tags
}

resource "oci_identity_compartment" "children" {
  for_each = local.child_compartments

  compartment_id = oci_identity_compartment.root.id
  name           = each.value.name
  description    = each.value.description
  enable_delete  = each.value.enable_delete
  defined_tags   = var.defined_tags
  freeform_tags  = var.freeform_tags
}
