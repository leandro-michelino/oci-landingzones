# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
resource "oci_network_load_balancer_network_load_balancer" "this" {
  count = var.create_network_load_balancer ? 1 : 0

  compartment_id                 = local.target_compartment_ocid
  display_name                   = local.nlb_display_name
  subnet_id                      = var.subnet_id
  is_private                     = var.is_private
  is_preserve_source_destination = var.is_preserve_source_destination
  is_symmetric_hash_enabled      = var.is_symmetric_hash_enabled
  network_security_group_ids     = var.network_security_group_ids
  assigned_private_ipv4          = var.assigned_private_ipv4
  assigned_ipv6                  = var.assigned_ipv6
  nlb_ip_version                 = var.nlb_ip_version
  defined_tags                   = var.defined_tags
  freeform_tags                  = local.common_freeform_tags
}

resource "oci_network_load_balancer_backend_set" "this" {
  for_each = var.backend_sets

  network_load_balancer_id = local.network_load_balancer_id
  name                     = coalesce(each.value.name, "${local.name_prefix}-${each.key}")
  policy                   = each.value.policy
  is_preserve_source       = each.value.is_preserve_source
  is_fail_open             = each.value.is_fail_open
  ip_version               = each.value.ip_version

  health_checker {
    protocol            = each.value.health_checker.protocol
    port                = each.value.health_checker.port
    url_path            = each.value.health_checker.url_path
    return_code         = each.value.health_checker.return_code
    retries             = each.value.health_checker.retries
    interval_in_millis  = each.value.health_checker.interval_in_millis
    timeout_in_millis   = each.value.health_checker.timeout_in_millis
    request_data        = each.value.health_checker.request_data
    response_data       = each.value.health_checker.response_data
    response_body_regex = each.value.health_checker.response_body_regex
  }
}

resource "oci_network_load_balancer_backend" "this" {
  for_each = local.backend_matrix

  network_load_balancer_id = local.network_load_balancer_id
  backend_set_name         = each.value.backend_set_name
  name                     = each.value.name
  ip_address               = each.value.ip_address
  target_id                = each.value.target_id
  port                     = each.value.port
  weight                   = each.value.weight
  is_backup                = each.value.is_backup
  is_drain                 = each.value.is_drain
  is_offline               = each.value.is_offline

  depends_on = [oci_network_load_balancer_backend_set.this]
}

resource "oci_network_load_balancer_listener" "this" {
  for_each = var.listeners

  network_load_balancer_id = local.network_load_balancer_id
  name                     = coalesce(each.value.name, "${local.name_prefix}-${each.key}")
  default_backend_set_name = coalesce(each.value.default_backend_set_name, try(oci_network_load_balancer_backend_set.this[each.value.backend_set_key].name, null))
  port                     = each.value.port
  protocol                 = each.value.protocol
  ip_version               = each.value.ip_version
  is_ppv2enabled           = each.value.is_ppv2enabled
  tcp_idle_timeout         = each.value.tcp_idle_timeout
  udp_idle_timeout         = each.value.udp_idle_timeout
  l3ip_idle_timeout        = each.value.l3ip_idle_timeout
}

resource "oci_identity_policy" "access" {
  count = length(var.policy_statements) > 0 ? 1 : 0

  provider       = oci.home
  compartment_id = local.policy_compartment_ocid
  name           = "${local.name_prefix}-access"
  description    = "Network Load Balancer access policy for ${local.name_prefix}."
  statements     = var.policy_statements
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}
