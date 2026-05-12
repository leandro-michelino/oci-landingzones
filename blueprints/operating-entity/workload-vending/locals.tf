# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name = "workload-vending"
  name_prefix    = "${var.org}-${var.environment}-${var.region_key}"
}
