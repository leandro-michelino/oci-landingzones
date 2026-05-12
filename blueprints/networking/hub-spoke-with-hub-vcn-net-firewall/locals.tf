# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name = "networking-hub-spoke-with-hub-vcn-net-firewall"
  name_prefix    = "${var.org}-${var.environment}-${var.region_key}"
}
