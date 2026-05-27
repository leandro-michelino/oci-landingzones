locals {
  blueprint_name = "networking-hub-spoke-with-hub-vcn-ipsec-vpn"
  name_prefix    = "${var.org}-${var.environment}-${var.region_key}"
}
