locals {
  blueprint_name = "industry-healthcare-platform"
  name_prefix    = "${var.org}-${var.environment}-${var.region_key}"
  tags           = merge(var.freeform_tags, { Blueprint = local.blueprint_name, ManagedBy = "terraform" })
  foundation     = var.enable_foundation && var.costs_approved
  key_ready      = var.kms_key_id != null && var.kms_policies_ready
  app            = local.foundation && var.enable_application && local.key_ready && length(var.application_instances) > 0 && var.tls_public_certificate != null && nonsensitive(var.tls_private_key != null) && length(var.backend_trusted_ca_ids) > 0 && var.boot_volume_backup_policy_id != null && var.drg_id != null && length(var.hospital_client_cidrs) > 0
  database       = local.foundation && var.enable_database && local.key_ready && nonsensitive(var.database_admin_password != null)
  documents      = local.foundation && var.enable_documents && local.key_ready
  namespaces     = toset(["ingress", "application", "database"])
  ranges = { for name, cidr in merge({ vcn = var.vcn_cidr }, var.subnet_cidrs) : name => {
    first = try(sum([for i, octet in split(".", cidrhost(cidr, 0)) : tonumber(octet) * pow(256, 3 - i)]), -1)
    last  = try(sum([for i, octet in split(".", cidrhost(cidr, -1)) : tonumber(octet) * pow(256, 3 - i)]), -1)
  } }
}
