# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
resource "oci_identity_domain" "this" {
  for_each = local.identity_domains

  compartment_id            = coalesce(each.value.compartment_ocid, local.target_compartment_ocid)
  display_name              = coalesce(each.value.display_name, "${local.name_prefix}-id-domain-${each.key}")
  description               = each.value.description
  home_region               = coalesce(each.value.home_region, var.home_region, var.region)
  license_type              = each.value.license_type
  admin_email               = each.value.admin_email
  admin_first_name          = each.value.admin_first_name
  admin_last_name           = each.value.admin_last_name
  admin_user_name           = each.value.admin_user_name
  is_hidden_on_login        = each.value.is_hidden_on_login
  is_notification_bypassed  = each.value.is_notification_bypassed
  is_primary_email_required = each.value.is_primary_email_required
  defined_tags              = var.defined_tags
  freeform_tags             = local.common_freeform_tags
}

resource "oci_identity_domain_replication_to_region" "replicas" {
  for_each = local.identity_domain_replicas

  domain_id      = oci_identity_domain.this[each.value.domain_key].id
  replica_region = each.value.region
}
