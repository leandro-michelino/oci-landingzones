# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
resource "oci_core_virtual_circuit" "this" {
  count = var.enable_fastconnect ? 1 : 0

  compartment_id            = var.compartment_ocid
  display_name              = "${local.name_prefix}-fc-${var.virtual_circuit_label}"
  type                      = upper(var.virtual_circuit_type)
  bandwidth_shape_name      = var.bandwidth_shape_name
  gateway_id                = upper(var.virtual_circuit_type) == "PRIVATE" ? var.drg_id : null
  customer_bgp_asn          = var.customer_bgp_asn
  provider_service_id       = var.provider_service_id
  provider_service_key_name = var.provider_service_key_name
  routing_policy            = upper(var.virtual_circuit_type) == "PRIVATE" ? var.routing_policy : null
  ip_mtu                    = var.ip_mtu
  defined_tags              = var.defined_tags
  freeform_tags = merge(
    var.freeform_tags,
    {
      Blueprint = local.module_name
    }
  )
}
