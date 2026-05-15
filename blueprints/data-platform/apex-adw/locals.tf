# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name          = "data-platform-apex-adw"
  name_prefix             = "${var.org}-${var.environment}-${var.region_key}"
  adb_compartment_ocid    = try(data.oci_database_autonomous_database.this[0].compartment_id, null)
  target_compartment_ocid = coalesce(var.compartment_ocid, local.adb_compartment_ocid, var.tenancy_ocid)

  autonomous_database_private_endpoint_ip = coalesce(
    var.autonomous_database_private_endpoint_ip,
    try(data.oci_database_autonomous_database.this[0].private_endpoint_ip, null)
  )

  ords_backend_ip_addresses = distinct(compact(concat(
    tolist(var.ords_backend_ip_addresses),
    var.use_autonomous_database_private_endpoint_ip_as_backend ? [local.autonomous_database_private_endpoint_ip] : []
  )))

  load_balancer_display_name = coalesce(var.load_balancer_display_name, "${local.name_prefix}-lb")
  load_balancer_id           = var.create_load_balancer ? try(oci_load_balancer_load_balancer.this[0].id, null) : var.load_balancer_id
  backend_set_name           = coalesce(var.backend_set_name, "${local.name_prefix}-bset-ords")
  listener_name              = coalesce(var.listener_name, "${local.name_prefix}-lis-ords")

  direct_apex_url = coalesce(
    var.apex_url,
    try(data.oci_database_autonomous_database.this[0].connection_urls[0].apex_url, null)
  )

  direct_ords_url = coalesce(
    var.ords_url,
    try(data.oci_database_autonomous_database.this[0].connection_urls[0].ords_url, null)
  )

  private_apex_url = var.apex_fqdn != null ? "https://${var.apex_fqdn}${var.apex_path}" : null
  admin_secret_id  = var.admin_secret_id != null ? var.admin_secret_id : try(oci_vault_secret.apex_admin[0].id, null)

  common_freeform_tags = merge(var.freeform_tags, {
    ManagedBy = "Terraform"
    Blueprint = local.blueprint_name
  })
}
