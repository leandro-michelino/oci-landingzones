# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  module_name = "iam-groups"
  cis_level   = var.cis_level == null ? null : lower(var.cis_level)
  name_prefix = "${var.org}-${var.environment}-${var.region_key}"

  default_groups = {
    landing_zone_admins = {
      description = "Administrators for the landing zone baseline."
    }
    network_admins = {
      description = "Administrators for landing zone networking resources."
    }
    security_admins = {
      description = "Administrators for landing zone security resources."
    }
    governance_admins = {
      description = "Administrators for landing zone governance and operations resources."
    }
    workload_admins = {
      description = "Administrators for workload and operating entity resources."
    }
    auditors = {
      description = "Read-only auditors for landing zone resources."
    }
  }

  groups = {
    for key, group in merge(var.enable_default_groups ? local.default_groups : {}, var.groups) : key => {
      name        = coalesce(try(group.name, null), "${local.name_prefix}-grp-${replace(key, "_", "-")}")
      description = group.description
    }
  }
}
