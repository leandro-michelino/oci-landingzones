# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  external_resource_ids = merge(
    { for key, vcn_id in var.vcn_ids : "vcn_${key}" => vcn_id },
    { for key, subnet_id in var.subnet_ids : "subnet_${key}" => subnet_id },
    { for key, target_id in var.route_target_ids : "route_target_${key}" => target_id },
    var.drg_id == null ? {} : { drg = var.drg_id }
  )
}
