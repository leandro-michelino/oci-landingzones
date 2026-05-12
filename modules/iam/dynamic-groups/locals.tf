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
