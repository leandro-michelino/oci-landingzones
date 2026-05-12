# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  module_name = "networking-drg"
  cis_level   = var.cis_level == null ? null : lower(var.cis_level)
  name_prefix = "${var.org}-${var.environment}-${var.region_key}"
  drg_name    = coalesce(var.drg_display_name, "${local.name_prefix}-drg-${var.drg_label}")
}
