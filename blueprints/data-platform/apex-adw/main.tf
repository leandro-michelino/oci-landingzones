# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
data "oci_database_autonomous_database" "this" {
  count = var.autonomous_database_id == null ? 0 : 1

  autonomous_database_id = var.autonomous_database_id
}

resource "oci_load_balancer_load_balancer" "this" {
  count = var.enable_load_balancer && var.create_load_balancer ? 1 : 0

  compartment_id               = local.target_compartment_ocid
  display_name                 = local.load_balancer_display_name
  shape                        = var.load_balancer_shape
  subnet_ids                   = var.load_balancer_subnet_ids
  is_private                   = var.is_private_load_balancer
  network_security_group_ids   = var.load_balancer_network_security_group_ids
  ip_mode                      = var.load_balancer_ip_mode
  is_delete_protection_enabled = var.is_delete_protection_enabled
  is_request_id_enabled        = var.is_request_id_enabled
  request_id_header            = var.request_id_header
  defined_tags                 = var.defined_tags
  freeform_tags                = local.common_freeform_tags

  dynamic "shape_details" {
    for_each = lower(var.load_balancer_shape) == "flexible" ? [1] : []

    content {
      minimum_bandwidth_in_mbps = var.minimum_bandwidth_in_mbps
      maximum_bandwidth_in_mbps = var.maximum_bandwidth_in_mbps
    }
  }
}

resource "oci_load_balancer_backend_set" "ords" {
  count = var.enable_load_balancer && (var.create_load_balancer || var.load_balancer_id != null) ? 1 : 0

  load_balancer_id = local.load_balancer_id
  name             = local.backend_set_name
  policy           = var.backend_set_policy

  health_checker {
    protocol            = var.health_checker_protocol
    url_path            = var.health_checker_url_path
    port                = var.health_checker_port
    return_code         = var.health_checker_return_code
    retries             = var.health_checker_retries
    timeout_in_millis   = var.health_checker_timeout_in_millis
    interval_ms         = var.health_checker_interval_ms
    is_force_plain_text = var.health_checker_force_plain_text
  }

  dynamic "ssl_configuration" {
    for_each = var.enable_backend_ssl ? [1] : []

    content {
      certificate_ids                   = var.backend_certificate_ids
      certificate_name                  = var.backend_certificate_name
      trusted_certificate_authority_ids = var.backend_trusted_certificate_authority_ids
      verify_peer_certificate           = var.backend_verify_peer_certificate
      verify_depth                      = var.backend_verify_depth
      protocols                         = var.backend_ssl_protocols
      cipher_suite_name                 = var.backend_ssl_cipher_suite_name
      server_order_preference           = var.backend_ssl_server_order_preference
    }
  }
}

resource "oci_load_balancer_backend" "ords" {
  for_each = var.enable_load_balancer && (var.create_load_balancer || var.load_balancer_id != null) ? {
    for ip_address in local.ords_backend_ip_addresses : ip_address => ip_address
  } : {}

  load_balancer_id = local.load_balancer_id
  backendset_name  = oci_load_balancer_backend_set.ords[0].name
  ip_address       = each.value
  port             = var.ords_backend_port
  weight           = var.backend_weight
  backup           = var.backend_backup
  drain            = var.backend_drain
  offline          = var.backend_offline
  max_connections  = var.backend_max_connections
}

resource "oci_load_balancer_listener" "https" {
  count = var.enable_load_balancer && var.enable_listener && (var.create_load_balancer || var.load_balancer_id != null) ? 1 : 0

  load_balancer_id         = local.load_balancer_id
  name                     = local.listener_name
  default_backend_set_name = oci_load_balancer_backend_set.ords[0].name
  port                     = var.listener_port
  protocol                 = upper(var.listener_protocol)
  hostname_names           = var.listener_hostname_names
  rule_set_names           = var.listener_rule_set_names

  dynamic "ssl_configuration" {
    for_each = upper(var.listener_protocol) == "HTTPS" ? [1] : []

    content {
      certificate_ids                   = var.listener_certificate_ids
      certificate_name                  = var.listener_certificate_name
      trusted_certificate_authority_ids = var.listener_trusted_certificate_authority_ids
      verify_peer_certificate           = var.listener_verify_peer_certificate
      verify_depth                      = var.listener_verify_depth
      protocols                         = var.listener_ssl_protocols
      cipher_suite_name                 = var.listener_ssl_cipher_suite_name
      server_order_preference           = var.listener_ssl_server_order_preference
    }
  }
}

resource "oci_vault_secret" "apex_admin" {
  count = var.enable_admin_secret && var.vault_id != null && var.key_id != null && var.admin_secret_content_base64 != null ? 1 : 0

  compartment_id = local.target_compartment_ocid
  vault_id       = var.vault_id
  key_id         = var.key_id
  secret_name    = coalesce(var.admin_secret_name, "${local.name_prefix}-sec-admin")
  description    = "APEX workspace bootstrap and admin material for ${local.name_prefix}."
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags

  secret_content {
    content_type = "BASE64"
    content      = var.admin_secret_content_base64
    name         = var.admin_secret_content_name
    stage        = "CURRENT"
  }

  dynamic "secret_rules" {
    for_each = var.admin_secret_version_expiry_interval == null ? [] : [var.admin_secret_version_expiry_interval]

    content {
      rule_type                      = "SECRET_EXPIRY_RULE"
      secret_version_expiry_interval = secret_rules.value
    }
  }
}
