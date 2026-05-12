# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
resource "oci_core_drg" "this" {
  compartment_id = var.compartment_ocid
  display_name   = local.drg_name
  defined_tags   = var.defined_tags
  freeform_tags  = var.freeform_tags
}

resource "oci_core_drg_attachment" "vcn" {
  for_each = var.vcn_attachments

  drg_id       = oci_core_drg.this.id
  display_name = coalesce(each.value.display_name, "${local.name_prefix}-drga-${each.key}")
  defined_tags = var.defined_tags
  freeform_tags = merge(
    var.freeform_tags,
    try(each.value.freeform_tags, {})
  )

  network_details {
    id             = each.value.vcn_id
    route_table_id = try(each.value.vcn_route_table_id, null)
    type           = "VCN"
    vcn_route_type = try(each.value.vcn_route_type, null)
  }
}
