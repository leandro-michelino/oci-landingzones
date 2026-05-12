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

  region_key_map = {
    eu-frankfurt-1    = "fra"
    uk-london-1       = "lhr"
    af-johannesburg-1 = "jnb"
    sa-saopaulo-1     = "gru"
    eu-amsterdam-1    = "ams"
    us-ashburn-1      = "iad"
    us-phoenix-1      = "phx"
    me-dubai-1        = "dxb"
    ap-sydney-1       = "syd"
    ap-tokyo-1        = "nrt"
  }
}
