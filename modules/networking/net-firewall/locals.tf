# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  module_name = "networking-net-firewall"
  cis_level   = var.cis_level == null ? null : lower(var.cis_level)
  name_prefix = "${var.org}-${var.environment}-${var.region_key}"
  policy_id   = coalesce(var.network_firewall_policy_id, try(oci_network_firewall_network_firewall_policy.this[0].id, null))
}
