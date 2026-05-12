# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  module_name = "iam-compartments"
  cis_level   = var.cis_level == null ? null : lower(var.cis_level)
  name_prefix = "${var.org}-${var.environment}-${var.region_key}"
  root_name   = coalesce(var.root_compartment_name, "${local.name_prefix}-cmp-root")

  child_compartments = {
    for key, compartment in var.child_compartments : key => {
      name          = "${local.name_prefix}-cmp-${key}"
      description   = compartment.description
      enable_delete = try(compartment.enable_delete, var.enable_delete)
    }
  }
}
