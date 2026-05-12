# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
resource "oci_core_cpe" "this" {
  count = var.enable_ipsec ? 1 : 0

  compartment_id = var.compartment_ocid
  display_name   = coalesce(var.cpe_display_name, "${local.name_prefix}-cpe-${local.vpn_label}")
  ip_address     = var.cpe_ip_address
  is_private     = var.cpe_is_private
  defined_tags   = var.defined_tags
  freeform_tags  = var.freeform_tags
}

resource "oci_core_ipsec" "this" {
  count = var.enable_ipsec ? 1 : 0

  compartment_id = var.compartment_ocid
  cpe_id         = oci_core_cpe.this[0].id
  display_name   = coalesce(var.ipsec_display_name, "${local.name_prefix}-vpn-${local.vpn_label}")
  drg_id         = var.drg_id
  static_routes  = var.static_routes
  defined_tags   = var.defined_tags
  freeform_tags  = var.freeform_tags
}
