# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
resource "oci_redis_redis_cluster" "this" {
  count = var.create_cluster ? 1 : 0

  compartment_id          = local.target_compartment_ocid
  display_name            = local.cluster_display_name
  software_version        = var.software_version
  subnet_id               = var.subnet_id
  nsg_ids                 = var.nsg_ids
  node_count              = var.node_count
  node_memory_in_gbs      = var.node_memory_in_gbs
  shard_count             = var.shard_count
  cluster_mode            = var.cluster_mode
  oci_cache_config_set_id = var.oci_cache_config_set_id
  backup_id               = var.backup_id
  defined_tags            = var.defined_tags
  freeform_tags           = local.common_freeform_tags
}

resource "oci_monitoring_alarm" "this" {
  for_each = var.alarms

  compartment_id        = local.target_compartment_ocid
  display_name          = coalesce(each.value.display_name, "${local.name_prefix}-alm-${each.key}")
  namespace             = each.value.namespace
  query                 = each.value.query
  severity              = each.value.severity
  destinations          = each.value.destinations
  metric_compartment_id = coalesce(each.value.metric_compartment_id, local.target_compartment_ocid)
  body                  = each.value.body
  is_enabled            = each.value.is_enabled
  defined_tags          = var.defined_tags
  freeform_tags         = local.common_freeform_tags
}

resource "oci_identity_policy" "access" {
  count = length(var.policy_statements) > 0 ? 1 : 0

  provider       = oci.home
  compartment_id = local.policy_compartment_ocid
  name           = "${local.name_prefix}-pol-access"
  description    = "Redis Cache access policy for ${local.name_prefix}."
  statements     = var.policy_statements
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}
