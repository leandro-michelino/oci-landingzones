# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name = "zero-trust"
  name_prefix    = "${var.org}-${var.environment}-${var.region_key}"

  common_freeform_tags = merge(
    var.freeform_tags,
    {
      Blueprint = local.blueprint_name
      Pattern   = "ZeroTrust"
    }
  )
}
