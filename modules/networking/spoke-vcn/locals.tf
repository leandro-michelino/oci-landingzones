# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  module_name = "networking-spoke-vcn"
  cis_level   = var.cis_level == null ? null : lower(var.cis_level)
  name_prefix = "${var.org}-${var.environment}-${var.region_key}"
  vcn_name    = coalesce(var.vcn_display_name, "${local.name_prefix}-vcn-${var.vcn_label}")

  region_key_map = {
    eu-frankfurt-1    = "fra"
    uk-london-1       = "lhr"
    af-johannesburg-1 = "jnb"
    sa-saopaulo-1     = "gru"
    eu-amsterdam-1    = "ams"
    us-ashburn-1      = "iad"
    us-phoenix-1      = "phx"
    me-dubai-1        = "dxb"
    ap-sydney-1       = "syd"
    ap-tokyo-1        = "nrt"
    eu-madrid-1       = "mad"
    me-abudhabi-1     = "auh"
  }

  route_entity_ids = merge(
    {
      igw = try(oci_core_internet_gateway.this[0].id, null)
      nat = try(oci_core_nat_gateway.this[0].id, null)
      sgw = try(oci_core_service_gateway.this[0].id, null)
      drg = var.drg_id
    },
    var.route_entity_ids
  )

  route_destinations = {
    all-services = try(data.oci_core_services.all_services.services[0].cidr_block, null)
  }

  security_list_ids = merge(
    { default = oci_core_vcn.this.default_security_list_id },
    { for key, security_list in oci_core_security_list.this : key => security_list.id },
    var.security_list_ids
  )
}
