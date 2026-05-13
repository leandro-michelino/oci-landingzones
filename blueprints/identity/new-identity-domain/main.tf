# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
resource "oci_identity_domain" "this" {
  count = var.enable_identity_domain ? 1 : 0

  compartment_id            = local.target_compartment_ocid
  display_name              = local.domain_display_name
  description               = var.domain_description
  home_region               = coalesce(var.home_region, var.region)
  license_type              = var.license_type
  admin_email               = var.admin_email
  admin_first_name          = var.admin_first_name
  admin_last_name           = var.admin_last_name
  admin_user_name           = var.admin_user_name
  is_hidden_on_login        = var.is_hidden_on_login
  is_notification_bypassed  = var.is_notification_bypassed
  is_primary_email_required = var.is_primary_email_required
  defined_tags              = var.defined_tags
  freeform_tags             = local.common_freeform_tags
}

resource "oci_identity_domain_replication_to_region" "replicas" {
  for_each = var.enable_identity_domain ? toset(var.replica_regions) : toset([])

  domain_id      = oci_identity_domain.this[0].id
  replica_region = each.value
}
