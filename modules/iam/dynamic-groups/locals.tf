# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  module_name = "iam-dynamic-groups"
  cis_level   = var.cis_level == null ? null : lower(var.cis_level)
  name_prefix = "${var.org}-${var.environment}-${var.region_key}"

  dynamic_groups = {
    for key, dynamic_group in var.dynamic_groups : key => {
      name          = coalesce(try(dynamic_group.name, null), "${local.name_prefix}-dgrp-${replace(key, "_", "-")}")
      description   = dynamic_group.description
      matching_rule = dynamic_group.matching_rule
    }
  }
}
